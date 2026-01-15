# Relic Rush - API Reference

## Server-Side Modules

### DataManager

Handles all player data persistence and management.

#### Methods

##### `DataManager:Initialize()`
Initializes the data system and sets up player events.
- **Returns**: None
- **Side Effects**: Connects to PlayerAdded/PlayerRemoving events

##### `DataManager:GetData(player: Player)`
Retrieves player's data.
- **Parameters**: 
  - `player`: Player instance
- **Returns**: Table containing player data or nil

##### `DataManager:AddExperience(player: Player, amount: number)`
Adds experience to player and handles level ups.
- **Parameters**:
  - `player`: Player instance
  - `amount`: Experience amount to add
- **Returns**: boolean (success)
- **Side Effects**: May trigger level up, unlocks zones

##### `DataManager:AddArtifact(player: Player, rarity: string)`
Records artifact collection.
- **Parameters**:
  - `player`: Player instance
  - `rarity`: Rarity tier (Common, Uncommon, Rare, Epic, Legendary, Mythical)
- **Returns**: boolean (success)
- **Side Effects**: Updates statistics, awards experience

##### `DataManager:UnlockZone(player: Player, zoneId: string)`
Unlocks a zone for the player.
- **Parameters**:
  - `player`: Player instance
  - `zoneId`: Zone identifier
- **Returns**: boolean (success)

##### `DataManager:EquipCosmetic(player: Player, cosmeticType: string, cosmeticId: string)`
Equips a cosmetic item.
- **Parameters**:
  - `player`: Player instance
  - `cosmeticType`: Type of cosmetic (e.g., "Trail")
  - `cosmeticId`: Cosmetic identifier
- **Returns**: boolean (success)

---

### RewardSystem

Manages randomized reward generation with rarity weights.

#### Methods

##### `RewardSystem:CalculateRarity(rarityBoost: number?)`
Calculates a random rarity based on weights.
- **Parameters**:
  - `rarityBoost`: Optional boost to shift rarity up tiers
- **Returns**: string (rarity name)

##### `RewardSystem:GenerateArtifact(zoneId: string, eventModifiers: table?)`
Generates a complete artifact with metadata.
- **Parameters**:
  - `zoneId`: Zone where artifact spawns
  - `eventModifiers`: Optional event bonuses
- **Returns**: table (artifact data)

##### `RewardSystem:BoostRarity(currentRarity: string, boostAmount: number)`
Shifts rarity up by specified tiers.
- **Parameters**:
  - `currentRarity`: Current rarity tier
  - `boostAmount`: Number of tiers to boost
- **Returns**: string (boosted rarity)

##### `RewardSystem:ValidateReward(artifact: table)`
Validates artifact data structure.
- **Parameters**:
  - `artifact`: Artifact data table
- **Returns**: boolean (valid)

---

### ZoneManager

Handles zone unlocking, validation, and teleportation.

#### Methods

##### `ZoneManager:Initialize(dataManager)`
Initializes zone system with reference to DataManager.
- **Parameters**:
  - `dataManager`: DataManager instance
- **Returns**: None

##### `ZoneManager:CanUnlockZone(player: Player, zoneId: string)`
Checks if player meets zone unlock requirements.
- **Parameters**:
  - `player`: Player instance
  - `zoneId`: Zone identifier
- **Returns**: boolean

##### `ZoneManager:UnlockZone(player: Player, zoneId: string)`
Unlocks zone if requirements are met.
- **Parameters**:
  - `player`: Player instance
  - `zoneId`: Zone identifier
- **Returns**: boolean (success)

##### `ZoneManager:TeleportToZone(player: Player, zoneId: string)`
Teleports player to zone spawn position.
- **Parameters**:
  - `player`: Player instance
  - `zoneId`: Zone identifier
- **Returns**: boolean (success)

##### `ZoneManager:GetNextZone(player: Player)`
Gets the next zone player should unlock.
- **Parameters**:
  - `player`: Player instance
- **Returns**: table (zone info with progress) or nil

---

### EventManager

Manages global timed events.

#### Methods

##### `EventManager:Initialize()`
Starts event scheduling system.
- **Returns**: None
- **Side Effects**: Begins event scheduling loop

##### `EventManager:StartEvent(eventId: string)`
Manually starts a specific event.
- **Parameters**:
  - `eventId`: Event identifier
- **Returns**: boolean (success)

##### `EventManager:EndEvent()`
Ends the currently active event.
- **Returns**: None

##### `EventManager:GetActiveEvent()`
Gets currently active event data.
- **Returns**: table (event data) or nil

##### `EventManager:GetEventModifiers()`
Gets modifiers from active event.
- **Returns**: table (modifiers)

##### `EventManager:IsEventActive()`
Checks if any event is currently active.
- **Returns**: boolean

---

### ArtifactSpawner

Handles artifact spawning and collection.

#### Methods

##### `ArtifactSpawner:Initialize(dataManager, rewardSystem, eventManager)`
Initializes spawning system.
- **Parameters**:
  - `dataManager`: DataManager instance
  - `rewardSystem`: RewardSystem instance
  - `eventManager`: EventManager instance
- **Returns**: None

##### `ArtifactSpawner:TrySpawnArtifact(zoneId: string)`
Attempts to spawn artifact in zone.
- **Parameters**:
  - `zoneId`: Zone identifier
