# Quick Reference - Relic Rush Framework

## 🎯 Quick Commands

### Common Customizations

#### Change Experience Rate
```lua
-- GameConstants.lua
GameConstants.Progression.BaseExperienceRequired = 100  -- Lower = faster leveling
GameConstants.Progression.ExperienceMultiplier = 1.15  -- Lower = slower scaling
```

#### Adjust Rarity Drop Rates
```lua
-- GameConstants.lua (weights out of 10000)
GameConstants.Rarities.Weights = {
    Common = 5000,      -- 50% (increase for more commons)
    Legendary = 250,    -- 2.5% (increase for more legendaries)
    Mythical = 50       -- 0.5% (increase for more mythicals)
}
```

#### Change Artifact Spawn Rate
```lua
-- GameConstants.lua
GameConstants.Gameplay.ArtifactSpawnInterval = 30  -- Seconds (lower = more frequent)
GameConstants.Gameplay.MaxArtifactsPerZone = 10   -- Max per zone (higher = more artifacts)
```

#### Modify Event Duration
```lua
-- GameConstants.lua
GameConstants.GlobalEvents.Events = {
    {
        Name = "Artifact Storm",
        Duration = 300,     -- Seconds (5 minutes)
        Cooldown = 1800,    -- Seconds (30 minutes)
        RewardMultiplier = 2.0  -- 2x rewards
    }
}
```

## 📊 Data Structure

### Player Data Template
```lua
{
    Level = 1,
    Experience = 0,
    ArtifactsCollected = 0,
    UnlockedZones = {"zone_1"},
    EquippedCosmetics = {
        Trail = "trail_basic"
    },
    Inventory = {},
    Statistics = {
        TotalPlayTime = 0,
        SessionCount = 0,
        ArtifactsByRarity = {
            Common = 0,
            Uncommon = 0,
            Rare = 0,
            Epic = 0,
            Legendary = 0,
            Mythical = 0
        }
    },
    LastLogin = 0
}
```

## 🔧 Common Tasks

### Add a New Zone
```lua
-- In GameConstants.lua, add to Zones array:
{
    Name = "Your Zone Name",
    Id = "zone_7",
    LevelRequired = 60,
    ArtifactsRequired = 300,
    SpawnPosition = Vector3.new(600, 5, 0)
}
```

### Create a New Event
```lua
-- In GameConstants.GlobalEvents.Events array:
{
    Name = "Your Event Name",
    Id = "event_custom",
    Duration = 420,  -- 7 minutes
    Cooldown = 2400, -- 40 minutes
    RewardMultiplier = 2.5,
    Description = "Your event description!"
}
```

### Add a New Rarity Tier
```lua
-- 1. Add to Weights
GameConstants.Rarities.Weights.Divine = 10  -- 0.1%

-- 2. Add to Colors
GameConstants.Rarities.Colors.Divine = Color3.fromRGB(255, 255, 0)

-- 3. Add to Order
GameConstants.Rarities.Order = {"Common", ..., "Mythical", "Divine"}

-- 4. Add experience value
GameConstants.Progression.ExperiencePerArtifact.Divine = 1000
```

### Create Custom Cosmetic
```lua
-- In GameConstants.Cosmetics.Trails:
{
    Name = "Rainbow Trail",
    Id = "trail_rainbow",
    UnlockLevel = 75,
    Color = Color3.fromRGB(255, 0, 255)
}
```

## 🎮 Server Commands

### Manually Trigger Event
```lua
-- In ServerScriptService Script:
local EventManager = require(script.Parent.EventManager)
EventManager:ForceStartEvent("event_storm")  -- Start Artifact Storm
EventManager:ForceEndEvent()  -- End current event
```

### Grant Items to Player
```lua
-- In a server script:
local DataManager = require(game.ServerScriptService.DataManager)
local player = game.Players:FindFirstChild("PlayerName")

DataManager:AddExperience(player, 1000)  -- Add 1000 XP
DataManager:AddArtifact(player, "Legendary")  -- Give legendary artifact
DataManager:UnlockZone(player, "zone_5")  -- Unlock zone 5
```

