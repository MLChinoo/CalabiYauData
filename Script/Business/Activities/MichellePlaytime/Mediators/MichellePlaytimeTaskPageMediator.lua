local MichellePlaytimeTaskPageMediator = class("MichellePlaytimeTaskPageMediator", PureMVC.Mediator)
function MichellePlaytimeTaskPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum,
    NotificationDefines.Activities.MichellePlaytime.ShowOneClickClaimBtn
  }
end
function MichellePlaytimeTaskPageMediator:OnRegister()
end
function MichellePlaytimeTaskPageMediator:OnRemove()
end
function MichellePlaytimeTaskPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum then
    viewComponent:UpdateConsumeNum()
  elseif noteName == NotificationDefines.Activities.MichellePlaytime.ShowOneClickClaimBtn then
    viewComponent:SetOneClickClaimVisible()
  end
end
return MichellePlaytimeTaskPageMediator
