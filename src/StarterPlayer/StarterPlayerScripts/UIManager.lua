--[[
	UIManager.lua
	
	Client-side UI management for player stats, notifications, and menus.
	Creates and updates UI elements dynamically.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local UIManager = {}
UIManager.ScreenGui = nil
UIManager.Elements = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function UIManager:Initialize(dataHandler)
	self.DataHandler = dataHandler
	
	print("[UIManager] Creating UI elements...")
	
	-- Wait for PlayerGui
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create main screen GUI
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "RelicRushUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = playerGui
	
	-- Create UI elements
	self:CreateStatsPanel()
	self:CreateNotificationArea()
	
	-- Setup update loop
	task.spawn(function()
		self:UpdateLoop()
	end)
	
	print("[UIManager] UI ready")
end

-- ===========================
-- STATS PANEL
-- ===========================

function UIManager:CreateStatsPanel()
	-- Main stats frame
	local statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsPanel"
	statsFrame.Size = UDim2.new(0, 250, 0, 150)
	statsFrame.Position = UDim2.new(0, 10, 0, 10)
	statsFrame.BackgroundColor3 = GameConstants.UI.Theme.Primary
	statsFrame.BackgroundTransparency = 0.3
	statsFrame.BorderSizePixel = 0
	
	-- Add corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = statsFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "Player Stats"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = statsFrame
	
	-- Level label
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(1, -20, 0, 25)
	levelLabel.Position = UDim2.new(0, 10, 0, 35)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level: 1"
	levelLabel.TextColor3 = GameConstants.UI.Theme.Accent
	levelLabel.TextSize = 16
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Parent = statsFrame
	
	-- Experience bar background
	local expBarBg = Instance.new("Frame")
	expBarBg.Name = "ExpBarBg"
	expBarBg.Size = UDim2.new(1, -20, 0, 20)
	expBarBg.Position = UDim2.new(0, 10, 0, 65)
	expBarBg.BackgroundColor3 = GameConstants.UI.Theme.Secondary
	expBarBg.BorderSizePixel = 0
	expBarBg.Parent = statsFrame
	
	local expBarCorner = Instance.new("UICorner")
	expBarCorner.CornerRadius = UDim.new(0, 4)
	expBarCorner.Parent = expBarBg
	
	-- Experience bar fill
	local expBarFill = Instance.new("Frame")
	expBarFill.Name = "ExpBarFill"
	expBarFill.Size = UDim2.new(0, 0, 1, 0)
	expBarFill.BackgroundColor3 = GameConstants.UI.Theme.Success
	expBarFill.BorderSizePixel = 0
	expBarFill.Parent = expBarBg
	
	local expFillCorner = Instance.new("UICorner")
	expFillCorner.CornerRadius = UDim.new(0, 4)
	expFillCorner.Parent = expBarFill
	
	-- Experience text
	local expText = Instance.new("TextLabel")
	expText.Name = "ExpText"
	expText.Size = UDim2.new(1, 0, 1, 0)
	expText.BackgroundTransparency = 1
	expText.Text = "0 / 100 XP"
	expText.TextColor3 = Color3.new(1, 1, 1)
	expText.TextSize = 12
	expText.Font = Enum.Font.GothamBold
	expText.Parent = expBarBg
	
	-- Artifacts collected label
	local artifactsLabel = Instance.new("TextLabel")
	artifactsLabel.Name = "ArtifactsLabel"
	artifactsLabel.Size = UDim2.new(1, -20, 0, 25)
	artifactsLabel.Position = UDim2.new(0, 10, 0, 95)
	artifactsLabel.BackgroundTransparency = 1
	artifactsLabel.Text = "Artifacts: 0"
	artifactsLabel.TextColor3 = Color3.new(1, 1, 1)
	artifactsLabel.TextSize = 14
	artifactsLabel.Font = Enum.Font.Gotham
	artifactsLabel.TextXAlignment = Enum.TextXAlignment.Left
	artifactsLabel.Parent = statsFrame
	
	-- Zones unlocked label
	local zonesLabel = Instance.new("TextLabel")
	zonesLabel.Name = "ZonesLabel"
	zonesLabel.Size = UDim2.new(1, -20, 0, 25)
	zonesLabel.Position = UDim2.new(0, 10, 0, 120)
	zonesLabel.BackgroundTransparency = 1
	zonesLabel.Text = "Zones: 1/6"
	zonesLabel.TextColor3 = Color3.new(1, 1, 1)
	zonesLabel.TextSize = 14
	zonesLabel.Font = Enum.Font.Gotham
	zonesLabel.TextXAlignment = Enum.TextXAlignment.Left
	zonesLabel.Parent = statsFrame
	
	statsFrame.Parent = self.ScreenGui
	self.Elements.StatsPanel = statsFrame
end

-- ===========================
-- NOTIFICATION AREA
-- ===========================

function UIManager:CreateNotificationArea()
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "NotificationArea"
	notificationFrame.Size = UDim2.new(0, 300, 0, 100)
	notificationFrame.Position = UDim2.new(1, -310, 0, 10)
	notificationFrame.BackgroundTransparency = 1
	notificationFrame.Parent = self.ScreenGui
	
	self.Elements.NotificationArea = notificationFrame
end

-- ===========================
-- UPDATE LOOP
-- ===========================

function UIManager:UpdateLoop()
	while true do
		task.wait(0.5)
		self:UpdateStatsDisplay()
	end
end

function UIManager:UpdateStatsDisplay()
	if not self.DataHandler then return end
	
	local statsPanel = self.Elements.StatsPanel
	if not statsPanel then return end
	
	-- Update level
	local levelLabel = statsPanel:FindFirstChild("LevelLabel")
	if levelLabel then
		levelLabel.Text = "Level: " .. self.DataHandler:GetLevel()
	end
	
	-- Update experience bar
	local expBarFill = statsPanel:FindFirstChild("ExpBarBg"):FindFirstChild("ExpBarFill")
	local expText = statsPanel:FindFirstChild("ExpBarBg"):FindFirstChild("ExpText")
	if expBarFill and expText then
		local currentExp = self.DataHandler:GetExperience()
		local requiredExp = self.DataHandler:GetExperienceToNextLevel()
		local progress = self.DataHandler:GetLevelProgress() / 100
		
		expBarFill.Size = UDim2.new(progress, 0, 1, 0)
		expText.Text = currentExp .. " / " .. requiredExp .. " XP"
	end
	
	-- Update artifacts
	local artifactsLabel = statsPanel:FindFirstChild("ArtifactsLabel")
	if artifactsLabel then
		artifactsLabel.Text = "Artifacts: " .. self.DataHandler:GetArtifactsCollected()
	end
	
	-- Update zones
	local zonesLabel = statsPanel:FindFirstChild("ZonesLabel")
	if zonesLabel then
		local unlockedZones = self.DataHandler:GetUnlockedZones()
		zonesLabel.Text = "Zones: " .. #unlockedZones .. "/6"
	end
end

-- ===========================
-- NOTIFICATIONS
-- ===========================

function UIManager:ShowNotification(title: string, message: string, duration: number?)
	duration = duration or 5
	
	local notificationArea = self.Elements.NotificationArea
	if not notificationArea then return end
	
	-- Create notification
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 60)
	notification.Position = UDim2.new(0, 0, 0, 0)
	notification.BackgroundColor3 = GameConstants.UI.Theme.Primary
	notification.BackgroundTransparency = 0.2
	notification.BorderSizePixel = 0
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notification
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -10, 0, 20)
	titleLabel.Position = UDim2.new(0, 5, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = GameConstants.UI.Theme.Accent
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notification
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -10, 0, 30)
	messageLabel.Position = UDim2.new(0, 5, 0, 25)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = Color3.new(1, 1, 1)
	messageLabel.TextSize = 12
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notification
	
	notification.Parent = notificationArea
	
	-- Auto-remove after duration
	task.delay(duration, function()
		if notification.Parent then
			notification:Destroy()
		end
	end)
end

return UIManager
