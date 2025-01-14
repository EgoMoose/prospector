--!strict

local Future = require(script.Parent.Helpers.Future)

local SPAWN_AFTER = 1
local PART_PROPERTIES = {
	Name = "SomePart",
	Color = Color3.fromRGB(10, 20, 30),
}

local function packAsCallback<T...>(...: T...): () -> T...
	local n = select("#", ...)
	local packed = { select(1, ...) }
	return function()
		return unpack(packed, 1, n)
	end
end

local function wrapFuture<T, U...>(callback: (U...) -> T, ...: U...)
	local future = Future.raw() :: Future.Future<T>
	local unpackCallback = packAsCallback(...)
	task.spawn(function()
		future:complete(callback(unpackCallback()))
	end)
	return future
end

return function()
	local WaitForChild = require(script.Parent:FindFirstChild("WaitForChild"))

	local target1: BasePart
	task.delay(SPAWN_AFTER, function()
		target1 = Instance.new("WedgePart")
		for property, value in PART_PROPERTIES do
			(target1 :: any)[property] = value
		end
		target1.Parent = workspace
	end)

	local target2: Decal
	task.delay(SPAWN_AFTER, function()
		target2 = Instance.new("Decal")
		target2.Name = "WrongName"
		target2.Parent = workspace

		task.wait(0.1)
		target2.Parent = game.ReplicatedStorage
		target2.Name = "CorrectName"
		task.wait(0.6)
		target2.Parent = workspace
	end)

	local futures: { [string]: Future.Future<Instance?> } = {}

	-- byPredicate
	local function predicate(child: Instance)
		return child:IsA("BasePart") and child.Color == PART_PROPERTIES.Color
	end

	futures.byPredicate = wrapFuture(WaitForChild.byPredicate, workspace, SPAWN_AFTER + 1, predicate)
	futures.byPredicateHalf = wrapFuture(WaitForChild.byPredicate, workspace, SPAWN_AFTER / 2, predicate)

	futures.byPredicateWrongParent = wrapFuture(WaitForChild.byPredicate, workspace, SPAWN_AFTER + 0.5, function(child)
		return child.Name == "CorrectName"
	end)

	futures.byPredicateWrongParent2 = wrapFuture(WaitForChild.byPredicate, workspace, SPAWN_AFTER + 1, function(child)
		return child.Name == "CorrectName"
	end)

	-- byName

	futures.byName = wrapFuture(WaitForChild.byName, workspace, SPAWN_AFTER + 1, PART_PROPERTIES.Name)
	futures.byNameHalf = wrapFuture(WaitForChild.byName, workspace, SPAWN_AFTER / 2, PART_PROPERTIES.Name)

	-- ofClass
	futures.ofClass = wrapFuture(WaitForChild.ofClass, workspace, SPAWN_AFTER + 1, "WedgePart")
	futures.ofClassHalf = wrapFuture(WaitForChild.ofClass, workspace, SPAWN_AFTER / 2, "WedgePart")

	-- whichIsA
	futures.whichIsA = wrapFuture(WaitForChild.whichIsA, workspace, SPAWN_AFTER + 1, "WedgePart")
	futures.whichIsAHalf = wrapFuture(WaitForChild.whichIsA, workspace, SPAWN_AFTER / 2, "WedgePart")

	-- byPath
	futures.byPath = wrapFuture(WaitForChild.byPath, game, SPAWN_AFTER + 1, { "Workspace", PART_PROPERTIES.Name })
	futures.byPathHalf = wrapFuture(WaitForChild.byPath, game, SPAWN_AFTER / 2, { "Workspace", PART_PROPERTIES.Name })

	describe("byPredicate", function()
		it("should find Instances conditionally", function()
			local found = futures.byPredicate:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = futures.byPredicateHalf:expect()

			expect(found).to.equal(nil)
		end)

		it("should timeout if when the condition passes under the wrong parent", function()
			local found = futures.byPredicateWrongParent:expect()

			expect(found).to.equal(nil)
		end)

		it("should succeed if when the condition passes under the right parent", function()
			local found = futures.byPredicateWrongParent2:expect()

			expect(found).to.equal(target2)
		end)
	end)

	describe("byName", function()
		it("should find Instances conditionally", function()
			local found = futures.byName:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = futures.byNameHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("ofClass", function()
		it("should find Instances conditionally", function()
			local found = futures.ofClass:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = futures.ofClassHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("whichIsA", function()
		it("should find Instances conditionally", function()
			local found = futures.whichIsA:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = futures.whichIsAHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	describe("byPath", function()
		it("should find Instances conditionally", function()
			local found = futures.byPath:expect()

			expect(target1).never.to.equal(nil)
			expect(found).to.equal(target1)
		end)

		it("should timeout if no Instances are found conditionally", function()
			local found = futures.byPathHalf:expect()

			expect(found).to.equal(nil)
		end)
	end)

	for _, future in futures do
		(future :: Future.Future<any>):expect()
	end

	target1:Destroy()
	target2:Destroy()
end
