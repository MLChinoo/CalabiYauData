local IntimacyLvCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function IntimacyLvCond:BPGetMatchConditionCount(paramStr)
  LogDebug("IntimacyLvCond", "default IntimacyLvCond is false")
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local value = conditionProxy:GetValueByRoleIDAndKey(CurrentRoleId, RoleAttrMap.RoleSettingKey.RoleLikeLv) or 1
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  if KaPhoneProxy.RolesProperties then
    local properties = KaPhoneProxy.RolesProperties[CurrentRoleId]
    if properties then
      local roleIntimacyLv = properties.intimacy_lv
      if value < roleIntimacyLv then
        LogInfo("IntimacyLvCond:BPGetMatchConditionCount", "value < roleIntimacyLv value is " .. tostring(value) .. " roleIntimacyLv " .. tostring(roleIntimacyLv))
        return 1
      else
        LogInfo("IntimacyLvCond:BPGetMatchConditionCount", "value >= roleIntimacyLv value is " .. tostring(value) .. " roleIntimacyLv " .. tostring(roleIntimacyLv))
      end
    else
      LogInfo("IntimacyLvCond:BPGetMatchConditionCount", "no properties")
    end
  else
    LogInfo("IntimacyLvCond:BPGetMatchConditionCount", "no KaPhoneProxy.RolesProperties")
  end
  return 0
end
function IntimacyLvCond:Update()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local roleIntimacyLv
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  if KaPhoneProxy.RolesProperties then
    local properties = KaPhoneProxy.RolesProperties[currentRoleId]
    if properties then
      roleIntimacyLv = properties.intimacy_lv
    end
  end
  if nil == roleIntimacyLv then
    LogInfo("IntimacyLvCond ", "roleIntimacyLv is nil")
    return
  end
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  conditionProxy:SaveSettingByRoleId(RoleAttrMap.RoleSettingKey.RoleLikeLv, roleIntimacyLv, currentRoleId)
end
return IntimacyLvCond
