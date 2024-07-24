--!strict

return function()
	local FindFirstChild = require(script.Parent:FindFirstChild("FindFirstChild"))

	local somePart = Instance.new("Part", game.ReplicatedStorage)

	describe("byPredicate", function()
		it("should find Instances conditionally", function()
			local found = FindFirstChild.byPredicate(workspace, false, function(child)
				return child:IsA("BasePart") and child.Size.X > 500
			end):expect()

			expect(found).to.equal(workspace.Baseplate)
		end)

		it("should find Instances conditionally with recursion", function()
			local found = FindFirstChild.byPredicate(game, true, function(child)
				return child:IsA("BasePart") and child.Size.X > 500
			end):expect()

			expect(found).to.equal(workspace.Baseplate)
		end)

		it("should exclude descendants of candidate when predicate returns nil with recursion", function()
			local found = FindFirstChild.byPredicate(game, true, function(child)
				if child == workspace then
					return nil
				end
				return child:IsA("BasePart") and child.Size.X > 500
			end):expect()

			expect(found).to.equal(nil)

			local found2 = FindFirstChild.byPredicate(game, true, function(child)
				if child == workspace then
					return nil
				end
				return child:IsA("BasePart")
			end):expect()

			expect(found2).to.never.equal(nil)
			expect(found2).to.equal(somePart)
		end)
	end)

	describe("byName", function()
		it("should find Instances conditionally", function()
			local found = FindFirstChild.byName(workspace, false, "Terrain"):expect()

			expect(found.Name).to.equal("Terrain")
		end)

		it("should find Instances conditionally with recursion", function()
			local found = FindFirstChild.byName(game, true, "Terrain"):expect()

			expect(found.Name).to.equal("Terrain")
		end)
	end)

	describe("ofClass", function()
		it("should find Instances conditionally", function()
			local found = FindFirstChild.ofClass(workspace, false, "Terrain"):expect()

			expect(found.ClassName).to.equal("Terrain")
		end)

		it("should find Instances conditionally with recursion", function()
			local found = FindFirstChild.ofClass(game, true, "Terrain"):expect()

			expect(found.ClassName).to.equal("Terrain")
		end)
	end)

	describe("whichIsA", function()
		it("should find Instances conditionally", function()
			local found = FindFirstChild.whichIsA(workspace, false, "BasePart"):expect()

			expect(found).never.to.equal(nil)
			expect(found:IsA("BasePart")).to.equal(true)
		end)

		it("should find Instances conditionally with recursion", function()
			local found = FindFirstChild.whichIsA(game, true, "BasePart"):expect()

			expect(found).never.to.equal(nil)
			expect(found:IsA("BasePart")).to.equal(true)
		end)
	end)

	describe("byPath", function()
		it("should find Instances conditionally", function()
			local found = FindFirstChild.byPath(game, { "Workspace", "Terrain" }):expect()

			expect(found).to.equal(workspace.Terrain)
		end)
	end)
end
