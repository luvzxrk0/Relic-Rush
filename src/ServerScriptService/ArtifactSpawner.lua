--[[
	ArtifactSpawner.lua
	
	Server-authoritative artifact spawning and collection system.
	Handles spawning artifacts in zones and processing player collections.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local ArtifactSpawner = {}
ArtifactSpawner.DataManager = nil
ArtifactSpawner.RewardSystem = nil
ArtifactSpawner.EventManager = nil
ArtifactSpawner.ActiveArtifacts = {} -- [artifactId] = artifactData

-- ===========================
-- INITIALIZATION
-- ===========================

function ArtifactSpawner:Initialize(dataManager, rewardSystem, eventManager)
	self.DataManager = dataManager
	self.RewardSystem = rewardSystem
	self.EventManager = eventManager
	
	print("[ArtifactSpawner] Initializing artifact spawning system...")
	
	-- Start spawning loop
	task.spawn(function()
		self:SpawningLoop()
	end)
	
	-- Setup collection detection
	self:SetupCollectionDetection()
	
	print("[ArtifactSpawner] Artifact spawning system ready")
end

-- ===========================
-- SPAWNING LOOP
-- ===========================

function ArtifactSpawner:SpawningLoop()
	while true do
		-- Get base spawn interval
		local spawnInterval = GameConstants.Gameplay.ArtifactSpawnInterval
		
		-- Modify based on active events
		local eventModifiers = self.EventManager:GetEventModifiers()
		if eventModifiers.RewardMultiplier then
			spawnInterval = spawnInterval / eventModifiers.RewardMultiplier
		end
		
		task.wait(spawnInterval)
		
		-- Spawn artifacts in each zone
		for _, zone in ipairs(GameConstants.Zones) do
			self:TrySpawnArtifact(zone.Id)
		end
	end
end

-- ===========================
-- ARTIFACT SPAWNING
-- ===========================

function ArtifactSpawner:TrySpawnArtifact(zoneId: string): boolean
	-- Count current artifacts in this zone
	local artifactsInZone = 0
	for _, artifact in pairs(self.ActiveArtifacts) do
		if artifact.ZoneId == zoneId then
			artifactsInZone += 1
		end
	end
	
	-- Check if zone has reached max artifacts
	if artifactsInZone >= GameConstants.Gameplay.MaxArtifactsPerZone then
		return false
	end
	
	-- Generate artifact with event modifiers
	local eventModifiers = self.EventManager:GetEventModifiers()
	local artifact = self.RewardSystem:GenerateArtifact(zoneId, eventModifiers)
	
	-- Store active artifact
	self.ActiveArtifacts[artifact.Id] = artifact
	
	-- Get zone info for spawn position
	local zone = nil
	for _, z in ipairs(GameConstants.Zones) do
		if z.Id == zoneId then
			zone = z
			break
		end
	end
	
	if zone then
		-- Add random offset to spawn position
		local offsetX = math.random(-40, 40)
		local offsetZ = math.random(-40, 40)
		artifact.Position = zone.SpawnPosition + Vector3.new(offsetX, 0, offsetZ)
	end
	
	-- Notify clients to create visual representation
	self:BroadcastArtifactSpawn(artifact)
	
	return true
end

-- ===========================
-- ARTIFACT COLLECTION
-- ===========================

function ArtifactSpawner:SetupCollectionDetection()
	-- Create remote event for collection
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "CollectArtifact"
	remoteEvent.Parent = ReplicatedStorage
	
	remoteEvent.OnServerEvent:Connect(function(player, artifactId)
		self:AttemptCollection(player, artifactId)
	end)
end

function ArtifactSpawner:AttemptCollection(player: Player, artifactId: string): boolean
	-- Verify artifact exists
	local artifact = self.ActiveArtifacts[artifactId]
	if not artifact then
		warn("[ArtifactSpawner] Artifact not found: " .. artifactId)
		return false
	end
	
	-- Verify player character exists
	local character = player.Character
	if not character then
		return false
	end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false
	end
	
	-- Verify distance (anti-cheat)
	if artifact.Position then
		local distance = (humanoidRootPart.Position - artifact.Position).Magnitude
		if distance > GameConstants.Gameplay.ArtifactCollectionRange then
			warn("[ArtifactSpawner] Player " .. player.Name .. " too far from artifact")
			return false
		end
	end
	
	-- Process collection
	local success = self.DataManager:AddArtifact(player, artifact.Rarity)
	
	if success then
		-- Remove from active artifacts
		self.ActiveArtifacts[artifactId] = nil
		
		-- Broadcast removal to all clients
		self:BroadcastArtifactCollected(artifactId, player.UserId)
		
		-- Get experience multiplier from active events
		local eventModifiers = self.EventManager:GetEventModifiers()
		local expMultiplier = eventModifiers.ExperienceMultiplier or 1
		
		-- Send collection confirmation to player
		local remoteEvent = ReplicatedStorage:FindFirstChild("ArtifactCollected")
		if remoteEvent then
			remoteEvent:FireClient(player, {
				Rarity = artifact.Rarity,
				ExperienceGained = GameConstants.Progression.ExperiencePerArtifact[artifact.Rarity] * expMultiplier,
				Color = artifact.Color
			})
		end
		
		print("[ArtifactSpawner] Player " .. player.Name .. " collected " .. artifact.Rarity .. " artifact")
	end
	
	return success
end

-- ===========================
-- BROADCASTING
-- ===========================

function ArtifactSpawner:BroadcastArtifactSpawn(artifact: table)
	local remoteEvent = ReplicatedStorage:FindFirstChild("ArtifactSpawned")
	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "ArtifactSpawned"
		remoteEvent.Parent = ReplicatedStorage
	end
	
	remoteEvent:FireAllClients({
		Id = artifact.Id,
		Rarity = artifact.Rarity,
		ZoneId = artifact.ZoneId,
		Position = artifact.Position,
		Color = artifact.Color,
		ParticleEffect = artifact.ParticleEffect
	})
end

function ArtifactSpawner:BroadcastArtifactCollected(artifactId: string, collectorUserId: number)
	local remoteEvent = ReplicatedStorage:FindFirstChild("ArtifactRemoved")
	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "ArtifactRemoved"
		remoteEvent.Parent = ReplicatedStorage
	end
	
	remoteEvent:FireAllClients(artifactId, collectorUserId)
end

-- ===========================
-- MANAGEMENT
-- ===========================

function ArtifactSpawner:RemoveArtifact(artifactId: string)
	if self.ActiveArtifacts[artifactId] then
		self.ActiveArtifacts[artifactId] = nil
		self:BroadcastArtifactCollected(artifactId, 0)
	end
end

function ArtifactSpawner:ClearAllArtifacts()
	for artifactId, _ in pairs(self.ActiveArtifacts) do
		self:RemoveArtifact(artifactId)
	end
end

function ArtifactSpawner:GetActiveArtifactCount(): number
	local count = 0
	for _, _ in pairs(self.ActiveArtifacts) do
		count += 1
	end
	return count
end

function ArtifactSpawner:GetZoneArtifactCount(zoneId: string): number
	local count = 0
	for _, artifact in pairs(self.ActiveArtifacts) do
		if artifact.ZoneId == zoneId then
			count += 1
		end
	end
	return count
end

-- ===========================
-- STATISTICS
-- ===========================

function ArtifactSpawner:GetSpawnerStatistics(): table
	local stats = {
		TotalActiveArtifacts = self:GetActiveArtifactCount(),
		ArtifactsByZone = {},
		ArtifactsByRarity = {}
	}
	
	for _, artifact in pairs(self.ActiveArtifacts) do
		-- Count by zone
		stats.ArtifactsByZone[artifact.ZoneId] = (stats.ArtifactsByZone[artifact.ZoneId] or 0) + 1
		
		-- Count by rarity
		stats.ArtifactsByRarity[artifact.Rarity] = (stats.ArtifactsByRarity[artifact.Rarity] or 0) + 1
	end
	
	return stats
end

return ArtifactSpawner
