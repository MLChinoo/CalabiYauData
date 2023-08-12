local LotteryDisplayBasePanel = class("LotteryDisplayBasePanel", PureMVC.ViewComponentPanel)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function LotteryDisplayBasePanel:InitializeLuaEvent()
  LogDebug("LotteryDisplayBasePanel", "Init lua event")
  self.actionOnBuyTicket = LuaEvent.new()
  self.actionOnShowDetail = LuaEvent.new()
  self.actionOnEnter = LuaEvent.new()
end
function LotteryDisplayBasePanel:OnOpenLottery()
  if self.Anim_Begin then
    self:PlayAnimationForward(self.Anim_Begin)
  end
end
function LotteryDisplayBasePanel:Construct()
  LogDebug("LotteryDisplayBasePanel", "Lua implement OnOpen")
  LotteryDisplayBasePanel.super.Construct(self)
  if self.Button_Detail then
    self.Button_Detail.OnPressed:Add(self, self.OnHoverDetail)
    self.Button_Detail.OnUnhovered:Add(self, self.OnUnhoverDetail)
    self.Button_Detail.OnClicked:Add(self, self.OnClickDetail)
  end
  if self.Button_History then
    self.Button_History.OnPressed:Add(self, self.OnHoverHistory)
    self.Button_History.OnUnhovered:Add(self, self.OnUnhoverHistory)
    self.Button_History.OnClicked:Add(self, self.OnClickHistory)
  end
  if self.Button_Buy then
    self.Button_Buy.OnClicked:Add(self, self.OnClickBuy)
  end
  if self.Button_Enter then
    self.Button_Enter.OnClickEvent:Add(self, self.OnClickEnter)
  end
end
function LotteryDisplayBasePanel:Destruct()
  if self.Button_Detail then
    self.Button_Detail.OnPressed:Remove(self, self.OnHoverDetail)
    self.Button_Detail.OnUnhovered:Remove(self, self.OnUnhoverDetail)
    self.Button_Detail.OnClicked:Remove(self, self.OnClickDetail)
  end
  if self.Button_History then
    self.Button_History.OnPressed:Remove(self, self.OnHoverHistory)
    self.Button_History.OnUnhovered:Remove(self, self.OnUnhoverHistory)
    self.Button_History.OnClicked:Remove(self, self.OnClickHistory)
  end
  if self.Button_Buy then
    self.Button_Buy.OnClicked:Remove(self, self.OnClickBuy)
  end
  if self.Button_Enter then
    self.Button_Enter.OnClickEvent:Remove(self, self.OnClickEnter)
  end
  LotteryDisplayBasePanel.super.Destruct(self)
end
function LotteryDisplayBasePanel:UpdateLotteryInfo(lotteryInfo)
  if lotteryInfo.bonus then
    self:UpdateView(lotteryInfo.bonus)
  end
  if self.Image_Ticket then
    local ticketIcon = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemImg(lotteryInfo.ticketId)
    self:SetImageByTexture2D(self.Image_Ticket, ticketIcon)
  end
  if self.Text_TicketOwned then
    self.Text_TicketOwned:SetText(UE4.UKismetTextLibrary.Conv_IntToText(lotteryInfo.ticketCnt))
  end
end
function LotteryDisplayBasePanel:UpdateView(bonusInfo)
  if bonusInfo and self.Text_Hint then
    local minCnt, showQuality
    for key, value in pairs(bonusInfo) do
      if nil == minCnt or value < minCnt or minCnt == value and value > showQuality then
        minCnt = value
        showQuality = key
      end
    end
    if nil == minCnt or nil == showQuality then
      return
    end
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "LotteryBonusHint")
    local stringMap = {
      [0] = minCnt,
      [1] = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, LotteryEnum.qualityText[showQuality])
    }
    formatText = string.replace(formatText, "Red", LotteryEnum.qualityText[showQuality])
    if self.BonusHintTxtType then
      formatText = string.replace(formatText, "TxtType", self.BonusHintTxtType)
    end
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.Text_Hint:SetText(text)
  end
end
function LotteryDisplayBasePanel:OnHoverDetail()
  if self.WidgetSwitcher_TextColor then
    self.WidgetSwitcher_TextColor:SetActiveWidgetIndex(1)
  end
end
function LotteryDisplayBasePanel:OnUnhoverDetail()
  if self.WidgetSwitcher_TextColor then
    self.WidgetSwitcher_TextColor:SetActiveWidgetIndex(0)
  end
end
function LotteryDisplayBasePanel:OnClickDetail()
  self.actionOnShowDetail()
end
function LotteryDisplayBasePanel:OnHoverHistory()
  if self.WidgetSwitcher_TextColor_History then
    self.WidgetSwitcher_TextColor_History:SetActiveWidgetIndex(1)
  end
end
function LotteryDisplayBasePanel:OnUnhoverHistory()
  if self.WidgetSwitcher_TextColor_History then
    self.WidgetSwitcher_TextColor_History:SetActiveWidgetIndex(0)
  end
end
function LotteryDisplayBasePanel:OnClickHistory()
  LogInfo("LotteryDisplayBasePanel", "Show lottery history")
  ViewMgr:OpenPage(self, UIPageNameDefine.LotteryHistoryPage)
end
function LotteryDisplayBasePanel:OnClickBuy()
  self.actionOnBuyTicket()
end
function LotteryDisplayBasePanel:OnClickEnter()
  self.actionOnEnter()
end
return LotteryDisplayBasePanel
