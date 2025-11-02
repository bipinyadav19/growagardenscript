# EXP-GAG Advanced Lua Script

**Version 2.0 - Humanized & Production Ready**

A fully-featured, production-ready Lua automation script for garden farming games with comprehensive features, smart detection, robust error handling, and advanced humanization to reduce detection risk.

## 🚀 Features

### Core Automation Features

✅ **Pet & Egg Spawner** - Automatically spawns pets and hatches eggs
- Auto-detects available pets and eggs
- Multiple spawn methods (Remote → GUI → Tool)
- Respects ownership limits
- Smart detection of shop locations

✅ **Seed Spawner** - Automatically purchases and manages seeds
- Currency checking before purchase
- Maintains optimal seed inventory
- Auto-detects available seed types
- Multiple purchase methods

✅ **Auto Farm** - Intelligent plot management
- Finds and caches farm plots
- Ownership verification (only farms your plots)
- Automatic watering
- Plot status monitoring
- Smart caching system

✅ **Auto Plant** - Automatic seed planting
- Detects empty plots automatically
- Multiple planting methods
- Tool-based and remote-based planting
- Intelligent plot selection

✅ **Auto Harvest** - Automatic crop harvesting
- Detects ready crops instantly
- Multiple harvest methods
- Works seamlessly with AutoFarm
- Tool-based and remote-based harvesting

✅ **Auto Sell** - Intelligent inventory management
- Sells items when threshold reached
- Respects preferred items list
- Multiple shop detection methods
- Configurable sell thresholds

✅ **Auto Buy** - Automatic item purchasing
- Scheduled item purchases
- Configurable buy intervals
- Currency verification
- Multiple shop detection

✅ **Dupe Tools** - Tool duplication system
- Duplicates tools in backpack
- Configurable duplication frequency
- ⚠️ Use at your own risk

✅ **Event Automation** - Automatic event/quest completion
- Finds events and quests automatically
- Completes events at intervals
- Multiple event detection methods
- Remote and workspace event support

✅ **Dark Spawner** - Secret shop automation
- Finds dark/secret shops automatically
- Spawns dark items/pets
- Handles special shop mechanics

✅ **Mobile Support** - Enhanced mobile experience
- Anti-AFK system
- Mobile device optimization
- Prevents idle disconnection
- VirtualUser integration

### Advanced Features

🌟 **Humanization System (NEW in v2.0)**
- **Randomized Skip Actions**: ~5% chance to skip actions (simulates human distraction)
- **Error Simulation**: 3% chance to simulate failed clicks/actions (realistic mistakes)
- **Occasional Pauses**: 2% chance for random breaks (2-8 seconds)
- **Action Limit**: Auto-pauses after 10-20 consecutive actions (prevents bot-like patterns)
- **Realistic Timing**: All delays use ranges (2-6 seconds) instead of fixed values

🌟 **Randomized Movement (NEW in v2.0)**
- Small random offsets to target positions
- Variable walk speed (±3 from base speed)
- Occasional brief pauses before moving
- Re-targeting during movement (5% chance)
- No perfect bot-like movement patterns

🌟 **Order Randomization (NEW in v2.0)**
- Randomizes plot/seed/item processing order
- No predictable sequences
- Simulates natural human behavior
- Applies to farming, planting, harvesting, selling, and buying

🌟 **Smart Auto-Detection**
- Auto-detects shops, remotes, plots, pets, eggs, and seeds
- No manual configuration needed for most games
- Fallback methods for maximum compatibility

🌟 **GUI Control Panel**
- Beautiful, draggable control interface
- Real-time feature toggles
- Visual status indicators (Green = ON, Red = OFF)
- Stop all features button

🌟 **Logging System**
- Comprehensive logging with timestamps
- Multiple log levels (INFO, WARNING, ERROR, SUCCESS)
- Access logs via `_G.EXPGAG.Logs`
- Helps with debugging and monitoring
- **Warnings for risky features** displayed in-game and logs

