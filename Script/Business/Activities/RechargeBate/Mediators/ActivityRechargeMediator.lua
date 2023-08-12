local ActivityRechargeMediator = class("ActivityRechargeMediator", PureMVC.Mediator)
function ActivityRechargeMediator:OnViewComponentPagePostOpen()
  GameFacade:RetrieveProxy(ProxyNames.RechargeBateProxy):ReqReChargeData()
end
function ActivityRechargeMediator:ListNotificationInterests()
  return {
    NotificationDefines.ActivitiesRechargeBateUpdatePage
  }
end
function ActivityRechargeMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.ActivitiesRechargeBateUpdatePage then
    self:GetViewComponent():Init(Body)
  end
end
return ActivityRechargeMediator
