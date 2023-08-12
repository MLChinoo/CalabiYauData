local FirstEnterCharacterRoomCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function FirstEnterCharacterRoomCond:BPGetMatchConditionCount(paramStr)
  LogDebug("FirstEnterCharacterRoomCond", "default firstEnterCharacterRoomCond is false")
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if NewPlayerGuideProxy:IsAllGuideComplete() == false then
    return 0
  else
    local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
    local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
    local ApartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy)
    local roleskin = ApartmentRoomProxy:GetRoleWearSkinID(CurrentRoleId)
    local value = conditionProxy:GetValueByRoleIDAndKey(CurrentRoleId, roleskin)
    LogInfo("FirstEnterCharacterRoomCond", "value is " .. tostring(value) .. "CurrentRoleId " .. tostring(CurrentRoleId))
    local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local role = RoleProxy:GetRole(CurrentRoleId)
    if role and (role.Navigation == GlobalEnumDefine.EApartmentNavigation.ShowNewGuideDefault or role.Navigation == GlobalEnumDefine.EApartmentNavigation.ShowAllDefault) then
      return 0
    end
    if value == RoleAttrMap.FirstGoApartmentFlag then
      return 0
    end
    return 1
  end
end
function FirstEnterCharacterRoomCond:Update()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
  local conditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local ApartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy)
  local roleSkin = ApartmentRoomProxy:GetRoleWearSkinID(CurrentRoleId)
  conditionProxy:SaveSettingByRoleId(roleSkin, RoleAttrMap.FirstGoApartmentFlag, CurrentRoleId)
  KaChatProxy:UpdateRedDotNum()
end
return FirstEnterCharacterRoomCond
