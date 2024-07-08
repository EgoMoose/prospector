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
			if not predicate or predicate(child) then
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
	@param predicate? (Instance) -> boolean -- The function to filter the descendants with.
	@return { Instance } -- The filtered descendants.

	Travels Breadth-First. Any Instances that do not pass the predicate will not be included.

	```lua
	local onlyBaseParts = descendantsBFS(workspace, function(child)
		return child:IsA("BasePart")
	end)
	```
]=]
function Collect.descendantsBFS(root: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local descendants = {}

		local queue = Queue.new(root:GetChildren())
		while queue:getLength() > 0 do
			local front = queue:dequeue()

			if not predicate or predicate(front) then
				table.insert(descendants, front)
				for _, child in front:GetChildren() do
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
	@param predicate? (Instance) -> boolean -- The function to filter the descendants with.
	@return { Instance } -- The filtered descendants.

	Travels Depth-First. Any Instances that do not pass the predicate will not be included.

	```lua
	local onlyBaseParts = descendantsDFS(workspace, function(child)
		return child:IsA("BasePart")
	end)
	```
]=]
function Collect.descendantsDFS(root: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local descendants = {}

		local stack = reverse(root:GetChildren())
		while #stack > 0 do
			local popped = table.remove(stack) :: Instance

			if not predicate or predicate(popped) then
				table.insert(descendants, popped)

				local children = popped:GetChildren()
				for i = #children, 1, -1 do
					table.insert(stack, children[i])
				end
			end
		end

		return descendants
	end)
end

--

return Collect
