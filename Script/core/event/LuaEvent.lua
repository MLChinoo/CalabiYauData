local LuaEvent = class("LuaEvent")
function LuaEvent:ctor()
  self.multiBroadcastEvent = {}
end
function LuaEvent:Add(func, obj)
  local slot = FuncSlot(func, obj)
  for _, v in ipairs(self.multiBroadcastEvent) do
    if v == slot then
      LogWarn("LuaEvent", "FuncSlot(func:%s obj:%s) have added to lua event", tostring(func), tostring(obj))
      break
    end
  end
  table.insert(self.multiBroadcastEvent, slot)
end
function LuaEvent:Remove(func, obj)
  local slot = FuncSlot(func, obj)
  for i = #self.multiBroadcastEvent, 1, -1 do
    local tmpSlot = self.multiBroadcastEvent[i]
    if tmpSlot == slot then
      table.remove(self.multiBroadcastEvent, i)
    end
  end
end
function LuaEvent:__call(...)
  for _, v in ipairs(self.multiBroadcastEvent) do
    v(...)
  end
end
return LuaEvent
