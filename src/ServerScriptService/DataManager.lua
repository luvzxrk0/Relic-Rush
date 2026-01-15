--[[
	DataManager.lua
	
	Server-authoritative data management system for player persistence.
	Compatible with ProfileService for production use.
	Handles loading, saving, and managing player data with retry logic.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local DataManager = {}
DataManager.Profiles = {}
DataManager.ProfileService = nil -- Will be set to ProfileService if available

-- ===========================
-- INITIALIZATION
-- ===========================

function DataManager:Initialize()
	-- In production, this would use ProfileService
	-- For this framework, we'll use a mock implementation
	print("[DataManager] Initializing data system...")
	
	-- Connect to player events
	Players.PlayerAdded:Connect(function(player)
		self:LoadPlayerData(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:SavePlayerData(player)
	end)
	
	-- Auto-save loop
	task.spawn(function()
		while true do
			task.wait(GameConstants.DataSettings.AutoSaveInterval)
			self:SaveAllPlayerData()
		end
	end)
	
	print("[DataManager] Data system ready")
end

-- ===========================
-- DATA LOADING
-- ===========================

function DataManager:LoadPlayerData(player: Player)
	print("[DataManager] Loading data for player:", player.Name)
	
	local attempts = 0
	local success = false
	local profile = nil
	
	-- Retry logic for data loading
	while attempts < GameConstants.DataSettings.MaxLoadRetries and not success do
		attempts += 1
		
		local loadSuccess, errorMsg = pcall(function()
			-- In production, this would use ProfileService
			-- For now, create a new profile from template
			profile = self:CreateProfileFromTemplate(player)
		end)
		
		if loadSuccess then
			success = true
			self.Profiles[player] = profile
			
			-- Update last login time
			profile.Data.LastLogin = os.time()
			profile.Data.Statistics.SessionCount += 1
			
			-- Replicate initial data to client
			self:ReplicateDataToClient(player)
			
			print("[DataManager] Successfully loaded data for:", player.Name)
		else
			warn("[DataManager] Failed to load data (attempt " .. attempts .. "):", errorMsg)
			task.wait(1)
		end
	end
	
	if not success then
		-- If data loading fails, kick the player
		player:Kick("Failed to load your data. Please rejoin.")
	end
end

-- ===========================
-- PROFILE CREATION
-- ===========================

function DataManager:CreateProfileFromTemplate(player: Player)
	-- Deep copy the template
	local profileData = {}
	
	for key, value in pairs(GameConstants.DataSettings.ProfileTemplate) do
		if typeof(value) == "table" then
			profileData[key] = self:DeepCopyTable(value)
		else
			profileData[key] = value
		end
	end
	
	-- Create profile object
	local profile = {
		Data = profileData,
		Player = player,
		LastSave = os.time()
	}
	
	return profile
end

-- ===========================
-- DATA SAVING
-- ===========================

function DataManager:SavePlayerData(player: Player)
	local profile = self.Profiles[player]
	if not profile then return end
	
	local success, errorMsg = pcall(function()
		-- In production, this would save to ProfileService DataStore
		profile.LastSave = os.time()
		print("[DataManager] Saved data for:", player.Name)
	end)
	
	if not success then
		warn("[DataManager] Failed to save data for " .. player.Name .. ":", errorMsg)
	end
	
	-- Clean up profile on player leave
	self.Profiles[player] = nil
end

function DataManager:SaveAllPlayerData()
	for player, profile in pairs(self.Profiles) do
		if player and player.Parent then
			local success, errorMsg = pcall(function()
				profile.LastSave = os.time()
			end)
			
			if not success then
				warn("[DataManager] Auto-save failed for " .. player.Name .. ":", errorMsg)
			end
		end
	end
end

-- ===========================
-- DATA GETTERS
-- ===========================

function DataManager:GetProfile(player: Player)
	return self.Profiles[player]
end

function DataManager:GetData(player: Player)
	local profile = self.Profiles[player]
	return profile and profile.Data or nil
end

-- ===========================
-- DATA SETTERS (Server-Authoritative)
-- ===========================

function DataManager:AddExperience(player: Player, amount: number)
	local data = self:GetData(player)
	if not data then return false end
	
	data.Experience += amount
	
	-- Check for level up
	while data.Experience >= self:GetExperienceRequired(data.Level) do
		if data.Level < GameConstants.Progression.MaxLevel then
			data.Experience -= self:GetExperienceRequired(data.Level)
			data.Level += 1
			
			-- Fire level up event
			self:OnLevelUp(player, data.Level)
		else
			-- Max level reached, cap experience
			data.Experience = self:GetExperienceRequired(data.Level)
			break
		end
	end
	
	self:ReplicateDataToClient(player)
	return true
end

function DataManager:AddArtifact(player: Player, rarity: string)
	local data = self:GetData(player)
	if not data then return false end
	
	-- Increment counters
	data.ArtifactsCollected += 1
	data.Statistics.ArtifactsByRarity[rarity] = (data.Statistics.ArtifactsByRarity[rarity] or 0) + 1
	
	-- Add to inventory
	table.insert(data.Inventory, {
		Rarity = rarity,
		Timestamp = os.time()
	})
	
	-- Award experience based on rarity
	local expGain = GameConstants.Progression.ExperiencePerArtifact[rarity] or 0
	self:AddExperience(player, expGain)
	
	self:ReplicateDataToClient(player)
	return true
end

function DataManager:UnlockZone(player: Player, zoneId: string)
	local data = self:GetData(player)
	if not data then return false end
	
	-- Check if already unlocked
	if table.find(data.UnlockedZones, zoneId) then
		return false
	end
	
	-- Add to unlocked zones
	table.insert(data.UnlockedZones, zoneId)
	
	self:ReplicateDataToClient(player)
	return true
end

function DataManager:EquipCosmetic(player: Player, cosmeticType: string, cosmeticId: string)
	local data = self:GetData(player)
	if not data then return false end
	
	data.EquippedCosmetics[cosmeticType] = cosmeticId
	
	self:ReplicateDataToClient(player)
	return true
end

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

function DataManager:GetExperienceRequired(level: number): number
	return math.floor(
		GameConstants.Progression.BaseExperienceRequired * 
		(GameConstants.Progression.ExperienceMultiplier ^ (level - 1))
	)
end

function DataManager:OnLevelUp(player: Player, newLevel: number)
	print("[DataManager] Player " .. player.Name .. " reached level " .. newLevel)
	
	-- Check for zone unlocks
	for _, zone in ipairs(GameConstants.Zones) do
		local data = self:GetData(player)
		if not data then continue end
		
		if newLevel >= zone.LevelRequired and 
		   data.ArtifactsCollected >= zone.ArtifactsRequired and
		   not table.find(data.UnlockedZones, zone.Id) then
			self:UnlockZone(player, zone.Id)
		end
	end
	
	-- Fire remote event to client for celebration
	local remoteEvent = ReplicatedStorage:FindFirstChild("LevelUpEvent")
	if remoteEvent then
		remoteEvent:FireClient(player, newLevel)
	end
end

function DataManager:ReplicateDataToClient(player: Player)
	local data = self:GetData(player)
	if not data then return end
	
	-- Create a safe copy for client (remove sensitive data if needed)
	local clientData = {}
	for key, value in pairs(data) do
		clientData[key] = value
	end
	
	-- Fire to client
	local remoteEvent = ReplicatedStorage:FindFirstChild("DataReplication")
	if remoteEvent then
		remoteEvent:FireClient(player, clientData)
	end
end

function DataManager:DeepCopyTable(original)
	local copy = {}
	for key, value in pairs(original) do
		if typeof(value) == "table" then
			copy[key] = self:DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return DataManager
