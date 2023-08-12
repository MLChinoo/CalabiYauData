local AcquireRankPrizeCmd = class("AcquireRankPrizeCmd", PureMVC.Command)
function AcquireRankPrizeCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.AcquireRankPrizeCmd then
    GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):ReqReward(notification:GetBody())
  end
end
return AcquireRankPrizeCmd
