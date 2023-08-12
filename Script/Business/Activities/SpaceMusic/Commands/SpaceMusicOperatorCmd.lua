local SpaceMusicOperatorCmd = class("SpaceMusicOperatorCmd", PureMVC.Command)
function SpaceMusicOperatorCmd:Execute(notification)
  local notifyBody = notification:GetBody()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.SpaceMusicProxy)
  if proxy then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PendingPage)
    proxy:ReqGetReward(notifyBody.day)
  end
end
return SpaceMusicOperatorCmd
