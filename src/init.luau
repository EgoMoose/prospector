--!strict

local Getters = require(script:WaitForChild("Getters"))

local searchers = script:WaitForChild("Searchers")
local FindFirstChild = require(searchers:WaitForChild("FindFirstChild"))
local WaitForChild = require(searchers:WaitForChild("WaitForChild"))

return {
	Get = Getters,
	FindFirstChild = FindFirstChild,
	WaitForChild = WaitForChild,
}
