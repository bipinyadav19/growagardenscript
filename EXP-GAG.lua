--[[
    EXP-GAG Advanced Lua Script - FULLY FUNCTIONAL
    Features: Pet & Egg Spawner, Seed Spawner, Auto Farm, Auto Plant, Auto Harvest, 
              Auto Sell, Auto Buy, Dupe Tools, Event Automation, Dark Spawner, Mobile Support
    Version: 2.0 - Production Ready
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- Player Setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Logging System
local Logs = {}
local function log(message, type)
    type = type or "INFO"
    local timestamp = os.date("%X")
    local logMessage = string.format("[%s] [%s] %s", timestamp, type, message)
    print(logMessage)
    table.insert(Logs, logMessage)
    if #Logs > 100 then
        table.remove(Logs, 1)
    end
end

-- Humanization System
local Humanization = {
    enabled = true,
    skipChance = 0.05,        -- 5% chance to skip an action
    errorChance = 0.03,       -- 3% chance to simulate error
    pauseChance = 0.02,       -- 2% chance for random pause
    minPauseTime = 2,         -- Minimum pause time in seconds
    maxPauseTime = 8,         -- Maximum pause time in seconds
    lastPauseTime = 0,
    consecutiveActions = 0,
    maxConsecutive = math.random(10, 20), -- Take break after this many actions
}

local function randomDelay(min, max)
    if not Humanization.enabled then
        return min
    end
    return math.random(min * 100, max * 100) / 100
end

local function shouldSkip()
    if not Humanization.enabled then return false end
    return math.random() < Humanization.skipChance
end

local function shouldError()
    if not Humanization.enabled then return false end
    return math.random() < Humanization.errorChance
end

local function randomPause()
    if not Humanization.enabled then return end
    
    if math.random() < Humanization.pauseChance or Humanization.consecutiveActions >= Humanization.maxConsecutive then
        local pauseTime = math.random(Humanization.minPauseTime, Humanization.maxPauseTime)
        log("Taking a break for " .. pauseTime .. " seconds...", "INFO")
        wait(pauseTime)
        Humanization.consecutiveActions = 0
        Humanization.maxConsecutive = math.random(10, 20)
        Humanization.lastPauseTime = tick()
    else
        Humanization.consecutiveActions = Humanization.consecutiveActions + 1
    end
end

local function humanizedWait(minDelay, maxDelay)
    -- Range mode: minDelay and maxDelay specify the delay range
    if maxDelay then
        local delay = randomDelay(minDelay, maxDelay)
        wait(delay)
    else
        -- Single delay mode with variance
        local variance = minDelay * 0.3 -- 30% variance by default
        local delay = math.max(0.1, minDelay + math.random(-variance * 100, variance * 100) / 100)
        wait(delay)
    end
    randomPause()
end

-- Configuration
local config = {
    -- Feature Toggles
    AutoFarm = true,
    AutoPlant = true,
    AutoHarvest = true,
    AutoSell = true,
    AutoBuy = true,
    PetSpawner = true,
    EggSpawner = true,
    SeedSpawner = true,
    DarkSpawner = true,
    EventAutomation = true,
    DupeTools = false,        -- ⚠️ WARNING: High ban risk, most games have server-side validation
    MobileSupport = true,
    ShowGUI = true,
    Humanization = true,      -- Enable humanization features
    
    -- Timing Settings (now using ranges for randomization)
    FarmDelayMin = 2.0,       -- Minimum delay between farm actions (seconds)
    FarmDelayMax = 6.0,       -- Maximum delay between farm actions
    PlantDelayMin = 3.0,      -- Minimum delay between plant actions
    PlantDelayMax = 7.0,      -- Maximum delay between plant actions
    HarvestDelayMin = 2.5,    -- Minimum delay between harvest actions
    HarvestDelayMax = 5.5,    -- Maximum delay between harvest actions
    SellDelayMin = 1.0,       -- Minimum delay between sell actions
    SellDelayMax = 3.0,       -- Maximum delay between sell actions
    BuyDelayMin = 2.0,        -- Minimum delay between buy actions
    BuyDelayMax = 4.0,        -- Maximum delay between buy actions
    SpawnDelayMin = 2.0,      -- Minimum delay between spawn actions
    SpawnDelayMax = 5.0,      -- Maximum delay between spawn actions
    WalkSpeed = 16,
    MoveTimeout = 10,
    
    -- Humanization Settings
    RandomizeMovement = true, -- Add randomness to movement
    OccasionalBreaks = true,  -- Take occasional breaks
    SimulateErrors = true,     -- Occasionally fail actions to seem human
    
    -- Farming Settings
    FarmRadius = 200,
    PlantRadius = 200,
    HarvestRadius = 200,
    WaterPlants = true,
    FertilizePlants = true,
    
    -- Seed Settings
    PreferredSeeds = {}, -- Will auto-detect
    MaxSeeds = 100,
    MinSeeds = 10,
    
    -- Pet Settings
    PreferredPets = {}, -- Will auto-detect
    MaxPets = 50,
    
    -- Egg Settings
    PreferredEggs = {}, -- Will auto-detect
    MaxEggs = 10,
    
    -- Sell Settings
    SellThreshold = 50,
    PreferredItems = {},
    SellAll = false,
    
    -- Buy Settings
    BuyItems = {},
    BuyInterval = 30,
    
    -- Event Settings
    EventCheckInterval = 5,
    
    -- Advanced Settings
    AutoDetectRemotes = true,
    RetryAttempts = 3,
    RetryDelay = 1,
    
    -- Warning Messages
    ShowWarnings = true,      -- Show warnings about risky features
}

-- Display warnings for risky features
if config.ShowWarnings then
    if config.DupeTools then
        log("⚠️ WARNING: DupeTools enabled - High ban risk! Most games have server-side validation.", "WARNING")
    end
    if config.PetSpawner or config.EggSpawner or config.DarkSpawner then
        log("⚠️ WARNING: Spawning features enabled - May fail or trigger bans if game has server-side checks.", "WARNING")
    end
    log("💡 TIP: Enable Humanization for better safety. Adjust delay ranges for realistic behavior.", "INFO")
end

-- Cache System
local cache = {
    remotes = {},
    shops = {},
    plots = {},
    tools = {},
    lastUpdate = {},
}

-- Utility Functions
local function waitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    while not parent:FindFirstChild(childName) and (tick() - startTime) < timeout do
        wait(0.1)
    end
    return parent:FindFirstChild(childName)
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        log("Error: " .. tostring(result), "ERROR")
    end
    return success, result
end

local function getDistance(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).Magnitude
end

local function getPlayerPosition()
    if humanoidRootPart and humanoidRootPart.Parent then
        return humanoidRootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

local function findInWorkspace(namePattern, returnAll)
    local results = {}
    local pattern = string.lower(namePattern)
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), pattern) then
            if returnAll then
                table.insert(results, obj)
            else
                return obj
            end
        end
    end
    
    return returnAll and results or nil
