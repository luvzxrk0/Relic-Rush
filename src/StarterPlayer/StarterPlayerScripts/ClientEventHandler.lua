--[[
	ClientEventHandler.lua
	
	Client-side global event handler.
	Receives event notifications and displays event UI.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local ClientEventHandler = {}
ClientEventHandler.CurrentEvent = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function ClientEventHandler:Initialize()
	print("[ClientEventHandler] Initializing event handler...")
	
	-- Listen for event start
	local eventStart = ReplicatedStorage:WaitForChild("GlobalEventStart")
	eventStart.OnClientEvent:Connect(function(eventData)
		self:OnEventStart(eventData)
	end)
	
	-- Listen for event end
	local eventEnd = ReplicatedStorage:WaitForChild("GlobalEventEnd")
	eventEnd.OnClientEvent:Connect(function(eventData)
		self:OnEventEnd(eventData)
	end)
	
	print("[ClientEventHandler] Event handler ready")
end

-- ===========================
-- EVENT HANDLING
-- ===========================

function ClientEventHandler:OnEventStart(eventData: table)
	self.CurrentEvent = eventData
	
	print("[ClientEventHandler] Global event started: " .. eventData.Name)
	
	-- Show event notification
	self:ShowEventNotification(eventData, true)
	
	-- Apply visual effects
	self:ApplyEventVisuals(eventData)
end

function ClientEventHandler:OnEventEnd(eventData: table)
	print("[ClientEventHandler] Global event ended: " .. eventData.Name)
	
	-- Show end notification
	self:ShowEventNotification(eventData, false)
	
	-- Remove visual effects
	self:RemoveEventVisuals()
	
	self.CurrentEvent = nil
end

-- ===========================
-- NOTIFICATIONS
-- ===========================

function ClientEventHandler:ShowEventNotification(eventData: table, isStart: boolean)
	-- Send notification to player
	local message = isStart and 
		"🎉 " .. eventData.Name .. " has started! " .. eventData.Description or
		"⏰ " .. eventData.Name .. " has ended!"
	
	StarterGui:SetCore("SendNotification", {
		Title = isStart and "Global Event Started!" or "Global Event Ended",
		Text = message,
		Duration = 5,
		Icon = ""
	})
end

-- ===========================
-- VISUAL EFFECTS
-- ===========================

function ClientEventHandler:ApplyEventVisuals(eventData: table)
	-- Apply special lighting or atmosphere for events
	local Lighting = game:GetService("Lighting")
	
	-- Store original values
	self.OriginalAmbient = Lighting.Ambient
	self.OriginalBrightness = Lighting.Brightness
	
	-- Modify based on event type
	if eventData.Name == "Artifact Storm" then
		Lighting.Ambient = Color3.fromRGB(100, 150, 200)
	elseif eventData.Name == "Mystic Hour" then
		Lighting.Ambient = Color3.fromRGB(150, 100, 200)
	elseif eventData.Name == "Rush Mode" then
		Lighting.Ambient = Color3.fromRGB(200, 150, 100)
	end
end

function ClientEventHandler:RemoveEventVisuals()
	-- Restore original lighting
	local Lighting = game:GetService("Lighting")
	
	if self.OriginalAmbient then
		Lighting.Ambient = self.OriginalAmbient
	end
	
	if self.OriginalBrightness then
		Lighting.Brightness = self.OriginalBrightness
	end
end

-- ===========================
-- EVENT QUERIES
-- ===========================

function ClientEventHandler:GetCurrentEvent(): table?
	return self.CurrentEvent
end

function ClientEventHandler:IsEventActive(): boolean
	return self.CurrentEvent ~= nil
end

function ClientEventHandler:GetEventModifiers(): table
	if not self.CurrentEvent then
		return {}
	end
	
	return self.CurrentEvent.Modifiers or {}
end

return ClientEventHandler
