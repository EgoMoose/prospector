--!strict

local root = script.Parent.Parent
local Queue = require(root.Util.Queue)
local RejectIfNil = require(root.Util.RejectIfNil)

local packages = root.Parent
local Promise = require(packages.Promise)

local FindFirstChild = {}

-- Private

local function byPredicate(parent: Instance, recursive: boolean, predicate: (Instance) -> boolean)
	return Promise.new(function(resolve: (Instance?) -> ())
		local queue = Queue.new(parent:GetChildren())

		while queue:getLength() > 0 do
			local popped = queue:dequeue()

			if predicate(popped) then
				return resolve(popped)
			elseif recursive then
				for _, child in popped:GetChildren() do
					queue:enqueue(child)
				end
			end
		end

		resolve(nil)
	end)
end

local function byName(parent: Instance, recursive: boolean, name: string)
	return Promise.new(function(resolve)
		resolve(parent:FindFirstChild(name, recursive))
	end)
end

local function byPath(parent: Instance, path: { string })
	local search = Promise.resolve(parent)
	for _, name in path do
		search = search:andThen(function(child)
			return byName(child, false, name)
		end)
	end

	return search
end

-- Public

FindFirstChild.byPredicate = RejectIfNil.wrap(byPredicate)
FindFirstChild.byName = RejectIfNil.wrap(byName)
FindFirstChild.byPath = RejectIfNil.wrap(byPath)

--

return FindFirstChild