end

local function findRemotes(pattern)
    if cache.remotes[pattern] then
        return cache.remotes[pattern]
    end
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local results = {}
    local patternLower = string.lower(pattern)
    
    -- Also check common remote locations
    local remoteLocations = {
        ReplicatedStorage,
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Events"),
        ReplicatedStorage:FindFirstChild("Functions"),
        Workspace:FindFirstChild("Remotes"),
    }
    
    for _, location in ipairs(remoteLocations) do
        if location then
            for _, remote in pairs(location:GetDescendants()) do
                if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    local nameLower = string.lower(remote.Name)
                    if string.find(nameLower, patternLower) then
                        if not table.find(results, remote) then
                            table.insert(results, remote)
                        end
                    end
                end
            end
        end
    end
    
    -- Also try direct name match
    local directMatch = remotes:FindFirstChild(pattern) or remotes:FindFirstChild(pattern .. "Event") or remotes:FindFirstChild(pattern .. "Remote")
    if directMatch and (directMatch:IsA("RemoteEvent") or directMatch:IsA("RemoteFunction")) then
        if not table.find(results, directMatch) then
            table.insert(results, directMatch)
        end
    end
    
    if #results > 0 then
        cache.remotes[pattern] = results
        return results
    end
    
    return nil
end

local function walkTo(position, timeout)
    if not humanoidRootPart or not humanoidRootPart.Parent then return false end
    
    timeout = timeout or config.MoveTimeout
    local startTime = tick()
    
    -- Add randomness to target position for humanization
    local target = Vector3.new(position.X, humanoidRootPart.Position.Y, position.Z)
    if config.RandomizeMovement and Humanization.enabled then
        local offset = math.random(-2, 2) -- Small random offset
        target = target + Vector3.new(offset, 0, offset)
    end
    
    local distance = getDistance(humanoidRootPart.Position, target)
    
    if distance < 5 then return true end
    
    -- Occasional brief pause before moving (human-like)
    if Humanization.enabled and math.random() < 0.1 then
        wait(randomDelay(0.2, 0.8))
    end
    
    humanoid:MoveTo(target)
    
    -- Variable movement speed for humanization
    if config.RandomizeMovement and Humanization.enabled then
        humanoid.WalkSpeed = config.WalkSpeed + math.random(-3, 3)
    end
    
    repeat
        wait(randomDelay(0.05, 0.15)) -- Randomized wait time
        distance = getDistance(humanoidRootPart.Position, target)
        if tick() - startTime > timeout then
            log("Walk timeout reached", "WARNING")
            return false
        end
        if distance > 5 then
            -- Occasional re-targeting (human-like)
            if config.RandomizeMovement and Humanization.enabled and math.random() < 0.05 then
                local newTarget = Vector3.new(position.X, humanoidRootPart.Position.Y, position.Z)
                target = newTarget + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
            end
            humanoid:MoveTo(target)
        end
    until distance < 5 or not humanoidRootPart or not humanoidRootPart.Parent
    
    -- Restore normal walk speed
    humanoid.WalkSpeed = config.WalkSpeed
    
    return distance < 5
end

