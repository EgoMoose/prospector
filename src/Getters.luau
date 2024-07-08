--!strict

local root = script.Parent
local Queue = require(root.Util.Queue)

local Getters = {}

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

function Getters.children(parent: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local children = {}
		for _, child in parent:GetChildren() do
			if not predicate or predicate(child) then
				table.insert(children, child)
			end
		end
		return children
	end)
end

function Getters.descendantsBFS(parent: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local descendants = {}

		local queue = Queue.new(parent:GetChildren())
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

function Getters.descendantsDFS(parent: Instance, predicate: ((Instance) -> boolean)?)
	return noYield(function()
		local descendants = {}

		local stack = reverse(parent:GetChildren())
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

return Getters
