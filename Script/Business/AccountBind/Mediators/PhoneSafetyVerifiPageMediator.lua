local PhoneSafetyVerifiPageMediator = class("PhoneSafetyVerifiPageMediator", PureMVC.Mediator)
function PhoneSafetyVerifiPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.PhoneCheckSuccess
  }
end
function PhoneSafetyVerifiPageMediator:OnRegister()
  self.super:OnRegister()
end
function PhoneSafetyVerifiPageMediator:OnRemove()
  self.super:OnRemove()
end
function PhoneSafetyVerifiPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.PhoneCheckSuccess then
    self:GetViewComponent():OnPhoneCheckSuccess()
  end
end
return PhoneSafetyVerifiPageMediator
