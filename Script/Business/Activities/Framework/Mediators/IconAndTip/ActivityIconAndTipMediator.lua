local ActivityIconAndTipMediator = calss("ActivityIconAndTipMediator", PureMVC.Mediator)
function ActivityIconAndTipMediator:ListNotificationInterests()
  return {}
end
function ActivityIconAndTipMediator:OnRegister()
end
function ActivityIconAndTipMediator:OnRemove()
end
function ActivityIconAndTipMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
end
return ActivityIconAndTipMediator
