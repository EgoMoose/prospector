local ExploreByPredicate = require(game.ReplicatedStorage.Packages.ExploreByPredicate)

--stylua: ignore
ExploreByPredicate.findFirstChild(workspace, "Part"):andThen(function(part)
	print("Found", part)
end):catch(warn)

ExploreByPredicate.waitForChild(workspace, "Part"):andThen(function(part)
	print("Waited for", part)
end)

local created = Instance.new("Part")
created.Transparency = 1
created.Parent = workspace

ExploreByPredicate.findFirstChildWithPredicate(workspace, false, function(child)
	return child:IsA("BasePart") and child.Transparency < 1
end):andThen(function(part)
	print("Found non transparent", part)
end)

local PlayerModule = ExploreByPredicate.findFirstPath(game, { "StarterPlayer", "StarterPlayerScripts", "PlayerModule" }):expect()
print(PlayerModule:GetFullName())
