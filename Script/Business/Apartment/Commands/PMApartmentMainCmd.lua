local PMApartmentMainCmd = class("PMApartmentMainCmd", PureMVC.Command)
function PMApartmentMainCmd:Execute(notification)
  local Type = notification:GetType()
  if Type == NotificationDefines.ApartmentRoleUpgrade then
    local contractUpgradeInfo = self:GetRoleUpdataInfo(notification:GetBody())
    GameFacade:SendNotification(NotificationDefines.PMApartmentMainCmd, contractUpgradeInfo, NotificationDefines.UpdateApartmentScene.ShowRoleUpgrade)
  elseif Type == NotificationDefines.ApartmentContract.ShowUpGradeEff then
    self:ShowContractUpGrade(notification:GetBody())
  end
end
function PMApartmentMainCmd:GetRoleCurData()
  local data = {
    roleId = 0,
    roleIntimacy = 1,
    roleIntimacyLv = 1
  }
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local roleProp = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  LogInfo("PMApartmentMainCmd Navigator To RoleId ====" .. CurrentRoleId)
  data.roleId = CurrentRoleId
  if roleProp then
    data.roleIntimacy = roleProp.intimacy
    data.roleIntimacyLv = roleProp.intimacy_lv
  end
  return data
end
function PMApartmentMainCmd:GetRoleUpdataInfo(info)
  local data = {}
  data.roleId = info.role_id
  data.roleIntimacy = info.intimacy
  data.roleIntimacyLv = info.intimacy_lv
  data.upgrade_lv = info.upgrade_lv
  data.add_intimacy = info.add_intimacy
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProp = RoleProxy:GetRoleProfile(info.role_id)
  data.roleNameCn = roleProp.NameShortCn
  local roleFavorible = RoleProxy:GetRoleFavoribility(data.roleIntimacyLv)
  data.roleNextIntimacy = roleFavorible.FExp
  data.roleIntimacyNickName = roleFavorible.Name
  return data
end
function PMApartmentMainCmd:ShowContractUpGrade(effInfo)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ApartmentContractUpGradePage, nil, effInfo)
end
return PMApartmentMainCmd
