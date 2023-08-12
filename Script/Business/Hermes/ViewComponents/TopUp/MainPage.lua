local HermesTopUpPage = class("HermesTopUpPage", PureMVC.ViewComponentPage)
local HermesTopUpMediator = require("Business/Hermes/Mediators/TopUp/TopUpMediator")
local Valid
function HermesTopUpPage:Update(Data)
  for index, MainItem in pairs(self.ItemMap or {}) do
    Valid = MainItem and MainItem:Init(Data[index])
  end
  local MonthCardData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetMonthCardData()
  for i, v in pairs(Data) do
    if 1 == v.IsCardSpecial then
      self.SpecialId = v.CommodityId
      if MonthCardData then
        if os.time() < MonthCardData.end_time then
          Valid = self.WidgetSwitcher_MonthCardBg and self.WidgetSwitcher_MonthCardBg:SetActiveWidgetIndex(1)
          Valid = self.WidgetSwitcher_GivingDesc and self.WidgetSwitcher_GivingDesc:SetActiveWidgetIndex(1)
          Valid = self.WidgetSwitcher_Buy and self.WidgetSwitcher_Buy:SetActiveWidgetIndex(1)
          Valid = self.LeftTime and self.LeftTime:SetText(MonthCardData.left_count)
          Valid = self.Button_Buy and self.Button_Buy:SetIsEnabled(false)
          Valid = self.WidgetSwitcher_BuyButtonBg and self.WidgetSwitcher_BuyButtonBg:SetActiveWidgetIndex(4)
        else
          Valid = self.WidgetSwitcher_MonthCardBg and self.WidgetSwitcher_MonthCardBg:SetActiveWidgetIndex(0)
          Valid = self.WidgetSwitcher_GivingDesc and self.WidgetSwitcher_GivingDesc:SetActiveWidgetIndex(0)
          Valid = self.WidgetSwitcher_Buy and self.WidgetSwitcher_Buy:SetActiveWidgetIndex(0)
          Valid = self.WidgetSwitcher_BuyButtonBg and self.WidgetSwitcher_BuyButtonBg:SetActiveWidgetIndex(0)
        end
      end
    end
  end
end
function HermesTopUpPage:ListNeededMediators()
  return {HermesTopUpMediator}
end
function HermesTopUpPage:OnOpen(luaOpenData, nativeOpenData)
  self.ItemMap = {
    self.MainItem1,
    self.MainItem2,
    self.MainItem3,
    self.MainItem4,
    self.MainItem5,
    self.MainItem6
  }
  if self.Recharge_Open then
    self:BindToAnimationFinished(self.Recharge_Open, {
      self,
      self.ShowAllParticle
    })
    self:PlayAnimation(self.Recharge_Open, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  Valid = self.Button_Buy and self.Button_Buy.OnClicked:Add(self, self.OnClickBuyMonthCard)
  Valid = self.Button_Buy and self.Button_Buy.OnHovered:Add(self, self.OnHoveredBuyMonthCard)
  Valid = self.Button_Buy and self.Button_Buy.OnUnhovered:Add(self, self.OnUnhoveredBuyMonthCard)
  Valid = self.CheckUseNativeBrowser and self.CheckUseNativeBrowser.OnCheckStateChanged:Add(self, self.OnUseNativeBrowserStateChanged)
  Valid = self.TextBlock_BuySign and self.TextBlock_BuySign:SetColorAndOpacity(self.NormalColor)
  Valid = self.TextBlock_BuyNum and self.TextBlock_BuyNum:SetColorAndOpacity(self.NormalColor)
end
function HermesTopUpPage:OnClose()
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  Valid = self.Button_Buy and self.Button_Buy.OnClicked:Remove(self, self.OnClickBuyMonthCard)
  Valid = self.Button_Buy and self.Button_Buy.OnHovered:Remove(self, self.OnHoveredBuyMonthCard)
  Valid = self.Button_Buy and self.Button_Buy.OnUnhovered:Remove(self, self.OnUnhoveredBuyMonthCard)
  Valid = self.CheckUseNativeBrowser and self.CheckUseNativeBrowser.OnCheckStateChanged:Remove(self, self.OnUseNativeBrowserStateChanged)
end
function HermesTopUpPage:ShowAllParticle()
  for index, MainItem in pairs(self.ItemMap or {}) do
    Valid = MainItem and MainItem:UpdateParticle()
  end
end
function HermesTopUpPage:OnEscHotKeyClick()
  LogInfo("HermesTopUpPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function HermesTopUpPage:OnUseNativeBrowserStateChanged(bIsChecked)
  LogInfo("HermesTopUpPage:OnUseNativeBrowserStateChanged", tostring(bIsChecked))
  self.bIsUseNativeBrowser = bIsChecked
  for index, MainItem in pairs(self.ItemMap or {}) do
    Valid = MainItem and MainItem:SetIsUseNativeBrowser(bIsChecked)
  end
end
function HermesTopUpPage:OnClickBuyMonthCard()
  if not self.SpecialId then
    return
  end
  if self.bIsUseNativeBrowser then
    local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
    if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ or dataCenter:GetLoginType() == UE4.ELoginType.ELT_Wechat then
      local pageData = {}
      pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Store, "HermesTopUpTips")
      pageData.bIsOneBtn = true
      pageData.source = self
      pageData.cb = self.ReqRefreshPlayerData
      ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
    end
    GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(self.SpecialId, true)
  else
    GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(self.SpecialId)
  end
end
function HermesTopUpPage:OnHoveredBuyMonthCard()
  Valid = self.TextBlock_BuySign and self.TextBlock_BuySign:SetColorAndOpacity(self.HoveredColor)
  Valid = self.TextBlock_BuyNum and self.TextBlock_BuyNum:SetColorAndOpacity(self.HoveredColor)
  Valid = self.WidgetSwitcher_BuyButtonBg and self.WidgetSwitcher_BuyButtonBg:SetActiveWidgetIndex(1)
  Valid = self.MouthCard_Hovered and self:PlayAnimation(self.MouthCard_Hovered, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function HermesTopUpPage:OnUnhoveredBuyMonthCard()
  Valid = self.MouthCard_Hovered and self:StopAnimation(self.MouthCard_Hovered)
  Valid = self.TextBlock_BuySign and self.TextBlock_BuySign:SetColorAndOpacity(self.NormalColor)
  Valid = self.TextBlock_BuyNum and self.TextBlock_BuyNum:SetColorAndOpacity(self.NormalColor)
  Valid = self.WidgetSwitcher_BuyButtonBg and self.WidgetSwitcher_BuyButtonBg:SetActiveWidgetIndex(0)
end
return HermesTopUpPage