🌟 **Smart Caching System**
- Caches shops, remotes, and plots for performance
- Reduces unnecessary searches
- Auto-refreshes when needed

🌟 **Plot Ownership Checking**
- Only farms plots owned by you
- Verifies ownership before farming
- Prevents farming other players' plots

🌟 **Currency Checking (NEW in v2.0)**
- Verifies funds before purchases
- Prevents spammy failure loops
- Supports multiple currency types
- Avoids repeated unsuccessful attempts

🌟 **Retry Logic (NEW in v2.0)**
- Configurable retry attempts (default: 3)
- Delayed retries to avoid mass error patterns
- Not infinite - prevents detection from repeated failures
- Safe function calls prevent crashes

🌟 **Multiple Fallback Methods**
- Remote → GUI → Tool fallback system
- Maximum compatibility across different games
- Automatic method switching

🌟 **Risky Feature Safety (NEW in v2.0)**
- DupeTools, DarkSpawner: Only 30% execution chance
- Automatic skipping for high-risk operations
- Warnings displayed when risky features are enabled
- Extra delays for risky operations

## 📋 Configuration

### Basic Configuration

Edit the `config` table at the top of the script:

```lua
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
    DupeTools = false,
    MobileSupport = true,
    ShowGUI = true,              -- Show GUI control panel
    
    -- Timing Settings (NEW: Ranges for randomization)
    FarmDelayMin = 2.0,          -- Minimum delay between farm actions (seconds)
    FarmDelayMax = 6.0,          -- Maximum delay between farm actions
    PlantDelayMin = 3.0,         -- Minimum delay between plant actions
    PlantDelayMax = 7.0,         -- Maximum delay between plant actions
    HarvestDelayMin = 2.5,       -- Minimum delay between harvest actions
    HarvestDelayMax = 5.5,       -- Maximum delay between harvest actions
    SellDelayMin = 1.0,          -- Minimum delay between sell actions
    SellDelayMax = 3.0,          -- Maximum delay between sell actions
    BuyDelayMin = 2.0,           -- Minimum delay between buy actions
    BuyDelayMax = 4.0,           -- Maximum delay between buy actions
    SpawnDelayMin = 2.0,         -- Minimum delay between spawn actions
    SpawnDelayMax = 5.0,         -- Maximum delay between spawn actions
    WalkSpeed = 16,              -- Walking speed
    MoveTimeout = 10,            -- Movement timeout in seconds
    
    -- Humanization Settings (NEW in v2.0)
    Humanization = true,         -- Enable humanization features
    RandomizeMovement = true,    -- Add randomness to movement
    OccasionalBreaks = true,     -- Take occasional breaks
    SimulateErrors = true,       -- Occasionally fail actions to seem human
    
    -- Farming Settings
    FarmRadius = 200,            -- Farm detection radius
    PlantRadius = 200,           -- Plant detection radius
    HarvestRadius = 200,         -- Harvest detection radius
    WaterPlants = true,          -- Auto-water plants
    FertilizePlants = true,      -- Auto-fertilize plants
    
    -- Seed Settings
    PreferredSeeds = {},         -- Will auto-detect if empty
    MaxSeeds = 100,              -- Maximum seeds to keep
    MinSeeds = 10,               -- Minimum seeds before buying
    
    -- Pet Settings
    PreferredPets = {},         -- Will auto-detect if empty
    MaxPets = 50,                -- Maximum pets to own
    
    -- Egg Settings
    PreferredEggs = {},         -- Will auto-detect if empty
    MaxEggs = 10,                -- Maximum eggs to own
    
    -- Sell Settings
    SellThreshold = 50,          -- Sell when inventory reaches this
    PreferredItems = {},         -- Items to keep (don't sell)
    SellAll = false,             -- Sell all items (ignore threshold)
    
    -- Buy Settings
    BuyItems = {},               -- Items to auto-buy
    BuyInterval = 30,             -- Seconds between auto-buy checks
    
    -- Event Settings
    EventCheckInterval = 5,       -- Seconds between event checks
    
    -- Advanced Settings
    AutoDetectRemotes = true,    -- Auto-detect remote locations
    RetryAttempts = 3,            -- Number of retry attempts
    RetryDelay = 1,               -- Delay between retries
}
```

