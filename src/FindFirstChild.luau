--!strict

local rootPackage = script.Parent
local Queue = require(rootPackage.Util.Queue)
local RejectIfNil = require(rootPackage.Util.RejectIfNil)

local packages = rootPackage.Parent
local Promise = require(packages.Promise)

--[=[
	@class FindFirstChild

	FindFirstChild is a set of functions that search for descendants conditionally.
]=]
local FindFirstChild = {}

-- Private

--[=[
	@function byPredicate
	@within FindFirstChild

	@param root Instance
	@param recursive boolean -- Whether or not the search should be conducted recursively.
	@param predicate? (Instance) -> boolean -- The conditions under which the search has successfully found a result.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels Breadth-First through the descendants of `root` until it finds an Instance 
	that passes the conditions of the predicate.

	```lua
	local found = byPredicate(workspace, true, function(child)
		-- looking for the first descendant of workspace that's a BasePart and has a certain color
		return child:IsA("BasePart") and child.Color = Color3.fromRGB(100, 120, 80)
	end):expect()
	```
]=]
local function byPredicate(root: Instance, recursive: boolean, predicate: (Instance) -> boolean)
	return Promise.new(function(resolve: (Instance?) -> ())
		local queue = Queue.new(root:GetChildren())

		while queue:getLength() > 0 do
			local front = queue:dequeue()

			if predicate(front) then
				return resolve(front)
			elseif recursive then
				for _, child in front:GetChildren() do
					queue:enqueue(child)
				end
			end
		end

		resolve(nil)
	end)
end

--[=[
	@function byName
	@within FindFirstChild

	@param root Instance
	@param recursive boolean -- Whether or not the search should be conducted recursively.
	@param name string -- The name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels Breadth-First through the descendants of `root` until it finds an Instance with the provided Name.

	```lua
	local found = byName(workspace, false, "Terrain"):expect()
	```
]=]
local function byName(root: Instance, recursive: boolean, name: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstChild(name, recursive))
	end)
end

--[=[
	@function ofClass
	@within FindFirstChild

	@param root Instance
	@param recursive boolean -- Whether or not the search should be conducted recursively.
	@param className string -- The class name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels Breadth-First through the descendants of `root` until it finds an Instance with the provided ClassName.

	```lua
	local found = ofClass(workspace, false, "Part"):expect()
	```
]=]
local function ofClass(root: Instance, recursive: boolean, className: string)
	if recursive then
		return byPredicate(root, true, function(child)
			return child.ClassName == className
		end)
	end

	return Promise.new(function(resolve)
		resolve(root:FindFirstChildOfClass(className))
	end)
end

--[=[
	@function whichIsA
	@within FindFirstChild

	@param root Instance
	@param recursive boolean -- Whether or not the search should be conducted recursively.
	@param className string -- The class name of the Instance being searched for.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels Breadth-First through the descendants of `root` until it finds an Instance with a class 
	equivalent to or a subclass of a given class.

	```lua
	local found = whichIsA(workspace, false, "BasePart"):expect()
	```
]=]
local function whichIsA(root: Instance, recursive: boolean, className: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstChildWhichIsA(className, recursive))
	end)
end

--[=[
	@function byPath
	@within FindFirstChild

	@param root Instance
	@param path { string } -- The path by name from the root to the target Instance.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels the path starting from the `root` until it either cannot find the next step in the path or
	resolves the entire path.

	```lua
	local found = byPath(game, { "Workspace", "Terrain" }):expect()
	```
]=]
local function byPath(root: Instance, path: { string })
	local search = Promise.resolve(root)
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
FindFirstChild.ofClass = RejectIfNil.wrap(ofClass)
FindFirstChild.whichIsA = RejectIfNil.wrap(whichIsA)
FindFirstChild.byPath = RejectIfNil.wrap(byPath)

--

return FindFirstChild
