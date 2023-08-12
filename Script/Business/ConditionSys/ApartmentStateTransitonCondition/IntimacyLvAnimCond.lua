local IntimacyLvAnimCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function IntimacyLvAnimCond:BPGetMatchConditionCount(paramStr)
  LogDebug("IntimacyLvAnimCond", "default IntimacyLvAnimCond is false")
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local value = conditionProxy:GetValueByRoleIDAndKey(CurrentRoleId, RoleAttrMap.RoleSettingKey.RoleLikeLvAnim) or 1
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  if KaPhoneProxy.RolesProperties then
    local properties = KaPhoneProxy.RolesProperties[CurrentRoleId]
    if properties then
      local roleIntimacyLv = properties.intimacy_lv
      if value < roleIntimacyLv then
        LogInfo("IntimacyLvAnimCond:BPGetMatchConditionCount", "value < roleIntimacyLv value is " .. tostring(value) .. " roleIntimacyLv " .. tostring(roleIntimacyLv))
        return 1
      else
        LogInfo("IntimacyLvAnimCond:BPGetMatchConditionCount", "value >= roleIntimacyLv value is " .. tostring(value) .. " roleIntimacyLv " .. tostring(roleIntimacyLv))
      end
    else
      LogInfo("IntimacyLvAnimCond:BPGetMatchConditionCount", "no properties")
    end
  else
    LogInfo("IntimacyLvAnimCond:BPGetMatchConditionCount", "no KaPhoneProxy.RolesProperties")
  end
  return 0
end
function IntimacyLvAnimCond:Update()
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
  conditionProxy:SaveSettingByRoleId(RoleAttrMap.RoleSettingKey.RoleLikeLvAnim, roleIntimacyLv, currentRoleId)
end
return IntimacyLvAnimCond
