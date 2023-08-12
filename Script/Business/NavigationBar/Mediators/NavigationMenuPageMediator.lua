local NavigationMenuPageMediator = class("NavigationMenuPageMediator", PureMVC.Mediator)
function NavigationMenuPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.UpdataAccountInfo,
    NotificationDefines.AccountBind.PhoneBindSuccess,
    NotificationDefines.AccountBind.FanbookBindSuccess
  }
end
function NavigationMenuPageMediator:OnRegister()
  self.super:OnRegister()
end
function NavigationMenuPageMediator:OnRemove()
  self.super:OnRemove()
end
function NavigationMenuPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.PhoneBindSuccess or notification:GetName() == NotificationDefines.AccountBind.UpdataAccountInfo or notification:GetName() == NotificationDefines.AccountBind.FanbookBindSuccess then
    self:GetViewComponent():UpdataRedDot()
  end
end
return NavigationMenuPageMediator
