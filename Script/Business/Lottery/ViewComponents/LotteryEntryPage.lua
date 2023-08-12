local LotteryEntryPage = class("LotteryEntryPage", PureMVC.ViewComponentPage)
local LotteryEntryMediator = require("Business/Lottery/Mediators/LotteryEntryMediator")
function LotteryEntryPage:ListNeededMediators()
  return {LotteryEntryMediator}
end
function LotteryEntryPage:InitializeLuaEvent()
  LogDebug("LotteryEntryPage", "Init lua event")
  self.actionOnSelectLottery = LuaEvent.new(lotteryId)
  self.actionOnBuyTicket = LuaEvent.new()
  self.actionOnShowDetail = LuaEvent.new()
  self.actionOnEnter = LuaEvent.new()
end
function LotteryEntryPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotteryEntryPage", "Lua implement OnOpen")
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  lotteryProxy:SetInLottery(false)
  lotteryProxy:SetLotterySubsystem()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
  if self.LotteryBGM then
    lotteryProxy:SetLotteryBGM(self.LotteryBGM)
  end
  if self.LotteryRootTagName then
    lotteryProxy:SetSceneRoot(self.LotteryRootTagName)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  if luaOpenData then
    self:InitLottery(luaOpenData)
  end
  GameFacade:SendNotification(NotificationDefines.Lottery.InitSceneViews)
end
function LotteryEntryPage:OnClose()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
end
function LotteryEntryPage:InitLottery(lotteryId)
  if self.Slot_Display then
    self.Slot_Display:ClearChildren()
    local lotteryCfg = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryCfg(lotteryId)
    if lotteryCfg then
      local displayBP = ObjectUtil:LoadClass(lotteryCfg.DisplayBlueprint)
      LogDebug("LotteryEntryPage", "BP path: %s", lotteryCfg.DisplayBlueprint)
      if displayBP then
        local displayIns = UE4.UWidgetBlueprintLibrary.Create(self, displayBP)
        if displayIns.actionOnBuyTicket and displayIns.actionOnShowDetail and displayIns.actionOnEnter then
          displayIns.actionOnBuyTicket:Add(self.OnClickBuy, self)
          displayIns.actionOnShowDetail:Add(self.OnClickDetail, self)
          displayIns.actionOnEnter:Add(self.OnClickEnter, self)
        end
        self.lotteryInfoPage = displayIns
        self.Slot_Display:AddChild(displayIns)
        displayIns:OnOpenLottery()
        self.actionOnSelectLottery(lotteryId)
        if self.WidgetSwitcher_HasData then
          self.WidgetSwitcher_HasData:SetActiveWidgetIndex(1)
        end
      end
    end
  end
  self:UpdateLotteryInfo(lotteryId)
end
function LotteryEntryPage:UpdateLotteryInfo(lotteryId)
  if self.lotteryInfoPage then
    local info = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryInfo(lotteryId)
    if info then
      self.lotteryInfoPage:UpdateLotteryInfo(info)
    end
  end
end
function LotteryEntryPage:OnHoverDetail()
  if self.WidgetSwitcher_TextColor then
    self.WidgetSwitcher_TextColor:SetActiveWidgetIndex(1)
  end
end
function LotteryEntryPage:OnUnhoverDetail()
  if self.WidgetSwitcher_TextColor then
    self.WidgetSwitcher_TextColor:SetActiveWidgetIndex(0)
  end
end
function LotteryEntryPage:OnClickDetail()
  LogInfo("LotteryEntryPage", "On click detail")
  self.actionOnShowDetail()
end
function LotteryEntryPage:OnClickBuy()
  LogInfo("LotteryEntryPage", "On click buy")
  self.actionOnBuyTicket()
end
function LotteryEntryPage:OnClickEnter()
  LogInfo("LotteryEntryPage", "On click enter")
  self.actionOnEnter()
end
function LotteryEntryPage:OnEscHotKeyClick()
  LogInfo("LotteryEntryPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
return LotteryEntryPage