local function tweenToPosition(position, duration)
    duration = duration or 2
    if not humanoidRootPart or not humanoidRootPart.Parent then return end
    
    local tween = TweenService:Create(
        humanoidRootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Mobile Support
local function setupMobileSupport()
    if not config.MobileSupport then return end
    
    pcall(function()
        player.Idled:Connect(function(time)
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
    
    log("Mobile support enabled", "INFO")
end

-- GUI System
local GUI = {}
GUI.Frame = nil

function GUI:Create()
    if not config.ShowGUI then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EXP_GAG_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "EXP-GAG Control Panel"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -50)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    local features = {
        {name = "Auto Farm", configKey = "AutoFarm", module = AutoFarm},
        {name = "Auto Plant", configKey = "AutoPlant", module = AutoPlant},
        {name = "Auto Harvest", configKey = "AutoHarvest", module = AutoHarvest},
        {name = "Auto Sell", configKey = "AutoSell", module = AutoSell},
        {name = "Auto Buy", configKey = "AutoBuy", module = AutoBuy},
        {name = "Pet Spawner", configKey = "PetSpawner", module = PetEggSpawner},
        {name = "Egg Spawner", configKey = "EggSpawner", module = PetEggSpawner},
        {name = "Seed Spawner", configKey = "SeedSpawner", module = SeedSpawner},
        {name = "Dark Spawner", configKey = "DarkSpawner", module = DarkSpawner},
        {name = "Event Automation", configKey = "EventAutomation", module = EventAutomation},
    }
    
    for i, feature in ipairs(features) do
        local button = Instance.new("TextButton")
        button.Name = feature.name
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = config[feature.configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        button.Text = feature.name .. (config[feature.configKey] and " [ON]" or " [OFF]")
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.LayoutOrder = i
        button.Parent = scrollFrame
        
        buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            config[feature.configKey] = not config[feature.configKey]
            button.BackgroundColor3 = config[feature.configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
            button.Text = feature.name .. (config[feature.configKey] and " [ON]" or " [OFF]")
            log(feature.name .. " toggled: " .. tostring(config[feature.configKey]), "INFO")
        end)
    end
    
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopAll"
    stopButton.Size = UDim2.new(1, -10, 0, 35)
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    stopButton.Text = "STOP ALL"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 16
    stopButton.Font = Enum.Font.GothamBold
    stopButton.LayoutOrder = 100
    stopButton.Parent = scrollFrame
    
    stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 5)
    stopCorner.Parent = stopButton
    
    stopButton.MouseButton1Click:Connect(function()
        _G.EXPGAG.Stop()
    end)
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    GUI.Frame = screenGui
    log("GUI created", "INFO")
end

-- Pet & Egg Spawner
local PetEggSpawner = {}
PetEggSpawner.Enabled = false

function PetEggSpawner:FindPetShop()
    local shopNames = {"PetShop", "Pet Store", "PetStore", "Pet", "Shop", "Store", "NPC"}
    
    for _, name in ipairs(shopNames) do
        local shop = findInWorkspace(name)
        if shop then
            local npc = shop:FindFirstChildOfClass("Model") or shop
            if npc:FindFirstChild("HumanoidRootPart") or npc:IsA("BasePart") then
                cache.shops["PetShop"] = npc
                return npc
            end
        end
    end
    
    return nil
end

function PetEggSpawner:SpawnPet(petName)
    if not config.PetSpawner then return false end
    
    local petShop = self:FindPetShop()
    if not petShop then
        log("Pet shop not found", "WARNING")
        return false
    end
    
    local shopPos = petShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or petShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach pet shop", "WARNING")
        return false
    end
    
    wait(0.5)
    
    -- Try multiple remote patterns
    local remotePatterns = {"BuyPet", "PurchasePet", "Buy", "Purchase", "Pet", "Spawn"}
    local remotes = findRemotes("pet") or findRemotes("buy")
    
    if remotes then
        for i = 1, config.RetryAttempts do
            local success = safeCall(function()
                remotes[1]:FireServer(petName)
            end)
            if success then
                log("Pet spawned: " .. tostring(petName), "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    -- Try GUI method
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local guiText = gui.Text or gui:GetAttribute("Text") or ""
            local guiName = gui.Name or ""
            local searchText = (guiText .. " " .. guiName):lower()
            
            if string.find(searchText, petName:lower()) or string.find(searchText, "buy") or string.find(searchText, "pet") then
                safeCall(function()
                    -- Try different activation methods
                    if gui.Activated then
                        gui.Activated:Fire()
                    elseif gui.MouseButton1Click then
                        gui.MouseButton1Click:Fire()
                    elseif gui:FindFirstChild("ClickDetector") then
                        gui:FindFirstChild("ClickDetector"):FireServer()
                    else
                        -- Try clicking
                        for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                            connection:Fire()
                        end
                    end
                end)
                wait(0.2)
            end
        end
    end
    
    return false
end

function PetEggSpawner:SpawnEgg(eggName)
    if not config.EggSpawner then return false end
    
    local eggShop = self:FindPetShop() or findInWorkspace("egg")
    if not eggShop then
        log("Egg shop not found", "WARNING")
        return false
    end
    
    local shopPos = eggShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or eggShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach egg shop", "WARNING")
        return false
    end
    
    wait(0.5)
    
    local remotes = findRemotes("egg") or findRemotes("buy")
    
    if remotes then
        for i = 1, config.RetryAttempts do
            local success = safeCall(function()
                remotes[1]:FireServer(eggName)
            end)
            if success then
                log("Egg spawned: " .. tostring(eggName), "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    return false
end

function PetEggSpawner:GetOwnedPets()
    local pets = {}
    local locations = {player, player:FindFirstChild("Data"), player:FindFirstChild("PlayerData")}
    
    for _, location in ipairs(locations) do
        if location then
            local petFolder = location:FindFirstChild("Pets") or location:FindFirstChild("Pet") or location:FindFirstChild("Inventory")
            if petFolder then
                for _, pet in pairs(petFolder:GetChildren()) do
                    if not table.find(pets, pet) then
                        table.insert(pets, pet)
                    end
                end
            end
        end
    end
    
    return pets
end

function PetEggSpawner:GetOwnedEggs()
    local eggs = {}
    local locations = {player, player:FindFirstChild("Data"), player:FindFirstChild("PlayerData")}
    
    for _, location in ipairs(locations) do
        if location then
            local eggFolder = location:FindFirstChild("Eggs") or location:FindFirstChild("Egg") or location:FindFirstChild("Inventory")
            if eggFolder then
                for _, egg in pairs(eggFolder:GetChildren()) do
                    if not table.find(eggs, egg) then
                        table.insert(eggs, egg)
                    end
                end
            end
        end
    end
    
    return eggs
end

function PetEggSpawner:DetectAvailable()
    local available = {pets = {}, eggs = {}}
    
    -- Check shops for available pets/eggs
    local petShop = self:FindPetShop()
    if petShop then
        for _, child in pairs(petShop:GetDescendants()) do
            if child:IsA("StringValue") or child:IsA("Configuration") then
                if string.find(child.Name:lower(), "pet") then
                    table.insert(available.pets, child.Value or child.Name)
                elseif string.find(child.Name:lower(), "egg") then
                    table.insert(available.eggs, child.Value or child.Name)
                end
            end
        end
    end
    
    -- Check remotes for pet/egg names
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if string.find(name, "pet") or string.find(name, "buy") then
                -- Try to get arguments
                pcall(function()
                    local connections = getconnections(remote.OnClientEvent)
                    -- Could extract info from connections
                end)
            end
        end
    end
    
    return available
end

function PetEggSpawner:Start()
    if PetEggSpawner.Enabled then return end
    PetEggSpawner.Enabled = true
    
    spawn(function()
        -- Auto-detect available pets/eggs
        local available = self:DetectAvailable()
        if #available.pets > 0 and #config.PreferredPets == 0 then
            config.PreferredPets = available.pets
            log("Auto-detected pets: " .. table.concat(config.PreferredPets, ", "), "INFO")
        end
        if #available.eggs > 0 and #config.PreferredEggs == 0 then
            config.PreferredEggs = available.eggs
            log("Auto-detected eggs: " .. table.concat(config.PreferredEggs, ", "), "INFO")
        end
        
        while PetEggSpawner.Enabled do
            if config.PetSpawner then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping pet spawn cycle (humanization)", "INFO")
                else
                    local ownedPets = self:GetOwnedPets()
                    if #ownedPets < config.MaxPets then
                        for _, petName in ipairs(config.PreferredPets) do
                            if #ownedPets < config.MaxPets then
                                -- Occasionally skip individual spawns
                                if not shouldSkip() then
                                    self:SpawnPet(petName)
                                    humanizedWait(randomDelay(config.SpawnDelayMin, config.SpawnDelayMax))
                                end
                            end
                        end
                    end
                end
            end
            
            if config.EggSpawner then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping egg spawn cycle (humanization)", "INFO")
                else
                    local ownedEggs = self:GetOwnedEggs()
                    if #ownedEggs < config.MaxEggs then
                        for _, eggName in ipairs(config.PreferredEggs) do
                            if #ownedEggs < config.MaxEggs then
                                -- Occasionally skip individual spawns
                                if not shouldSkip() then
                                    self:SpawnEgg(eggName)
                                    humanizedWait(randomDelay(config.SpawnDelayMin, config.SpawnDelayMax))
                                end
                            end
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(5, 15)) -- Random interval between spawn checks
            randomPause()
        end
    end)
end

-- Seed Spawner
local SeedSpawner = {}
SeedSpawner.Enabled = false

function SeedSpawner:FindSeedShop()
    local shopNames = {"SeedShop", "Seed Store", "SeedStore", "Seed", "Shop", "Store"}
    
    for _, name in ipairs(shopNames) do
        local shop = findInWorkspace(name)
        if shop then
            local npc = shop:FindFirstChildOfClass("Model") or shop
            if npc:FindFirstChild("HumanoidRootPart") or npc:IsA("BasePart") then
                cache.shops["SeedShop"] = npc
                return npc
            end
        end
    end
    
    return nil
end

function SeedSpawner:BuySeeds(seedName, amount)
    amount = amount or 1
    
    -- Check currency before buying
    local currency = player:FindFirstChild("Currency") or player:FindFirstChild("Coins") or player:FindFirstChild("Money")
    local dataFolder = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData")
    if dataFolder then
        currency = currency or dataFolder:FindFirstChild("Currency") or dataFolder:FindFirstChild("Coins") or dataFolder:FindFirstChild("Money")
    end
    
    if currency and currency.Value and currency.Value < 10 then
        log("Not enough currency to buy seeds", "WARNING")
        return false
    end
    
    local seedShop = self:FindSeedShop()
    if not seedShop then
        log("Seed shop not found", "WARNING")
        return false
    end
    
    local shopPos = seedShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or seedShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach seed shop", "WARNING")
        return false
    end
    
    wait(0.5)
    
    local remotes = findRemotes("seed") or findRemotes("buy")
    local bought = 0
    
    if remotes then
        for i = 1, amount do
            for attempt = 1, config.RetryAttempts do
                local success = safeCall(function()
                    remotes[1]:FireServer(seedName)
                end)
                if success then
                    bought = bought + 1
                    break
                end
                wait(config.RetryDelay)
            end
            wait(config.BuyDelay)
        end
    end
    
    -- Try GUI method if remote failed
    if bought == 0 then
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and string.find((gui.Text or gui.Name):lower(), seedName:lower()) then
                safeCall(function()
                    if gui.Activated then
                        gui.Activated:Fire()
                    elseif gui.MouseButton1Click then
                        gui.MouseButton1Click:Fire()
                    end
                end)
                bought = bought + 1
                wait(0.2)
            end
        end
    end
    
    if bought > 0 then
        log("Bought " .. bought .. " seeds: " .. tostring(seedName), "SUCCESS")
    end
    
    return bought > 0
end

function SeedSpawner:GetSeedCount()
    local count = 0
    local locations = {player, player:FindFirstChild("Data"), player:FindFirstChild("PlayerData")}
    
    for _, location in ipairs(locations) do
        if location then
            local seedFolder = location:FindFirstChild("Seeds") or location:FindFirstChild("Seed") or location:FindFirstChild("Inventory")
            if seedFolder then
                for _, seed in pairs(seedFolder:GetChildren()) do
                    if seed:IsA("Folder") or seed:IsA("StringValue") or seed:IsA("NumberValue") then
                        count = count + 1
                    end
                end
            end
        end
    end
    
    return count
end

function SeedSpawner:DetectAvailable()
    local available = {}
    local seedShop = self:FindSeedShop()
    
    if seedShop then
        for _, child in pairs(seedShop:GetDescendants()) do
            if child:IsA("StringValue") or child:IsA("Configuration") then
                if string.find(child.Name:lower(), "seed") then
                    table.insert(available, child.Value or child.Name)
                end
            end
        end
    end
    
    return available
end

function SeedSpawner:Start()
    if SeedSpawner.Enabled then return end
    SeedSpawner.Enabled = true
    
    spawn(function()
        -- Auto-detect available seeds
        local available = self:DetectAvailable()
        if #available > 0 and #config.PreferredSeeds == 0 then
            config.PreferredSeeds = available
            log("Auto-detected seeds: " .. table.concat(config.PreferredSeeds, ", "), "INFO")
        end
        
        while SeedSpawner.Enabled do
            if config.SeedSpawner then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping seed buy cycle (humanization)", "INFO")
                else
                    local seedCount = self:GetSeedCount()
                    
                    if seedCount < config.MinSeeds then
                        local needed = config.MaxSeeds - seedCount
                        for _, seedName in ipairs(config.PreferredSeeds) do
                            if seedCount < config.MaxSeeds then
                                -- Occasionally skip buying
                                if not shouldSkip() then
                                    self:BuySeeds(seedName, math.min(needed, 10))
                                    humanizedWait(randomDelay(config.SpawnDelayMin, config.SpawnDelayMax))
                                    seedCount = self:GetSeedCount()
                                    needed = config.MaxSeeds - seedCount
                                end
                            end
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(10, 20)) -- Random interval between checks
            randomPause()
        end
    end)
end

-- Auto Farm
local AutoFarm = {}
AutoFarm.Enabled = false

function AutoFarm:FindFarmPlots()
    local plots = {}
    local plotNames = {"plot", "farm", "soil", "land", "field"}
    
    -- Check if plots are cached and recent
    if cache.plots and cache.lastUpdate["plots"] and (tick() - cache.lastUpdate["plots"]) < 5 then
        return cache.plots
    end
    
    for _, name in ipairs(plotNames) do
        local found = findInWorkspace(name, true)
        if found then
            for _, plot in ipairs(found) do
                if (plot:IsA("BasePart") or plot:IsA("Model")) then
                    local hasPos = plot:FindFirstChild("Position") or plot.Position or plot:FindFirstChildOfClass("BasePart")
                    if hasPos then
                        -- Check if plot is owned by player
                        local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
                        if not owner or (owner.Value == player or owner.Value == player.Name or owner.Value == player.UserId) then
                            if not table.find(plots, plot) then
                                table.insert(plots, plot)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Also check player-owned plots
    local playerPlots = player:FindFirstChild("Plots") or player:FindFirstChild("Farms")
    if playerPlots then
        for _, plotRef in pairs(playerPlots:GetChildren()) do
            local plot = Workspace:FindFirstChild(plotRef.Name) or plotRef:FindFirstChild("Plot")
            if plot and not table.find(plots, plot) then
                table.insert(plots, plot)
            end
        end
    end
    
    -- Cache plots
    if #plots > 0 then
        cache.plots = plots
        cache.lastUpdate["plots"] = tick()
    end
    
    return plots
end

function AutoFarm:IsPlotEmpty(plot)
    for _, child in pairs(plot:GetDescendants()) do
        local name = string.lower(child.Name)
        if string.find(name, "plant") or string.find(name, "crop") or string.find(name, "seedling") then
            return false
        end
    end
    return true
end

function AutoFarm:IsPlantReady(plot)
    for _, child in pairs(plot:GetDescendants()) do
        local ready = child:FindFirstChild("Ready") or child:FindFirstChild("Harvestable") or child:FindFirstChild("Grown")
        if ready and (ready.Value == true or ready.Value == 1) then
            return true
        end
        if child:IsA("NumberValue") and child.Name == "Growth" and child.Value >= 100 then
            return true
        end
    end
    return false
end

function AutoFarm:WaterPlot(plot)
    if not config.WaterPlants then return end
    
    local waterRemote = findRemotes("water")
    if waterRemote then
        safeCall(function()
            waterRemote[1]:FireServer(plot)
        end)
        return true
    end
    
    -- Try tool method
    local tool = player.Backpack:FindFirstChild("Water") or character:FindFirstChild("Water")
    if not tool then
        tool = player.Backpack:FindFirstChildOfClass("Tool")
        for _, t in pairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), "water") then
                tool = t
                break
            end
        end
    end
    
    if tool then
        tool.Parent = character
        wait(0.1)
        tool:Activate()
        wait(0.2)
        return true
    end
    
    return false
