local InitLotteryCmd = class("InitLotteryCmd", PureMVC.Command)
function InitLotteryCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Lottery.InitLotteryCmd then
    local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
    local lotteryInfoAll = lotteryProxy:GetAllLottery()
    local lotteryCfgAll = {}
    for key, value in pairs(lotteryInfoAll) do
      table.insert(lotteryCfgAll, lotteryProxy:GetLotteryCfg(key))
    end
    GameFacade:SendNotification(NotificationDefines.Lottery.AllLotteryCfgInfo, lotteryCfgAll)
  end
end
return InitLotteryCmd
