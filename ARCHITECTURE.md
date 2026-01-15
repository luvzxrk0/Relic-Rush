# Architecture & Design Patterns

## Overview

Relic Rush follows a clean, modular architecture with clear separation between server and client code. The framework emphasizes:

- **Server Authority**: All critical game logic on server
- **Modular Design**: Independent, reusable components
- **Single Responsibility**: Each module has one clear purpose
- **Data Encapsulation**: Controlled access to player data
- **Event-Driven Communication**: RemoteEvents for client-server sync

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GAME FRAMEWORK                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────┐         ┌──────────────────────┐   │
│  │   SERVER SYSTEMS    │         │   CLIENT SYSTEMS     │   │
│  │  (Authoritative)    │◄───────►│   (Presentation)     │   │
│  └─────────────────────┘         └──────────────────────┘   │
│           │                                  │                │
│           ├─ DataManager                     ├─ ClientData   │
│           ├─ RewardSystem                    ├─ Visualizer   │
│           ├─ ZoneManager                     ├─ EventHandler │
│           ├─ EventManager                    └─ UIManager    │
│           ├─ ArtifactSpawner                                 │
│           └─ CosmeticManager                                 │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              SHARED RESOURCES                         │   │
│  │  GameConstants (Configuration & Settings)             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Design Patterns Used

### 1. Manager Pattern

**What**: Centralized controllers for specific game domains

**Where**: All main systems (DataManager, ZoneManager, etc.)

**Why**: 
- Single source of truth for each domain
- Easy to locate and modify functionality
- Clear API boundaries

**Example**:
```lua
-- DataManager handles ALL data operations
DataManager:AddExperience(player, 100)
DataManager:GetData(player)
DataManager:SavePlayerData(player)
```

### 2. Module Pattern

**What**: Self-contained modules with private state and public API

**Where**: All ModuleScripts

**Why**:
- Encapsulation of implementation details
- Reusable across projects
- Clear interface for usage

**Example**:
```lua
local RewardSystem = {}
-- Private state
local rng = Random.new()

-- Public API
function RewardSystem:CalculateRarity()
    -- Implementation hidden
end

return RewardSystem
```

### 3. Observer Pattern (Event-Driven)

**What**: Systems respond to events without tight coupling

**Where**: RemoteEvents for client-server communication

**Why**:
- Decouples systems
- Easy to add new listeners
- Clean separation of concerns

**Example**:
```lua
-- Server broadcasts event
GlobalEventStart:FireAllClients(eventData)

-- Client listens and responds
eventStart.OnClientEvent:Connect(function(data)
    -- Handle event
end)
```

### 4. Factory Pattern

**What**: Centralized object creation with consistent structure

**Where**: RewardSystem artifact generation

**Why**:
- Consistent artifact structure
- Easy to modify creation logic
- Encapsulates complexity

**Example**:
```lua
function RewardSystem:GenerateArtifact(zoneId, modifiers)
    return {
        Id = self:GenerateUniqueId(),
        Rarity = self:CalculateRarity(),
        ZoneId = zoneId,
        -- ... other properties
    }
end
```

### 5. Strategy Pattern

**What**: Interchangeable algorithms (rarity calculation)

**Where**: RewardSystem with event modifiers

**Why**:
- Modify behavior without changing structure
- Easy to add new strategies
- Clean code organization

**Example**:
```lua
-- Base strategy
local rarity = CalculateRarity()

-- Modified strategy (event active)
local rarity = CalculateRarity(eventModifiers.RarityBoost)
```

### 6. Data Transfer Object (DTO)

**What**: Structured data packages for communication

**Where**: Artifact data, player data, event data

**Why**:
- Consistent data format
- Easy validation
- Clear contracts between systems

**Example**:
```lua
local artifactData = {
    Id = "artifact_123",
    Rarity = "Legendary",
    ZoneId = "zone_1",
    Position = Vector3.new(0, 5, 0),
    Color = Color3.new(1, 0.8, 0)
}
```

### 7. Singleton-Like Pattern

**What**: Single instance of manager systems

**Where**: All manager modules

**Why**:
- Shared state across server
- Consistent behavior
- Easy access to functionality

**Example**:
```lua
-- Only one DataManager instance managing all player data
local DataManager = {}
DataManager.Profiles = {}  -- Shared state
```

## Code Organization Principles

### 1. Separation of Concerns

**Server Responsibilities**:
- Data validation and storage
- Game logic and rules
- Reward generation
- Anti-cheat verification

**Client Responsibilities**:
- Visual representation
- User input handling
- UI updates
- Local feedback

**Shared**:
- Constants and configuration
- Data structures

### 2. Server Authority Model

```
Client Request → Server Validation → Server Update → Client Notification

Example:
1. Client: "I collected artifact_123"
2. Server: Verify distance, artifact exists, player can collect
3. Server: Update player data, remove artifact
4. Server: Notify all clients to remove visual
5. Server: Notify collector of success
```

