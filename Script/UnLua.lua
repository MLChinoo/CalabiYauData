local rawget = rawget
local rawset = rawset
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local require = require
local str_sub = string.sub
local GetUProperty = GetUProperty
local SetUProperty = SetUProperty
local RegisterClass = RegisterClass
local RegisterEnum = RegisterEnum
local print = UEPrint
local NotExist = _G._NotExist or {}
local Index = function(t, k)
  local mt = getmetatable(t)
  local super = mt
  while super do
    local v = rawget(super, k)
    if nil ~= v and not rawequal(v, NotExist) then
      rawset(t, k, v)
      return v
    end
    super = rawget(super, "Super")
  end
  local p = mt[k]
  if nil ~= p then
    if "userdata" == type(p) then
      return GetUProperty(t, p)
    elseif "function" == type(p) then
      rawset(t, k, p)
    elseif rawequal(p, NotExist) then
      return nil
    end
  else
    rawset(mt, k, NotExist)
  end
  return p
end
local NewIndex = function(t, k, v)
  local mt = getmetatable(t)
  local p = mt[k]
  if "userdata" == type(p) then
    return SetUProperty(t, p, v)
  end
  rawset(t, k, v)
end
local Class = function(super_name)
  local super_class
  if nil ~= super_name then
    super_class = require(super_name)
  end
  local new_class = {}
  new_class.__index = Index
  new_class.__newindex = NewIndex
  new_class.Super = super_class
  return new_class
end
local global_index = function(t, k)
  if "string" == type(k) then
    local s = str_sub(k, 1, 1)
    if "U" == s or "A" == s or "F" == s then
      RegisterClass(k)
    elseif "E" == s then
      RegisterEnum(k)
    end
  end
  return rawget(t, k)
end
if WITH_UE4_NAMESPACE then
  print("WITH_UE4_NAMESPACE==true")
else
  local global_mt = {}
  global_mt.__index = global_index
  setmetatable(_G, global_mt)
  UE = _G
  UE4 = UE
  print("WITH_UE4_NAMESPACE==false")
end
_G._NotExist = NotExist
_G.print = print
_G.Index = Index
_G.NewIndex = NewIndex
_G.Class = Class
