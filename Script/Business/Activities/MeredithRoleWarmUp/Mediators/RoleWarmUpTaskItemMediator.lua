local RoleWarmUpPageMediator = class("RoleWarmUpPageMediator", PureMVC.Mediator)
function RoleWarmUpPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.TaskUpdate
  }
end
function RoleWarmUpPageMediator:OnRegister()
end
function RoleWarmUpPageMediator:OnRemove()
end
function RoleWarmUpPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.BattlePass.TaskUpdate then
    viewComponent:UpdataTaskItem()
    GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.UpdateEnergyNum)
  end
end
return RoleWarmUpPageMediator
