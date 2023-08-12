local ResultAccountAndRoleMediator = class("ResultAccountAndRoleMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultAccountAndRoleMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultReviceData
  }
end
function ResultAccountAndRoleMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultAccountAndRoleMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultReviceData then
    self:UpdateView()
  end
end
function ResultAccountAndRoleMediator:OnRegister()
  LogDebug("ResultAccountAndRoleMediator", "OnRegister")
  ResultAccountAndRoleMediator.super.OnRegister(self)
  self:UpdateView()
end
function ResultAccountAndRoleMediator:OnRemove()
  LogDebug("ResultAccountAndRoleMediator", "OnRemove")
  ResultAccountAndRoleMediator.super.OnRemove(self)
end
function ResultAccountAndRoleMediator:UpdateView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local SettleBattleGameData = battleResultProxy:GetSettleBattleGameData()
  if not SettleBattleGameData then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local RoleIdSigned = kaNavigationProxy:GetCurrentRoleId()
  local RoleSignedExist = false
  for key, role in pairs(SettleBattleGameData.roles) do
    if role.role_id == RoleIdSigned then
      RoleSignedExist = true
    end
  end
  if RoleSignedExist then
    local CompareFunc = function(a, b)
      if nil == a or nil == b then
        return false
      end
      if a.role_id == RoleIdSigned then
        return true
      end
      if b.role_id == RoleIdSigned then
        return false
      end
      return false
    end
    table.sort(SettleBattleGameData.roles, CompareFunc)
  else
    table.insert(SettleBattleGameData.roles, 1, {
      role_id = RoleIdSigned,
      intimacy = 0,
      is_final = false
    })
  end
  local ResultRoleDatas = {}
  for key, role in pairs(SettleBattleGameData.roles) do
    if role.intimacy > 0 then
      local ResultRoleData = {}
      ResultRoleData.RoleId = role.role_id
      local roleProp = RoleProxy:GetRoleProfile(ResultRoleData.RoleId)
      ResultRoleData.Name = roleProp.NameCn
      local RoleSkinTableRow = RoleProxy:GetRoleDefaultSkin(ResultRoleData.RoleId)
      ResultRoleData.IconRoleSkin = RoleSkinTableRow.IconRoleSkin
      local IntimacysPreBattle = battleResultProxy:GetRoleIntimacysPreBattle(ResultRoleData.RoleId)
      ResultRoleData.PreIntimacyData = {}
      ResultRoleData.PreIntimacyData.Lv = IntimacysPreBattle.IntimacyLv
      ResultRoleData.PreIntimacyData.Intimacy = IntimacysPreBattle.Intimacy
      local RoleFavorabilityTableRow = RoleProxy:GetRoleFavoribility(ResultRoleData.PreIntimacyData.Lv)
      ResultRoleData.PreIntimacyData.UpIntimacy = RoleFavorabilityTableRow.FExp
      local roleApartmentInfo = KaPhoneProxy:GetRoleProperties(ResultRoleData.RoleId)
      if roleApartmentInfo then
        ResultRoleData.NewIntimacyData = {}
        ResultRoleData.NewIntimacyData.Lv = roleApartmentInfo.intimacy_lv
        ResultRoleData.NewIntimacyData.Intimacy = roleApartmentInfo.intimacy
        local RoleFavorabilityTableRow = RoleProxy:GetRoleFavoribility(ResultRoleData.NewIntimacyData.Lv)
        ResultRoleData.NewIntimacyData.UpIntimacy = RoleFavorabilityTableRow.FExp
        ResultRoleData.CurIntimacyData = table.clone(ResultRoleData.PreIntimacyData)
        ResultRoleData.IntimacyAdd = role.intimacy
        ResultRoleData.RoleTasks = battleResultProxy:GetSignedRoleTasks(ResultRoleData.RoleId)
        table.insert(ResultRoleDatas, ResultRoleData)
      else
        LogDebug("KaPhoneProxy", "GetRoleProperties fail, RoleId = %s", ResultRoleData.RoleId)
      end
    end
  end
  LogDebug("ResultRoleDatas", TableToString(ResultRoleDatas))
  self.viewComponent:UpdateRole(ResultRoleDatas)
end
return ResultAccountAndRoleMediator
