local CombatSettingPanelMediator = class("CombatSettingPanelMediator", PureMVC.Mediator)
function CombatSettingPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingSwitchSingleEnemyChatNtf
  }
end
function CombatSettingPanelMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingSwitchSingleEnemyChatNtf then
    self:GetViewComponent():SetAllCompetitorChatChecked(body.bChecked)
  end
end
function CombatSettingPanelMediator:OnRegister()
  self.super:OnRegister()
  self:InitView()
end
function CombatSettingPanelMediator:InitView()
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  local GameState = UE4.UGameplayStatics.GetGameState(self:GetViewComponent())
  local data = SettingCombatProxy:GetPlayerData(GameState:GetModeType())
  self:GetViewComponent():SetData(data)
  self:GetViewComponent():RefreshView()
end
function CombatSettingPanelMediator:OnRemove()
  self.super:OnRemove()
end
return CombatSettingPanelMediator
