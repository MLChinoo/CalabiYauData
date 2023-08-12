local PhoneBindPageMediator = class("PhoneBindPageMediator", PureMVC.Mediator)
function PhoneBindPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.PhoneBindSuccess
  }
end
function PhoneBindPageMediator:OnRegister()
  self.super:OnRegister()
end
function PhoneBindPageMediator:OnRemove()
  self.super:OnRemove()
end
function PhoneBindPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.PhoneBindSuccess then
    self:GetViewComponent():OnClickCloseBtn()
  end
end
return PhoneBindPageMediator
