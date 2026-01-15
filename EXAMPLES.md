# Extension Examples

This document provides practical examples of how to extend the Relic Rush framework with custom features.

## Table of Contents
1. [Adding Custom Events](#adding-custom-events)
2. [Creating New Zone Types](#creating-new-zone-types)
3. [Custom Cosmetics](#custom-cosmetics)
4. [Achievement System](#achievement-system)
5. [Daily Rewards](#daily-rewards)
6. [Player Badges](#player-badges)

---

## Adding Custom Events

### Example: "Lucky Hour" Event

```lua
-- 1. Add to GameConstants.lua
GameConstants.GlobalEvents.Events = {
    -- ... existing events
    {
        Name = "Lucky Hour",
        Id = "event_lucky",
        Duration = 900,  -- 15 minutes
        Cooldown = 7200, -- 2 hours
        RewardMultiplier = 1.0,
        RarityBoost = 2, -- Boost rarity by 2 tiers!
        Description = "Extremely rare artifacts appear!"
    }
}

-- 2. The EventManager will automatically schedule it!
-- 3. Add custom visual effects in ClientEventHandler.lua

function ClientEventHandler:ApplyEventVisuals(eventData: table)
    local Lighting = game:GetService("Lighting")
    
    if eventData.Name == "Lucky Hour" then
        -- Golden glow
        Lighting.Ambient = Color3.fromRGB(255, 215, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 230, 100)
    end
    
    -- ... existing event visuals
end
```

---

## Creating New Zone Types

### Example: "PvP Arena" Zone

```lua
-- 1. Add zone to GameConstants.lua
{
    Name = "Combat Arena",
    Id = "zone_pvp",
    LevelRequired = 40,
    ArtifactsRequired = 150,
    SpawnPosition = Vector3.new(700, 5, 0),
    ZoneType = "PvP", -- Custom property
    EnableCombat = true -- Custom property
}

-- 2. Create PvPManager.lua in ServerScriptService
local PvPManager = {}

function PvPManager:Initialize(dataManager, zoneManager)
    self.DataManager = dataManager
    self.ZoneManager = zoneManager
    
    -- Setup combat detection
    self:SetupCombatZones()
end

function PvPManager:SetupCombatZones()
    for _, zone in ipairs(GameConstants.Zones) do
        if zone.EnableCombat then
            -- Create PvP region
            local region = Instance.new("Part")
            region.Name = "PvPZone_" .. zone.Id
            region.Size = Vector3.new(80, 50, 80)
            region.Position = zone.SpawnPosition
            region.Transparency = 1
            region.CanCollide = false
            region.Anchored = true
            
            -- Add region detection
            region.Touched:Connect(function(hit)
                self:OnPlayerEnterCombatZone(hit.Parent)
            end)
            
            region.Parent = workspace
        end
    end
end

function PvPManager:OnPlayerEnterCombatZone(character)
    local player = game.Players:GetPlayerFromCharacter(character)
    if player then
        -- Enable combat for player
        print(player.Name .. " entered PvP zone!")
    end
end

return PvPManager

-- 3. Initialize in ServerMain.lua
local PvPManager = require(ServerScriptService.PvPManager)
PvPManager:Initialize(DataManager, ZoneManager)
```

---

## Custom Cosmetics

### Example: Pet System

```lua
-- 1. Add to GameConstants.lua
GameConstants.Cosmetics.Pets = {
    {
        Name = "Crystal Companion",
        Id = "pet_crystal",
        UnlockLevel = 15,
        Model = "rbxassetid://1234567890", -- Your pet model ID
        Color = Color3.fromRGB(100, 200, 255)
    },
    {
        Name = "Shadow Follower",
        Id = "pet_shadow",
        UnlockLevel = 30,
        Model = "rbxassetid://0987654321",
        Color = Color3.fromRGB(50, 50, 80)
    }
}

-- 2. Extend CosmeticManager.lua
function CosmeticManager:ApplyPet(character: Model, petId: string)
    -- Find pet configuration
    local petConfig = nil
    for _, pet in ipairs(GameConstants.Cosmetics.Pets) do
        if pet.Id == petId then
            petConfig = pet
            break
        end
    end
    
    if not petConfig then return end
    
    -- Remove existing pet
    local existingPet = character:FindFirstChild("EquippedPet")
    if existingPet then
        existingPet:Destroy()
    end
    
    -- Create new pet (simplified - you'd load actual model)
    local pet = Instance.new("Part")
    pet.Name = "EquippedPet"
    pet.Size = Vector3.new(2, 2, 2)
    pet.Color = petConfig.Color
    pet.Material = Enum.Material.Neon
    pet.CanCollide = false
    
    -- Add AlignPosition to follow player
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = pet
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local attachment1 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(-3, 0, -3) -- Offset from player
    attachment1.Parent = hrp
    
    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = attachment0
    alignPos.Attachment1 = attachment1
    alignPos.RigidityEnabled = false
    alignPos.Parent = pet
    
    pet.Parent = character
end

-- Update ApplyPlayerCosmetics to include pets
function CosmeticManager:ApplyPlayerCosmetics(player: Player, character: Model)
    local data = self.DataManager:GetData(player)
    if not data then return end
    
    -- Apply trail
    if data.EquippedCosmetics.Trail then
        self:ApplyTrail(character, data.EquippedCosmetics.Trail)
    end
    
    -- Apply pet
    if data.EquippedCosmetics.Pet then
        self:ApplyPet(character, data.EquippedCosmetics.Pet)
    end
end
```

---

## Achievement System

### Example: Milestone Achievements

```lua
-- 1. Create AchievementManager.lua
local AchievementManager = {}

local ACHIEVEMENTS = {
    {
        Id = "first_artifact",
        Name = "Beginner Collector",
        Description = "Collect your first artifact",
        Requirement = function(data)
            return data.ArtifactsCollected >= 1
        end,
        Reward = {Type = "Experience", Amount = 100}
    },
    {
        Id = "level_10",
        Name = "Apprentice Explorer",
        Description = "Reach level 10",
        Requirement = function(data)
            return data.Level >= 10
        end,
        Reward = {Type = "Cosmetic", Id = "trail_special"}
    },
    {
        Id = "rare_collector",
        Name = "Rare Hunter",
        Description = "Collect 10 rare or higher artifacts",
        Requirement = function(data)
            local count = 0
            for _, rarity in ipairs({"Rare", "Epic", "Legendary", "Mythical"}) do
                count += data.Statistics.ArtifactsByRarity[rarity] or 0
            end
            return count >= 10
        end,
        Reward = {Type = "Experience", Amount = 500}
    }
}

function AchievementManager:Initialize(dataManager)
    self.DataManager = dataManager
    
    -- Add achievements to data template
    GameConstants.DataSettings.ProfileTemplate.Achievements = {}
    
    print("[AchievementManager] Achievement system ready")
end

function AchievementManager:CheckAchievements(player: Player)
    local data = self.DataManager:GetData(player)
    if not data then return end
    
    for _, achievement in ipairs(ACHIEVEMENTS) do
        -- Skip if already earned
        if data.Achievements[achievement.Id] then
            continue
        end
        
        -- Check requirement
        if achievement.Requirement(data) then
            self:AwardAchievement(player, achievement)
        end
    end
end

function AchievementManager:AwardAchievement(player: Player, achievement)
    local data = self.DataManager:GetData(player)
    if not data then return end
    
    -- Mark as earned
    data.Achievements[achievement.Id] = os.time()
    
    -- Grant reward
    if achievement.Reward.Type == "Experience" then
        self.DataManager:AddExperience(player, achievement.Reward.Amount)
    elseif achievement.Reward.Type == "Cosmetic" then
        -- Unlock cosmetic (would need to extend data system)
    end
    
    -- Notify player
    local remoteEvent = game.ReplicatedStorage:FindFirstChild("AchievementUnlocked")
    if remoteEvent then
        remoteEvent:FireClient(player, achievement)
    end
    
    print("[Achievement] " .. player.Name .. " earned: " .. achievement.Name)
end

return AchievementManager

-- 2. Hook into data changes in DataManager.lua
function DataManager:AddArtifact(player: Player, rarity: string)
    -- ... existing code
    
    -- Check achievements after artifact added
    local AchievementManager = require(script.Parent.AchievementManager)
    AchievementManager:CheckAchievements(player)
    
    return true
end
```

---

## Daily Rewards

### Example: Login Streak System

```lua
-- 1. Create DailyRewardManager.lua
local DailyRewardManager = {}

local DAILY_REWARDS = {
    {Day = 1, Experience = 100, Coins = 50},
    {Day = 2, Experience = 150, Coins = 75},
    {Day = 3, Experience = 200, Coins = 100},
    {Day = 7, Experience = 500, Coins = 500, Cosmetic = "trail_weekly"}
}

function DailyRewardManager:Initialize(dataManager)
    self.DataManager = dataManager
    
    -- Add to data template
    GameConstants.DataSettings.ProfileTemplate.DailyStreak = {
        CurrentStreak = 0,
        LastClaim = 0,
        TotalDays = 0
    }
    
    -- Check on player join
    game.Players.PlayerAdded:Connect(function(player)
        task.wait(1) -- Wait for data to load
        self:CheckDailyReward(player)
    end)
end

function DailyRewardManager:CheckDailyReward(player: Player)
    local data = self.DataManager:GetData(player)
    if not data then return end
    
    local now = os.time()
    local lastClaim = data.DailyStreak.LastClaim
    local daysSinceLastClaim = math.floor((now - lastClaim) / 86400)
    
    if daysSinceLastClaim >= 1 then
        -- Eligible for reward
        if daysSinceLastClaim == 1 then
            -- Consecutive day
            data.DailyStreak.CurrentStreak += 1
        else
            -- Streak broken
            data.DailyStreak.CurrentStreak = 1
        end
        
        self:GrantDailyReward(player)
    end
end

function DailyRewardManager:GrantDailyReward(player: Player)
    local data = self.DataManager:GetData(player)
    
    -- Find reward for current streak day
    local reward = DAILY_REWARDS[data.DailyStreak.CurrentStreak] or DAILY_REWARDS[#DAILY_REWARDS]
    
    -- Grant rewards
    self.DataManager:AddExperience(player, reward.Experience)
    
    -- Update claim time
    data.DailyStreak.LastClaim = os.time()
    data.DailyStreak.TotalDays += 1
    
    -- Notify player
    local remoteEvent = game.ReplicatedStorage:FindFirstChild("DailyRewardClaimed")
    if remoteEvent then
        remoteEvent:FireClient(player, reward, data.DailyStreak.CurrentStreak)
    end
end

return DailyRewardManager
```

---

## Player Badges

### Example: Roblox Badge Integration

```lua
-- 1. Create BadgeManager.lua
local BadgeService = game:GetService("BadgeService")

local BadgeManager = {}

local BADGES = {
    FirstArtifact = 1234567890, -- Replace with actual badge ID
    Level50 = 9876543210,
    AllZones = 1122334455
}

function BadgeManager:Initialize(dataManager)
    self.DataManager = dataManager
end

function BadgeManager:AwardBadge(player: Player, badgeName: string)
    local badgeId = BADGES[badgeName]
    if not badgeId then
        warn("Badge not found:", badgeName)
        return
    end
    
    -- Check if player already has badge
    local hasbadge = false
    local success, result = pcall(function()
        return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
    end)
    
    if success and result then
        return -- Already has badge
    end
    
    -- Award badge
    local awardSuccess = pcall(function()
        BadgeService:AwardBadge(player.UserId, badgeId)
    end)
    
    if awardSuccess then
        print("[BadgeManager] Awarded badge to " .. player.Name .. ": " .. badgeName)
    end
end

-- Hook into appropriate events
function BadgeManager:OnArtifactCollected(player: Player)
    local data = self.DataManager:GetData(player)
    
    if data.ArtifactsCollected == 1 then
        self:AwardBadge(player, "FirstArtifact")
    end
end

function BadgeManager:OnLevelUp(player: Player, newLevel: number)
    if newLevel == 50 then
        self:AwardBadge(player, "Level50")
    end
end

function BadgeManager:OnZoneUnlocked(player: Player)
    local data = self.DataManager:GetData(player)
    
    if #data.UnlockedZones == #GameConstants.Zones then
        self:AwardBadge(player, "AllZones")
    end
end

return BadgeManager
```

---

## Integration Tips

### 1. Don't Modify Core Files
Create new modules instead of editing existing ones when possible.

### 2. Use Events
Hook into existing RemoteEvents or create new ones.

### 3. Extend Data Template
Add new fields to `GameConstants.DataSettings.ProfileTemplate`.

### 4. Follow Patterns
Use the same coding style and patterns as the framework.

### 5. Test Thoroughly
Test new features with multiple players and edge cases.

---

**Framework Version**: 1.0.0  
**Examples Last Updated**: 2026
