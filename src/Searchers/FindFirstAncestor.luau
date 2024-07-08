--!strict

local root = script.Parent.Parent
local RejectIfNil = require(root.Util.RejectIfNil)

local packages = root.Parent
local Promise = require(packages.Promise)

local FindFirstAncestor = {}

-- Private

local function byPredicate(descendant: Instance, predicate: (Instance) -> boolean)
	return Promise.new(function(resolve: (Instance?) -> ())
		local parent = descendant.Parent
		while parent do
			if predicate(parent) then
				return resolve(parent)
			end
			parent = parent.Parent
		end

		resolve(nil)
	end)
end

local function byName(descendant: Instance, name: string)
	return Promise.new(function(resolve)
		resolve(descendant:FindFirstAncestor(name))
	end)
end

local function ofClass(descendant: Instance, className: string)
	return Promise.new(function(resolve)
		resolve(descendant:FindFirstAncestorOfClass(className))
	end)
end

local function whichIsA(descendant: Instance, className: string)
	return Promise.new(function(resolve)
		resolve(descendant:FindFirstAncestorWhichIsA(className))
	end)
end

-- Public

FindFirstAncestor.byPredicate = RejectIfNil.wrap(byPredicate)
FindFirstAncestor.byName = RejectIfNil.wrap(byName)
FindFirstAncestor.ofClass = RejectIfNil.wrap(ofClass)
FindFirstAncestor.whichIsA = RejectIfNil.wrap(whichIsA)

--

return FindFirstAncestor
