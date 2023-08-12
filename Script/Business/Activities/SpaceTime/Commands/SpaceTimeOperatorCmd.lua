local SpaceTimeOperatorCmd = class("SpaceTimeOperatorCmd", PureMVC.Command)
function SpaceTimeOperatorCmd:Execute(notification)
  local notifyType = notification:GetType()
  local notifyBody = notification:GetBody()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.SpaceTimeProxy)
  if notifyType == NotificationDefines.Activities.SpaceTime.CardOpenReqType then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PendingPage)
    proxy:ReqOpenCard(notifyBody.day)
  elseif notifyType == NotificationDefines.Activities.SpaceTime.CardSendReqType then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PendingPage)
    proxy:ReqChooseReward(notifyBody.day)
  end
end
return SpaceTimeOperatorCmd
