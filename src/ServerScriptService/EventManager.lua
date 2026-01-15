--[[
	EventManager.lua
	
	Server-authoritative global events system with timed events.
	Manages event scheduling, activation, and deactivation.
	
	Author: Original Framework
	Created: 2026
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local EventManager = {}
EventManager.ActiveEvent = nil
EventManager.LastEventTime = 0
EventManager.EventHistory = {}

local rng = Random.new()

-- ===========================
-- INITIALIZATION
-- ===========================

function EventManager:Initialize()
	print("[EventManager] Initializing global events system...")
	
	-- Start event scheduling loop
	task.spawn(function()
		self:EventSchedulingLoop()
	end)
	
	print("[EventManager] Global events system ready")
end

-- ===========================
-- EVENT SCHEDULING
-- ===========================

function EventManager:EventSchedulingLoop()
	while true do
		task.wait(60) -- Check every minute
		
		-- Skip if event is currently active
		if self.ActiveEvent then
			continue
		end
		
		-- Check if enough time has passed since last event
		local timeSinceLastEvent = os.time() - self.LastEventTime
		if timeSinceLastEvent < GameConstants.GlobalEvents.MinTimeBetweenEvents then
			continue
		end
		
		-- Try to start a random event
		self:TryStartRandomEvent()
	end
end

function EventManager:TryStartRandomEvent()
	-- Get available events (not on cooldown)
	local availableEvents = self:GetAvailableEvents()
	
	if #availableEvents == 0 then
		return false
	end
	
	-- Select random event
	local selectedEvent = availableEvents[rng:NextInteger(1, #availableEvents)]
	
	-- Start the event
	self:StartEvent(selectedEvent.Id)
	
	return true
end

-- ===========================
-- EVENT CONTROL
-- ===========================

function EventManager:StartEvent(eventId: string)
	local eventConfig = self:GetEventById(eventId)
	if not eventConfig then
		warn("[EventManager] Event not found: " .. eventId)
		return false
	end
	
	-- Don't start if event already active
	if self.ActiveEvent then
		return false
	end
	
	-- Create active event instance
	self.ActiveEvent = {
		Config = eventConfig,
		StartTime = os.time(),
		EndTime = os.time() + eventConfig.Duration
	}
	
	-- Record in history
	table.insert(self.EventHistory, {
		EventId = eventId,
		StartTime = os.time()
	})
	
	-- Broadcast to all players
	self:BroadcastEventStart(eventConfig)
	
	print("[EventManager] Started global event: " .. eventConfig.Name)
	
	-- Schedule event end
	task.delay(eventConfig.Duration, function()
		self:EndEvent()
	end)
	
	return true
end

function EventManager:EndEvent()
	if not self.ActiveEvent then
		return
	end
	
	local eventConfig = self.ActiveEvent.Config
	
	-- Broadcast event end
	self:BroadcastEventEnd(eventConfig)
	
	print("[EventManager] Ended global event: " .. eventConfig.Name)
	
	-- Clear active event
	self.ActiveEvent = nil
	self.LastEventTime = os.time()
end

-- ===========================
-- EVENT QUERIES
-- ===========================

function EventManager:GetEventById(eventId: string): table?
	for _, event in ipairs(GameConstants.GlobalEvents.Events) do
		if event.Id == eventId then
			return event
		end
	end
	return nil
end

function EventManager:GetActiveEvent(): table?
	return self.ActiveEvent
end

function EventManager:IsEventActive(): boolean
	return self.ActiveEvent ~= nil
end

function EventManager:GetEventModifiers(): table
	if not self.ActiveEvent then
		return {}
	end
	
	local config = self.ActiveEvent.Config
	local modifiers = {}
	
	if config.RewardMultiplier then
		modifiers.RewardMultiplier = config.RewardMultiplier
	end
	
	if config.RarityBoost then
		modifiers.RarityBoost = config.RarityBoost
	end
	
	if config.ExperienceMultiplier then
		modifiers.ExperienceMultiplier = config.ExperienceMultiplier
	end
	
	return modifiers
end

function EventManager:GetAvailableEvents(): table
	local available = {}
	local currentTime = os.time()
	
	for _, event in ipairs(GameConstants.GlobalEvents.Events) do
		-- Check if event is on cooldown
		local lastActivation = self:GetLastActivationTime(event.Id)
		
		if not lastActivation or (currentTime - lastActivation) >= event.Cooldown then
			table.insert(available, event)
		end
	end
	
	return available
end

function EventManager:GetLastActivationTime(eventId: string): number?
	-- Search history in reverse for most recent activation
	for i = #self.EventHistory, 1, -1 do
		if self.EventHistory[i].EventId == eventId then
			return self.EventHistory[i].StartTime
		end
	end
	return nil
end

-- ===========================
-- EVENT BROADCASTING
-- ===========================

function EventManager:BroadcastEventStart(eventConfig: table)
	local remoteEvent = ReplicatedStorage:FindFirstChild("GlobalEventStart")
	if remoteEvent then
		remoteEvent:FireAllClients({
			Name = eventConfig.Name,
			Description = eventConfig.Description,
			Duration = eventConfig.Duration,
			Modifiers = {
				RewardMultiplier = eventConfig.RewardMultiplier,
				RarityBoost = eventConfig.RarityBoost,
				ExperienceMultiplier = eventConfig.ExperienceMultiplier
			}
		})
	end
end

function EventManager:BroadcastEventEnd(eventConfig: table)
	local remoteEvent = ReplicatedStorage:FindFirstChild("GlobalEventEnd")
	if remoteEvent then
		remoteEvent:FireAllClients({
			Name = eventConfig.Name
		})
	end
end

-- ===========================
-- EVENT STATISTICS
-- ===========================

function EventManager:GetEventStatistics(): table
	local stats = {}
	
	for _, event in ipairs(GameConstants.GlobalEvents.Events) do
		local activationCount = 0
		local lastActivation = nil
		
		for _, history in ipairs(self.EventHistory) do
			if history.EventId == event.Id then
				activationCount += 1
				if not lastActivation or history.StartTime > lastActivation then
					lastActivation = history.StartTime
				end
			end
		end
		
		stats[event.Id] = {
			Name = event.Name,
			ActivationCount = activationCount,
			LastActivation = lastActivation,
			IsAvailable = table.find(self:GetAvailableEvents(), event) ~= nil
		}
	end
	
	return stats
end

function EventManager:GetTimeUntilNextEvent(): number?
	if self.ActiveEvent then
		return self.ActiveEvent.EndTime - os.time()
	end
	
	local timeSinceLastEvent = os.time() - self.LastEventTime
	local timeUntilMinMet = GameConstants.GlobalEvents.MinTimeBetweenEvents - timeSinceLastEvent
	
	if timeUntilMinMet > 0 then
		return timeUntilMinMet
	end
	
	-- Events can happen anytime now
	return 0
end

-- ===========================
-- ADMIN COMMANDS
-- ===========================

function EventManager:ForceStartEvent(eventId: string): boolean
	-- For testing/admin purposes
	return self:StartEvent(eventId)
end

function EventManager:ForceEndEvent()
	-- For testing/admin purposes
	self:EndEvent()
end

return EventManager
