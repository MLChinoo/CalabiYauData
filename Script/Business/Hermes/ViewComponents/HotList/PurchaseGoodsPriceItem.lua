local HermesPurchaseGoodsPriceItem = class("HermesPurchaseGoodsPriceItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Hidden = UE4.ESlateVisibility.Hidden
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local EnumButtonStyle = {
  Normal = 0,
  Clicked = 1,
  Hovered = 2,
  Disable = 3
}
local Valid
function HermesPurchaseGoodsPriceItem:SetCurrentPrice(ItemIndex, PriceData)
  if nil == PriceData then
    return
  end
  self.ItemIndex = ItemIndex
  self.CurrencyId = PriceData.currencyID
  self.CurrencyNum = PriceData.currencyNum
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local Currency_Img = PriceData.currencyID and ItemProxy:GetCurrencyConfig(PriceData.currencyID).IconTipItem
  Valid = self.Currency_Img and self:SetImageByTexture2D(self.Currency_Img, Currency_Img)
  Valid = self.CurrencyOri_Img and self:SetImageByTexture2D(self.CurrencyOri_Img, Currency_Img)
  Valid = self.CurrencyOffset_Img and self:SetImageByTexture2D(self.CurrencyOffset_Img, Currency_Img)
  local PriceText = UE4.UKismetTextLibrary.Conv_IntToText(PriceData.currencyNum)
  Valid = self.Price and self.Price:SetText(PriceText)
  local OffsetNum = HermesProxy:GetNeedsCurrency(PriceData.currencyID, PriceData.currencyNum)
  Valid = OffsetNum and self.CurrencyOffset_Overlay and self.CurrencyOffset_Overlay:SetVisibility(SelfHitTestInvisible)
  Valid = OffsetNum and self.CurrencyOffset_Price and self.CurrencyOffset_Price:SetText(OffsetNum)
end
function HermesPurchaseGoodsPriceItem:FixedCurrentPrice(Num)
  local FixedPrice = self.CurrencyNum and self.CurrencyNum * Num
  Valid = self.Price and self.Price:SetText(FixedPrice)
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local OffsetNum = HermesProxy:GetNeedsCurrency(self.CurrencyId, FixedPrice)
  Valid = self.CurrencyOffset_Overlay and self.CurrencyOffset_Overlay:SetVisibility(OffsetNum and SelfHitTestInvisible or Hidden)
  Valid = OffsetNum and self.CurrencyOffset_Price and self.CurrencyOffset_Price:SetText(OffsetNum)
end
function HermesPurchaseGoodsPriceItem:SetOriginPrice(bHasDiscount, PriceOriginData, DiscountNum)
  if bHasDiscount then
    local OriPriceText = UE4.UKismetTextLibrary.Conv_IntToText(PriceOriginData)
    Valid = self.OriPriceOverlay and self.OriPriceOverlay:SetVisibility(SelfHitTestInvisible)
    Valid = self.CurrencyOri_Price and self.CurrencyOri_Price:SetText(OriPriceText)
  end
end
function HermesPurchaseGoodsPriceItem:SetTimeLeft(TimeLeft)
  Valid = self.CurrencyOri_TimeLeft and self.CurrencyOri_TimeLeft:SetText(TimeLeft)
end
function HermesPurchaseGoodsPriceItem:OnClickCurrencyButton()
  self.clickItemEvent(self.ItemIndex)
  self:SetCurrencyButtonState(EnumButtonStyle.Clicked)
end
function HermesPurchaseGoodsPriceItem:OnHoveredCurrencyButton()
  self:SetCurrencyButtonState(EnumButtonStyle.Hovered)
end
function HermesPurchaseGoodsPriceItem:OnUnhoveredCurrencyButton()
  self:SetCurrencyButtonState(EnumButtonStyle.Normal)
end
function HermesPurchaseGoodsPriceItem:SetCurrencyButtonState(ChangeState)
  if self.CurrencyButton and self.CurrencyButton:GetIsEnabled() then
    Valid = self.Price and self.Price:SetColorAndOpacity(self.NormalColor)
    if ChangeState == EnumButtonStyle.Normal then
      Valid = self.CurrencyButton and self.CurrencyButton:SetIsEnabled(true)
    elseif ChangeState == EnumButtonStyle.Clicked then
      Valid = self.CurrencyButton and self.CurrencyButton:SetIsEnabled(false)
    elseif ChangeState == EnumButtonStyle.Disable then
      Valid = self.CurrencyButton and self.CurrencyButton:SetIsEnabled(false)
      Valid = self.Price and self.Price:SetColorAndOpacity(self.DisableColor)
    end
    Valid = self.ButtonDisplaySwitcher and self.ButtonDisplaySwitcher:SetActiveWidgetIndex(ChangeState)
  end
end
function HermesPurchaseGoodsPriceItem:UnlockButton()
  if self.ButtonDisplaySwitcher and self.ButtonDisplaySwitcher:GetActiveWidgetIndex() == EnumButtonStyle.Clicked then
    Valid = self.CurrencyButton and self.CurrencyButton:SetIsEnabled(true)
    self:SetCurrencyButtonState(EnumButtonStyle.Normal)
  end
end
function HermesPurchaseGoodsPriceItem:InitializeLuaEvent()
  self.clickItemEvent = LuaEvent.new()
end
function HermesPurchaseGoodsPriceItem:Construct()
  HermesPurchaseGoodsPriceItem.super.Construct(self)
  Valid = self.CurrencyButton and self.CurrencyButton.OnClicked:Add(self, self.OnClickCurrencyButton)
  Valid = self.CurrencyButton and self.CurrencyButton.OnHovered:Add(self, self.OnHoveredCurrencyButton)
  Valid = self.CurrencyButton and self.CurrencyButton.OnUnhovered:Add(self, self.OnUnhoveredCurrencyButton)
end
function HermesPurchaseGoodsPriceItem:Destruct()
  Valid = self.CurrencyButton and self.CurrencyButton.OnClicked:Remove(self, self.OnClickCurrencyButton)
  Valid = self.CurrencyButton and self.CurrencyButton.OnHovered:Remove(self, self.OnHoveredCurrencyButton)
  Valid = self.CurrencyButton and self.CurrencyButton.OnUnhovered:Remove(self, self.OnUnhoveredCurrencyButton)
  HermesPurchaseGoodsPriceItem.super.Destruct(self)
end
return HermesPurchaseGoodsPriceItem