### Setting Preferred Items

Before running, configure your preferred items (optional - will auto-detect):

```lua
config.PreferredSeeds = {"BasicSeed", "GoldenSeed", "RainbowSeed"}
config.PreferredPets = {"CommonPet", "RarePet", "LegendaryPet"}
config.PreferredEggs = {"BasicEgg", "GoldenEgg", "RainbowEgg"}
config.PreferredItems = {"Tool1", "Tool2"} -- Items to keep when selling
config.BuyItems = {"Upgrade1", "Upgrade2", "Upgrade3"} -- Items to auto-buy
```

## 💻 Usage

### Basic Usage

1. Load `EXP-GAG.lua` in your executor
2. Script automatically starts all enabled features
3. GUI control panel appears (if `ShowGUI = true`)
4. Features run in the background automatically

### Manual Control via Console

The script exports a global `_G.EXPGAG` table for advanced control:

```lua
-- Stop all features
_G.EXPGAG.Stop()

-- Start all features
_G.EXPGAG.Start()

-- Access individual modules
_G.EXPGAG.AutoFarm:Start()
_G.EXPGAG.AutoPlant:Start()
_G.EXPGAG.AutoHarvest:Start()
_G.EXPGAG.AutoSell:Start()
_G.EXPGAG.AutoBuy:Start()

-- Toggle features via config
_G.EXPGAG.Config.AutoFarm = false
_G.EXPGAG.Config.AutoPlant = true

-- View logs
print(_G.EXPGAG.Logs)

-- Access GUI
_G.EXPGAG.GUI.Frame -- Access GUI frame
```

### GUI Control Panel

The GUI provides an intuitive interface:
- **Feature Buttons**: Toggle each feature on/off
- **Visual Indicators**: Green = Enabled, Red = Disabled
- **Stop All Button**: Instantly stops all features
- **Draggable**: Click and drag the title bar to move

## 🔧 Module Details

### AutoFarm Module
```lua
_G.EXPGAG.AutoFarm:Start()      -- Start farming
_G.EXPGAG.AutoFarm.Enabled       -- Check if running
_G.EXPGAG.AutoFarm:FindFarmPlots()  -- Find all plots
_G.EXPGAG.AutoFarm:IsPlotEmpty(plot)  -- Check if plot is empty
_G.EXPGAG.AutoFarm:IsPlantReady(plot)  -- Check if ready to harvest
_G.EXPGAG.AutoFarm:WaterPlot(plot)    -- Water a plot
```

### AutoPlant Module
```lua
_G.EXPGAG.AutoPlant:Start()           -- Start planting
_G.EXPGAG.AutoPlant:PlantSeed(plot, seedName)  -- Plant seed in plot
```

### AutoHarvest Module
```lua
_G.EXPGAG.AutoHarvest:Start()          -- Start harvesting
_G.EXPGAG.AutoHarvest:HarvestPlot(plot)  -- Harvest a plot
```

### PetEggSpawner Module
```lua
_G.EXPGAG.PetEggSpawner:Start()       -- Start spawning
_G.EXPGAG.PetEggSpawner:SpawnPet(petName)  -- Spawn specific pet
_G.EXPGAG.PetEggSpawner:SpawnEgg(eggName)  -- Spawn specific egg
_G.EXPGAG.PetEggSpawner:GetOwnedPets()  -- Get owned pets
_G.EXPGAG.PetEggSpawner:GetOwnedEggs()  -- Get owned eggs
_G.EXPGAG.PetEggSpawner:DetectAvailable()  -- Detect available pets/eggs
```

