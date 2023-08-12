local Queue = class("Queue")
function Queue:ctor()
  self.queue = {}
  self.head = 0
  self.rear = -1
end
function Queue:PushFront(element)
  self.head = self.head - 1
  self.queue[self.head] = element
end
function Queue:PushBack(element)
  self.rear = self.rear + 1
  self.queue[self.rear] = element
end
function Queue:PopFront()
  if self.head > self.rear then
    LogInfo("Queue is empty")
    return nil
  end
  local value = self.queue[self.head]
  self.queue[self.head] = nil
  self.head = self.head + 1
  return value
end
function Queue:PopBack()
  if self.head > self.rear then
    LogInfo("Queue is empty")
    return nil
  end
  local value = self.queue[self.rear]
  self.queue[self.rear] = nil
  self.rear = self.rear - 1
  return value
end
function Queue:Peek()
  if self.head > self.rear then
    LogInfo("Queue is empty")
    return nil
  end
  local value = self.queue[self.head]
  return value
end
function Queue:Clear()
  self.queue = nil
  self.queue = {}
  self.head = 0
  self.rear = -1
end
function Queue:IsEmpty()
  local size = self.rear - self.head + 1
  if 0 == size then
    return true
  end
  return false
end
function Queue:Size()
  local size = self.rear - self.head + 1
  return size
end
function Queue:PrintElements()
  local h = self.head
  local r = self.rear
  if 0 == #self.queue then
    return
  end
  LogInfo("********* Queue PrintElements *********")
  for index = h, r do
    LogInfo("Element:", self.queue[index])
  end
end
return Queue
