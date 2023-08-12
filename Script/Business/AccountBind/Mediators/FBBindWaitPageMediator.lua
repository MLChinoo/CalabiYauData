local FBBindWaitPageMediator = class("FBBindWaitPageMediator", PureMVC.Mediator)
function FBBindWaitPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.FanbookBindSuccess,
    NotificationDefines.AccountBind.FanbookBindFail
  }
end
function FBBindWaitPageMediator:OnRegister()
  self.super:OnRegister()
end
function FBBindWaitPageMediator:OnRemove()
  self.super:OnRemove()
end
function FBBindWaitPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.FanbookBindSuccess or notification:GetName() == NotificationDefines.AccountBind.FanbookBindFail then
    self:GetViewComponent():OnClickCloseBtn()
  end
end
return FBBindWaitPageMediator