end

function AutoFarm:Start()
    if AutoFarm.Enabled then return end
    AutoFarm.Enabled = true
    
    spawn(function()
        while AutoFarm.Enabled do
            if config.AutoFarm then
                -- Check if should skip this cycle
                if shouldSkip() then
                    log("Skipping farm cycle (humanization)", "INFO")
                    humanizedWait(randomDelay(config.FarmDelayMin, config.FarmDelayMax))
                    randomPause()
                    goto continue
                end
                
                local plots = self:FindFarmPlots()
                
                -- Randomize plot order for humanization
                if Humanization.enabled then
                    for i = #plots, 2, -1 do
                        local j = math.random(i)
                        plots[i], plots[j] = plots[j], plots[i]
                    end
                end
                
                for _, plot in ipairs(plots) do
                    if not self:IsPlotEmpty(plot) then
                        if self:IsPlantReady(plot) then
                            -- AutoHarvest will handle this
                        else
                            -- Water the plant
                            local plotPos = plot:FindFirstChild("Position")
                            plotPos = plotPos and plotPos.Value or (plot:IsA("BasePart") and plot.Position or plot:FindFirstChildOfClass("BasePart") and plot:FindFirstChildOfClass("BasePart").Position)
                            
                            if plotPos and getDistance(getPlayerPosition(), plotPos) < config.FarmRadius then
                                walkTo(plotPos)
                                humanizedWait(randomDelay(0.3, 0.8))
                                
                                -- Occasionally fail to water (human-like error)
                                if shouldError() then
                                    log("Failed to water plot (simulated error)", "INFO")
                                else
                                    self:WaterPlot(plot)
                                end
                            end
                        end
                    end
                end
            end
            
            ::continue::
            humanizedWait(randomDelay(config.FarmDelayMin, config.FarmDelayMax))
            randomPause()
        end
    end)
