--!strict

return function()
	local Collect = require(script.Parent:FindFirstChild("Collect"))

	describe("children", function()
		it("should match :GetChildren()", function()
			local children = Collect.children(workspace)
			local childrenRaw = workspace:GetChildren()

			expect(#children).to.equal(#childrenRaw)
			for i, v in children do
				expect(v).to.equal(childrenRaw[i])
			end
		end)

		it("should filter its results by the predicate", function()
			local children = Collect.children(workspace, function(child)
				return child:IsA("Terrain")
			end)

			expect(#children).to.equal(1)
			expect(children[1]).to.equal(workspace.Terrain)
		end)
	end)

	describe("descendantsBFS", function()
		it("should filter its results by the predicate", function()
			local descendants = Collect.descendantsBFS(game, function(child)
				return child:IsA("Terrain")
			end)

			expect(#descendants).to.equal(1)
			expect(descendants[1]).to.equal(workspace.Terrain)
		end)

		it("should dead-end when a predicate result is nil", function()
			local descendants = Collect.descendantsBFS(game, function(child)
				if child:IsA("Workspace") then
					return nil
				end

				return child:IsA("Terrain")
			end)

			expect(#descendants).to.equal(0)
		end)

		it("should respect depth", function()
			local childrenRaw = workspace:GetChildren()
			local children = Collect.descendantsBFS(workspace, function(_, depth)
				return depth == 1
			end)

			expect(#children).to.equal(#childrenRaw)
			for i, v in children do
				expect(v).to.equal(childrenRaw[i])
			end
		end)
	end)

	describe("descendantsDFS", function()
		it("should match :GetDescendants()", function()
			local descendants = Collect.descendantsDFS(game)
			local descendantsRaw = game:GetDescendants()

			expect(#descendants).to.equal(#descendantsRaw)
			for i, v in descendants do
				expect(v).to.equal(descendantsRaw[i])
			end
		end)

		it("should filter its results by the predicate", function()
			local descendants = Collect.descendantsDFS(game, function(child)
				return child:IsA("Terrain")
			end)

			expect(#descendants).to.equal(1)
			expect(descendants[1]).to.equal(workspace.Terrain)
		end)

		it("should dead-end when a predicate result is nil", function()
			local descendants = Collect.descendantsDFS(game, function(child)
				if child:IsA("Workspace") then
					return nil
				end

				return child:IsA("Terrain")
			end)

			expect(#descendants).to.equal(0)
		end)

		it("should respect depth", function()
			local childrenRaw = workspace:GetChildren()
			local children = Collect.descendantsDFS(workspace, function(_, depth)
				return depth == 1
			end)

			expect(#children).to.equal(#childrenRaw)
			for i, v in children do
				expect(v).to.equal(childrenRaw[i])
			end
		end)
	end)
end
