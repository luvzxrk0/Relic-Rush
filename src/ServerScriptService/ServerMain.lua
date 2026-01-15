--[[
	ServerMain.lua
	
	Main server initialization script for Relic Rush game framework.
	Initializes all server-side systems in correct order and manages dependencies.
	
	Author: Original Framework
	Created: 2026
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===========================
-- MODULE LOADING
-- ===========================

print("[ServerMain] Loading server modules...")

local DataManager = require(ServerScriptService.DataManager)
local RewardSystem = require(ServerScriptService.RewardSystem)
local ZoneManager = require(ServerScriptService.ZoneManager)
local EventManager = require(ServerScriptService.EventManager)
local ArtifactSpawner = require(ServerScriptService.ArtifactSpawner)
local CosmeticManager = require(ServerScriptService.CosmeticManager)

-- ===========================
-- CREATE REMOTE EVENTS
-- ===========================

print("[ServerMain] Creating remote events...")

local function createRemoteEvent(name: string)
	if not ReplicatedStorage:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = ReplicatedStorage
		return event
	end
	return ReplicatedStorage:FindFirstChild(name)
end

-- Create all necessary remote events
createRemoteEvent("DataReplication")
createRemoteEvent("LevelUpEvent")
createRemoteEvent("ZoneUnlocked")
createRemoteEvent("GlobalEventStart")
createRemoteEvent("GlobalEventEnd")
createRemoteEvent("CollectArtifact")
createRemoteEvent("ArtifactCollected")
createRemoteEvent("ArtifactSpawned")
createRemoteEvent("ArtifactRemoved")
createRemoteEvent("EquipCosmetic")

print("[ServerMain] Remote events created")

-- ===========================
-- SYSTEM INITIALIZATION
-- ===========================

print("[ServerMain] Initializing game systems...")

-- Initialize in dependency order
DataManager:Initialize()
ZoneManager:Initialize(DataManager)
EventManager:Initialize()
CosmeticManager:Initialize(DataManager)
ArtifactSpawner:Initialize(DataManager, RewardSystem, EventManager)

print("[ServerMain] All systems initialized successfully")

-- ===========================
-- SERVER READY
-- ===========================

print("=====================================")
print("  RELIC RUSH - Server Ready")
print("=====================================")
print("  All systems operational")
print("  Framework version: 1.0.0")
print("=====================================")
