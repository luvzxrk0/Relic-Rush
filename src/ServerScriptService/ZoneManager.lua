--[[
	ZoneManager.lua
	
	Server-authoritative zone management system.
	Handles zone unlocking, teleportation, and zone-specific logic.
	
	Author: Original Framework
	Created: 2026
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local ZoneManager = {}
ZoneManager.DataManager = nil -- Reference to DataManager (set during initialization)

-- ===========================
-- INITIALIZATION
-- ===========================

function ZoneManager:Initialize(dataManager)
	self.DataManager = dataManager
	print("[ZoneManager] Zone system initialized")
end

-- ===========================
-- ZONE QUERIES
-- ===========================

function ZoneManager:GetZoneById(zoneId: string): table?
	for _, zone in ipairs(GameConstants.Zones) do
		if zone.Id == zoneId then
			return zone
		end
	end
	return nil
end

function ZoneManager:GetZoneByName(zoneName: string): table?
	for _, zone in ipairs(GameConstants.Zones) do
		if zone.Name == zoneName then
			return zone
		end
	end
	return nil
end

function ZoneManager:GetAllZones(): table
	return GameConstants.Zones
end

-- ===========================
-- ZONE UNLOCKING
-- ===========================

function ZoneManager:CanUnlockZone(player: Player, zoneId: string): boolean
	local zone = self:GetZoneById(zoneId)
	if not zone then return false end
	
	local data = self.DataManager:GetData(player)
	if not data then return false end
	
	-- Check if already unlocked
	if table.find(data.UnlockedZones, zoneId) then
		return false
	end
	
	-- Check requirements
	local meetsLevelReq = data.Level >= zone.LevelRequired
	local meetsArtifactReq = data.ArtifactsCollected >= zone.ArtifactsRequired
	
	return meetsLevelReq and meetsArtifactReq
end

function ZoneManager:UnlockZone(player: Player, zoneId: string): boolean
	if not self:CanUnlockZone(player, zoneId) then
		return false
	end
	
	local success = self.DataManager:UnlockZone(player, zoneId)
	
	if success then
		local zone = self:GetZoneById(zoneId)
		print("[ZoneManager] Player " .. player.Name .. " unlocked zone: " .. zone.Name)
		
		-- Notify client
		local remoteEvent = ReplicatedStorage:FindFirstChild("ZoneUnlocked")
		if remoteEvent then
			remoteEvent:FireClient(player, zoneId, zone.Name)
		end
	end
	
	return success
end

-- ===========================
-- ZONE ACCESS
-- ===========================

function ZoneManager:IsZoneUnlocked(player: Player, zoneId: string): boolean
	local data = self.DataManager:GetData(player)
	if not data then return false end
	
	return table.find(data.UnlockedZones, zoneId) ~= nil
end

function ZoneManager:GetUnlockedZones(player: Player): table
	local data = self.DataManager:GetData(player)
	if not data then return {} end
	
	local unlockedZones = {}
	for _, zoneId in ipairs(data.UnlockedZones) do
		local zone = self:GetZoneById(zoneId)
		if zone then
			table.insert(unlockedZones, zone)
		end
	end
	
	return unlockedZones
end

function ZoneManager:GetLockedZones(player: Player): table
	local data = self.DataManager:GetData(player)
	if not data then return {} end
	
	local lockedZones = {}
	for _, zone in ipairs(GameConstants.Zones) do
		if not table.find(data.UnlockedZones, zone.Id) then
			table.insert(lockedZones, {
				Zone = zone,
				MeetsLevelReq = data.Level >= zone.LevelRequired,
				MeetsArtifactReq = data.ArtifactsCollected >= zone.ArtifactsRequired
			})
		end
	end
	
	return lockedZones
end

-- ===========================
-- ZONE TELEPORTATION
-- ===========================

function ZoneManager:TeleportToZone(player: Player, zoneId: string): boolean
	-- Verify zone is unlocked
	if not self:IsZoneUnlocked(player, zoneId) then
		warn("[ZoneManager] Cannot teleport " .. player.Name .. " to locked zone: " .. zoneId)
		return false
	end
	
	local zone = self:GetZoneById(zoneId)
	if not zone then return false end
	
	-- Teleport player's character
	local character = player.Character
	if not character then return false end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end
	
	humanoidRootPart.CFrame = CFrame.new(zone.SpawnPosition)
	
	print("[ZoneManager] Teleported " .. player.Name .. " to zone: " .. zone.Name)
	return true
end

-- ===========================
-- ZONE PROGRESSION
-- ===========================

function ZoneManager:GetNextZone(player: Player): table?
	local data = self.DataManager:GetData(player)
	if not data then return nil end
	
	-- Find the first locked zone
	for _, zone in ipairs(GameConstants.Zones) do
		if not table.find(data.UnlockedZones, zone.Id) then
			return {
				Zone = zone,
				MeetsLevelReq = data.Level >= zone.LevelRequired,
				MeetsArtifactReq = data.ArtifactsCollected >= zone.ArtifactsRequired,
				LevelsNeeded = math.max(0, zone.LevelRequired - data.Level),
				ArtifactsNeeded = math.max(0, zone.ArtifactsRequired - data.ArtifactsCollected)
			}
		end
	end
	
	return nil -- All zones unlocked
end

function ZoneManager:GetZoneProgress(player: Player): table
	local data = self.DataManager:GetData(player)
	if not data then return {} end
	
	local progress = {
		TotalZones = #GameConstants.Zones,
		UnlockedCount = #data.UnlockedZones,
		LockedCount = #GameConstants.Zones - #data.UnlockedZones,
		PercentComplete = (#data.UnlockedZones / #GameConstants.Zones) * 100
	}
	
	return progress
end

-- ===========================
-- ZONE VALIDATION
-- ===========================

function ZoneManager:ValidateZoneStructure(): boolean
	local seenIds = {}
	
	for i, zone in ipairs(GameConstants.Zones) do
		-- Check required fields
		if not zone.Name or not zone.Id or not zone.LevelRequired or 
		   not zone.ArtifactsRequired or not zone.SpawnPosition then
			warn("[ZoneManager] Zone " .. i .. " missing required fields")
			return false
		end
		
		-- Check for duplicate IDs
		if seenIds[zone.Id] then
			warn("[ZoneManager] Duplicate zone ID: " .. zone.Id)
			return false
		end
		seenIds[zone.Id] = true
		
		-- Validate spawn position
		if typeof(zone.SpawnPosition) ~= "Vector3" then
			warn("[ZoneManager] Zone " .. zone.Id .. " has invalid SpawnPosition")
			return false
		end
	end
	
	return true
end

return ZoneManager
