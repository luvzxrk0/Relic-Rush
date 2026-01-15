# Relic Rush

**A fully original Roblox game framework featuring modular architecture, server-authoritative logic, and comprehensive game systems.**

## 🎮 About

Relic Rush is a complete, production-ready Roblox game framework where players explore ancient temples, collect mystical artifacts, unlock new dimensions, and progress through a rich leveling system. Built with clean architecture and best practices, this framework provides a solid foundation for creating engaging multiplayer experiences.

## ✨ Key Features

- **🎯 Player Progression**: Experience-based leveling with exponential curves (1-100)
- **🎁 Randomized Rewards**: 6-tier rarity system with weighted drop chances
- **🗺️ Zone System**: 6 unique zones with progressive unlock requirements
- **⏰ Global Events**: Timed events that modify gameplay (3 unique events)
- **✨ Cosmetic System**: Unlockable trails and visual effects
- **💾 Data Persistence**: ProfileService-compatible with auto-save
- **🔒 Security**: Server-authoritative with anti-cheat measures
- **📱 UI System**: Dynamic stat displays and notifications

## 🏗️ Architecture

```
Modular Design with Clean Separation:
├── Server Systems (ServerScriptService)
│   ├── Data Management
│   ├── Reward Generation
│   ├── Zone Control
│   ├── Event Scheduling
│   ├── Artifact Spawning
│   └── Cosmetic Management
│
├── Shared Resources (ReplicatedStorage)
│   └── Game Constants & Configuration
│
└── Client Systems (StarterPlayerScripts)
    ├── Data Synchronization
    ├── Visual Rendering
    ├── Event Handling
    └── UI Management
```

## 🚀 Quick Start

1. **Clone or download** this repository
2. **Copy framework files** to your Roblox Studio game:
   - `src/ServerScriptService/*` → ServerScriptService
   - `src/ReplicatedStorage/*` → ReplicatedStorage
   - `src/StarterPlayer/*` → StarterPlayer
3. **Configure** game values in `GameConstants.lua`
4. **Test** in Roblox Studio

## 📖 Documentation

- **[Full Documentation](DOCUMENTATION.md)** - Complete setup and customization guide
- **[API Reference](API_REFERENCE.md)** - Detailed API documentation for all modules

## 🎨 Game Systems

### Progression System
- Experience-based leveling (Level 1-100)
- Exponential XP curve with 1.15x multiplier
- Different XP rewards per rarity tier

### Rarity System
| Rarity    | Drop Rate | Color       |
|-----------|-----------|-------------|
| Common    | 50%       | Gray        |
| Uncommon  | 25%       | Green       |
| Rare      | 15%       | Blue        |
| Epic      | 7%        | Purple      |
| Legendary | 2.5%      | Gold        |
| Mythical  | 0.5%      | Pink        |

### Zone Unlocking
6 progressive zones requiring specific levels and artifact counts:
1. Ancient Courtyard (Level 1, 0 artifacts)
2. Forgotten Library (Level 5, 10 artifacts)
3. Crystal Caverns (Level 10, 25 artifacts)
4. Celestial Observatory (Level 20, 50 artifacts)
5. Temporal Sanctum (Level 35, 100 artifacts)
6. Void Nexus (Level 50, 200 artifacts)

### Global Events
- **Artifact Storm**: 2x spawn rate (5 min, 30 min cooldown)
- **Mystic Hour**: +1 rarity tier (10 min, 60 min cooldown)
- **Rush Mode**: 3x experience (3 min, 15 min cooldown)

## 🔧 Configuration

All game values are centralized in `GameConstants.lua`:

```lua
-- Adjust progression speed
GameConstants.Progression.BaseExperienceRequired = 100
GameConstants.Progression.ExperienceMultiplier = 1.15

-- Modify rarity weights
GameConstants.Rarities.Weights = {
    Common = 5000,
    Legendary = 250,
    -- etc.
}

-- Configure event timings
GameConstants.GlobalEvents.Events[1].Duration = 300
```

## 🔒 Security Features

- ✅ Server-authoritative game logic
- ✅ Distance validation for collections
- ✅ Data validation and sanitization
- ✅ Anti-exploit measures
- ✅ Secure remote event handling

## 📊 Technical Highlights

- **Modular Design**: Easy to extend and maintain
- **Performance Optimized**: Efficient spawning and UI updates
- **Clean Code**: Comprehensive comments and documentation
- **Best Practices**: Follows Roblox development standards
- **ToS Compliant**: Fully original and compliant with Roblox ToS

## 🎯 Use Cases

Perfect for:
- Learning Roblox game development
- Starting a new multiplayer game
- Understanding server-client architecture
- Implementing data persistence
- Creating progression systems

## 📝 License

Fully original framework created for educational and development purposes.

## 🤝 Contributing

This framework is designed to be extended. Follow the existing patterns:
- Maintain server-authoritative logic
- Keep systems modular and independent
- Update GameConstants for new content
- Document all changes

## 📬 Support

- Check `DOCUMENTATION.md` for detailed guides
- Review `API_REFERENCE.md` for module documentation
- Examine server console for debug messages

---

**Framework Version**: 1.0.0  
**Roblox Compatibility**: Current Studio version  
**Created**: 2026  

**100% Original | Zero Dependencies | Production Ready**
