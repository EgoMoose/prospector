--!strict

local rootPackage = script.Parent
local RejectIfNil = require(rootPackage.Util.RejectIfNil)

local packages = rootPackage.Parent
local Promise = require(packages.Promise)

--[=[
	@class FindFirstAncestor

	FindFirstAncestor is a set of functions that search for ancestors conditionally.
]=]
local FindFirstAncestor = {}

-- Private

--[=[
	@function byPredicate
	@within FindFirstAncestor

	@param root Instance
	@param predicate? (Instance) -> boolean -- The conditions under which the search has successfully found a result.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels up through the ancestry of `root` until it finds an Instance that passes the conditions of the predicate.

	```lua
	local found = byPredicate(workspace.Terrain, function(parent)
		return parent.Name ~= "NotThisName"
	end):expect()
	```
]=]
local function byPredicate(root: Instance, predicate: (Instance) -> boolean)
	return Promise.new(function(resolve: (Instance?) -> ())
		local parent = root.Parent
		while parent do
			if predicate(parent) then
				return resolve(parent)
			end
			parent = parent.Parent
		end

		resolve(nil)
	end)
end

--[=[
	@function byName
	@within FindFirstAncestor

	@param root Instance
	@param name string -- The name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels up through the ancestry of `root` until it finds an Instance that matches the provided name.

	```lua
	local found = byName(workspace.Terrain, "Workspace"):expect()
	```
]=]
local function byName(root: Instance, name: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstAncestor(name))
	end)
end

--[=[
	@function ofClass
	@within FindFirstAncestor

	@param root Instance
	@param className string -- The class name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels up through the ancestry of `root` until it finds an Instance that matches the provided ClassName.

	```lua
	local found = ofClass(workspace.Terrain, "Workspace"):expect()
	```
]=]
local function ofClass(root: Instance, className: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstAncestorOfClass(className))
	end)
end

--[=[
	@function whichIsA
	@within FindFirstAncestor

	@param root Instance
	@param className string -- The class name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels up through the ancestry of `root` until it finds an Instance with a class equivalent to or a subclass of a given class.

	```lua
	local found = whichIsA(workspace.Terrain, "WorldRoot"):expect()
	```
]=]
local function whichIsA(root: Instance, className: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstAncestorWhichIsA(className))
	end)
end

--[=[
	@function byDepth
	@within FindFirstAncestor

	@param root Instance
	@param depth number -- How many steps upwards should be travelled
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels up through the ancestry of `root` by `depth` number of steps.

	```lua
	local found = byDepth(workspace.Terrain, 2):expect()
	```
]=]
local function byDepth(root: Instance, depth: number)
	return Promise.new(function(resolve, reject)
		local count = 0
		local parent = root
		while count < depth do
			parent = parent.Parent :: Instance
			if not parent then
				return reject(nil)
			end
			count = count + 1
		end

		resolve(parent)
	end)
end

-- Public

FindFirstAncestor.byPredicate = RejectIfNil.wrap(byPredicate)
FindFirstAncestor.byName = RejectIfNil.wrap(byName)
FindFirstAncestor.ofClass = RejectIfNil.wrap(ofClass)
FindFirstAncestor.whichIsA = RejectIfNil.wrap(whichIsA)
FindFirstAncestor.byDepth = RejectIfNil.wrap(byDepth)

--

return FindFirstAncestor
