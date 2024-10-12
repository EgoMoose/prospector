--!strict

local rootPackage = script.Parent
local RejectIfNil = require(rootPackage.Util.RejectIfNil)

local packages = rootPackage.Parent
local Trove = require(packages.Trove)
local Promise = require(packages.Promise)

--[=[
	@class WaitForChild

	WaitForChild is a set of functions that waits for descendants conditionally.
]=]
local WaitForChild = {}

-- Private

local function byPredicate(root: Instance, timeout: number, predicate: (Instance) -> boolean)
	assert(timeout > 0, "timeout must be greater than 0")

	local watching = {}
	local trove = Trove.new()
	local search = Promise.new(function(resolve)
		local function watch(child: Instance)
			if watching[child] then
				return
			end

			watching[child] = true

			trove:Add(child.Changed:Connect(function()
				if child.Parent == root and predicate(child) then
					resolve(child)
				end
			end))

			trove:Add(child.AttributeChanged:Connect(function()
				if child.Parent == root and predicate(child) then
					resolve(child)
				end
			end))
		end

		local function check(child: Instance)
			if child.Parent == root and predicate(child) then
				return resolve(child)
			end
			watch(child)
		end

		for _, child in root:GetChildren() do
			check(child)
		end

		trove:Add(root.ChildAdded:Connect(function(child)
			check(child)
		end))
	end)

	Promise.try(function()
		search:await()
		trove:Destroy()
	end)

	return Promise.race({
		search,
		Promise.delay(timeout):andThenReturn(nil),
	})
end

local function byName(root: Instance, timeout: number, name: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return Promise.new(function(resolve)
		resolve(root:WaitForChild(name, timeout))
	end)
end

local function ofClass(root: Instance, timeout: number, className: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return byPredicate(root, timeout, function(child)
		return child.ClassName == className
	end)
end

local function whichIsA(root: Instance, timeout: number, className: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return byPredicate(root, timeout, function(child)
		return child:IsA(className)
	end)
end

local function byPath(root: Instance, timeout: number, path: { string })
	assert(timeout > 0, "timeout must be greater than 0")

	local t = os.clock()
	local search = Promise.resolve(root)
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

local byPredicateWrapped = RejectIfNil.wrap(byPredicate)
local byNameWrapped = RejectIfNil.wrap(byName)
local ofClassWrapped = RejectIfNil.wrap(ofClass)
local whichIsAWrapped = RejectIfNil.wrap(whichIsA)
local byPathWrapped = RejectIfNil.wrap(byPath)

-- Public

--[=[
	@function byPredicate
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param predicate? (Instance) -> boolean -- The conditions under which the search has successfully found a result.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	First looks through the children of `root` for an Instance that passes the conditions of the predicate and if none 
	are found begins listening for new instances and changes to existing ones.

	```lua
	local found = byPredicate(workspace, math.huge, function(child)
		-- waiting for the first descendant of workspace that's a BasePart and has a certain color
		return child:IsA("BasePart") and child.Color = Color3.fromRGB(100, 120, 80)
	end):expect()
	```
]=]
function WaitForChild.byPredicate(root: Instance, timeout: number, predicate: (Instance) -> boolean)
	return byPredicateWrapped(root, timeout, predicate)
end

--[=[
	@function byName
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param name string -- The name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	First looks through the children of `root` for an Instance with the same name and if none are found begins 
	listening for new instances and changes to existing ones.

	```lua
	local found = byName(workspace, math.huge, "Part"):expect()
	```
]=]
function WaitForChild.byName(root: Instance, timeout: number, name: string)
	return byNameWrapped(root, timeout, name)
end

--[=[
	@function ofClass
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param className string -- The class name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	First looks through the children of `root` for an Instance with the same ClassName and if none are found begins 
	listening for new instances and changes to existing ones.

	```lua
	local found = ofClass(workspace, math.huge, "Part"):expect()
	```
]=]
function WaitForChild.ofClass(root: Instance, timeout: number, className: string)
	return ofClassWrapped(root, timeout, className)
end

--[=[
	@function whichIsA
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param className string -- The class name of the Instance being search for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	First looks through the children of `root` for an Instance that's equivalent to or a subclass of a given class
	and if if none are found then begins listening for new instances and changes to existing ones.

	```lua
	local found = whichIsA(workspace, math.huge, "BasePart"):expect()
	```
]=]
function WaitForChild.whichIsA(root: Instance, timeout: number, className: string)
	return whichIsAWrapped(root, timeout, className)
end

--[=[
	@function byPath
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param path { string } -- The path by name from the root to the target Instance.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels the path starting from the `root` instance and if none are found begins listening for new instances and 
	changes to existing ones at each step.

	```lua
	local found = byPath(game, math.huge, { "Workspace", "Terrain" }):expect()
	```
]=]
function WaitForChild.byPath(root: Instance, timeout: number, path: { string })
	return byPathWrapped(root, timeout, path)
end

--

return WaitForChild
