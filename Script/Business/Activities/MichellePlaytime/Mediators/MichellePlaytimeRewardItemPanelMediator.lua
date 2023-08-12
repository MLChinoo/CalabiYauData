local MichellePlaytimeRewardItemPanelMediator = class("MichellePlaytimeRewardItemPanelMediator", PureMVC.Mediator)
function MichellePlaytimeRewardItemPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.MichellePlaytime.ShowPendingReceiveStateParticle
  }
end
function MichellePlaytimeRewardItemPanelMediator:OnRegister()
end
function MichellePlaytimeRewardItemPanelMediator:OnRemove()
end
function MichellePlaytimeRewardItemPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.MichellePlaytime.ShowPendingReceiveStateParticle then
    viewComponent:ShowPendingReceiveStateAnimation()
  end
end
return MichellePlaytimeRewardItemPanelMediator
