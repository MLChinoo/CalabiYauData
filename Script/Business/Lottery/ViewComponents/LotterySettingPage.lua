local LotterySettingPage = class("LotterySettingPage", PureMVC.ViewComponentPage)
local LotterySettingMediator = require("Business/Lottery/Mediators/LotterySettingMediator")
function LotterySettingPage:ListNeededMediators()
  return {LotterySettingMediator}
end
function LotterySettingPage:InitializeLuaEvent()
  LogDebug("LotteryEntryPage", "Init lua event")
  self.actionOnBuyTicket = LuaEvent.new()
end
function LotterySettingPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotterySettingPage", "Lua implement OnOpen")
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  lotteryProxy:SetInLottery(true)
  if self.Button_Buy then
    self.Button_Buy.OnClicked:Add(self, self.OnClickBuy)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  self.bCanInput = true
  if self.OperationDeskTagName then
    LogDebug("LotterySettingPage", "Init Operation desk")
    lotteryProxy:SetOperationDesk(self.OperationDeskTagName)
    GameFacade:SendNotification(NotificationDefines.Lottery.InitOperationDesk)
  end
  lotteryProxy:SetLotteryStatus(UE4.ELotteryState.Start)
  if self.StartSequenceId then
    UE4.UCySequenceManager.Get(self):StopSequence()
    UE4.UCySequenceManager.Get(self):PlaySequence(self.StartSequenceId)
  end
  GameFacade:SendNotification(NotificationDefines.Lottery.ShowOperationDesk)
end
function LotterySettingPage:OnClose()
  if self.Button_Buy then
    self.Button_Buy.OnClicked:Remove(self, self.OnClickBuy)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):EnableOperationDesk(false)
end
function LotterySettingPage:UpdateView(ticketId, ticketCnt, currencyCnt)
  if self.Image_Ticket then
    local ticketIcon = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemImg(ticketId)
    self:SetImageByTexture2D(self.Image_Ticket, ticketIcon)
  end
  if self.Text_TicketOwned then
    self.Text_TicketOwned:SetText(UE4.UKismetTextLibrary.Conv_IntToText(ticketCnt))
  end
  if self.Text_CoinOwned then
    self.Text_CoinOwned:SetText(UE4.UKismetTextLibrary.Conv_IntToText(currencyCnt))
  end
end
function LotterySettingPage:SetEnableInput(bEnabled)
  self.bCanInput = bEnabled
end
function LotterySettingPage:OnClickBuy()
  if not self.bCanInput then
    return
  end
  LogInfo("LotterySettingPage", "On click buy")
  self.actionOnBuyTicket()
end
function LotterySettingPage:OnEscHotKeyClick()
  if not self.bCanInput then
    return
  end
  LogInfo("LotterySettingPage", "OnEscHotKeyClick")
  ViewMgr:ClosePage(self)
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetInLottery(false)
  local lotteryId = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotterySelected()
  ViewMgr:OpenPage(self, UIPageNameDefine.LotteryEntryPage, false, lotteryId)
end
function LotterySettingPage:LuaHandleKeyEvent(key, inputEvent)
  if self.HotKeyButton_Esc then
    return self.HotKeyButton_Esc:MonitorKeyDown(key, inputEvent)
  end
  return false
end
return LotterySettingPage
