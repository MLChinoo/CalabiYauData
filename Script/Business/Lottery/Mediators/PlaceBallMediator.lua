local PlaceBallMediator = class("PlaceBallMediator", PureMVC.Mediator)
function PlaceBallMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.ShowOperationDesk,
    NotificationDefines.Lottery.EnableTableInput,
    NotificationDefines.Lottery.SetLotteryCnt
  }
end
function PlaceBallMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.ShowOperationDesk then
    self:GetViewComponent():InitOperationDesk()
  end
  if notification:GetName() == NotificationDefines.Lottery.EnableTableInput then
    self:GetViewComponent():SetInputEnabled(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Lottery.SetLotteryCnt then
    self:GetViewComponent():UpdateButtonState(notification:GetBody())
  end
end
return PlaceBallMediator
