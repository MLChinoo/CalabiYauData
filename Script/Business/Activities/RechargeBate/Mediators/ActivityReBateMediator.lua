local ActivityReBateMediator = class("ActivityReBateMediator", PureMVC.Mediator)
local ActivityReBatePage
function ActivityReBateMediator:OnViewComponentPagePostOpen()
  GameFacade:RetrieveProxy(ProxyNames.RechargeBateProxy):ReqReChargeData()
end
function ActivityReBateMediator:ListNotificationInterests()
  return {
    NotificationDefines.ActivitiesRechargeBateUpdatePage,
    NotificationDefines.ActivitiesReBateTakeSuccess
  }
end
function ActivityReBateMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  ActivityReBatePage = self:GetViewComponent()
  if Name == NotificationDefines.ActivitiesRechargeBateUpdatePage then
    ActivityReBatePage:Init(Body)
  elseif Name == NotificationDefines.ActivitiesReBateTakeSuccess then
    ActivityReBatePage:SetButtonDisable()
  end
end
return ActivityReBateMediator
