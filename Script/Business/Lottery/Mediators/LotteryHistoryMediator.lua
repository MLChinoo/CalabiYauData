local LotteryHistoryMediator = class("LotteryHistoryMediator", PureMVC.Mediator)
function LotteryHistoryMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.HistoryDataPrepared
  }
end
function LotteryHistoryMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.HistoryDataPrepared then
    self:GetViewComponent():InitView(notification:GetBody())
  end
end
return LotteryHistoryMediator