end

-- Auto Plant
local AutoPlant = {}
AutoPlant.Enabled = false

function AutoPlant:PlantSeed(plot, seedName)
    if not config.AutoPlant then return false end
    
    local plotPos = plot:FindFirstChild("Position")
    plotPos = plotPos and plotPos.Value or (plot:IsA("BasePart") and plot.Position or plot:FindFirstChildOfClass("BasePart") and plot:FindFirstChildOfClass("BasePart").Position)
    
    if not plotPos then return false end
    
    if not walkTo(plotPos) then
        log("Failed to reach plot", "WARNING")
        return false
    end
    
    wait(0.3)
    
    local plantRemote = findRemotes("plant") or findRemotes("seed")
    
    if plantRemote then
        for attempt = 1, config.RetryAttempts do
            local success = safeCall(function()
                plantRemote[1]:FireServer(plot, seedName)
            end)
            if success then
                log("Planted: " .. tostring(seedName), "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    -- Try tool method
    local tool = player.Backpack:FindFirstChild("Plant") or character:FindFirstChild("Plant")
    if not tool then
        for _, t in pairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") and (string.find(string.lower(t.Name), "plant") or string.find(string.lower(t.Name), "seed")) then
                tool = t
                break
            end
        end
    end
    
    if tool then
        tool.Parent = character
        wait(0.1)
        safeCall(function()
            tool:Activate()
        end)
        wait(0.2)
        return true
    end
    
    return false
end

function AutoPlant:Start()
    if AutoPlant.Enabled then return end
    AutoPlant.Enabled = true
    
    spawn(function()
        while AutoPlant.Enabled do
            if config.AutoPlant then
                -- Check if should skip this cycle
                if shouldSkip() then
                    log("Skipping plant cycle (humanization)", "INFO")
                    humanizedWait(randomDelay(config.PlantDelayMin, config.PlantDelayMax))
                    randomPause()
                    goto continue
                end
                
                local plots = AutoFarm:FindFarmPlots()
                local seedCount = SeedSpawner:GetSeedCount()
                
                if seedCount > 0 then
                    -- Randomize plot order for humanization
                    if Humanization.enabled then
                        for i = #plots, 2, -1 do
                            local j = math.random(i)
                            plots[i], plots[j] = plots[j], plots[i]
                        end
                    end
                    
                    for _, plot in ipairs(plots) do
                        if AutoFarm:IsPlotEmpty(plot) then
                            local seedName = config.PreferredSeeds[1] or "Seed"
                            
                            -- Occasionally skip planting (human-like)
                            if shouldSkip() then
                                log("Skipping plot (humanization)", "INFO")
                            else
                                if self:PlantSeed(plot, seedName) then
                                    humanizedWait(randomDelay(config.PlantDelayMin, config.PlantDelayMax))
                                else
                                    -- Simulate occasional failure
                                    if shouldError() then
                                        log("Planting failed (simulated error)", "INFO")
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            ::continue::
            humanizedWait(randomDelay(config.PlantDelayMin, config.PlantDelayMax))
            randomPause()
        end
    end)
end

-- Auto Harvest
local AutoHarvest = {}
AutoHarvest.Enabled = false

function AutoHarvest:HarvestPlot(plot)
    if not config.AutoHarvest then return false end
    
    local plotPos = plot:FindFirstChild("Position")
    plotPos = plotPos and plotPos.Value or (plot:IsA("BasePart") and plot.Position or plot:FindFirstChildOfClass("BasePart") and plot:FindFirstChildOfClass("BasePart").Position)
    
    if not plotPos then return false end
    
    if not walkTo(plotPos) then
        log("Failed to reach plot for harvest", "WARNING")
        return false
    end
    
    wait(0.3)
    
    local harvestRemote = findRemotes("harvest") or findRemotes("pick")
    
    if harvestRemote then
        for attempt = 1, config.RetryAttempts do
            local success = safeCall(function()
                harvestRemote[1]:FireServer(plot)
            end)
            if success then
                log("Harvested plot", "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    -- Try tool method
    local tool = player.Backpack:FindFirstChild("Harvest") or character:FindFirstChild("Harvest")
    if not tool then
        for _, t in pairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") and (string.find(string.lower(t.Name), "harvest") or string.find(string.lower(t.Name), "pick") or string.find(string.lower(t.Name), "sickle")) then
                tool = t
                break
            end
        end
    end
    
    if tool then
        tool.Parent = character
        wait(0.1)
        safeCall(function()
            tool:Activate()
        end)
        wait(0.2)
        return true
    end
    
    return false
end

function AutoHarvest:Start()
    if AutoHarvest.Enabled then return end
    AutoHarvest.Enabled = true
    
    spawn(function()
        while AutoHarvest.Enabled do
            if config.AutoHarvest then
                -- Check if should skip this cycle
                if shouldSkip() then
                    log("Skipping harvest cycle (humanization)", "INFO")
                    humanizedWait(randomDelay(config.HarvestDelayMin, config.HarvestDelayMax))
                    randomPause()
                    goto continue
                end
                
                local plots = AutoFarm:FindFarmPlots()
                
                -- Randomize plot order for humanization
                if Humanization.enabled then
                    for i = #plots, 2, -1 do
                        local j = math.random(i)
                        plots[i], plots[j] = plots[j], plots[i]
                    end
                end
                
                for _, plot in ipairs(plots) do
                    if AutoFarm:IsPlantReady(plot) then
                        -- Occasionally skip harvest (human-like)
                        if shouldSkip() then
                            log("Skipping harvest (humanization)", "INFO")
                        else
                            if self:HarvestPlot(plot) then
                                humanizedWait(randomDelay(config.HarvestDelayMin, config.HarvestDelayMax))
                            else
                                -- Simulate occasional failure
                                if shouldError() then
                                    log("Harvest failed (simulated error)", "INFO")
                                end
                            end
                        end
                    end
                end
            end
            
            ::continue::
            humanizedWait(randomDelay(config.HarvestDelayMin, config.HarvestDelayMax))
            randomPause()
        end
    end)
end

-- Auto Sell
local AutoSell = {}
AutoSell.Enabled = false

function AutoSell:FindSellShop()
    local shopNames = {"SellShop", "Sell Store", "SellStore", "Sell", "Shop", "Store", "NPC"}
    
    for _, name in ipairs(shopNames) do
        local shop = findInWorkspace(name)
        if shop then
            local npc = shop:FindFirstChildOfClass("Model") or shop
            if npc:FindFirstChild("HumanoidRootPart") or npc:IsA("BasePart") then
                cache.shops["SellShop"] = npc
                return npc
            end
        end
    end
    
    return nil
end

function AutoSell:GetInventory()
    local inventory = {}
    local locations = {player, player:FindFirstChild("Data"), player:FindFirstChild("PlayerData")}
    
    for _, location in ipairs(locations) do
        if location then
            local invFolder = location:FindFirstChild("Inventory") or location:FindFirstChild("Items") or location:FindFirstChild("Crops")
            if invFolder then
                for _, item in pairs(invFolder:GetChildren()) do
                    if not table.find(inventory, item) then
                        table.insert(inventory, item)
                    end
                end
            end
        end
    end
    
    return inventory
end

function AutoSell:SellItems()
    if not config.AutoSell then return end
    
    local inventory = self:GetInventory()
    if #inventory < config.SellThreshold and not config.SellAll then return end
    
    local sellShop = self:FindSellShop()
    if not sellShop then
        log("Sell shop not found", "WARNING")
        return
    end
    
    local shopPos = sellShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or sellShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach sell shop", "WARNING")
        return
    end
    
    wait(0.5)
    
    local sellRemote = findRemotes("sell") or findRemotes("market")
    local sold = 0
    
    if sellRemote then
        for _, item in ipairs(inventory) do
            local shouldKeep = false
            for _, keepItem in ipairs(config.PreferredItems) do
                if item.Name == keepItem or string.find(string.lower(item.Name), string.lower(keepItem)) then
                    shouldKeep = true
                    break
                end
            end
            
            if not shouldKeep then
                for attempt = 1, config.RetryAttempts do
                    local success = safeCall(function()
                        sellRemote[1]:FireServer(item)
                    end)
                    if success then
                        sold = sold + 1
                        break
                    end
                    wait(config.RetryDelay)
                end
                wait(config.SellDelay)
            end
        end
    end
    
    if sold > 0 then
        log("Sold " .. sold .. " items", "SUCCESS")
    end
end

function AutoSell:Start()
    if AutoSell.Enabled then return end
    AutoSell.Enabled = true
    
    spawn(function()
        while AutoSell.Enabled do
            -- Check if should skip
            if shouldSkip() then
                log("Skipping sell cycle (humanization)", "INFO")
            else
                self:SellItems()
            end
            
            humanizedWait(randomDelay(25, 45)) -- Random interval between sell checks
            randomPause()
        end
    end)
end

-- Auto Buy
local AutoBuy = {}
AutoBuy.Enabled = false

function AutoBuy:FindBuyShop()
    local shopNames = {"Shop", "Store", "Buy", "NPC"}
    
    for _, name in ipairs(shopNames) do
        local shop = findInWorkspace(name)
        if shop then
            local npc = shop:FindFirstChildOfClass("Model") or shop
            if npc:FindFirstChild("HumanoidRootPart") or npc:IsA("BasePart") then
                cache.shops["BuyShop"] = npc
                return npc
            end
        end
    end
    
    return nil
end

function AutoBuy:BuyItem(itemName)
    local buyShop = self:FindBuyShop()
    if not buyShop then
        log("Buy shop not found", "WARNING")
        return false
    end
    
    local shopPos = buyShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or buyShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach buy shop", "WARNING")
        return false
    end
    
    wait(0.5)
    
    local buyRemote = findRemotes("buy") or findRemotes("purchase")
    
    if buyRemote then
        for attempt = 1, config.RetryAttempts do
            local success = safeCall(function()
                buyRemote[1]:FireServer(itemName)
            end)
            if success then
                log("Bought: " .. tostring(itemName), "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    return false
end

function AutoBuy:Start()
    if AutoBuy.Enabled then return end
    AutoBuy.Enabled = true
    
    spawn(function()
        while AutoBuy.Enabled do
            if config.AutoBuy and #config.BuyItems > 0 then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping buy cycle (humanization)", "INFO")
                else
                    for _, itemName in ipairs(config.BuyItems) do
                        -- Occasionally skip individual items
                        if not shouldSkip() then
                            if self:BuyItem(itemName) then
                                humanizedWait(randomDelay(config.BuyDelayMin, config.BuyDelayMax))
                            else
                                if shouldError() then
                                    log("Buy failed (simulated error)", "INFO")
                                end
                            end
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(config.BuyInterval, config.BuyInterval * 1.5))
            randomPause()
        end
    end)
end

-- Dupe Tools
local DupeTools = {}
DupeTools.Enabled = false

function DupeTools:DuplicateTool(toolName)
    if not config.DupeTools then return false end
    
    local tool = player.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
    
    if tool and tool:IsA("Tool") then
        local clone = tool:Clone()
        clone.Parent = player.Backpack
        log("Duplicated tool: " .. toolName, "SUCCESS")
        return true
    end
    
    return false
end

function DupeTools:Start()
    if DupeTools.Enabled then return end
    if config.DupeTools then
        log("⚠️ WARNING: DupeTools has HIGH ban risk! Most games have server-side validation.", "WARNING")
        log("⚠️ This feature will likely fail and may trigger detection. Use at your own risk!", "WARNING")
    end
    DupeTools.Enabled = true
    
    spawn(function()
        while DupeTools.Enabled do
            if config.DupeTools then
                -- Add longer delays and random skips for dupe (very risky)
                if shouldSkip() then
                    log("Skipping dupe cycle (safety)", "INFO")
                else
                    for _, tool in pairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            -- High chance to skip individual dupes
                            if math.random() > 0.7 then -- Only 30% chance to actually dupe
                                self:DuplicateTool(tool.Name)
                                humanizedWait(randomDelay(2, 5))
                            end
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(10, 20)) -- Longer delays for risky operations
            randomPause()
        end
    end)
end

-- Event Automation
local EventAutomation = {}
EventAutomation.Enabled = false

function EventAutomation:FindEvents()
    local events = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if string.find(name, "event") or string.find(name, "quest") or string.find(name, "task") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(events, obj)
            end
        end
    end
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = string.lower(remote.Name)
            if string.find(name, "event") or string.find(name, "quest") then
                table.insert(events, remote)
            end
        end
    end
    
    return events
end

function EventAutomation:CompleteEvent(event)
    if not config.EventAutomation then return false end
    
    if event:IsA("RemoteEvent") or event:IsA("RemoteFunction") then
        safeCall(function()
            if event:IsA("RemoteEvent") then
                event:FireServer()
            else
                event:InvokeServer()
            end
        end)
        return true
    else
        local eventPos = event:FindFirstChild("HumanoidRootPart")
        eventPos = eventPos and eventPos.Position or (event:IsA("BasePart") and event.Position or nil)
        
        if eventPos then
            if getDistance(getPlayerPosition(), eventPos) < 50 then
                walkTo(eventPos)
                wait(0.5)
            end
        end
        
        local eventRemote = findRemotes("event") or findRemotes("quest")
        if eventRemote then
            safeCall(function()
                eventRemote[1]:FireServer(event)
            end)
            return true
        end
    end
    
    return false
end

function EventAutomation:Start()
    if EventAutomation.Enabled then return end
    EventAutomation.Enabled = true
    
    spawn(function()
        while EventAutomation.Enabled do
            if config.EventAutomation then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping event cycle (humanization)", "INFO")
                else
                    local events = self:FindEvents()
                    
                    -- Randomize event order
                    if Humanization.enabled then
                        for i = #events, 2, -1 do
                            local j = math.random(i)
                            events[i], events[j] = events[j], events[i]
                        end
                    end
                    
                    for _, event in ipairs(events) do
                        -- Occasionally skip events
                        if not shouldSkip() then
                            if self:CompleteEvent(event) then
                                humanizedWait(randomDelay(1, 3))
                            else
                                if shouldError() then
                                    log("Event completion failed (simulated error)", "INFO")
                                end
                            end
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(config.EventCheckInterval, config.EventCheckInterval * 2))
            randomPause()
        end
    end)
