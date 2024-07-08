--!strict

local FindFirstChild = require(script.Searchers:WaitForChild("FindFirstChild"))
local WaitForChild = require(script.Searchers:WaitForChild("WaitForChild"))

return {
	FindFirstChild = FindFirstChild,
	WaitForChild = WaitForChild,
}
