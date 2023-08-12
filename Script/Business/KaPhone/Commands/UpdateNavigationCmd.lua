local UpdateNavigationCmd = class("UpdateNavigationCmd", PureMVC.Command)
local KaPhoneProxy, RoleProxy, kaNavigationProxy
function UpdateNavigationCmd:Execute(notification)
  KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  GameFacade:SendNotification(NotificationDefines.NtfKaNavigation, self:GetAllNavigationData())
end
function UpdateNavigationCmd:GetAllNavigationData()
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local UnLockRoles = KaPhoneProxy:GetUnLockRoles()
  local CurRoleProperties = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  local CurRoleInfo = RoleProxy:GetRoleProfile(CurrentRoleId)
  local CurRoleSkinId = RoleProxy:GetRoleCurrentWearSkinID(CurrentRoleId)
  local CurRoleSkinInfos = RoleProxy:GetRoleSkin(CurRoleSkinId)
  local Result = {}
  if nil == CurRoleProperties or nil == CurRoleInfo or nil == CurRoleSkinId or nil == CurRoleSkinInfos then
    return nil
  end
  Result.Current = {
    RoleId = CurrentRoleId,
    Name = CurRoleInfo.NameShortCn,
    Address = CurRoleInfo.Apartment,
    LoveLevel = CurRoleProperties.intimacy_lv,
    Avatar = CurRoleSkinInfos.IconRoleMoments
  }
  Result.Others = {}
  for i, v in pairs(UnLockRoles or {}) do
    if RoleProxy:GetRole(v.role_id) then
      local InCurRoleNavigation = RoleProxy:GetRole(v.role_id).Navigation
      if v.role_id ~= CurrentRoleId and InCurRoleNavigation ~= GlobalEnumDefine.EApartmentNavigation.None then
        local InCurRoleInfo = RoleProxy:GetRoleProfile(v.role_id)
        local InCurRoleSkinId = RoleProxy:GetRoleCurrentWearSkinID(v.role_id)
        local InCurRoleSkinInfos = RoleProxy:GetRoleSkin(InCurRoleSkinId)
        local Other = {
          RoleId = v.role_id,
          LoveLevel = v.intimacy_lv,
          Name = InCurRoleInfo.NameShortCn,
          Avatar = InCurRoleSkinInfos.IconRoleMoments,
          Address = InCurRoleInfo.Apartment
        }
        table.insert(Result.Others, Other)
      end
    end
  end
  table.sort(Result.Others, function(a, b)
    if a and b then
      if a.LoveLevel > b.LoveLevel then
        return true
      elseif a.LoveLevel == b.LoveLevel and a.RoleId < b.RoleId then
        return true
      end
    end
    return false
  end)
  return Result
end
return UpdateNavigationCmd
