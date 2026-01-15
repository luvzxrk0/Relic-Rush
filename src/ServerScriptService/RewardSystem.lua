--[[
	RewardSystem.lua
	
	Server-authoritative reward generation system with weighted rarities.
	Handles random artifact generation, rarity calculation, and reward distribution.
	
	Author: Original Framework
	Created: 2026
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local RewardSystem = {}

-- Random number generator seed
local rng = Random.new()

-- ===========================
-- RARITY CALCULATION
-- ===========================

function RewardSystem:CalculateRarity(rarityBoost: number?)
	rarityBoost = rarityBoost or 0
	
	-- Calculate total weight
	local totalWeight = 0
	for _, weight in pairs(GameConstants.Rarities.Weights) do
		totalWeight += weight
	end
	
	-- Generate random number
	local roll = rng:NextInteger(1, totalWeight)
	
	-- Determine rarity based on weight
	local currentWeight = 0
	local selectedRarity = "Common"
	
	for _, rarityName in ipairs(GameConstants.Rarities.Order) do
		currentWeight += GameConstants.Rarities.Weights[rarityName]
		if roll <= currentWeight then
			selectedRarity = rarityName
			break
		end
	end
	
	-- Apply rarity boost (shift up tiers)
	if rarityBoost > 0 then
		selectedRarity = self:BoostRarity(selectedRarity, rarityBoost)
	end
	
	return selectedRarity
end

-- ===========================
-- RARITY BOOSTING
-- ===========================

function RewardSystem:BoostRarity(currentRarity: string, boostAmount: number): string
	local currentIndex = table.find(GameConstants.Rarities.Order, currentRarity)
	if not currentIndex then return currentRarity end
	
	local newIndex = math.min(currentIndex + boostAmount, #GameConstants.Rarities.Order)
	return GameConstants.Rarities.Order[newIndex]
end

-- ===========================
-- REWARD GENERATION
-- ===========================

function RewardSystem:GenerateArtifact(zoneId: string, eventModifiers: table?)
	eventModifiers = eventModifiers or {}
	
	-- Calculate rarity with potential event boost
	local rarityBoost = eventModifiers.RarityBoost or 0
	local rarity = self:CalculateRarity(rarityBoost)
	
	-- Create artifact data
	local artifact = {
		Id = self:GenerateUniqueId(),
		Rarity = rarity,
		ZoneId = zoneId,
		GeneratedAt = os.time(),
		Color = GameConstants.Rarities.Colors[rarity],
		ParticleEffect = GameConstants.Cosmetics.ParticleEffects[rarity]
	}
	
	return artifact
end

-- ===========================
-- BATCH GENERATION
-- ===========================

function RewardSystem:GenerateArtifactBatch(count: number, zoneId: string, eventModifiers: table?): table
	local artifacts = {}
	
	for i = 1, count do
		table.insert(artifacts, self:GenerateArtifact(zoneId, eventModifiers))
	end
	
	return artifacts
end

-- ===========================
-- REWARD VALIDATION
-- ===========================

function RewardSystem:ValidateReward(artifact: table): boolean
	-- Verify artifact has required fields
	if not artifact.Id or not artifact.Rarity or not artifact.ZoneId then
		return false
	end
	
	-- Verify rarity is valid
	if not GameConstants.Rarities.Weights[artifact.Rarity] then
		return false
	end
	
	return true
end

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

function RewardSystem:GenerateUniqueId(): string
	-- Generate a unique identifier using timestamp and random number
	local timestamp = os.time()
	local randomPart = rng:NextInteger(1000, 9999)
	return string.format("artifact_%d_%d", timestamp, randomPart)
end

function RewardSystem:GetRarityColor(rarity: string): Color3
	return GameConstants.Rarities.Colors[rarity] or GameConstants.Rarities.Colors.Common
end

function RewardSystem:GetRarityWeight(rarity: string): number
	return GameConstants.Rarities.Weights[rarity] or 0
end

-- ===========================
-- STATISTICS
-- ===========================

function RewardSystem:CalculateDropChance(rarity: string): number
	local weight = self:GetRarityWeight(rarity)
	local totalWeight = 0
	
	for _, w in pairs(GameConstants.Rarities.Weights) do
		totalWeight += w
	end
	
	return (weight / totalWeight) * 100
end

function RewardSystem:GetRarityStatistics(): table
	local stats = {}
	
	for _, rarity in ipairs(GameConstants.Rarities.Order) do
		stats[rarity] = {
			Weight = self:GetRarityWeight(rarity),
			DropChance = self:CalculateDropChance(rarity),
			Color = self:GetRarityColor(rarity)
		}
	end
	
	return stats
end

return RewardSystem