### SeedSpawner Module
```lua
_G.EXPGAG.SeedSpawner:Start()         -- Start spawning
_G.EXPGAG.SeedSpawner:BuySeeds(seedName, amount)  -- Buy seeds
_G.EXPGAG.SeedSpawner:GetSeedCount()  -- Get seed count
_G.EXPGAG.SeedSpawner:DetectAvailable()  -- Detect available seeds
```

### AutoSell Module
```lua
_G.EXPGAG.AutoSell:Start()            -- Start selling
_G.EXPGAG.AutoSell:SellItems()        -- Sell items manually
_G.EXPGAG.AutoSell:GetInventory()     -- Get current inventory
```

### AutoBuy Module
```lua
_G.EXPGAG.AutoBuy:Start()             -- Start buying
_G.EXPGAG.AutoBuy:BuyItem(itemName)   -- Buy specific item
```

### EventAutomation Module
```lua
_G.EXPGAG.EventAutomation:Start()     -- Start automation
_G.EXPGAG.EventAutomation:FindEvents()  -- Find available events
_G.EXPGAG.EventAutomation:CompleteEvent(event)  -- Complete specific event
```

### DarkSpawner Module
```lua
_G.EXPGAG.DarkSpawner:Start()         -- Start spawning
_G.EXPGAG.DarkSpawner:SpawnDark(darkName)  -- Spawn dark item
```

## 🎯 Smart Detection System

The script includes intelligent auto-detection:

- **Shop Detection**: Automatically finds shops by common names
- **Remote Detection**: Searches multiple locations for remotes
- **Plot Detection**: Finds plots with ownership verification
- **Item Detection**: Auto-detects available pets, eggs, and seeds
- **Tool Detection**: Finds and uses appropriate tools

### Detection Priority

1. **Primary**: Direct name matching
2. **Secondary**: Pattern matching
3. **Tertiary**: Multiple location search
4. **Fallback**: GUI interaction

## 🔍 Troubleshooting

### Script Not Working

**Issue**: Script doesn't detect shops/remotes
- ✅ The script auto-detects most games
- ✅ Check console logs for detection messages
- ✅ Verify shop/remote names match common patterns
- ✅ Enable `AutoDetectRemotes = true` in config

**Issue**: Features not executing
- ✅ Check if features are enabled in config
- ✅ Verify character is loaded
- ✅ Check console for error messages
- ✅ Review logs: `_G.EXPGAG.Logs`

### Performance Issues

**Issue**: Script is too slow
- ✅ Reduce delay values in config
- ✅ Increase cache refresh intervals
- ✅ Disable unused features

**Issue**: Script is too fast (causes lag)
- ✅ Increase delay values in config
- ✅ Add more wait times between actions
- ✅ Reduce `FarmRadius`, `PlantRadius`, etc.

### Detection Issues

**Issue**: Can't find shops
- ✅ Check `FarmRadius`, `PlantRadius` values
- ✅ Verify shop names in your game
- ✅ Check logs for detection messages
- ✅ Manually configure shop names if needed

**Issue**: Can't find remotes
- ✅ Enable `AutoDetectRemotes = true`
- ✅ Check ReplicatedStorage structure
- ✅ Review logs for remote detection

### Mobile Issues

**Issue**: Disconnects on mobile
- ✅ Ensure `MobileSupport = true`
- ✅ Verify VirtualUser service is available
- ✅ Check anti-AFK is working

## 📝 Logging System

The script includes comprehensive logging:

```lua
-- View all logs
for _, logEntry in ipairs(_G.EXPGAG.Logs) do
    print(logEntry)
end

-- Logs include timestamps and log levels:
-- [HH:MM:SS] [INFO] Message
-- [HH:MM:SS] [WARNING] Message
-- [HH:MM:SS] [ERROR] Message
-- [HH:MM:SS] [SUCCESS] Message
```

## ⚙️ Advanced Customization

### Custom Shop Names

