--[[
	ClientDataHandler.lua
	
	Client-side data management and synchronization.
	Receives data updates from server and manages local state.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local ClientDataHandler = {}
ClientDataHandler.PlayerData = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function ClientDataHandler:Initialize()
	print("[ClientDataHandler] Initializing client data handler...")
	
	-- Listen for data replication from server
	local dataReplication = ReplicatedStorage:WaitForChild("DataReplication")
	dataReplication.OnClientEvent:Connect(function(data)
		self:OnDataReceived(data)
	end)
	
	-- Listen for level up events
	local levelUpEvent = ReplicatedStorage:WaitForChild("LevelUpEvent")
	levelUpEvent.OnClientEvent:Connect(function(newLevel)
		self:OnLevelUp(newLevel)
	end)
	
	print("[ClientDataHandler] Client data handler ready")
end

-- ===========================
-- DATA RECEPTION
-- ===========================

function ClientDataHandler:OnDataReceived(data: table)
	self.PlayerData = data
	print("[ClientDataHandler] Received player data update")
	
	-- Trigger UI updates (would be handled by UI manager)
	self:TriggerDataChangeEvent()
end

-- ===========================
-- DATA GETTERS
-- ===========================

function ClientDataHandler:GetPlayerData(): table?
	return self.PlayerData
end

function ClientDataHandler:GetLevel(): number
	return self.PlayerData and self.PlayerData.Level or 1
end

function ClientDataHandler:GetExperience(): number
	return self.PlayerData and self.PlayerData.Experience or 0
end

function ClientDataHandler:GetArtifactsCollected(): number
	return self.PlayerData and self.PlayerData.ArtifactsCollected or 0
end

function ClientDataHandler:GetUnlockedZones(): table
	return self.PlayerData and self.PlayerData.UnlockedZones or {"zone_1"}
end

function ClientDataHandler:IsZoneUnlocked(zoneId: string): boolean
	local unlockedZones = self:GetUnlockedZones()
	return table.find(unlockedZones, zoneId) ~= nil
end

function ClientDataHandler:GetExperienceToNextLevel(): number
	local level = self:GetLevel()
	if level >= GameConstants.Progression.MaxLevel then
		return 0
	end
	
	return math.floor(
		GameConstants.Progression.BaseExperienceRequired * 
		(GameConstants.Progression.ExperienceMultiplier ^ (level - 1))
	)
end

function ClientDataHandler:GetLevelProgress(): number
	local exp = self:GetExperience()
	local required = self:GetExperienceToNextLevel()
	
	if required == 0 then
		return 100
	end
	
	return (exp / required) * 100
end

-- ===========================
-- EVENT HANDLING
-- ===========================

function ClientDataHandler:OnLevelUp(newLevel: number)
	print("[ClientDataHandler] Level up! New level: " .. newLevel)
	
	-- Play celebration effects (would be handled by effects manager)
	-- Show UI notification (would be handled by UI manager)
end

function ClientDataHandler:TriggerDataChangeEvent()
	-- This would trigger updates to UI elements
	-- In a complete implementation, this would fire bindable events
end

-- ===========================
-- STATISTICS
-- ===========================

function ClientDataHandler:GetStatistics(): table
	return self.PlayerData and self.PlayerData.Statistics or {}
end

function ClientDataHandler:GetPlayTime(): number
	local stats = self:GetStatistics()
	return stats.TotalPlayTime or 0
end

function ClientDataHandler:GetArtifactsByRarity(): table
	local stats = self:GetStatistics()
	return stats.ArtifactsByRarity or {}
end

return ClientDataHandler
