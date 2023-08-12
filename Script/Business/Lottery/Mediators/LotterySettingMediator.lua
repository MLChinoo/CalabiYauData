local LotterySettingMediator = class("LotterySettingMediator", PureMVC.Mediator)
function LotterySettingMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.UpdateLotteryInfo,
    NotificationDefines.PlayerAttrChanged,
    NotificationDefines.Lottery.DoLottery,
    NotificationDefines.Lottery.EnableTableInput
  }
end
function LotterySettingMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.UpdateLotteryInfo then
    self:UpdateView()
  end
  if notification:GetName() == NotificationDefines.Lottery.DoLottery then
    self:GetViewComponent():SetEnableInput(false)
  end
  if notification:GetName() == NotificationDefines.Lottery.EnableTableInput and notification:GetBody() then
    self:GetViewComponent():SetEnableInput(true)
  end
  if notification:GetName() == NotificationDefines.PlayerAttrChanged and table.containsValue(notification:GetBody(), GlobalEnumDefine.PlayerAttributeType.emCrystal) then
    self:UpdateView()
  end
end
function LotterySettingMediator:OnRegister()
  LogDebug("LotterySettingMediator", "On register")
  LotterySettingMediator.super.OnRegister(self)
  self.ticketId = 0
  self.ticketCnt = 0
  self:GetViewComponent().actionOnBuyTicket:Add(self.BuyTicket, self)
end
function LotterySettingMediator:OnRemove()
  self:GetViewComponent().actionOnBuyTicket:Remove(self.BuyTicket, self)
  LotterySettingMediator.super.OnRemove(self)
end
function LotterySettingMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  self:UpdateView()
end
function LotterySettingMediator:UpdateView()
  local lotteryInfo = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryInfo()
  if lotteryInfo then
    self.ticketId = lotteryInfo.ticketId
    self.ticketCnt = lotteryInfo.ticketCnt
    local currencyCnt = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emCrystal)
    self:GetViewComponent():UpdateView(self.ticketId, self.ticketCnt, currencyCnt)
  end
end
function LotterySettingMediator:BuyTicket(buyCnt)
  if self.ticketId > 0 then
    local ticketInfo = {
      ticketId = self.ticketId,
      originalItemNum = buyCnt
    }
    GameFacade:SendNotification(NotificationDefines.Lottery.BuyTicketCmd, ticketInfo)
  end
end
return LotterySettingMediator
