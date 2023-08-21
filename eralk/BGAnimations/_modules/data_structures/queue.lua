local Queue = {}
Queue.__index = Queue

function Queue:new()
  local o = { first = 0, last = -1 }
  setmetatable(o, self)
  return o
end

function Queue:enqueue(val)
  local last = self.last + 1
  self.last = last
  self[last] = val
end

function Queue:size()
  return self.last - self.first + 1
end

function Queue:dequeue()
  local first = self.first
  if first > self.last then
    error("queue is empty")
  end
  local val = self[first]
  self[first] = nil
  self.first = first + 1
  return val
end

return Queue
