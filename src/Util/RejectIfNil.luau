--!strict

local root = script.Parent.Parent
local packages = root.Parent
local Promise = require(packages.Promise)

local ENABLED = false

local RejectIfNil = {}

-- Private

local function packVarArgs<T...>(...: T...): () -> T...
	local args = { select(1, ...) }
	local nArgs = select("#", ...)

	return function()
		return unpack(args, 1, nArgs)
	end
end

local function argMatch<T..., U...>(unpackVarArgs: () -> T..., ...: U...)
	local args = { select(1, ...) }
	local nArgs = select("#", ...)

	local args2 = { select(1, unpackVarArgs()) }
	local nArgs2 = select("#", unpackVarArgs())

	if nArgs == nArgs2 then
		for i = 1, nArgs do
			if args[i] ~= args2[i] then
				return false
			end
		end
		return true
	end
	return false
end

-- Public

function RejectIfNil.wrap<T, U..., V...>(func: (U...) -> T, ...: V...)
	local unpackVarArgs = packVarArgs(...)

	return function(...: U...)
		local promise = func(...) :: any
		if ENABLED then
			return promise:andThen(function(...)
				-- reject only if a singular nil return
				if argMatch(packVarArgs(...), nil) then
					return Promise.reject(unpackVarArgs())
				end
				return ...
			end) :: T
		else
			return promise :: T
		end
	end
end

--

return RejectIfNil
