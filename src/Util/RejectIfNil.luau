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

-- Public

function RejectIfNil.wrap<T, U..., V...>(func: (U...) -> T, ...: V...)
	local unpackVarArgs = packVarArgs(...)

	return function(...: U...)
		local promise = func(...) :: any
		if ENABLED then
			return promise:andThen(function(found)
				if not found then
					return Promise.reject(unpackVarArgs())
				end
				return found
			end) :: T
		else
			return promise :: T
		end
	end
end

--

return RejectIfNil