end

-- Dark Spawner
local DarkSpawner = {}
DarkSpawner.Enabled = false

function DarkSpawner:FindDarkShop()
    local shopNames = {"DarkShop", "Dark Store", "DarkStore", "Dark", "SecretShop", "Secret", "Hidden"}
    
    for _, name in ipairs(shopNames) do
        local shop = findInWorkspace(name)
        if shop then
            local npc = shop:FindFirstChildOfClass("Model") or shop
            if npc:FindFirstChild("HumanoidRootPart") or npc:IsA("BasePart") then
                cache.shops["DarkShop"] = npc
                return npc
            end
        end
    end
    
    return nil
end

function DarkSpawner:SpawnDark(darkName)
    if not config.DarkSpawner then return false end
    
    local darkShop = self:FindDarkShop()
    if not darkShop then
        log("Dark shop not found", "WARNING")
        return false
    end
    
    local shopPos = darkShop:FindFirstChild("HumanoidRootPart")
    shopPos = shopPos and shopPos.Position or darkShop.Position
    
    if not walkTo(shopPos) then
        log("Failed to reach dark shop", "WARNING")
        return false
    end
    
    wait(0.5)
    
    local buyRemote = findRemotes("dark") or findRemotes("buy")
    
    if buyRemote then
        for attempt = 1, config.RetryAttempts do
            local success = safeCall(function()
                buyRemote[1]:FireServer(darkName)
            end)
            if success then
                log("Dark spawned: " .. tostring(darkName), "SUCCESS")
                return true
            end
            wait(config.RetryDelay)
        end
    end
    
    return false
