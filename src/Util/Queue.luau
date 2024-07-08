--!strict

-- Class

local QueueClass = {}
QueueClass.__index = QueueClass
QueueClass.ClassName = "Queue"

export type Queue<T> = typeof(setmetatable(
	{} :: {
		list: { T },
		index: number,
		length: number,
	},
	QueueClass
))

-- Constructors

function QueueClass.new<T>(list: { T }): Queue<T>
	local self = setmetatable({}, QueueClass) :: Queue<T>

	self.index = 1
	self.list = list
	self.length = #list

	return self
end

-- Public Methods

function QueueClass.dequeue<T>(self: Queue<T>)
	local front = self.list[self.index]
	self.list[self.index] = nil
	self.index = self.index + 1
	self.length = self.length - 1
	return front
end

function QueueClass.enqueue<T>(self: Queue<T>, value: T)
	self.list[self.index + self.length] = value
	self.length = self.length + 1
end

function QueueClass.getLength<T>(self: Queue<T>)
	return self.length
end

--

return QueueClass
