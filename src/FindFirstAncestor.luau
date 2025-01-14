--!strict

--[=[
	@class FindFirstAncestor

	FindFirstAncestor is a set of functions that search for ancestors conditionally.
]=]
local FindFirstAncestor = {}

-- Public

--[=[
	@function byPredicate
	@within FindFirstAncestor

	@param root Instance
	@param predicate? (Instance, number) -> boolean -- The conditions under which the search has successfully found a result. The second parameter represents depth.
	@return Instance? -- The result of the search.

	Travels up through the ancestry of `root` until it finds an Instance that passes the conditions of the predicate.

	```lua
	local found = byPredicate(workspace.Terrain, function(ancestor)
		return ancestor.Name ~= "NotThisName"
	end)
	```
]=]
function FindFirstAncestor.byPredicate(root: Instance, predicate: (Instance, number) -> boolean): Instance?
	local depth = 1
	local parent = root.Parent
	while parent do
		if predicate(parent, depth) then
			return parent
		end
		parent = parent.Parent
		depth = depth + 1
	end

	return nil
end

--[=[
	@function byName
	@within FindFirstAncestor

	@param root Instance
	@param name string -- The name of the Instance being searched for.
	@return Instance? -- The result of the search.

	Travels up through the ancestry of `root` until it finds an Instance that matches the provided name.

	```lua
	local found = byName(workspace.Terrain, "Workspace")
	```
]=]
function FindFirstAncestor.byName(root: Instance, name: string)
	return root:FindFirstAncestor(name)
end

--[=[
	@function ofClass
	@within FindFirstAncestor

	@param root Instance
	@param className string -- The class name of the Instance being searched for.
	@return Instance? -- The result of the search.

	Travels up through the ancestry of `root` until it finds an Instance that matches the provided ClassName.

	```lua
	local found = ofClass(workspace.Terrain, "Workspace")
	```
]=]
function FindFirstAncestor.ofClass(root: Instance, className: string)
	return root:FindFirstAncestorOfClass(className)
end

--[=[
	@function whichIsA
	@within FindFirstAncestor

	@param root Instance
	@param className string -- The class name of the Instance being searched for.
	@return Instance? -- The result of the search.

	Travels up through the ancestry of `root` until it finds an Instance with a class equivalent to or a subclass of a given class.

	```lua
	local found = whichIsA(workspace.Terrain, "WorldRoot")
	```
]=]
function FindFirstAncestor.whichIsA(root: Instance, className: string)
	return root:FindFirstAncestorWhichIsA(className)
end

--[=[
	@function byDepth
	@within FindFirstAncestor

	@param root Instance
	@param depth number -- How many steps upwards to be traveled.
	@return Instance? -- The result of the search.

	Travels up through the ancestry of `root` by `depth` number of steps.

	```lua
	local found = byDepth(workspace.Terrain, 2)
	print(found == game)
	```
]=]
function FindFirstAncestor.byDepth(root: Instance, depth: number): Instance?
	local count = 0
	local parent = root
	while count < depth do
		parent = parent.Parent :: Instance
		if not parent then
			return nil
		end
		count = count + 1
	end

	return parent
end

--

return FindFirstAncestor
