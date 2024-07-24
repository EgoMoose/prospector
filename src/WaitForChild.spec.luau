--!strict

local rootPackage = script.Parent
local packages = rootPackage.Parent
local Promise = require(packages.Promise)

local spawnAfter = 0.2
local partProperties = {
	Name = "SomePart",
	Color = Color3.fromRGB(10, 20, 30),
}

return function()
	local WaitForChild = require(script.Parent:FindFirstChild("WaitForChild"))

	local target1: BasePart
	task.delay(spawnAfter, function()
		target1 = Instance.new("WedgePart")
		for property, value in partProperties do
			(target1 :: any)[property] = value
		end
		target1.Parent = workspace
	end)

	local target2: Decal
	task.delay(spawnAfter, function()
		target2 = Instance.new("Decal")
		target2.Name = "WrongName"
		target2.Parent = workspace

		task.wait(0.1)
		target2.Parent = game.ReplicatedStorage
		target2.Name = "CorrectName"
		task.wait(0.6)
		target2.Parent = workspace
	end)

	local promises = {}

	-- byPredicate
	local function predicate(child: Instance)
		return child:IsA("BasePart") and child.Color == partProperties.Color
	end

	promises.byPredicate = WaitForChild.byPredicate(workspace, spawnAfter + 1, predicate)
	promises.byPredicateHalf = WaitForChild.byPredicate(workspace, spawnAfter / 2, predicate)

	promises.byPredicateWrongParent = WaitForChild.byPredicate(workspace, spawnAfter + 0.5, function(child)
		return child.Name == "CorrectName"
	end)

	promises.byPredicateWrongParent2 = WaitForChild.byPredicate(workspace, spawnAfter + 1, function(child)
		return child.Name == "CorrectName"
	end)

	-- byName
	promises.byName = WaitForChild.byName(workspace, spawnAfter + 1, partProperties.Name)
	promises.byNameHalf = WaitForChild.byName(workspace, spawnAfter / 2, partProperties.Name)

	-- ofClass
	promises.ofClass = WaitForChild.ofClass(workspace, spawnAfter + 1, "WedgePart")
	promises.ofClassHalf = WaitForChild.ofClass(workspace, spawnAfter / 2, "WedgePart")

	-- whichIsA
	promises.whichIsA = WaitForChild.whichIsA(workspace, spawnAfter + 1, "WedgePart")
	promises.whichIsAHalf = WaitForChild.whichIsA(workspace, spawnAfter / 2, "WedgePart")

	-- byPath
	promises.byPath = WaitForChild.byPath(game, spawnAfter + 1, { "Workspace", partProperties.Name })
	promises.byPathHalf = WaitForChild.byPath(game, spawnAfter / 2, { "Workspace", partProperties.Name })

	describe("byPredicate", function()
		it("should find Instances conditionally", function()
			local found = promises.byPredicate:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = promises.byPredicateHalf:expect()

			expect(found).to.equal(nil)
		end)

		it("should timeout if when the condition passes under the wrong parent", function()
			local found = promises.byPredicateWrongParent:expect()

			expect(found).to.equal(nil)
		end)

		it("should succeed if when the condition passes under the right parent", function()
			local found = promises.byPredicateWrongParent2:expect()

			expect(found).to.equal(target2)
		end)
	end)

	describe("byName", function()
		it("should find Instances conditionally", function()
			local found = promises.byName:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = promises.byNameHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("ofClass", function()
		it("should find Instances conditionally", function()
			local found = promises.ofClass:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = promises.ofClassHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("whichIsA", function()
		it("should find Instances conditionally", function()
			local found = promises.whichIsA:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = promises.whichIsAHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("byPath", function()
		it("should find Instances conditionally", function()
			local found = promises.byPath:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = promises.byPathHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	local flatPromises = {}
	for _, promise in promises do
		table.insert(flatPromises, promise)
	end

	Promise.all(flatPromises):await()
	target1:Destroy()
	target2:Destroy()
end
