local BattlePassClueRewardCmd = class("BattlePassClueRewardCmd", PureMVC.Command)
function BattlePassClueRewardCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.BattlePass.ClueRewardCmd then
    GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):ReqClueReward(notification:GetBody())
  end
end
return BattlePassClueRewardCmd
