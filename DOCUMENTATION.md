# Relic Rush - Original Roblox Game Framework

## Overview

Relic Rush is a fully original Roblox game framework featuring modular architecture, server-authoritative logic, and comprehensive game systems. Players explore ancient temples, collect mystical artifacts, unlock new dimensions, and progress through a rich experience system.

## 🎮 Game Features

### Core Systems
- **Player Progression**: Level-based system with exponential experience curves
- **Randomized Rewards**: Artifact collection with weighted rarity system (Common to Mythical)
- **Zone Unlocking**: 6 unique zones with level and artifact requirements
- **Global Events**: Timed events that modify gameplay (Artifact Storm, Mystic Hour, Rush Mode)
- **Cosmetic System**: Unlockable trails and visual effects
- **Data Persistence**: ProfileService-compatible data management with auto-save

### Technical Features
- **Modular ModuleScripts**: Clean separation of concerns
- **Server-Authoritative**: All critical logic runs on the server for security
- **Client-Side Visualization**: Efficient rendering and UI management
- **Anti-Cheat**: Distance validation, server-side verification
- **Scalable Architecture**: Easy to extend and maintain

## 📁 Folder Structure

```
src/
├── ServerScriptService/
│   ├── ServerMain.lua              # Main server initialization
│   ├── DataManager.lua             # Player data management
│   ├── RewardSystem.lua            # Rarity calculation & rewards
│   ├── ZoneManager.lua             # Zone unlocking & teleportation
│   ├── EventManager.lua            # Global timed events
│   ├── ArtifactSpawner.lua         # Artifact spawning logic
│   └── CosmeticManager.lua         # Visual effects & cosmetics
│
├── ReplicatedStorage/
│   └── Modules/
│       └── GameConstants.lua       # Centralized configuration
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── ClientMain.lua          # Main client initialization
        ├── ClientDataHandler.lua   # Client data synchronization
        ├── ArtifactVisualizer.lua  # Artifact 3D visualization
        ├── ClientEventHandler.lua  # Event notifications
        └── UIManager.lua            # UI creation & updates
```

## 🔧 Installation

1. **Create a new Roblox Place** in Roblox Studio
2. **Copy the framework files** into your game structure:
   - Place `ServerScriptService` files in `ServerScriptService`
   - Place `ReplicatedStorage/Modules` files in `ReplicatedStorage/Modules`
   - Place `StarterPlayer/StarterPlayerScripts` files in `StarterPlayer/StarterPlayerScripts`
3. **Optional**: Install ProfileService for production data persistence
4. **Test**: Play the game in Studio

## 🎯 Game Configuration

All gameplay values are centralized in `GameConstants.lua`. You can modify:

### Progression Settings
```lua
GameConstants.Progression = {
    BaseExperienceRequired = 100,
    ExperienceMultiplier = 1.15,
    MaxLevel = 100,
    ExperiencePerArtifact = { ... }
}
```

### Rarity Weights
```lua
GameConstants.Rarities.Weights = {
    Common = 5000,      -- 50%
    Uncommon = 2500,    -- 25%
    Rare = 1500,        -- 15%
    Epic = 700,         -- 7%
    Legendary = 250,    -- 2.5%
    Mythical = 50       -- 0.5%
}
```

### Zone Definitions
```lua
GameConstants.Zones = {
    {
        Name = "Ancient Courtyard",
        Id = "zone_1",
        LevelRequired = 1,
        ArtifactsRequired = 0,
        SpawnPosition = Vector3.new(0, 5, 0)
    },
    -- ... more zones
}
```

### Global Events
```lua
GameConstants.GlobalEvents.Events = {
    {
        Name = "Artifact Storm",
        Duration = 300,     -- 5 minutes
        Cooldown = 1800,    -- 30 minutes
        RewardMultiplier = 2.0
    },
    -- ... more events
}
```

## 🎨 Customization

### Adding New Rarities
1. Add to `GameConstants.Rarities.Weights`
2. Add to `GameConstants.Rarities.Colors`
3. Add to `GameConstants.Rarities.Order`
4. Add experience value to `GameConstants.Progression.ExperiencePerArtifact`

### Adding New Zones
1. Add zone definition to `GameConstants.Zones`
2. Set appropriate unlock requirements
3. Define spawn position in your world

### Adding New Events
1. Add event to `GameConstants.GlobalEvents.Events`
2. Define duration, cooldown, and modifiers
3. Event will automatically be scheduled by EventManager

### Adding New Cosmetics
1. Add to appropriate cosmetic array in `GameConstants.Cosmetics`
2. Set unlock requirements
3. Implement visual effects in `CosmeticManager.lua`

## 🔒 Security Features

- **Server-Authoritative Logic**: All critical operations validated on server
- **Distance Validation**: Collection requests verified against player position
- **Data Validation**: All data changes go through DataManager
- **Anti-Exploit**: Client requests are always verified before processing

## 📊 Data Structure

Player data template:
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
        ArtifactsByRarity = { ... }
    }
}
```

## 🚀 Production Deployment

### ProfileService Integration
To use ProfileService for production data persistence:

1. Install ProfileService module
2. Update `DataManager.lua`:
```lua
local ProfileService = require(ServerScriptService.ProfileService)
DataManager.ProfileService = ProfileService
```

3. Implement ProfileService store creation in `DataManager:Initialize()`

### Performance Optimization
- Artifact spawning is staggered across zones
- UI updates throttled to 0.5s intervals
- Client-side caching of player data

## 🎮 Gameplay Loop

1. **Player Joins**: Data loaded from ProfileService
2. **Explore Zones**: Teleport to unlocked zones
3. **Collect Artifacts**: Find and collect spawning artifacts
4. **Gain Experience**: Level up to unlock new content
5. **Unlock Zones**: Meet requirements to access new areas
6. **Participate in Events**: Global events provide bonuses
7. **Customize**: Unlock and equip cosmetic effects

## 📝 Code Comments

All scripts include comprehensive comments:
- File headers with description
- Section separators for organization
- Function documentation
- Inline explanations for complex logic

## ⚖️ Terms of Service Compliance

This framework is designed to be fully compliant with Roblox ToS:
- No copying of existing games or mechanics
- Original naming and concepts
- Clean, well-documented code
- Server-authoritative security
- No exploits or vulnerabilities

## 🔄 Updates & Maintenance

The modular architecture makes updates easy:
- Systems are independent and loosely coupled
- Constants centralized for easy tuning
- Clear separation of client and server code
- Remote events for clean communication

## 🤝 Contributing

To extend this framework:
1. Follow the existing code structure
2. Maintain server-authoritative patterns
3. Document all new features
4. Test thoroughly in Studio
5. Update GameConstants for new content

## 📜 License

This is a fully original framework created for educational and development purposes.

## 🆘 Support

For issues or questions:
1. Check `GameConstants.lua` for configuration options
2. Review server console for error messages
3. Verify RemoteEvents are created in `ServerMain.lua`
4. Ensure proper folder structure

---

**Framework Version**: 1.0.0  
**Created**: 2026  
**Roblox Studio Compatibility**: Current version
