--[[
	ClientMain.lua
	
	Main client initialization script for Relic Rush game framework.
	Initializes all client-side systems and UI components.
	
	Author: Original Framework
	Created: 2026
--]]

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- ===========================
-- MODULE LOADING
-- ===========================

print("[ClientMain] Loading client modules...")

local ClientDataHandler = require(StarterPlayerScripts.ClientDataHandler)
local ArtifactVisualizer = require(StarterPlayerScripts.ArtifactVisualizer)
local ClientEventHandler = require(StarterPlayerScripts.ClientEventHandler)
local UIManager = require(StarterPlayerScripts.UIManager)

-- ===========================
-- SYSTEM INITIALIZATION
-- ===========================

print("[ClientMain] Initializing client systems...")

ClientDataHandler:Initialize()
ArtifactVisualizer:Initialize()
ClientEventHandler:Initialize()
UIManager:Initialize(ClientDataHandler)

print("[ClientMain] All client systems initialized successfully")

-- ===========================
-- CLIENT READY
-- ===========================

print("=====================================")
print("  RELIC RUSH - Client Ready")
print("=====================================")
print("  Welcome to the adventure!")
print("=====================================")
