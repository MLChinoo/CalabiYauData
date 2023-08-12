local ApartmentRoleInfoChangedCmd = class("ApartmentRoleInfoChangedCmd", PureMVC.Command)
function ApartmentRoleInfoChangedCmd:Execute(notification)
  local AddSlashText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "AddSlash")
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  if nil == CurrentRoleId then
    return
  end
  local RoleProperties = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  local RoleLvData = RoleProxy:GetRoleFavoribility(RoleProperties.intimacy_lv)
  local CurExp = RoleProperties.intimacy
  local TotalExp = RoleLvData.FExp
  if RoleProperties.intimacy_lv > 1 then
    local LastRoleLvData = RoleProxy:GetRoleFavoribility(RoleProperties.intimacy_lv - 1)
    CurExp = CurExp - LastRoleLvData.FExp
    TotalExp = RoleLvData.FExp - LastRoleLvData.FExp
  end
  CurExp = math.clamp(CurExp, 0, TotalExp)
  local TextExpNowParam = ObjectUtil:GetTextFromFormat(AddSlashText, {
    [0] = CurExp,
    [1] = TotalExp
  })
  if RoleProperties.intimacy_lv == RoleProxy:GetRoleFavorabilityMaxLv() then
    TextExpNowParam = "MAX"
    CurExp = TotalExp
  end
  local Body = {
    TextLevel = RoleProperties.intimacy_lv,
    TextLevelName = RoleLvData.Name,
    TextExpNow = TextExpNowParam,
    ProgressLevel = CurExp / TotalExp
  }
  GameFacade:SendNotification(NotificationDefines.SetApartmentRoleInfo, Body)
end
return ApartmentRoleInfoChangedCmd
