require("UnLua")
local ConditionSystem = Class()
function ConditionSystem:CreateLuaUObject(outer, classType, moduleName)
  LogDebug("conditionsys", "Bind lua file %s", moduleName)
  return ObjectUtil:CreateLuaUObjectExt(outer, classType, moduleName)
end
return ConditionSystem
