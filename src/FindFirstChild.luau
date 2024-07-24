--!strict

local rootPackage = script.Parent
local RejectIfNil = require(rootPackage.Util.RejectIfNil)

local packages = rootPackage.Parent
local Deque = require(packages.Deque)
local Promise = require(packages.Promise)

--[=[
	@class FindFirstChild

	FindFirstChild is a set of functions that search for descendants conditionally.
]=]
local FindFirstChild = {}

-- Private

local function byPredicate(root: Instance, recursive: boolean, predicate: (Instance, number) -> boolean?)
	return Promise.new(function(resolve: (Instance?) -> ())
		local depthMap = {}
		local children = root:GetChildren()
		for _, child in children do
			depthMap[child] = 1
		end

		local queue = Deque.raw(root:GetChildren())
		while queue:getLength() > 0 do
			local front = queue:popFront()
			local depth = depthMap[front]

			local result = predicate(front, depth)
			if result == true then
				return resolve(front)
			elseif recursive and result == false then
				for _, child in front:GetChildren() do
					depthMap[child] = depth + 1
					queue:pushBack(child)
				end
			end
		end

		resolve(nil)
	end)
end

local function byName(root: Instance, recursive: boolean, name: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstChild(name, recursive))
	end)
end

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

local function whichIsA(root: Instance, recursive: boolean, className: string)
	return Promise.new(function(resolve)
		resolve(root:FindFirstChildWhichIsA(className, recursive))
	end)
end

local function byPath(root: Instance, path: { string })
	local search = Promise.resolve(root)
	for _, name in path do
		search = search:andThen(function(child)
			return byName(child, false, name)
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
	@within FindFirstChild

	@param root Instance
	@param recursive boolean -- Whether or not the search should be conducted recursively.
	@param predicate? (Instance, number) -> boolean -- The conditions under which the search has successfully found a result. The second parameter represents depth.
	@return Promise<Instance?> -- The result of the search wrapped as a promise.

	Travels Breadth-First through the descendants of `root` until it finds an Instance 
	that passes the conditions of the predicate.

	The predicate of this function can return `true`, `false`, or `nil` with different behaviors for each:
	* `true`: The Instance successfully matches the criteria of the search.
	* `false`: The Instance does not match the criteria of the search, but will continue to look through its descendants.
	* `nil`: The Instance does not match the criteria of the search and will **not** continue to look through its descendants.

	The distinction between `false` and `nil` only applies when `recursive = true`.

	```lua
	local found = byPredicate(workspace, true, function(descendant, depth)
		-- looking for the first descendant of workspace that's a BasePart and has a certain color
		return descendant:IsA("BasePart") and descendant.Color = Color3.fromRGB(100, 120, 80)
	end):expect()
	```
]=]
function FindFirstChild.byPredicate(root: Instance, recursive: boolean, predicate: (Instance, number) -> boolean?)
	return byPredicateWrapped(root, recursive, predicate)
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
function FindFirstChild.byName(root: Instance, recursive: boolean, name: string)
	return byNameWrapped(root, recursive, name)
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
function FindFirstChild.ofClass(root: Instance, recursive: boolean, className: string)
	return ofClassWrapped(root, recursive, className)
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
function FindFirstChild.whichIsA(root: Instance, recursive: boolean, className: string)
	return whichIsAWrapped(root, recursive, className)
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
function FindFirstChild.byPath(root: Instance, path: { string })
	return byPathWrapped(root, path)
end

--

return FindFirstChild
