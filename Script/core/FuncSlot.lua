local setmetatable = setmetatable
local _func_slot = {}
setmetatable(_func_slot, _func_slot)
function _func_slot:__call(...)
  if nil == self.obj then
    return self.func(...)
  else
    return self.func(self.obj, ...)
  end
end
function _func_slot.__eq(lhs, rhs)
  return lhs.func == rhs.func and lhs.obj == rhs.obj
end
local FuncSlot = function(func, obj)
  return setmetatable({func = func, obj = obj}, _func_slot)
end
_G.FuncSlot = FuncSlot
return _func_slot
