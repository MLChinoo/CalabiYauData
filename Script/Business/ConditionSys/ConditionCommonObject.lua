local ConditionCommonObject = Class()
function ConditionCommonObject:BPGetMatchConditionCount(luaModule, paramStr)
  local moduleTable = require(luaModule)
  if moduleTable then
    if type(moduleTable.BPGetMatchConditionCount) == "function" then
      return moduleTable:BPGetMatchConditionCount(paramStr)
    else
      LogError("conditionsys", "lua file %s have no function %s", luaModule, "BPGetMatchConditionCount")
    end
  else
    LogError("conditionsys", "no lua file %s", luaModule)
  end
  return -1
end
return ConditionCommonObject