- **Returns**: boolean (spawned)

##### `ArtifactSpawner:AttemptCollection(player: Player, artifactId: string)`
Processes collection request from player.
- **Parameters**:
  - `player`: Player instance
  - `artifactId`: Artifact identifier
- **Returns**: boolean (success)
- **Side Effects**: Validates distance, updates data, broadcasts removal

##### `ArtifactSpawner:GetActiveArtifactCount()`
Gets total number of active artifacts.
- **Returns**: number

---

### CosmeticManager

Manages visual effects and cosmetic customization.

#### Methods

##### `CosmeticManager:Initialize(dataManager)`
Initializes cosmetic system.
- **Parameters**:
  - `dataManager`: DataManager instance
- **Returns**: None

##### `CosmeticManager:IsCosmeticUnlocked(player: Player, cosmeticType: string, cosmeticId: string)`
Checks if player has unlocked a cosmetic.
- **Parameters**:
  - `player`: Player instance
  - `cosmeticType`: Type of cosmetic
  - `cosmeticId`: Cosmetic identifier
- **Returns**: boolean

##### `CosmeticManager:EquipCosmetic(player: Player, cosmeticType: string, cosmeticId: string)`
Equips cosmetic if unlocked.
- **Parameters**:
  - `player`: Player instance
  - `cosmeticType`: Type of cosmetic
  - `cosmeticId`: Cosmetic identifier
- **Returns**: boolean (success)

##### `CosmeticManager:ApplyPlayerCosmetics(player: Player, character: Model)`
Applies all equipped cosmetics to character.
- **Parameters**:
  - `player`: Player instance
  - `character`: Character model
- **Returns**: None

---

## Client-Side Modules

### ClientDataHandler

Manages client-side data state and synchronization.

#### Methods

##### `ClientDataHandler:Initialize()`
Sets up data replication listeners.
- **Returns**: None

##### `ClientDataHandler:GetPlayerData()`
Gets local player data cache.
- **Returns**: table or nil

##### `ClientDataHandler:GetLevel()`
Gets player's current level.
- **Returns**: number

##### `ClientDataHandler:GetExperience()`
Gets player's current experience.
- **Returns**: number

##### `ClientDataHandler:GetExperienceToNextLevel()`
Calculates experience required for next level.
- **Returns**: number

##### `ClientDataHandler:IsZoneUnlocked(zoneId: string)`
Checks if zone is unlocked.
- **Parameters**:
  - `zoneId`: Zone identifier
- **Returns**: boolean

---

### ArtifactVisualizer

Handles 3D visualization of artifacts.

#### Methods

##### `ArtifactVisualizer:Initialize()`
Sets up artifact rendering system.
- **Returns**: None

##### `ArtifactVisualizer:CreateArtifactVisual(artifactData: table)`
Creates 3D visual representation.
- **Parameters**:
  - `artifactData`: Artifact properties
- **Returns**: None
- **Side Effects**: Creates Part in Workspace

##### `ArtifactVisualizer:RequestCollection(artifactId: string)`
Sends collection request to server.
- **Parameters**:
  - `artifactId`: Artifact identifier
- **Returns**: None

---

### ClientEventHandler

Manages global event notifications on client.

#### Methods

##### `ClientEventHandler:Initialize()`
Sets up event listeners.
- **Returns**: None

##### `ClientEventHandler:GetCurrentEvent()`
Gets active event data.
- **Returns**: table or nil

##### `ClientEventHandler:IsEventActive()`
Checks if event is active.
- **Returns**: boolean

---

### UIManager

Creates and updates UI elements.

#### Methods

##### `UIManager:Initialize(dataHandler)`
Creates UI and starts update loop.
- **Parameters**:
  - `dataHandler`: ClientDataHandler instance
- **Returns**: None

##### `UIManager:ShowNotification(title: string, message: string, duration: number?)`
Displays temporary notification.
- **Parameters**:
  - `title`: Notification title
  - `message`: Notification message
  - `duration`: Display time in seconds (default: 5)
- **Returns**: None

---

## Remote Events

### Server → Client

- **DataReplication**: Sends player data updates
- **LevelUpEvent**: Notifies of level up
- **ZoneUnlocked**: Notifies of new zone unlock
- **GlobalEventStart**: Announces global event start
- **GlobalEventEnd**: Announces global event end
- **ArtifactSpawned**: Notifies of artifact spawn
- **ArtifactRemoved**: Notifies of artifact removal
- **ArtifactCollected**: Confirms successful collection

### Client → Server

- **CollectArtifact**: Requests artifact collection
- **EquipCosmetic**: Requests cosmetic equip

---

## Configuration

All configuration is in `GameConstants.lua`:

- `GameConstants.Progression`: Experience and leveling
- `GameConstants.Rarities`: Rarity weights and colors
- `GameConstants.Zones`: Zone definitions
- `GameConstants.GlobalEvents`: Event configurations
- `GameConstants.Cosmetics`: Visual effects
- `GameConstants.DataSettings`: Data persistence
- `GameConstants.Gameplay`: Game mechanics
- `GameConstants.UI`: UI theme and settings

---

**Version**: 1.0.0  
**Last Updated**: 2026