### 3. Data Flow

```
Player Action
    ↓
Client Detection (ProximityPrompt, UI Click)
    ↓
Fire RemoteEvent to Server
    ↓
Server Validation
    ↓
Server Data Update (via DataManager)
    ↓
Server Broadcasts Changes
    ↓
Clients Update Visuals/UI
```

### 4. Dependency Management

Systems are initialized in dependency order:

```lua
-- ServerMain.lua initialization order
1. DataManager (no dependencies)
2. ZoneManager (needs DataManager)
3. EventManager (no dependencies)
4. CosmeticManager (needs DataManager)
5. ArtifactSpawner (needs DataManager, RewardSystem, EventManager)
```

### 5. Configuration Centralization

All tunable values in `GameConstants.lua`:
- Easy to balance game
- Single file to modify
- No magic numbers in code
- Clear documentation of values

## Security Architecture

### 1. Trust Boundaries

```
┌─────────────────────────────────────┐
│         UNTRUSTED ZONE              │
│  (Client - Can be manipulated)      │
│                                      │
│  • User Input                        │
│  • Visual State                      │
│  • UI State                          │
└──────────────┬──────────────────────┘
               │ RemoteEvents (Firewall)
               │ • Validate all requests
               │ • Verify permissions
               │ • Check distances/timing
               ↓
┌─────────────────────────────────────┐
│         TRUSTED ZONE                │
│  (Server - Authoritative)            │
│                                      │
│  • Player Data                       │
│  • Game Logic                        │
│  • Reward Generation                 │
│  • State Management                  │
└─────────────────────────────────────┘
```

### 2. Validation Layers

**Layer 1: Type Checking**
```lua
if typeof(artifactId) ~= "string" then
    return false
end
```

**Layer 2: Existence Validation**
```lua
local artifact = self.ActiveArtifacts[artifactId]
if not artifact then
    warn("Artifact not found")
    return false
end
```

**Layer 3: Permission Checks**
```lua
if not self:IsZoneUnlocked(player, zoneId) then
    warn("Zone not unlocked")
    return false
end
```

**Layer 4: Distance/Physics Validation**
```lua
local distance = (playerPos - artifactPos).Magnitude
if distance > MAX_RANGE then
    warn("Player too far")
    return false
end
```

### 3. Data Integrity

- All data changes through DataManager
- No direct client access to data
- Server-side validation before updates
- Data replication one-way (server → client)

## Performance Optimizations

### 1. Update Throttling

```lua
-- UI updates every 0.5s instead of every frame
function UIManager:UpdateLoop()
    while true do
        task.wait(0.5)  -- Throttled
        self:UpdateStatsDisplay()
    end
end
```

### 2. Lazy Loading

```lua
-- RemoteEvents created only when needed
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Parent = ReplicatedStorage
end
```

### 3. Efficient Spawning

```lua
-- Stagger spawns across zones
-- Only spawn if under max limit per zone
if artifactsInZone >= MAX_PER_ZONE then
    return false
end
```

### 4. Client-Side Caching

```lua
-- Client caches player data locally
-- Only updates when server sends changes
ClientDataHandler.PlayerData = data
```

## Extensibility Points

### 1. New Systems

Add new managers following the pattern:
```lua
local NewSystem = {}

function NewSystem:Initialize(dependencies)
    -- Setup
end

-- Public API methods

return NewSystem
```

### 2. New Data Fields

Add to ProfileTemplate in GameConstants:
```lua
ProfileTemplate = {
    -- Existing fields
    NewField = defaultValue
}
```

### 3. New Events

Add to GameConstants.GlobalEvents.Events array

### 4. Custom Cosmetics

Add to GameConstants.Cosmetics arrays

### 5. New Zones

Add to GameConstants.Zones array

## Testing Strategy

### 1. Unit Testing Approach

Test individual module functions:
```lua
-- Test rarity calculation
local rarity = RewardSystem:CalculateRarity()
assert(table.find(GameConstants.Rarities.Order, rarity))
```

### 2. Integration Testing

Test system interactions:
```lua
-- Test collection flow
1. Spawn artifact
2. Player collects
3. Verify data updated
4. Verify artifact removed
```

### 3. Load Testing

Test with multiple players:
- Multiple concurrent collections
- Many active artifacts
- Simultaneous events

## Best Practices Implemented

✅ **DRY (Don't Repeat Yourself)**: Constants centralized  
✅ **SOLID Principles**: Single responsibility per module  
✅ **Clean Code**: Comprehensive comments and documentation  
✅ **Error Handling**: Graceful degradation with warnings  
✅ **Security First**: Server-authoritative design  
✅ **Performance**: Throttled updates, efficient algorithms  
✅ **Maintainability**: Modular, well-organized code  
✅ **Scalability**: Easy to add new features  

---

**Version**: 1.0.0  
**Architecture Type**: Client-Server with Server Authority  
**Pattern Philosophy**: SOLID + DRY + Security-First