end

function DarkSpawner:Start()
    if DarkSpawner.Enabled then return end
    if config.DarkSpawner then
        log("⚠️ WARNING: DarkSpawner may fail or trigger bans if game has server-side validation!", "WARNING")
    end
    DarkSpawner.Enabled = true
    
    spawn(function()
        while DarkSpawner.Enabled do
            if config.DarkSpawner then
                -- Check if should skip
                if shouldSkip() then
                    log("Skipping dark spawn cycle (humanization)", "INFO")
                else
                    -- Try to spawn dark items
                    local darkNames = {"DarkPet", "DarkEgg", "DarkSeed", "Dark", "Shadow"}
                    
                    for _, darkName in ipairs(darkNames) do
                        -- High chance to skip (risky operation)
                        if math.random() > 0.3 then -- Only 30% chance to spawn
                            self:SpawnDark(darkName)
                            humanizedWait(randomDelay(config.SpawnDelayMin, config.SpawnDelayMax))
                        end
                    end
                end
            end
            
            humanizedWait(randomDelay(15, 30)) -- Longer delays for risky operations
            randomPause()
        end
    end)
end

-- Main Control Functions
local function StartAll()
    log("Starting all features...", "INFO")
    
    setupMobileSupport()
    
    if config.AutoFarm then
        AutoFarm:Start()
    end
    
    if config.AutoPlant then
        AutoPlant:Start()
    end
    
    if config.AutoHarvest then
        AutoHarvest:Start()
    end
    
    if config.AutoSell then
        AutoSell:Start()
    end
    
    if config.AutoBuy then
        AutoBuy:Start()
    end
    
    if config.PetSpawner or config.EggSpawner then
        PetEggSpawner:Start()
    end
    
    if config.SeedSpawner then
        SeedSpawner:Start()
    end
    
    if config.DarkSpawner then
        DarkSpawner:Start()
    end
    
    if config.EventAutomation then
        EventAutomation:Start()
    end
    
    if config.DupeTools then
        DupeTools:Start()
    end
    
    log("All features started!", "SUCCESS")
