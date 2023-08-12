local HermesTopUpMainItem = class("HermesTopUpMainItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesTopUpMainItem:Init(ItemData)
  self.bIsUseNativeBrowser = false
  self.CommodityId = ItemData.CommodityId
  Valid = self.ProductImage and self:SetImageByTexture2D_MatchSize(self.ProductImage, ItemData.IconPay)
  Valid = self.ItemNum and self.ItemNum:SetText(ItemData.Num)
  Valid = self.ItemName and self.ItemName:SetText(ItemData.Name)
  Valid = self.Price and self.Price:SetText(ItemData.PriceText)
  Valid = self.GivingDesc and self.GivingDesc:SetVisibility(ItemData.GivingAmount > 0 and SelfHitTestInvisible or Collapsed)
  Valid = ItemData.GivingAmount > 0 and self.GivingCurrencyImg and self:SetImageByTexture2D(self.GivingCurrencyImg, ItemData.GivingCurrencyImg)
  Valid = ItemData.GivingAmount > 0 and self.GivingNum and self.GivingNum:SetText(ItemData.GivingAmount)
  Valid = self.PS_MainItem6 and self.PS_MainItem6:SetVisibility(Collapsed)
  self.bIsCanShowParticle = ItemData.bIsShowParticle and 1 == ItemData.bIsShowParticle
  Valid = self.BuyButton and self.BuyButton:SetIsEnabled(true)
end
function HermesTopUpMainItem:UpdateParticle()
  Valid = self.PS_MainItem6 and self.PS_MainItem6:SetVisibility(self.bIsCanShowParticle and SelfHitTestInvisible or Collapsed)
end
function HermesTopUpMainItem:SetIsUseNativeBrowser(bIsCheck)
  self.bIsUseNativeBrowser = bIsCheck
end
function HermesTopUpMainItem:Construct()
  HermesTopUpMainItem.super.Construct(self)
  Valid = self.BuyButton and self.BuyButton.OnClicked:Add(self, self.ClickBuyButton)
  Valid = self.BuyButton and self.BuyButton.OnHovered:Add(self, self.HoveredBuyButton)
  Valid = self.BuyButton and self.BuyButton.OnUnhovered:Add(self, self.UnHoveredBuyButton)
  Valid = self.BuyButton and self.BuyButton:SetIsEnabled(false)
  self:UnHoveredBuyButton()
end
function HermesTopUpMainItem:Destruct()
  Valid = self.BuyButton and self.BuyButton.OnClicked:Remove(self, self.ClickBuyButton)
  Valid = self.BuyButton and self.BuyButton.OnHovered:Remove(self, self.HoveredBuyButton)
  Valid = self.BuyButton and self.BuyButton.OnUnhovered:Remove(self, self.UnHoveredBuyButton)
  Valid = self.BuyButton and self.BuyButton:SetIsEnabled(false)
  HermesTopUpMainItem.super.Destruct(self)
end
function HermesTopUpMainItem:HoveredBuyButton()
  Valid = self.WidgetSwitcher_ButtonImage and self.WidgetSwitcher_ButtonImage:SetActiveWidgetIndex(1)
  Valid = self.Price and self.Price:SetColorAndOpacity(self.HoveredColor)
end
function HermesTopUpMainItem:UnHoveredBuyButton()
  Valid = self.WidgetSwitcher_ButtonImage and self.WidgetSwitcher_ButtonImage:SetActiveWidgetIndex(0)
  Valid = self.Price and self.Price:SetColorAndOpacity(self.NormalColor)
end
function HermesTopUpMainItem:ClickBuyButton()
  LogInfo("Pay", "ClickBuyButton")
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
    GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(self.CommodityId, true)
  else
    GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(self.CommodityId)
  end
end
function HermesTopUpMainItem:ReqRefreshPlayerData()
  LogInfo("HermesTopUpMainItem", "ReqRefreshPlayerData")
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  midasSys:MidasQueryBalance()
end
return HermesTopUpMainItem
