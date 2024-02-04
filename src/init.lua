--!strict

local Promise = require(script.Parent:WaitForChild("Promise"))
local QueueHelper = require(script:WaitForChild("QueueHelper"))

local module = {}

function module.findFirstChildWithPredicate(parent: Instance, recursive: boolean?, predicate: (Instance) -> boolean)
	return Promise.new(function(resolve, reject)
		local queue = QueueHelper.create(parent:GetChildren())

		while QueueHelper.getLength(queue) > 0 do
			local popped = QueueHelper.popFront(queue)

			if predicate(popped) then
				return resolve(popped)
			elseif recursive then
				for _, child in popped:GetChildren() do
					QueueHelper.pushBack(queue, child)
				end
			end
		end

		if recursive then
			reject(("Unable to find descendant of [%s] that matches predicate"):format(parent:GetFullName()))
		else
			reject(("Unable to find child of [%s] that matches predicate"):format(parent:GetFullName()))
		end
	end)
end

function module.waitForChildWithPredicate(parent: Instance, timeout: number?, predicate: (Instance) -> boolean)
	local connections = {}
	local searching = Promise.new(function(resolve)
		local function watch(child)
			table.insert(
				connections,
				child.Changed:Connect(function()
					if predicate(child) then
						resolve(child)
					end
				end)
			)

			table.insert(
				connections,
				child.AttributeChanged:Connect(function()
					if predicate(child) then
						resolve(child)
					end
				end)
			)
		end

		for _, child in parent:GetChildren() do
			if predicate(child) then
				return resolve(child)
			end
			watch(child)
		end

		table.insert(
			connections,
			parent.ChildAdded:Connect(function(child)
				if predicate(child) then
					return resolve(child)
				end
				watch(child)
			end)
		)
	end)

	Promise.try(function()
		searching:await()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)

	if timeout then
		return Promise.race({
			searching,
			Promise.delay(timeout):andThenReturn(nil),
		}):andThen(function(result)
			if result == nil then
				return Promise.reject(("Unable to find child of [%s] that matches predicate before timeout"):format(parent:GetFullName()))
			end
			return result
		end)
	else
		Promise.race({
			searching,
			Promise.delay(5):andThenReturn(nil),
		}):andThen(function(result)
			if result == nil then
				warn(("Infinite yield possible on [%s] waiting for predicate"):format(parent:GetFullName()))
			end
		end)

		return searching
	end
end

function module.findFirstChild(parent: Instance, name: string, recursive: boolean?)
	return module.findFirstChildWithPredicate(parent, recursive, function(child)
		return child.Name == name
	end)
end

function module.findFirstPath(parent: Instance, path: { string })
	local searching = Promise.resolve(parent)
	for _, name in path do
		searching = searching:andThen(function(subParent)
			return module.findFirstChild(subParent, name, false)
		end)
	end
	return searching
end

function module.waitForChild(parent: Instance, name: string, timeout: number?)
	return module.waitForChildWithPredicate(parent, timeout, function(child)
		return child.Name == name
	end)
end

function module.waitForPath(parent: Instance, path: { string }, timeout: number?)
	local searching = Promise.resolve(parent)
	for _, name in path do
		searching = searching:andThen(function(subparent)
			return module.waitForChild(subparent, name, nil)
		end)
	end

	if timeout then
		return Promise.race({
			searching,
			Promise.delay(timeout):andThenReturn(nil),
		}):andThen(function(result)
			if result == nil then
				return Promise.reject(("Unable to find path from [%s] before timeout"):format(parent:GetFullName()))
			end
			return result
		end)
	else
		Promise.race({
			searching,
			Promise.delay(5):andThenReturn(nil),
		}):andThen(function(result)
			if result == nil then
				warn(("Infinite yield possible on [%s] waiting for path"):format(parent:GetFullName()))
			end
		end)

		return searching
	end
end

return module
