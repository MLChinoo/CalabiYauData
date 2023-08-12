local RoleWarmUpPageMediator = class("RoleWarmUpPageMediator", PureMVC.Mediator)
function RoleWarmUpPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.RoleWarmUp.UpdateRoleWarmUpData,
    NotificationDefines.Activities.RoleWarmUp.TakePhaseAwardSuccess,
    NotificationDefines.Activities.RoleWarmUp.TakeRoleSuccess,
    NotificationDefines.Activities.RoleWarmUp.TakeTaskAwardSuccess
  }
end
function RoleWarmUpPageMediator:OnRegister()
end
function RoleWarmUpPageMediator:OnRemove()
end
function RoleWarmUpPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local ViewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.RoleWarmUp.UpdateRoleWarmUpData then
    ViewComponent:InitUI()
  elseif NotificationDefines.Activities.RoleWarmUp.TakePhaseAwardSuccess == noteName then
    UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(ViewComponent.AwardGetAudio))
  elseif NotificationDefines.Activities.RoleWarmUp.TakeTaskAwardSuccess == noteName then
    ViewComponent:TakeTaskAwardSuccess(noteBody)
  elseif NotificationDefines.Activities.RoleWarmUp.TakeRoleSuccess == noteName then
    ViewComponent:OnGetRoleSuccess()
  end
end
return RoleWarmUpPageMediator
