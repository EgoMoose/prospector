--!strict

local root = script.Parent.Parent
local RejectIfNil = require(root.Util.RejectIfNil)
local ConnectionMaid = require(root.Util.ConnectionMaid)

local packages = root.Parent
local Promise = require(packages.Promise)

local WaitForChild = {}

-- Private

local function byPredicate(parent: Instance, timeout: number, predicate: (Instance) -> boolean)
	assert(timeout > 0, "timeout must be greater than 0")

	local maid = ConnectionMaid.new()
	local search = Promise.new(function(resolve)
		local function watch(child: Instance)
			maid:mark(child.Changed:Connect(function()
				if predicate(child) then
					resolve(child)
				end
			end))

			maid:mark(child.AttributeChanged:Connect(function()
				if predicate(child) then
					resolve(child)
				end
			end))
		end

		local function check(child: Instance)
			if predicate(child) then
				return resolve(child)
			end
			watch(child)
		end

		for _, child in parent:GetChildren() do
			check(child)
		end

		maid:mark(parent.ChildAdded:Connect(function(child)
			check(child)
		end))
	end)

	Promise.try(function()
		search:await()
		maid:destroy()
	end)

	return Promise.race({
		search,
		Promise.delay(timeout):andThenReturn(nil),
	})
end

local function byName(parent: Instance, timeout: number, name: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return Promise.new(function(resolve)
		resolve(parent:WaitForChild(name, timeout))
	end)
end

local function byPath(parent: Instance, timeout: number, path: { string })
	assert(timeout > 0, "timeout must be greater than 0")

	local t = os.clock()
	local search = Promise.resolve(parent)
	for _, name in path do
		search = search:andThen(function(child)
			local remaining = timeout - (os.clock() - t)
			if remaining > 0 then
				return byName(child, remaining, name)
			else
				return Promise.resolve(nil)
			end
		end)
	end

	return search
end

-- Public

WaitForChild.byPredicate = RejectIfNil.wrap(byPredicate)
WaitForChild.byName = RejectIfNil.wrap(byName)
WaitForChild.byPath = RejectIfNil.wrap(byPath)

--

return WaitForChild