If your game uses custom shop names:

```lua
function PetEggSpawner:FindPetShop()
    local shopNames = {"YourCustomShopName", "AnotherShop", "PetStore"}
    for _, name in ipairs(shopNames) do
        local shop = Workspace:FindFirstChild(name)
        if shop then return shop end
    end
end
```

### Custom Remote Patterns

The script searches multiple remote locations:
- ReplicatedStorage
- ReplicatedStorage.Remotes
- ReplicatedStorage.Events
- ReplicatedStorage.Functions
- Workspace.Remotes

Remote patterns are automatically matched (case-insensitive).

### Custom Plot Detection

Plots are detected by names containing:
- "plot"
- "farm"
- "soil"
- "land"
- "field"

Ownership is verified automatically.

## 🛡️ Safety Features

- **Error Handling**: All functions wrapped in safe calls
- **Retry Logic**: Automatic retries on failure
- **Ownership Verification**: Only farms your plots
- **Currency Checking**: Verifies funds before purchases
- **Timeout Protection**: Prevents infinite loops
- **Character Respawn Handling**: Auto-reinitializes on death

## 📊 Performance Optimizations

- **Smart Caching**: Caches shops, remotes, and plots
- **Lazy Loading**: Only loads when needed
- **Efficient Searching**: Optimized search algorithms
- **Batch Operations**: Groups similar operations

## 🎮 Compatibility

Designed to work with:
- ✅ Most Roblox garden farming games
- ✅ Games using common remote patterns
- ✅ Games with standard shop structures
- ✅ Mobile and desktop platforms

**Note**: Some games may require minor adjustments to shop names or remote names.

## 🔄 Version 2.0 Key Improvements

### 🎯 Humanization System
1. **Randomized Skip Actions**
   - ~5% chance to skip actions (simulates human distraction)
   - Applies to all farming/planting/harvesting cycles
   - Prevents perfect bot-like execution

2. **Error Simulation**
   - 3% chance to simulate failed clicks/actions
   - Creates realistic human mistakes
   - Logs errors naturally

3. **Occasional Pauses**
   - 2% chance for random breaks (2-8 seconds)
   - Auto-pauses after 10-20 consecutive actions
   - Simulates taking breaks like a real player

4. **Realistic Timing**
   - All delays use ranges instead of fixed values
   - Farming: 2-6 seconds (was 0.1s)
   - Planting: 3-7 seconds (was 0.5s)
   - Harvesting: 2.5-5.5 seconds (was 0.3s)

### 🎲 Randomized Action Timing
- **Movement Randomization**
  - Small random offsets to target positions
  - Variable walk speed (±3 from base)
  - Occasional brief pauses before moving
  - Re-targeting during movement (5% chance)

- **Plot/Seed/Item Order Randomization**
  - Randomizes processing order for all operations
  - No predictable sequences
  - Simulates natural human behavior

### 🔒 Enhanced Safety Features
- **Currency Checks**: Verifies funds before purchases to prevent spam loops
- **Retry Logic**: Limited retries (3 attempts) with delays to avoid error patterns
- **Risky Feature Safety**: DupeTools/DarkSpawner only execute 30% of the time
- **Warning System**: Displays in-game warnings for risky features

### 📊 Detection/Ban Risk Analysis

#### ✅ **Lower Risk** (Humanized & Randomized)
- **Auto Farm**: Much lower risk due to humanization, randomization, and realistic timing
- **Auto Plant**: Randomized delays and order prevent detection
- **Auto Harvest**: Humanized patterns reduce ban risk significantly
- **Auto Sell**: Safe when properly configured with delays
- **Auto Buy**: Lower risk with currency checks and randomization

#### ⚠️ **Medium-High Risk** (May Fail or Trigger Bans)
- **Pet/Egg Spawner**: Will only work if server lacks security. Most games will block these attempts. Repeated tries may get flagged even with randomization.
- **Seed Spawner**: Safer if game allows seed purchases, but server-side validation may block

