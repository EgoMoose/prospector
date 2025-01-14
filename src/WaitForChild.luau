--!strict

local Trove = require(script.Parent.Parent.Trove)
local Future = require(script.Parent.Helpers.Future)

--[=[
	@class WaitForChild

	WaitForChild is a set of functions that waits for descendants conditionally.
]=]
local WaitForChild = {}

-- Public

--[=[
	@function byPredicate
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param predicate? (Instance) -> boolean -- The conditions under which the search has successfully found a result.
	@return Instance? -- The result of the search.

	First looks through the children of `root` for an Instance that passes the conditions of the predicate and if none 
	are found begins listening for new instances and changes to existing ones.

	```lua
	local found = byPredicate(workspace, math.huge, function(child)
		-- waiting for the first descendant of workspace that's a BasePart and has a certain color
		return child:IsA("BasePart") and child.Color = Color3.fromRGB(100, 120, 80)
	end)
	```
]=]
function WaitForChild.byPredicate(root: Instance, timeout: number, predicate: (Instance) -> boolean)
	assert(timeout > 0, "timeout must be greater than 0")

	local trove = Trove.new()
	local search = Future.raw()

	local function complete(instance: Instance?)
		if not search:isCompleted() then
			search:complete(instance)
		end
	end

	local tracking = {}
	local function track(child: Instance)
		if tracking[child] then
			return
		end
		tracking[child] = true

		trove:Add(child.Changed:Connect(function()
			if child.Parent == root and predicate(child) then
				complete(child)
			end
		end))

		trove:Add(child.AttributeChanged:Connect(function()
			if child.Parent == root and predicate(child) then
				complete(child)
			end
		end))
	end

	local function check(child: Instance)
		if child.Parent == root and predicate(child) then
			complete(child)
			return
		end
		track(child)
	end

	for _, child in root:GetChildren() do
		check(child)
	end

	trove:Add(root.ChildAdded:Connect(function(child)
		check(child)
	end))

	local thread: thread?
	if timeout < math.huge then
		thread = task.spawn(function()
			task.wait(timeout)
			complete(nil)
		end)
	end

	local result = search:expect()
	if thread then
		task.defer(function()
			if coroutine.status(thread) ~= "dead" then
				coroutine.close(thread)
			end
		end)
	end

	trove:Destroy()
	return result
end

--[=[
	@function byName
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param name string -- The name of the Instance being searched for.
	@return Instance? -- The result of the search.

	First looks through the children of `root` for an Instance with the same name and if none are found begins 
	listening for new instances and changes to existing ones.

	```lua
	local found = byName(workspace, math.huge, "Part")
	```
]=]
function WaitForChild.byName(root: Instance, timeout: number, name: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return root:WaitForChild(name, timeout)
end

--[=[
	@function ofClass
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param className string -- The class name of the Instance being searched for.
	@return Instance? -- The result of the search.

	First looks through the children of `root` for an Instance with the same ClassName and if none are found begins 
	listening for new instances and changes to existing ones.

	```lua
	local found = ofClass(workspace, math.huge, "Part")
	```
]=]
function WaitForChild.ofClass(root: Instance, timeout: number, className: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return WaitForChild.byPredicate(root, timeout, function(child)
		return child.ClassName == className
	end)
end

--[=[
	@function whichIsA
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param className string -- The class name of the Instance being search for.
	@return Instance? -- The result of the search.

	First looks through the children of `root` for an Instance that's equivalent to or a subclass of a given class
	and if if none are found then begins listening for new instances and changes to existing ones.

	```lua
	local found = whichIsA(workspace, math.huge, "BasePart")
	```
]=]
function WaitForChild.whichIsA(root: Instance, timeout: number, className: string)
	assert(timeout > 0, "timeout must be greater than 0")

	return WaitForChild.byPredicate(root, timeout, function(child)
		return child:IsA(className)
	end)
end

--[=[
	@function byPath
	@within WaitForChild

	@param root Instance
	@param timeout number -- How long before the promise automatically resolves as nil.
	@param path { string } -- The path by name from the root to the target Instance.
	@return Instance? -- The result of the search.

	Travels the path starting from the `root` instance and if none are found begins listening for new instances and 
	changes to existing ones at each step.

	```lua
	local found = byPath(game, math.huge, { "Workspace", "Terrain" })
	```
]=]
function WaitForChild.byPath(root: Instance, timeout: number, path: { string }): Instance?
	assert(timeout > 0, "timeout must be greater than 0")

	local t = os.clock()
	local found = root :: Instance?
	for _, name in path do
		local remaining = timeout - (os.clock() - t)
		if remaining > 0 then
			found = found and WaitForChild.byName(found, timeout, name)
		else
			return nil
		end
	end

	return found
end

--

return WaitForChild
