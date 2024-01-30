--[[
	This is based on some module I made a while ago for my team member @max96git.
	It does use somewhat similar code I made for that
]]

--// Services \\--
local RunService = game:GetService("RunService")

--// Bindables \\--
local playedEvent = Instance.new("BindableEvent")
local pausedEvent = Instance.new("BindableEvent")
local finishedEvent = Instance.new("BindableEvent")

local rainbow = {}
rainbow.__index = rainbow

function rainbow.new(item: Part, rainbowSpeed: number?)
	local self = setmetatable({}, rainbow)

	self.item = item
	self.playbackState = Enum.PlaybackState.Completed
	self.rainbowSpeed = rainbowSpeed or 13 --how many seconds until the rainbow loops
	
	self._connection = nil
	self._currentProgress = 0

	self.Played = playedEvent.Event
	self.Paused = pausedEvent.Event
	self.Finished = finishedEvent.Event

	return self
end

function rainbow:Play()
	if self._connection then 
		return 
	end
	
	self.playbackState = Enum.PlaybackState.Begin
	playedEvent:Fire(self.item, self.playbackState)

	local function nextFrame(deltaTime: number)
		self.playbackState = Enum.PlaybackState.Playing
		self._currentProgress = (self._currentProgress + (.1 / self.rainbowSpeed)) % 1

		self.item.Color = Color3.fromHSV(self._currentProgress, 1, 1)
	end
	
	self._connection = RunService:IsServer() and RunService.Stepped:Connect(nextFrame) or RunService.RenderStepped:Connect(nextFrame)
end

function rainbow:Pause()
	if self.playbackState ~= Enum.PlaybackState.Playing then
		return
	end

	pausedEvent:Fire(self.item, self.playbackState)
	self.playbackState = Enum.PlaybackState.Paused

	self._connection:Disconnect()
	self._connection = nil
end

function rainbow:Stop()
	if self.playbackState ~= Enum.PlaybackState.Playing then
		return
	end

	finishedEvent:Fire(self.item, self.playbackState)
	self.playbackState = Enum.PlaybackState.Cancelled

	self._connection:Disconnect()
	self._connection = nil
end

return rainbow
