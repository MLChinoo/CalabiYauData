local MichellePlaytimeTaskItemMediator = class("MichellePlaytimeTaskItemMediator", PureMVC.Mediator)
function MichellePlaytimeTaskItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.TaskUpdate,
    NotificationDefines.Activities.MichellePlaytime.OneClickClaim
  }
end
function MichellePlaytimeTaskItemMediator:OnRegister()
end
function MichellePlaytimeTaskItemMediator:OnRemove()
end
function MichellePlaytimeTaskItemMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.BattlePass.TaskUpdate then
    viewComponent:InitTaskItemData()
    GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum)
  elseif noteName == NotificationDefines.Activities.MichellePlaytime.OneClickClaim and viewComponent:TaskCanbeReceiveReward() then
    viewComponent:OnClickGetReward()
  end
end
return MichellePlaytimeTaskItemMediator
