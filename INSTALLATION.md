# Installation Guide - Relic Rush Framework

## Prerequisites

- **Roblox Studio** (latest version)
- Basic understanding of Roblox Studio interface
- Optional: ProfileService module (for production data persistence)

## Step-by-Step Installation

### 1. Create a New Place

1. Open Roblox Studio
2. Click **New** → **Baseplate** (or any template)
3. Save your place with a meaningful name (e.g., "Relic Rush Game")

### 2. Install Framework Files

#### Option A: Manual Installation

1. **Create folder structure** in your place:
   - Expand `ReplicatedStorage` in Explorer
   - Right-click → Insert Object → Folder → Name it "Modules"

2. **Add Server Scripts**:
   - In `ServerScriptService`, create ModuleScripts for each server file:
     - `DataManager`
     - `RewardSystem`
     - `ZoneManager`
     - `EventManager`
     - `ArtifactSpawner`
     - `CosmeticManager`
   - Create a Script named `ServerMain`
   - Copy the code from each corresponding `.lua` file in `src/ServerScriptService/`

3. **Add Shared Modules**:
   - In `ReplicatedStorage/Modules`, create ModuleScript:
     - `GameConstants`
   - Copy code from `src/ReplicatedStorage/Modules/GameConstants.lua`

4. **Add Client Scripts**:
   - In `StarterPlayer` → `StarterPlayerScripts`, create ModuleScripts:
     - `ClientDataHandler`
     - `ArtifactVisualizer`
     - `ClientEventHandler`
     - `UIManager`
   - Create a LocalScript named `ClientMain`
   - Copy code from each corresponding `.lua` file in `src/StarterPlayer/StarterPlayerScripts/`

#### Option B: Using Roblox-TS or Rojo (Advanced)

If you're using Rojo for syncing:
1. Clone this repository
2. Configure `default.project.json` to match your place structure
3. Run `rojo serve` and connect from Studio

### 3. Configure Your World

1. **Create spawn location**:
   - Insert a SpawnLocation at position (0, 5, 0)
   - This is the default spawn for "Ancient Courtyard"

2. **Optional: Build zone areas**:
   - Create distinct areas at the positions defined in `GameConstants.Zones`
   - Zone 1: (0, 5, 0)
   - Zone 2: (100, 5, 0)
   - Zone 3: (200, 5, 0)
   - Zone 4: (300, 5, 0)
   - Zone 5: (400, 5, 0)
   - Zone 6: (500, 5, 0)

3. **Add terrain/decorations** to make zones visually distinct (optional)

### 4. Test the Framework

1. **Click Play** in Studio
2. Check the **Output** window for initialization messages:
   ```
   [ServerMain] Loading server modules...
   [ServerMain] Creating remote events...
   [ServerMain] Initializing game systems...
   [DataManager] Initializing data system...
   [ZoneManager] Zone system initialized
   ...
   [ServerMain] All systems initialized successfully
   ```

3. **Client should also initialize**:
   ```
   [ClientMain] Loading client modules...
   [ClientDataHandler] Initializing client data handler...
   [ArtifactVisualizer] Initializing artifact visualizer...
   ...
   [ClientMain] All client systems initialized successfully
   ```

4. **Verify UI appears**: You should see a stats panel in the top-left corner

### 5. Common Installation Issues

#### Issue: "Module not found" errors
**Solution**: Verify all ModuleScripts are in the correct locations and named correctly

#### Issue: Client scripts not running
**Solution**: Ensure scripts in `StarterPlayerScripts` are LocalScripts or Scripts with proper hierarchy

#### Issue: UI not appearing
**Solution**: Check Output for errors. UIManager requires ClientDataHandler to be initialized first

#### Issue: No artifacts spawning
**Solution**: 
- Ensure `ServerMain.lua` is a Script (not LocalScript)
- Check that all RemoteEvents are created
- Look for errors in Output

### 6. Production Setup (Optional)

For production with real data persistence:

1. **Install ProfileService**:
   - Get ProfileService from [Roblox Library](https://www.roblox.com/library/4282863364/)
   - Insert into `ServerScriptService`

2. **Update DataManager**:
   ```lua
   local ProfileService = require(ServerScriptService.ProfileService)
   
   function DataManager:Initialize()
       -- Create ProfileStore
       local ProfileStore = ProfileService.GetProfileStore(
           "PlayerData",
           GameConstants.DataSettings.ProfileTemplate
       )
       self.ProfileStore = ProfileStore
       
       -- Rest of initialization...
   end
   ```

3. **Enable Auto-Save** (already configured in DataManager)

4. **Test data persistence** by leaving and rejoining

### 7. Customization

After installation, customize the framework:

1. **Edit `GameConstants.lua`** to adjust:
   - Experience rates
   - Rarity weights
   - Zone requirements
   - Event timings

2. **Modify zone spawn positions** to match your world layout

3. **Customize UI colors** in `GameConstants.UI.Theme`

4. **Add custom cosmetics** in `GameConstants.Cosmetics`

## Verification Checklist

Use this checklist to verify installation:

- [ ] All server scripts present in ServerScriptService
- [ ] All client scripts present in StarterPlayerScripts
- [ ] GameConstants module in ReplicatedStorage/Modules
- [ ] ServerMain runs without errors
- [ ] ClientMain runs without errors
- [ ] Stats UI appears on screen
- [ ] Artifacts spawn in the world (wait 30 seconds)
- [ ] Can collect artifacts with proximity prompt
- [ ] Experience bar updates after collection
- [ ] No error messages in Output

## Next Steps

After successful installation:

1. **Read [DOCUMENTATION.md](DOCUMENTATION.md)** for detailed feature explanations
2. **Review [API_REFERENCE.md](API_REFERENCE.md)** for coding reference
3. **Build your world** around the framework
4. **Customize gameplay** via GameConstants
5. **Add custom features** by extending the systems

## Getting Help

If you encounter issues:

1. **Check Output window** for error messages
2. **Verify file locations** match the folder structure
3. **Ensure all RemoteEvents** are created in ServerMain
4. **Check that ServerMain and ClientMain** are both running
5. **Review the example code** in each module for proper usage

## Framework Structure Reference

```
YourPlace
├── ServerScriptService
│   ├── ServerMain (Script)
│   ├── DataManager (ModuleScript)
│   ├── RewardSystem (ModuleScript)
│   ├── ZoneManager (ModuleScript)
│   ├── EventManager (ModuleScript)
│   ├── ArtifactSpawner (ModuleScript)
│   └── CosmeticManager (ModuleScript)
│
├── ReplicatedStorage
│   └── Modules (Folder)
│       └── GameConstants (ModuleScript)
│
└── StarterPlayer
    └── StarterPlayerScripts
        ├── ClientMain (LocalScript)
        ├── ClientDataHandler (ModuleScript)
        ├── ArtifactVisualizer (ModuleScript)
        ├── ClientEventHandler (ModuleScript)
        └── UIManager (ModuleScript)
```

---

**Installation Time**: ~15-30 minutes  
**Skill Level**: Beginner to Intermediate  
**Studio Version**: Current
