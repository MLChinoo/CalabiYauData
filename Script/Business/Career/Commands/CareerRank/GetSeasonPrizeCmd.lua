local GetSeasonPrizeCmd = class("GetSeasonPrizeCmd", PureMVC.Command)
function GetSeasonPrizeCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.GetSeasonPrizeCmd then
    local seasonPrize = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetRewardInfo(notification:GetBody())
    if nil == seasonPrize then
      return
    end
    local prizeInfo = {}
    prizeInfo.firstId = seasonPrize.firstId
    local prizeList = {}
    for key, value in pairs(seasonPrize) do
      if type(value) == "table" then
        prizeList[key] = value
      end
    end
    prizeInfo.prizeList = prizeList
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetSeasonPrize, prizeInfo)
  end
end
return GetSeasonPrizeCmd
