local ActivitiesCmd = class("ActivitiesCmd", PureMVC.Command)
function ActivitiesCmd:Execute(notification)
  local notiName = notification:GetName()
  local notiType = notification:GetType()
  if notiName == NotificationDefines.Activities.ReqActivitiesCmd then
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):ReqActivitiesPreList()
  end
end
return ActivitiesCmd
