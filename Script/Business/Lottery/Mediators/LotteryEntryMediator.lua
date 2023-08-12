local LotteryEntryMediator = class("LotteryEntryMediator", PureMVC.Mediator)
function LotteryEntryMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.AllLotteryCfgInfo,
    NotificationDefines.Lottery.UpdateLotteryInfo,
    NotificationDefines.Lottery.ShowMainPage
  }
end
function LotteryEntryMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.AllLotteryCfgInfo then
  end
  if notification:GetName() == NotificationDefines.Lottery.UpdateLotteryInfo then
    local newLottery = notification:GetBody()
    if newLottery and newLottery.lotteryId == self.lotterySelected then
      self.ticketId = newLottery.lotteryInfo.ticketId
      self.ticketCnt = newLottery.lotteryInfo.ticketCnt
    end
    self:GetViewComponent():UpdateLotteryInfo(newLottery.lotteryId)
  end
  if notification:GetName() == NotificationDefines.Lottery.ShowMainPage then
    self:GetViewComponent():SetVisibility(notification:GetBody() and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function LotteryEntryMediator:OnRegister()
  LogDebug("LotteryEntryMediator", "On register")
  LotteryEntryMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnSelectLottery:Add(self.SelectLottery, self)
  self:GetViewComponent().actionOnBuyTicket:Add(self.BuyTicket, self)
  self:GetViewComponent().actionOnShowDetail:Add(self.ShowDetail, self)
  self:GetViewComponent().actionOnEnter:Add(self.EnterLottery, self)
  self.ticketId = 0
  self.ticketCnt = 0
end
function LotteryEntryMediator:OnRemove()
  self:GetViewComponent().actionOnSelectLottery:Remove(self.SelectLottery, self)
  self:GetViewComponent().actionOnBuyTicket:Remove(self.BuyTicket, self)
  self:GetViewComponent().actionOnShowDetail:Remove(self.ShowDetail, self)
  self:GetViewComponent().actionOnEnter:Remove(self.EnterLottery, self)
  LotteryEntryMediator.super.OnRemove(self)
end
function LotteryEntryMediator:SelectLottery(lotteryId)
  self.lotterySelected = lotteryId
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetLotterySelected(self.lotterySelected)
end
function LotteryEntryMediator:BuyTicket()
  if self.ticketId > 0 then
    GameFacade:SendNotification(NotificationDefines.Lottery.BuyTicketCmd, {
      ticketId = self.ticketId,
      originalItemNum = 10
    })
  end
end
function LotteryEntryMediator:ShowDetail()
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.LotteryPoolDetailPage, false, {
    lotteryId = self.lotterySelected
  })
end
function LotteryEntryMediator:EnterLottery()
  ViewMgr:ClosePage(self:GetViewComponent())
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.LotterySettingPage)
end
return LotteryEntryMediator
