--!strict

-- Class

local ConnectionMaidClass = {}
ConnectionMaidClass.__index = ConnectionMaidClass
ConnectionMaidClass.ClassName = "ConnectionMaid"

export type ConnectionMaid = typeof(setmetatable(
	{} :: {
		isDestroyed: boolean,
		connectionsSet: { [RBXScriptConnection]: boolean },
	},
	ConnectionMaidClass
))

-- Constructors

function ConnectionMaidClass.new(): ConnectionMaid
	local self = setmetatable({}, ConnectionMaidClass) :: ConnectionMaid

	self.isDestroyed = false
	self.connectionsSet = {}

	return self
end

-- Public Methods

function ConnectionMaidClass.mark(self: ConnectionMaid, connection: RBXScriptConnection)
	assert(not self.isDestroyed, "The ConnectionMaid is destroyed.")
	self.connectionsSet[connection] = true
end

function ConnectionMaidClass.unmark(self: ConnectionMaid, connection: RBXScriptConnection)
	assert(not self.isDestroyed, "The ConnectionMaid is destroyed.")
	self.connectionsSet[connection] = nil
end

function ConnectionMaidClass.clean(self: ConnectionMaid)
	assert(not self.isDestroyed, "The ConnectionMaid is destroyed.")
	for connection, _ in self.connectionsSet do
		connection:Disconnect()
		self:unmark(connection)
	end
end

function ConnectionMaidClass.destroy(self: ConnectionMaid)
	self:clean()
	self.isDestroyed = true
end

--

return ConnectionMaidClass
