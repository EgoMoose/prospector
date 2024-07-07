--!strict

type Queue<T> = {
	list: { T },
	index: number,
	length: number,
}

local module = {}

function module.create<T>(list: { T }): Queue<T>
	return {
		index = 1,
		list = list, -- table.clone?
		length = #list,
	}
end

function module.popFront<T>(queue: Queue<T>)
	local popped = queue.list[queue.index]
	queue.list[queue.index] = nil
	queue.index = queue.index + 1
	queue.length = queue.length - 1
	return popped
end

function module.pushBack<T>(queue: Queue<T>, value: T)
	queue.list[queue.index + queue.length] = value
	queue.length = queue.length + 1
end

function module.getLength<T>(queue: Queue<T>): number
	return queue.length
end

return module
