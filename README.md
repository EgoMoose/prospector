# explore-by-predicate
 
A Roblox lua package for exploring the game hierarchy with predicates and promises

Get it here:

* [Wally](https://wally.run/package/egomoose/explore-by-predicate)
* [Releases](https://github.com/EgoMoose/explore-by-predicate/releases)

## API

```Luau
--[=[
Creates a new promise looking for a child/descendant that matches the conditions of the predicate provided. 
If no child/descendant is found the promise will reject.

@param parent Instance -- The instance to start the search from.
@param recursive boolean? -- If true, this function searches all descendants rather than only the immediate children.
@param predicate (Instance) -> boolean -- This function's is used to check all candidates for resolution eligibility.
@return Promise<Instance>
--]=]
function module.findFirstChildWithPredicate(parent: Instance, recursive: boolean?, predicate: (Instance) -> boolean)

--[=[
Creates a new promise looking for a child/descendant that matches the name provided.
If no child/descendant is found the promise will reject.

@param parent Instance -- The instance to start the search from.
@param name string -- The name of the child / descendant that should be found.
@param recursive boolean? -- If true, this function searches all descendants rather than only the immediate children.
@return Promise<Instance>
--]=]
function module.findFirstChild(parent: Instance, name: string, recursive: boolean?)

--[=[
Chains together a number of `findFirstChild` promises to search one after another for specific child names.
If no child/descendant is found at any point along the path the promise will reject.

This would be short hand for writing:

module.findFirstChild(workspace, "Model"):andThen(function(child)
	return module.findFirstChild(child, "Configuration")
end):andThen(function(child)
	return module.findFirstChild(child, "PrimaryColor")
end)

vs

module.findFirstPath(workspace, { "Model", "Configuration", "PrimaryColor" })

@param parent Instance -- The instance to start the search from.
@param path { string } -- The names in order that should be resolved.
@return Promise<Instance>
--]=]
function module.findFirstPath(parent: Instance, path: { string })

--[=[
Creates a new promise waiting for a child that matches the conditions of the predicate provided.

@param parent Instance -- The instance to start the search from.
@param timeout number? -- If the child is not found within this timeout then the promise will reject.
						  If no timeout is provided then a warning will be sent to the console after 5 seconds.
@param predicate (Instance) -> boolean -- This function's is used to check all candidates for resolution eligibility.
@return Promise<Instance>
--]=]
function module.waitForChildWithPredicate(parent: Instance, timeout: number?, predicate: (Instance) -> boolean)

--[=[
Creates a new promise waiting for a child that matches the name provided.

@param parent Instance -- The instance to start the search from.
@param name string -- The name of the child that should be found.
@param timeout number? -- If the child is not found within this timeout then the promise will reject.
						  If no timeout is provided then a warning will be sent to the console after 5 seconds.
@return Promise<Instance>
--]=]
function module.waitForChild(parent: Instance, name: string, timeout: number?)

--[=[
Chains together a number of `waitForChild` promises to search one after another for specific child names.
The timeout for this function does not reset after a child along the path is found. The entire path needs
to resolve within the timeout length or else the promise will be rejected.

This would be short hand for writing:

module.waitForChild(workspace, "Model"):andThen(function(child)
	return module.waitForChild(child, "Configuration")
end):andThen(function(child)
	return module.waitForChild(child, "PrimaryColor")
end)

vs

module.waitForPath(workspace, { "Model", "Configuration", "PrimaryColor" })

@param parent Instance -- The instance to start the search from.
@param path { string } -- The names in order that should be resolved.
@param timeout number? -- If the entire path is not found within this timeout then the promise will reject.
						  If no timeout is provided then a warning will be sent to the console after 5 seconds.
@return Promise<Instance>
--]=]
function module.waitForPath(parent: Instance, path: { string }, timeout: number?)
```