local ActivitiesRedDotCmd = class("ActivitiesRedDotCmd", PureMVC.Command)
function ActivitiesRedDotCmd:Execute(notification)
  local noteName = notification:GetName()
  local noteType = notification:GetType()
  local noteBody = notification:GetBody()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if proxy then
    local activityId = noteBody.activityId
    local activity = proxy:GetActivityById(activityId)
    if activity then
      activity.reddot = noteBody.reddotNum
    end
    local sendBody = {
      activityId = activityId,
      reddotNum = noteBody.reddotNum
    }
    GameFacade:SendNotification(NotificationDefines.Activities.ActivityRedDotUpdate, sendBody)
  end
end
return ActivitiesRedDotCmd