### Check Player Stats
```lua
-- In a server script:
local DataManager = require(game.ServerScriptService.DataManager)
local data = DataManager:GetData(player)

print("Level:", data.Level)
print("Experience:", data.Experience)
print("Artifacts:", data.ArtifactsCollected)
print("Zones:", #data.UnlockedZones)
```

## 🖥️ Client Commands

### Access Player Data
```lua
-- In a LocalScript:
local ClientDataHandler = require(script.Parent.ClientDataHandler)

local level = ClientDataHandler:GetLevel()
local exp = ClientDataHandler:GetExperience()
local artifacts = ClientDataHandler:GetArtifactsCollected()
```

### Show Notification
```lua
-- In a LocalScript:
local UIManager = require(script.Parent.UIManager)

UIManager:ShowNotification(
    "Achievement!",
    "You collected 100 artifacts!",
    5  -- Duration in seconds
)
```

### Check Event Status
```lua
-- In a LocalScript:
local ClientEventHandler = require(script.Parent.ClientEventHandler)

if ClientEventHandler:IsEventActive() then
    local event = ClientEventHandler:GetCurrentEvent()
    print("Active event:", event.Name)
end
```

## 📈 Progression Math

### Experience Required for Level
```
exp_required = BaseExp * (Multiplier ^ (level - 1))

Examples:
Level 1 → 2: 100 * (1.15 ^ 0) = 100 XP
Level 2 → 3: 100 * (1.15 ^ 1) = 115 XP
Level 10 → 11: 100 * (1.15 ^ 9) = 357 XP
Level 50 → 51: 100 * (1.15 ^ 49) = 64,462 XP
```

### Drop Chance Calculation
```
chance = (weight / total_weight) * 100

Total weight = 10,000
Legendary weight = 250
Legendary chance = (250 / 10000) * 100 = 2.5%
```

## 🎨 UI Theme Colors

```lua
GameConstants.UI.Theme = {
    Primary = Color3.fromRGB(45, 45, 60),      -- Dark blue-gray
    Secondary = Color3.fromRGB(60, 60, 80),    -- Medium blue-gray
    Accent = Color3.fromRGB(100, 200, 255),    -- Light blue
    Success = Color3.fromRGB(100, 255, 100),   -- Green
    Warning = Color3.fromRGB(255, 200, 50),    -- Yellow
    Error = Color3.fromRGB(255, 100, 100)      -- Red
}
```

## 🔒 Security Best Practices

### ✅ DO
- Validate all client requests on server
- Use DataManager for all data changes
- Check permissions before actions
- Verify distances for collections

### ❌ DON'T
- Trust client-sent values
- Allow direct data manipulation
- Skip validation checks
- Expose sensitive data to client

## 📱 Remote Events Reference

### Server → Client
```lua
DataReplication:FireClient(player, data)
LevelUpEvent:FireClient(player, newLevel)
ZoneUnlocked:FireClient(player, zoneId, zoneName)
GlobalEventStart:FireAllClients(eventData)
ArtifactSpawned:FireAllClients(artifactData)
```

### Client → Server
```lua
CollectArtifact:FireServer(artifactId)
EquipCosmetic:FireServer(cosmeticType, cosmeticId)
```

## 🐛 Debugging

### Enable Verbose Logging
Add print statements in key functions:
```lua
-- In any module function:
print("[ModuleName] Function called with:", param1, param2)
```

### Check System Status
```lua
-- Server console commands:
print("Active artifacts:", ArtifactSpawner:GetActiveArtifactCount())
print("Current event:", EventManager:GetActiveEvent())
print("Zone validation:", ZoneManager:ValidateZoneStructure())
```

### Monitor Performance
```lua
-- Check spawn rates:
local stats = ArtifactSpawner:GetSpawnerStatistics()
print("Total artifacts:", stats.TotalActiveArtifacts)
print("By zone:", stats.ArtifactsByZone)
```

## 📞 Support Quick Links

- Full Documentation: [DOCUMENTATION.md](DOCUMENTATION.md)
- API Reference: [API_REFERENCE.md](API_REFERENCE.md)
- Installation Guide: [INSTALLATION.md](INSTALLATION.md)

---

**Version**: 1.0.0  
**Last Updated**: 2026
