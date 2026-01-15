--[[
	CosmeticManager.lua
	
	Server-authoritative cosmetic system for visual effects and customization.
	Handles trail effects, particle systems, and other visual enhancements.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local CosmeticManager = {}
CosmeticManager.DataManager = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function CosmeticManager:Initialize(dataManager)
	self.DataManager = dataManager
	
	print("[CosmeticManager] Initializing cosmetic system...")
	
	-- Setup remote events for cosmetic requests
	self:SetupRemoteEvents()
	
	-- Monitor player characters for cosmetic application
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self:ApplyPlayerCosmetics(player, character)
		end)
	end)
	
	print("[CosmeticManager] Cosmetic system ready")
end

-- ===========================
-- REMOTE EVENT SETUP
-- ===========================

function CosmeticManager:SetupRemoteEvents()
	-- Create remote event for equipping cosmetics
	local equipEvent = Instance.new("RemoteEvent")
	equipEvent.Name = "EquipCosmetic"
	equipEvent.Parent = ReplicatedStorage
	
	equipEvent.OnServerEvent:Connect(function(player, cosmeticType, cosmeticId)
		self:EquipCosmetic(player, cosmeticType, cosmeticId)
	end)
end

-- ===========================
-- COSMETIC UNLOCKING
-- ===========================

function CosmeticManager:IsCosmeticUnlocked(player: Player, cosmeticType: string, cosmeticId: string): boolean
	local data = self.DataManager:GetData(player)
	if not data then return false end
	
	if cosmeticType == "Trail" then
		-- Find trail in constants
		for _, trail in ipairs(GameConstants.Cosmetics.Trails) do
			if trail.Id == cosmeticId then
				-- Check if player meets level requirement
				return data.Level >= trail.UnlockLevel
			end
		end
	end
	
	return false
end

function CosmeticManager:GetUnlockedCosmetics(player: Player, cosmeticType: string): table
	local data = self.DataManager:GetData(player)
	if not data then return {} end
	
	local unlocked = {}
	
	if cosmeticType == "Trail" then
		for _, trail in ipairs(GameConstants.Cosmetics.Trails) do
			if data.Level >= trail.UnlockLevel then
				table.insert(unlocked, trail)
			end
		end
	end
	
	return unlocked
end

-- ===========================
-- COSMETIC EQUIPPING
-- ===========================

function CosmeticManager:EquipCosmetic(player: Player, cosmeticType: string, cosmeticId: string): boolean
	-- Verify cosmetic is unlocked
	if not self:IsCosmeticUnlocked(player, cosmeticType, cosmeticId) then
		warn("[CosmeticManager] Player " .. player.Name .. " tried to equip locked cosmetic: " .. cosmeticId)
		return false
	end
	
	-- Update data
	local success = self.DataManager:EquipCosmetic(player, cosmeticType, cosmeticId)
	
	if success then
		-- Apply cosmetic to character if it exists
		if player.Character then
			self:ApplyPlayerCosmetics(player, player.Character)
		end
		
		print("[CosmeticManager] Player " .. player.Name .. " equipped " .. cosmeticType .. ": " .. cosmeticId)
	end
	
	return success
end

-- ===========================
-- COSMETIC APPLICATION
-- ===========================

function CosmeticManager:ApplyPlayerCosmetics(player: Player, character: Model)
	local data = self.DataManager:GetData(player)
	if not data then return end
	
	-- Apply equipped trail
	if data.EquippedCosmetics.Trail then
		self:ApplyTrail(character, data.EquippedCosmetics.Trail)
	end
end

function CosmeticManager:ApplyTrail(character: Model, trailId: string)
	-- Find trail configuration
	local trailConfig = nil
	for _, trail in ipairs(GameConstants.Cosmetics.Trails) do
		if trail.Id == trailId then
			trailConfig = trail
			break
		end
	end
	
	if not trailConfig then return end
	
	-- Remove existing trails
	for _, child in ipairs(character:GetDescendants()) do
		if child:IsA("Trail") and child.Name == "PlayerTrail" then
			child:Destroy()
		end
	end
	
	-- Create new trail
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	-- Create attachment points
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(-0.5, -1, 0)
	attachment0.Parent = humanoidRootPart
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0.5, -1, 0)
	attachment1.Parent = humanoidRootPart
	
	-- Create trail
	local trail = Instance.new("Trail")
	trail.Name = "PlayerTrail"
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(trailConfig.Color)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 1
	trail.MinLength = 0.1
	trail.Parent = humanoidRootPart
end

-- ===========================
-- PARTICLE EFFECTS
-- ===========================

function CosmeticManager:CreateParticleEffect(parent: Instance, effectType: string, color: Color3)
	if effectType == "Sparkles" then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = color
		sparkles.Parent = parent
		return sparkles
	elseif effectType == "Glow" then
		local light = Instance.new("PointLight")
		light.Color = color
		light.Brightness = 2
		light.Range = 10
		light.Parent = parent
		return light
	elseif effectType == "Shimmer" or effectType == "Aura" or effectType == "RadiantAura" then
		-- Create particle emitter
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(color)
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0)
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.Rate = effectType == "RadiantAura" and 30 or (effectType == "Aura" and 20 or 10)
		emitter.Speed = NumberRange.new(2, 5)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Parent = parent
		return emitter
	end
	
	return nil
end

-- ===========================
-- COSMETIC QUERIES
-- ===========================

function CosmeticManager:GetCosmeticInfo(cosmeticType: string, cosmeticId: string): table?
	if cosmeticType == "Trail" then
		for _, trail in ipairs(GameConstants.Cosmetics.Trails) do
			if trail.Id == cosmeticId then
				return trail
			end
		end
	end
	
	return nil
end

function CosmeticManager:GetAllCosmetics(cosmeticType: string): table
	if cosmeticType == "Trail" then
		return GameConstants.Cosmetics.Trails
	end
	
	return {}
end

-- ===========================
-- PLAYER COSMETIC STATUS
-- ===========================

function CosmeticManager:GetPlayerCosmeticStatus(player: Player): table
	local data = self.DataManager:GetData(player)
	if not data then return {} end
	
	local status = {
		Equipped = data.EquippedCosmetics,
		UnlockedTrails = self:GetUnlockedCosmetics(player, "Trail"),
		TotalTrails = #GameConstants.Cosmetics.Trails
	}
	
	return status
end

return CosmeticManager
