--!strict

--[=[
	@class Prospector

	A Roblox lua package for traveling and capturing the data-model hierarchy.
]=]
local Prospector = {
	Collect = require(script:FindFirstChild("Collect")),

	FindFirstAncestor = require(script:FindFirstChild("FindFirstAncestor")),
	FindFirstChild = require(script:FindFirstChild("FindFirstChild")),
	WaitForChild = require(script:FindFirstChild("WaitForChild")),
}

--- @prop Collect Collect
--- @within Prospector

--- @prop FindFirstAncestor FindFirstAncestor
--- @within Prospector

--- @prop FindFirstChild FindFirstChild
--- @within Prospector

--- @prop WaitForChild WaitForChild
--- @within Prospector

return Prospector
