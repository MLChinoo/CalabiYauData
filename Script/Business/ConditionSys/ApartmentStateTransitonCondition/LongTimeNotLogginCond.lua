local LongTimeNotLogginCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function LongTimeNotLogginCond:BPGetMatchConditionCount(paramStr)
  LogDebug("LongTimeNotLogginCond", "default LongTimeNotLogginCond is false")
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local roleSettings = conditionProxy:GetRoleSettings()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local value = conditionProxy:GetValueByRoleIDAndKey(CurrentRoleId, RoleAttrMap.RoleSettingKey.RoleTime)
  if nil == value then
    LogInfo("LongTimeNotLogginCond", "value is nil")
    return 0
  end
  local currentServerTime = UE4.UPMLuaBridgeBlueprintLibrary:GetServerTime()
  LogInfo("LongTimeNotLogginCond", "value is " .. tostring(value) .. " currentServerTime is " .. tostring(currentServerTime))
  local time = 86400
  local configData = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):GetApartmentConfigData()
  if configData then
    time = configData.HowLongEnterTime
  end
  if time < currentServerTime - value then
    return 1
  end
  return 0
end
function LongTimeNotLogginCond:Update()
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local roleSettings = conditionProxy:GetRoleSettings()
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local CurrentTime = UE4.UPMLuaBridgeBlueprintLibrary:GetServerTime()
  conditionProxy:SaveSettingByRoleId(RoleAttrMap.RoleSettingKey.RoleTime, CurrentTime, CurrentRoleId)
  LogInfo("ApartmentConditionProxy", "UpdateLongTimeNotLogginCond CurrentTime " .. tostring(CurrentTime) .. "CurrentRoleId" .. tostring(CurrentRoleId))
end
return LongTimeNotLogginCond
