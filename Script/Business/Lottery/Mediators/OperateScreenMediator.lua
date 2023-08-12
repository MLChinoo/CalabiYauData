local OperateScreenMediator = class("OperateScreenMediator", PureMVC.Mediator)
function OperateScreenMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.InitOperationDesk,
    NotificationDefines.Lottery.ShowOperationDesk
  }
end
function OperateScreenMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.InitOperationDesk then
    self:GetViewComponent():InitOperationDesk()
  end
  if notification:GetName() == NotificationDefines.Lottery.ShowOperationDesk then
  end
end
return OperateScreenMediator
