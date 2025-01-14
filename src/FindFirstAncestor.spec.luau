--!strict

return function()
	local FindFirstAncestor = require(script.Parent:FindFirstChild("FindFirstAncestor"))

	describe("byPredicate", function()
		it("should find Instances conditionally", function()
			local found = FindFirstAncestor.byPredicate(workspace.Terrain, function(parent)
				return parent:IsA("Model") and parent:GetScale() == 1
			end)

			expect(found).to.equal(workspace)
		end)
	end)

	describe("byName", function()
		it("should find Instances conditionally", function()
			local found = FindFirstAncestor.byName(workspace.Terrain, "Workspace")

			expect(found).to.equal(workspace)
		end)
	end)

	describe("ofClass", function()
		it("should find Instances conditionally", function()
			local found = FindFirstAncestor.ofClass(workspace.Terrain, "Workspace")

			expect(found).to.equal(workspace)
		end)
	end)

	describe("whichIsA", function()
		it("should find Instances conditionally", function()
			local found = FindFirstAncestor.whichIsA(workspace.Terrain, "Model")

			expect(found).to.equal(workspace)
		end)
	end)

	describe("byDepth", function()
		it("should find Instances conditionally", function()
			local found = FindFirstAncestor.byDepth(workspace.Terrain, 2)

			expect(found).to.equal(game)
		end)
	end)
end
