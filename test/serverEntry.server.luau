--!strict

local Explorer = require(game.ReplicatedStorage.Packages.ExploreByPredicate)

Explorer.FindFirstChild.byName(workspace, false, "Part"):andThen(function(part)
	if part then
		print(part, "was found!")
	else
		print("unable to find 'Part'.")
	end
end)

Explorer.WaitForChild.byName(workspace, math.huge, "Part"):andThen(function(part)
	if part then
		print(part, "was found!")
	else
		print("unable to find 'Part' before being timed out.")
	end
end)

local targetColor = Color3.fromRGB(40, 200, 130)
local part = Instance.new("Part")
part.Anchored = true
part.Color = targetColor
part.Parent = workspace

Explorer.FindFirstChild
	.byPredicate(game, true, function(candidate)
		return candidate:IsA("BasePart") and candidate.Color == targetColor
	end)
	:andThen(function(found)
		if found then
			print(found, "was found with correct color!")
		else
			print("unable to find BasePart with correct color.")
		end
	end)
