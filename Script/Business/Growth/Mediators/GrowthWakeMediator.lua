local GrowthWakeMediator = class("GrowthWakeMediator", PureMVC.Mediator)
function GrowthWakeMediator:ListNotificationInterests()
  return {
    NotificationDefines.Growth.GrowthWakeUpdate
  }
end
function GrowthWakeMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Growth.GrowthWakeUpdate then
    self:UpdateWake()
  end
end
function GrowthWakeMediator:OnRegister()
  GrowthWakeMediator.super.OnRegister(self)
  self:UpdateWake()
end
function GrowthWakeMediator:OnRemove()
  GrowthWakeMediator.super.OnRemove(self)
end
function GrowthWakeMediator:UpdateWake()
end
return GrowthWakeMediator
