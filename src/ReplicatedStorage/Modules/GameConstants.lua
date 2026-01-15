--[[
	GameConstants.lua
	
	Centralized configuration and constants for the Relic Rush game.
	Contains all gameplay values, rarity weights, progression curves, and system settings.
	
	Author: Original Framework
	Created: 2026
--]]

local GameConstants = {}

-- ===========================
-- PROGRESSION SYSTEM
-- ===========================

GameConstants.Progression = {
	-- Base experience required for level 1
	BaseExperienceRequired = 100,
	
	-- Multiplier for each subsequent level (exponential growth)
	ExperienceMultiplier = 1.15,
	
	-- Maximum level a player can reach
	MaxLevel = 100,
	
	-- Experience gained per artifact collected
	ExperiencePerArtifact = {
		Common = 10,
		Uncommon = 25,
		Rare = 50,
		Epic = 100,
		Legendary = 250,
		Mythical = 500
	}
}

-- ===========================
-- RARITY SYSTEM
-- ===========================

GameConstants.Rarities = {
	-- Rarity weights for random reward generation (out of 10000)
	Weights = {
		Common = 5000,      -- 50%
		Uncommon = 2500,    -- 25%
		Rare = 1500,        -- 15%
		Epic = 700,         -- 7%
		Legendary = 250,    -- 2.5%
		Mythical = 50       -- 0.5%
	},
	
	-- Visual colors for each rarity
	Colors = {
		Common = Color3.fromRGB(200, 200, 200),
		Uncommon = Color3.fromRGB(100, 255, 100),
		Rare = Color3.fromRGB(100, 150, 255),
		Epic = Color3.fromRGB(200, 100, 255),
		Legendary = Color3.fromRGB(255, 200, 50),
		Mythical = Color3.fromRGB(255, 50, 150)
	},
	
	-- Order of rarities (for sorting)
	Order = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
}

-- ===========================
-- ZONE SYSTEM
-- ===========================

GameConstants.Zones = {
	-- Zone definitions with unlock requirements
	{
		Name = "Ancient Courtyard",
		Id = "zone_1",
		LevelRequired = 1,
		ArtifactsRequired = 0,
		SpawnPosition = Vector3.new(0, 5, 0)
	},
	{
		Name = "Forgotten Library",
		Id = "zone_2",
		LevelRequired = 5,
		ArtifactsRequired = 10,
		SpawnPosition = Vector3.new(100, 5, 0)
	},
	{
		Name = "Crystal Caverns",
		Id = "zone_3",
		LevelRequired = 10,
		ArtifactsRequired = 25,
		SpawnPosition = Vector3.new(200, 5, 0)
	},
	{
		Name = "Celestial Observatory",
		Id = "zone_4",
		LevelRequired = 20,
		ArtifactsRequired = 50,
		SpawnPosition = Vector3.new(300, 5, 0)
	},
	{
		Name = "Temporal Sanctum",
		Id = "zone_5",
		LevelRequired = 35,
		ArtifactsRequired = 100,
		SpawnPosition = Vector3.new(400, 5, 0)
	},
	{
		Name = "Void Nexus",
		Id = "zone_6",
		LevelRequired = 50,
		ArtifactsRequired = 200,
		SpawnPosition = Vector3.new(500, 5, 0)
	}
}

-- ===========================
-- GLOBAL EVENTS SYSTEM
-- ===========================

GameConstants.GlobalEvents = {
	-- Event configurations
	Events = {
		{
			Name = "Artifact Storm",
			Id = "event_storm",
			Duration = 300, -- 5 minutes
			Cooldown = 1800, -- 30 minutes
			RewardMultiplier = 2.0,
			Description = "Double artifact spawn rate!"
		},
		{
			Name = "Mystic Hour",
			Id = "event_mystic",
			Duration = 600, -- 10 minutes
			Cooldown = 3600, -- 1 hour
			RewardMultiplier = 1.5,
			RarityBoost = 1, -- Shifts rarity up by 1 tier
			Description = "Increased rarity chances!"
		},
		{
			Name = "Rush Mode",
			Id = "event_rush",
			Duration = 180, -- 3 minutes
			Cooldown = 900, -- 15 minutes
			ExperienceMultiplier = 3.0,
			Description = "Triple experience gains!"
		}
	},
	
	-- Minimum time between any events (in seconds)
	MinTimeBetweenEvents = 300,
	
	-- Random variance in event timing (±% of cooldown)
	TimingVariance = 0.2
}

-- ===========================
-- COSMETIC SYSTEM
-- ===========================

GameConstants.Cosmetics = {
	-- Particle effects for different rarities
	ParticleEffects = {
		Common = false, -- No particles for common
		Uncommon = "Sparkles",
		Rare = "Glow",
		Epic = "Shimmer",
		Legendary = "Aura",
		Mythical = "RadiantAura"
	},
	
	-- Trail effects unlockable by achievements
	Trails = {
		{
			Name = "Basic Trail",
			Id = "trail_basic",
			UnlockLevel = 1,
			Color = Color3.fromRGB(255, 255, 255)
		},
		{
			Name = "Emerald Path",
			Id = "trail_emerald",
			UnlockLevel = 10,
			Color = Color3.fromRGB(0, 255, 100)
		},
		{
			Name = "Sapphire Stream",
			Id = "trail_sapphire",
			UnlockLevel = 25,
			Color = Color3.fromRGB(0, 100, 255)
		},
		{
			Name = "Golden Wake",
			Id = "trail_golden",
			UnlockLevel = 50,
			Color = Color3.fromRGB(255, 215, 0)
		}
	}
}

-- ===========================
-- DATA PERSISTENCE
-- ===========================

GameConstants.DataSettings = {
	-- ProfileService settings
	ProfileTemplate = {
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
	},
	
	-- Auto-save interval (in seconds)
	AutoSaveInterval = 120,
	
	-- Maximum retry attempts for data loading
	MaxLoadRetries = 3
}

-- ===========================
-- GAMEPLAY MECHANICS
-- ===========================

GameConstants.Gameplay = {
	-- Artifact spawn settings
	ArtifactSpawnInterval = 30, -- Base spawn time in seconds
	MaxArtifactsPerZone = 10,
	ArtifactCollectionRange = 10, -- Studs
	
	-- Player settings
	DefaultWalkSpeed = 16,
	SprintWalkSpeed = 24,
	
	-- Respawn settings
	RespawnTime = 5
}

-- ===========================
-- UI SETTINGS
-- ===========================

GameConstants.UI = {
	-- Notification durations
	NotificationDuration = 5,
	
	-- Animation speeds
	UIAnimationSpeed = 0.3,
	
	-- Color theme
	Theme = {
		Primary = Color3.fromRGB(45, 45, 60),
		Secondary = Color3.fromRGB(60, 60, 80),
		Accent = Color3.fromRGB(100, 200, 255),
		Success = Color3.fromRGB(100, 255, 100),
		Warning = Color3.fromRGB(255, 200, 50),
		Error = Color3.fromRGB(255, 100, 100)
	}
}

return GameConstants
