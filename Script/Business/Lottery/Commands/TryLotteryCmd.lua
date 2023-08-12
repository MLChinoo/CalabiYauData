local TryLotteryCmd = class("TryLotteryCmd", PureMVC.Command)
function TryLotteryCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Lottery.TryLotteryCmd then
    local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
    if lotteryProxy then
      local lotteryCnt = table.count(lotteryProxy:GetLotteryBallSet())
      if lotteryCnt <= 0 then
        local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "NoBallInputHint")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
        lotteryProxy:EnableOperationDesk(true)
        return
      end
      local lotteryInfo = lotteryProxy:GetLotteryInfo()
      if lotteryCnt > 0 and lotteryInfo then
        local ticketId = lotteryInfo.ticketId
        local ticketCnt = lotteryInfo.ticketCnt
        if ticketId and ticketId > 0 and ticketCnt then
          if lotteryCnt > ticketCnt then
            local ticketInfo = {
              ticketId = ticketId,
              originalItemNum = lotteryCnt - ticketCnt
            }
            GameFacade:SendNotification(NotificationDefines.Lottery.BuyTicketCmd, ticketInfo)
          else
            GameFacade:SendNotification(NotificationDefines.Lottery.DoLottery)
            lotteryProxy:ReqDoLottery(lotteryProxy:GetLotterySelected(), lotteryCnt)
          end
        end
      end
    end
  end
end
return TryLotteryCmd
