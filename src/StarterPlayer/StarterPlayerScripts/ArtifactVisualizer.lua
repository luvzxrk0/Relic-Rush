--[[
	ArtifactVisualizer.lua
	
	Client-side artifact visualization and collection interaction.
	Creates 3D representations of artifacts and handles collection input.
	
	Author: Original Framework
	Created: 2026
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local GameConstants = require(ReplicatedStorage.Modules.GameConstants)

local ArtifactVisualizer = {}
ArtifactVisualizer.ActiveArtifacts = {} -- [artifactId] = partInstance

-- ===========================
-- INITIALIZATION
-- ===========================

function ArtifactVisualizer:Initialize()
	print("[ArtifactVisualizer] Initializing artifact visualizer...")
	
	-- Create artifacts folder in workspace
	if not Workspace:FindFirstChild("Artifacts") then
		local folder = Instance.new("Folder")
		folder.Name = "Artifacts"
		folder.Parent = Workspace
	end
	
	-- Listen for artifact spawns
	local artifactSpawned = ReplicatedStorage:WaitForChild("ArtifactSpawned")
	artifactSpawned.OnClientEvent:Connect(function(artifactData)
		self:CreateArtifactVisual(artifactData)
	end)
	
	-- Listen for artifact removals
	local artifactRemoved = ReplicatedStorage:WaitForChild("ArtifactRemoved")
	artifactRemoved.OnClientEvent:Connect(function(artifactId, collectorUserId)
		self:RemoveArtifactVisual(artifactId)
	end)
	
	-- Listen for successful collections
	local artifactCollected = ReplicatedStorage:WaitForChild("ArtifactCollected")
	artifactCollected.OnClientEvent:Connect(function(collectionData)
		self:OnArtifactCollected(collectionData)
	end)
	
	-- Setup collection input
	self:SetupCollectionInput()
	
	print("[ArtifactVisualizer] Artifact visualizer ready")
end

-- ===========================
-- VISUAL CREATION
-- ===========================

function ArtifactVisualizer:CreateArtifactVisual(artifactData: table)
	-- Create artifact part
	local artifact = Instance.new("Part")
	artifact.Name = "Artifact_" .. artifactData.Id
	artifact.Size = Vector3.new(2, 2, 2)
	artifact.Position = artifactData.Position
	artifact.Anchored = true
	artifact.CanCollide = false
	artifact.Color = artifactData.Color
	artifact.Material = Enum.Material.Neon
	artifact.Shape = Enum.PartType.Ball
	
	-- Add rotation
	local rotation = Instance.new("BodyAngularVelocity")
	rotation.AngularVelocity = Vector3.new(0, 2, 0)
	rotation.MaxTorque = Vector3.new(0, math.huge, 0)
	rotation.Parent = artifact
	
	-- Add bobbing animation
	task.spawn(function()
		local startY = artifactData.Position.Y
		local time = 0
		while artifact.Parent do
			time += 0.05
			artifact.Position = Vector3.new(
				artifactData.Position.X,
				startY + math.sin(time * 2) * 0.5,
				artifactData.Position.Z
			)
			task.wait(0.05)
		end
	end)
	
	-- Add particle effects if specified
	if artifactData.ParticleEffect then
		self:AddParticleEffect(artifact, artifactData.ParticleEffect, artifactData.Color)
	end
	
	-- Add proximity prompt for collection
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect " .. artifactData.Rarity .. " Artifact"
	prompt.ObjectText = artifactData.Rarity
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = GameConstants.Gameplay.ArtifactCollectionRange
	prompt.Parent = artifact
	
	-- Handle collection trigger
	prompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == LocalPlayer then
			self:RequestCollection(artifactData.Id)
		end
	end)
	
	-- Store reference
	self.ActiveArtifacts[artifactData.Id] = artifact
	
	-- Parent to workspace
	artifact.Parent = Workspace.Artifacts
end

-- ===========================
-- PARTICLE EFFECTS
-- ===========================

function ArtifactVisualizer:AddParticleEffect(parent: Instance, effectType: string, color: Color3)
	if effectType == "Sparkles" then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = color
		sparkles.Parent = parent
	elseif effectType == "Glow" then
		local light = Instance.new("PointLight")
		light.Color = color
		light.Brightness = 3
		light.Range = 15
		light.Parent = parent
	else
		-- Create particle emitter for other effects
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(color)
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0)
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		emitter.Lifetime = NumberRange.new(0.5, 1.5)
		emitter.Rate = 20
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(360, 360)
		emitter.Parent = parent
	end
end

-- ===========================
-- COLLECTION
-- ===========================

function ArtifactVisualizer:SetupCollectionInput()
	-- Collection is now handled by ProximityPrompt
	-- This method can be used for additional input handling if needed
end

function ArtifactVisualizer:RequestCollection(artifactId: string)
	-- Send collection request to server
	local collectEvent = ReplicatedStorage:FindFirstChild("CollectArtifact")
	if collectEvent then
		collectEvent:FireServer(artifactId)
	end
end

function ArtifactVisualizer:OnArtifactCollected(collectionData: table)
	print("[ArtifactVisualizer] Collected " .. collectionData.Rarity .. " artifact!")
	
	-- Show collection feedback
	self:ShowCollectionEffect(collectionData)
end

-- ===========================
-- VISUAL REMOVAL
-- ===========================

function ArtifactVisualizer:RemoveArtifactVisual(artifactId: string)
	local artifact = self.ActiveArtifacts[artifactId]
	if artifact then
		-- Play collection animation
		task.spawn(function()
			local tween = game:GetService("TweenService"):Create(
				artifact,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Size = Vector3.new(0, 0, 0), Transparency = 1}
			)
			tween:Play()
			task.wait(0.3)
			artifact:Destroy()
		end)
		
		self.ActiveArtifacts[artifactId] = nil
	end
end

-- ===========================
-- EFFECTS
-- ===========================

function ArtifactVisualizer:ShowCollectionEffect(collectionData: table)
	-- Create a temporary part for collection effect
	local character = LocalPlayer.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Create effect part
	local effectPart = Instance.new("Part")
	effectPart.Anchored = true
	effectPart.CanCollide = false
	effectPart.Size = Vector3.new(0.5, 0.5, 0.5)
	effectPart.Position = hrp.Position + Vector3.new(0, 3, 0)
	effectPart.Color = collectionData.Color
	effectPart.Material = Enum.Material.Neon
	effectPart.Transparency = 0
	effectPart.Parent = Workspace
	
	-- Animate
	task.spawn(function()
		local tween = game:GetService("TweenService"):Create(
			effectPart,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = hrp.Position + Vector3.new(0, 5, 0), Transparency = 1}
		)
		tween:Play()
		task.wait(1)
		effectPart:Destroy()
	end)
end

return ArtifactVisualizer
