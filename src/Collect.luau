--!strict

local rootPackage = script.Parent
local Queue = require(rootPackage.Util.Queue)

--[=[
	@class Collect

	Collect is a set of functions that capture and filter the children or descendants of an instance.

	None of the predicates provided to these functions should yield.
]=]
local Collect = {}

-- Private

local function reverse<T>(arr: { T })
	for i = 1, math.floor(#arr / 2) do
		arr[i], arr[#arr - i + 1] = arr[#arr - i + 1], arr[i]
	end
	return arr
end

local function noYield<T..., U...>(callback: (T...) -> U..., ...: T...): U...
	local createdCoroutine = coroutine.create(callback)
	local results = table.pack(coroutine.resume(createdCoroutine, ...))

	if not results[1] then
		error(tostring(results[2]), 2)
	elseif coroutine.status(createdCoroutine) ~= "dead" then
		error(debug.traceback(createdCoroutine, "Attempted to yield inside a noYield block!"), 2)
	end

	return table.unpack(results :: { any }, 2, results.n)
end

-- Public

--[=[
	@function children
	@within Collect

	@param root Instance
	@param predicate? (Instance) -> boolean -- The function to filter the children with.
	@return { Instance } -- The filtered children.

	Any Instances that do not pass the predicate will not be included.

	```lua
	local onlyBaseParts = children(workspace, function(child)
		return child:IsA("BasePart")
	end)
	```
]=]
function Collect.children(root: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local children = {}
		for _, child in root:GetChildren() do
			local result = if predicate then predicate(child) else true
			if result then
				table.insert(children, child)
			end
		end
		return children
	end)
end

--[=[
	@function descendantsBFS
	@within Collect

	@param root Instance
	@param predicate? (Instance, number) -> boolean? -- The function to filter the descendants with. The second arg represents depth.
	@return { Instance } -- The filtered descendants.

	Travels Breadth-First. The predicate of this function can return `true`, `false`, or `nil` with different behaviors for each:
		`true`: The Instance is included in the result array
		`false`: The Instance is not included in the result array
		`nil`: The Instance is not included in the result array and travel will not continue through its descendants

	```lua
	local onlyBaseParts = descendantsBFS(game, function(child)
		if child:IsA("Workspace") then
			return nil
		end

		return child:IsA("BasePart")
	end)
	```
]=]
function Collect.descendantsBFS(root: Instance, predicate: ((Instance, number) -> boolean?)?)
	return noYield(function()
		local descendants = {}
		local depthMap = {}

		local children = root:GetChildren()
		for _, child in children do
			depthMap[child] = 1
		end

		local queue = Queue.new(children)
		while queue:getLength() > 0 do
			local front = queue:dequeue()
			local depth = depthMap[front]

			local result = if predicate then predicate(front, depth) else true
			if result then
				table.insert(descendants, front)
			end

			if result ~= nil then
				local nextDepth = depth + 1
				for _, child in front:GetChildren() do
					depthMap[child] = nextDepth
					queue:enqueue(child)
				end
			end
		end

		return descendants
	end)
end

--[=[
	@function descendantsDFS
	@within Collect

	@param root Instance
	@param predicate? (Instance, number) -> boolean? -- The function to filter the descendants with. The second arg represents depth.
	@return { Instance } -- The filtered descendants.

	Travels Depth-First. The predicate of this function can return `true`, `false`, or `nil` with different behaviors for each:
		`true`: The Instance is included in the result array
		`false`: The Instance is not included in the result array
		`nil`: The Instance is not included in the result array and travel will not continue through its descendants

	```lua
	local onlyBaseParts = descendantsDFS(game, function(child, depth)
		if child:IsA("Workspace") or depth >= 2 then
			return nil
		end

		return child:IsA("BasePart")
	end)
	```
]=]
function Collect.descendantsDFS(root: Instance, predicate: ((Instance, number) -> boolean?)?)
	return noYield(function()
		local descendants = {}
		local depthMap = {}

		local stack = reverse(root:GetChildren())
		for _, child in stack do
			depthMap[child] = 1
		end

		while #stack > 0 do
			local popped = table.remove(stack) :: Instance
			local depth = depthMap[popped]

			local result = if predicate then predicate(popped, depth) else true
			if result then
				table.insert(descendants, popped)
			end

			if result ~= nil then
				local nextDepth = depth + 1
				local children = popped:GetChildren()
				for i = #children, 1, -1 do
					local child = children[i]
					depthMap[child] = nextDepth
					table.insert(stack, child)
				end
			end
		end

		return descendants
	end)
end

--

return Collect
