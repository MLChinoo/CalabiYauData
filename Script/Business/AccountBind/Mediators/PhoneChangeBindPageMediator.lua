local PhoneChangeBindPageMediator = class("PhoneChangeBindPageMediator", PureMVC.Mediator)
function PhoneChangeBindPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.PhoneBindSuccess
  }
end
function PhoneChangeBindPageMediator:OnRegister()
  self.super:OnRegister()
end
function PhoneChangeBindPageMediator:OnRemove()
  self.super:OnRemove()
end
function PhoneChangeBindPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.PhoneBindSuccess then
    self:GetViewComponent():OnClickCloseBtn()
  end
end
return PhoneChangeBindPageMediator
