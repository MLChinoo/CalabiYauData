local SettingDetailItemMediator = class("SettingDetailItemMediator", PureMVC.Mediator)
function SettingDetailItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingShowTipNtf
  }
end
function SettingDetailItemMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingShowTipNtf then
    self:GetViewComponent():SetContent(body)
  end
end
function SettingDetailItemMediator:OnRegister()
  self.super:OnRegister()
end
function SettingDetailItemMediator:OnRemove()
  self.super:OnRemove()
end
return SettingDetailItemMediator
