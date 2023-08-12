local OperationSettingPanelMBMediator = class("OperationSettingPanelMBMediator", PureMVC.Mediator)
function OperationSettingPanelMBMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingDefaultApplyNtf,
    NotificationDefines.Setting.CustomLayoutCloseNtf
  }
end
function OperationSettingPanelMBMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingDefaultApplyNtf then
    self:ApplyDefaultConfig()
  elseif name == NotificationDefines.Setting.CustomLayoutCloseNtf then
    self:GetViewComponent():UpdateOperationDragPanel()
  end
end
function OperationSettingPanelMBMediator:ApplyDefaultConfig()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  local oriData = self:GetViewComponent().oriData
  local panelStr = SettingManagerProxy:GetCurPanelTypeStr()
  if panelStr and oriData.Type == panelStr then
    local value = SettingSaveDataProxy:GetDefaultValueByKey(oriData.Indexkey)
    self:GetViewComponent():RefreshView(value)
  end
end
function OperationSettingPanelMBMediator:OnRegister()
  self.super:OnRegister()
end
function OperationSettingPanelMBMediator:OnRemove()
  self.super:OnRemove()
end
return OperationSettingPanelMBMediator
