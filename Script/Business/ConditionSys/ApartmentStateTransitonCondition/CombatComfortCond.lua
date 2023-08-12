local CombatComfortCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function CombatComfortCond:BPGetMatchConditionCount(paramStr)
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  if conditionProxy.newResultFlag ~= UE4.ECyBattleResultType.None then
    LogInfo("CombatComfortCond", "retirm 1")
    return 1
  end
  LogInfo("CombatComfortCond", "retirm 0")
  return 0
end
function CombatComfortCond:Update()
  self:UpdateBattleResult()
end
function CombatComfortCond:GetBattlePlayStatus()
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  return conditionProxy.newResultFlag
end
function CombatComfortCond:UpdateBattleResult()
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  conditionProxy.newResultFlag = UE4.ECyBattleResultType.None
end
return CombatComfortCond
