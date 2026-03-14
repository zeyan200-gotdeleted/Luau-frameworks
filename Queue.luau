local Queue = {}; Queue.__index = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	self._items = {}
	self._start = 1
	self._end = 0
	return self
end

function Queue:Push(fn)
	self._end += 1
	self._items[self._end] = fn
end

function Queue:RunNext(...)
	if self._start > self._end then
		return
	end

	local fn = self._items[self._start]
	self._items[self._start] = nil
	self._start += 1

	if self._start > self._end then
		self._start = 1
		self._end = 0
	end

	return fn(...)
end

function Queue:Clear( ) 
	self._items = {}
	self._start = 1
	self._end = 0
end

return Queue
