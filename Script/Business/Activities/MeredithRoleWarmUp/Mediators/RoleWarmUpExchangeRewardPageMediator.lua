local RoleWarmUpExchangeRewardPageMediator = class("RoleWarmUpExchangeRewardPageMediator", PureMVC.Mediator)
function RoleWarmUpExchangeRewardPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.RoleWarmUp.UpdateEnergyNum
  }
end
function RoleWarmUpExchangeRewardPageMediator:OnRegister()
end
function RoleWarmUpExchangeRewardPageMediator:OnRemove()
end
function RoleWarmUpExchangeRewardPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.RoleWarmUp.UpdateEnergyNum then
    viewComponent:UpdataExchangeRewardUI()
  end
end
return RoleWarmUpExchangeRewardPageMediator