#### 🔴 **High Risk** (Likely to Fail & May Trigger Bans)
- **Dupe Tools**: Only works if game has fundamental security flaws. Most modern games have server-side validation. Even with 30% execution chance, repeated attempts may trigger bans.
- **Dark Spawner**: Similar to pet/egg spawner - server-side checks will likely block this
- **Event Automation**: Depends on game implementation - some games log suspicious event patterns

### 💡 **Important Notes**
- **NOT "Undetectable"**: While humanization reduces detection risk, it's not perfect
- **Server-Side Validation**: Most modern games validate purchases/spawns server-side. Client-side attempts will fail.
- **Use on Alt Accounts**: Always test on alternate accounts first. Main accounts risk bans.
- **ESP/Safe Features**: Client-side highlighting (ESP) is always safe as it doesn't interact with server
- **Humanization is Key**: Enable humanization (`Humanization = true`) for significantly lower detection risk
- **Realistic Timing**: Use delay ranges (2-6 seconds) instead of fixed values for better safety

### Version 2.0 Features Summary
- ✅ Production-ready implementation
- ✅ **Advanced humanization system**
- ✅ **Randomized delays (2-6 seconds)**
- ✅ **Order randomization**
- ✅ **Movement randomization**
- ✅ GUI control panel
- ✅ Smart auto-detection
- ✅ Comprehensive logging with warnings
- ✅ Enhanced error handling
- ✅ Plot ownership checking
- ✅ Currency verification
- ✅ Retry logic with limits
- ✅ Multiple fallback methods
- ✅ Caching system
- ✅ Character respawn handling
- ✅ **Risky feature safety (30% execution)**

## 📄 License

Free to use and modify for personal use.

## ⚠️ Disclaimer & Risk Warning

### 🚨 **CRITICAL WARNINGS**

1. **NOT "Undetectable"**
   - While humanization significantly reduces detection risk, this script is NOT completely undetectable
   - Anti-cheat systems can still detect suspicious patterns
   - Use at your own risk

2. **Server-Side Validation**
   - Most modern games have server-side validation for purchases/spawns
   - Features like DupeTools, Pet/Egg/Dark Spawner will **fail** in most games
   - Repeated attempts (even randomized) may still trigger bans

3. **Ban Risk Levels**
   - **Lower Risk**: Farming, Planting, Harvesting, Selling (with humanization enabled)
   - **Medium-High Risk**: Pet/Egg/Seed Spawner (may fail or trigger bans)
   - **High Risk**: DupeTools, Dark Spawner (likely to fail and may trigger bans)

4. **Recommendations**
   - **Always test on alternate accounts first**
   - **Never use risky features on main accounts**
   - Enable humanization for better safety
   - Adjust delay ranges for realistic behavior
   - Monitor logs for warnings and errors

5. **Legal Notice**
   - This script is for educational purposes
   - Use violates game terms of service
   - Authors are not responsible for any bans or penalties
   - You assume all risks when using this script

### 💡 **Safety Tips**
- Enable `Humanization = true` (default)
- Use realistic delay ranges (2-6 seconds)
- Disable risky features (DupeTools, DarkSpawner) unless absolutely necessary
- Monitor logs regularly
- Use on alt accounts only

## 💡 Tips

1. **Start Small**: Enable features one at a time to test compatibility
2. **Monitor Logs**: Check logs regularly to ensure everything is working
3. **Adjust Delays**: Fine-tune delays based on your game's speed
4. **Update Config**: Customize config for your specific game
5. **Use GUI**: The GUI makes it easy to toggle features on the fly

## 🆘 Support

If you encounter issues:

1. Check console logs for error messages
2. Review `_G.EXPGAG.Logs` for detailed information
3. Verify game structure matches expectations
4. Adjust shop/remote names if needed
5. Customize delays and settings for your game
6. Enable/disable features via GUI or config

---

**Happy Farming! 🌱**
