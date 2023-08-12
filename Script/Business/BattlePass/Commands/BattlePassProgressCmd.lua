local BattlePassProgressCmd = class("BattlePassProgressCmd", PureMVC.Command)
function BattlePassProgressCmd:Execute(notification)
  if notification:GetType() == NotificationDefines.BattlePass.ProgressCmdTypeView then
    GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressInitView)
  elseif notification:GetType() == NotificationDefines.BattlePass.ProgressCmdTypeClaimOnePrize then
    local proxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    local sendBody = notification:GetBody()
    if proxy then
      proxy:ReqProgressReward(sendBody.level, sendBody.senior)
    end
  elseif notification:GetType() == NotificationDefines.BattlePass.ProgressCmdTypeClaimAllPrize then
    local proxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    if proxy then
      proxy:ReqAllProgressReward()
    end
  end
end
return BattlePassProgressCmd
