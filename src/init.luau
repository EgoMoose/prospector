--!strict

local Getters = require(script:WaitForChild("Getters"))

local searchers = script:WaitForChild("Searchers")
local FindFirstAncestor = require(searchers:WaitForChild("FindFirstAncestor"))
local FindFirstChild = require(searchers:WaitForChild("FindFirstChild"))
local WaitForChild = require(searchers:WaitForChild("WaitForChild"))

return {
	Get = Getters,
	FindFirstAncestor = FindFirstAncestor,
	FindFirstChild = FindFirstChild,
	WaitForChild = WaitForChild,
}
