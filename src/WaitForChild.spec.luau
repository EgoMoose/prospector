--!strict

local spawnAfter = 0.1
local partProperties = {
	Name = "SomePart",
	Color = Color3.fromRGB(10, 20, 30),
}

local function spawnPart(callback: (() -> BasePart?) -> ())
	local destroyed = false
	local targetPart: BasePart
	task.delay(spawnAfter, function()
		targetPart = Instance.new("WedgePart")
		for property, value in partProperties do
			(targetPart :: any)[property] = value
		end

		if destroyed then
			targetPart:Destroy()
		else
			targetPart.Parent = workspace
		end
	end)

	local function getPart()
		return targetPart
	end

	callback(getPart)
	if targetPart then
		targetPart:Destroy()
	else
		destroyed = true
	end
end

return function()
	local WaitForChild = require(script.Parent:FindFirstChild("WaitForChild"))

	describe("byPredicate", function()
		it("should find Instances conditionally", function()
			spawnPart(function(getPart)
				local found = WaitForChild.byPredicate(workspace, spawnAfter + 1, function(child)
					return child:IsA("BasePart") and child.Color == partProperties.Color
				end):expect()

				local part = getPart()
				expect(part).to.never.equal(nil)
				expect(found).to.equal(part)
			end)
		end)

		it("should timeout if no Instances are found conditionally", function()
			spawnPart(function()
				local found = WaitForChild.byPredicate(workspace, spawnAfter / 2, function(child)
					return child:IsA("BasePart") and child.Color == partProperties.Color
				end):expect()

				expect(found).to.equal(nil)
			end)
		end)
	end)

	describe("byName", function()
		it("should find Instances conditionally", function()
			spawnPart(function(getPart)
				local found = WaitForChild.byName(workspace, spawnAfter + 1, partProperties.Name):expect()

				local part = getPart()
				expect(part).to.never.equal(nil)
				expect(found).to.equal(part)
			end)
		end)

		it("should timeout if no Instances are found conditionally", function()
			spawnPart(function()
				local found = WaitForChild.byName(workspace, spawnAfter / 2, partProperties.Name):expect()

				expect(found).to.equal(nil)
			end)
		end)
	end)

	describe("ofClass", function()
		it("should find Instances conditionally", function()
			spawnPart(function(getPart)
				local found = WaitForChild.ofClass(workspace, spawnAfter + 1, "WedgePart"):expect()

				local part = getPart()
				expect(part).to.never.equal(nil)
				expect(found).to.equal(part)
			end)
		end)

		it("should timeout if no Instances are found conditionally", function()
			spawnPart(function()
				local found = WaitForChild.ofClass(workspace, spawnAfter / 2, "WedgePart"):expect()

				expect(found).to.equal(nil)
			end)
		end)
	end)

	describe("whichIsA", function()
		it("should find Instances conditionally", function()
			spawnPart(function(getPart)
				local found = WaitForChild.whichIsA(workspace, spawnAfter + 1, "WedgePart"):expect()

				local part = getPart()
				expect(part).to.never.equal(nil)
				expect(found).to.equal(part)
			end)
		end)

		it("should timeout if no Instances are found conditionally", function()
			spawnPart(function()
				local found = WaitForChild.whichIsA(workspace, spawnAfter / 2, "WedgePart"):expect()

				expect(found).to.equal(nil)
			end)
		end)
	end)

	describe("byPath", function()
		it("should find Instances conditionally", function()
			spawnPart(function(getPart)
				local found = WaitForChild.byPath(game, spawnAfter + 1, { "Workspace", partProperties.Name }):expect()

				local part = getPart()
				expect(part).to.never.equal(nil)
				expect(found).to.equal(part)
			end)
		end)

		it("should timeout if no Instances are found conditionally", function()
			spawnPart(function()
				local found = WaitForChild.byPath(game, spawnAfter / 2, { "Workspace", partProperties.Name }):expect()

				expect(found).to.equal(nil)
			end)
		end)
	end)
end
