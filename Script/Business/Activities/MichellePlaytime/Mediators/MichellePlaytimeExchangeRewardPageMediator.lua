local MichellePlaytimeExchangeRewardPageMediator = class("MichellePlaytimeExchangeRewardPageMediator", PureMVC.Mediator)
function MichellePlaytimeExchangeRewardPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum
  }
end
function MichellePlaytimeExchangeRewardPageMediator:OnRegister()
end
function MichellePlaytimeExchangeRewardPageMediator:OnRemove()
end
function MichellePlaytimeExchangeRewardPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum then
    viewComponent:InitExchangeInfo()
  end
end
return MichellePlaytimeExchangeRewardPageMediator