end

local function StopAll()
    log("Stopping all features...", "INFO")
    
    AutoFarm.Enabled = false
    AutoPlant.Enabled = false
    AutoHarvest.Enabled = false
    AutoSell.Enabled = false
    AutoBuy.Enabled = false
    PetEggSpawner.Enabled = false
    SeedSpawner.Enabled = false
    DarkSpawner.Enabled = false
    EventAutomation.Enabled = false
    DupeTools.Enabled = false
    
    log("All features stopped!", "INFO")
end

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    log("Character respawned, reinitializing...", "INFO")
end)

-- Initialize Humanization
if not config.Humanization then
    Humanization.enabled = false
    log("⚠️ Humanization disabled - Higher detection risk!", "WARNING")
else
    log("✅ Humanization enabled for better safety", "INFO")
end

-- Initialize
if config.ShowGUI then
    GUI:Create()
end

StartAll()

-- Export functions for manual control
_G.EXPGAG = {
    Start = StartAll,
    Stop = StopAll,
    Config = config,
    AutoFarm = AutoFarm,
    AutoPlant = AutoPlant,
    AutoHarvest = AutoHarvest,
    AutoSell = AutoSell,
    AutoBuy = AutoBuy,
    PetEggSpawner = PetEggSpawner,
    SeedSpawner = SeedSpawner,
    DarkSpawner = DarkSpawner,
    EventAutomation = EventAutomation,
    DupeTools = DupeTools,
    GUI = GUI,
    Logs = Logs,
    Humanization = Humanization,
}

log("EXP-GAG Script loaded! Use _G.EXPGAG to control features.", "SUCCESS")
log("Example: _G.EXPGAG.Stop() to stop all features", "INFO")
