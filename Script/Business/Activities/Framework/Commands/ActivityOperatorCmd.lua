local ActivityOperatorCmd = class("ActivityOperatorCmd", PureMVC.Command)
function ActivityOperatorCmd:Execute(notification)
  local notifyType = notification:GetType()
  if notifyType == NotificationDefines.Activities.ActivityReqType then
    local reqBody = notification:GetBody()
    if reqBody then
      if reqBody.pageName == UIPageNameDefine.SpaceTimePage then
        ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PendingPage)
        GameFacade:RetrieveProxy(ProxyNames.SpaceTimeProxy):ReqGetCardList(reqBody.activityId)
      else
        ViewMgr:OpenPage(LuaGetWorld(), reqBody.pageName)
      end
    end
  elseif notifyType == NotificationDefines.Activities.ActivityResType then
    local resBody = notification:GetBody()
    if resBody then
      local proxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
      if proxy then
        local activity = proxy:GetActivityById(resBody.activityId)
        if activity then
          local pageName = activity.cfg.blue_print
          if pageName == UIPageNameDefine.SpaceTimePage then
            ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.PendingPage)
            if resBody.isSuccess and not resBody.isServerNtf then
              ViewMgr:OpenPage(LuaGetWorld(), pageName, {
                activityId = resBody.activityId
              })
            end
          end
        end
      end
    end
  end
end
return ActivityOperatorCmd
