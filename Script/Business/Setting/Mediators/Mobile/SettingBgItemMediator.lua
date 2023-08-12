local SettingBgItemMediator = class("SettingBgItemMediator", PureMVC.Mediator)
function SettingBgItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingShowTipNtf
  }
end
function SettingBgItemMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingShowTipNtf then
    self:GetViewComponent():Reset()
  end
end
function SettingBgItemMediator:OnRegister()
  self.super:OnRegister()
end
function SettingBgItemMediator:OnRemove()
  self.super:OnRemove()
end
return SettingBgItemMediator
