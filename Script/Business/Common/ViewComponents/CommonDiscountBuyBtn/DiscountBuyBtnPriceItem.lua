local DiscountBuyBtnPriceItem = class("DiscountBuyBtnPriceItem", PureMVC.ViewComponentPanel)
function DiscountBuyBtnPriceItem:InitializeLuaEvent()
end
function DiscountBuyBtnPriceItem:Construct()
  DiscountBuyBtnPriceItem.super.Construct(self)
end
function DiscountBuyBtnPriceItem:Destruct()
  DiscountBuyBtnPriceItem.super.Destruct(self)
end
function DiscountBuyBtnPriceItem:UpdatePrice(priceData)
  self:SetCurrentCount(priceData.currencyNum)
  self:SetCurrentIcon(priceData.currencyID)
end
function DiscountBuyBtnPriceItem:SetCurrentCount(num)
  if self.Text_Price then
    local PriceText = UE4.UKismetTextLibrary.Conv_IntToText(tonumber(num))
    self.Text_Price:SetText(PriceText)
  end
end
function DiscountBuyBtnPriceItem:SetCurrentIcon(currentID)
  if self.Img_Price and currentID then
    local currencyRow = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetCurrencyConfig(currentID)
    if currencyRow then
      self:SetImageByTexture2D(self.Img_Price, currencyRow.IconTipItem)
    end
  end
end
function DiscountBuyBtnPriceItem:SetNormalTextColor()
  if self.NormalTextColor and self.Text_Price then
    self.Text_Price:SetColorAndOpacity(self.NormalTextColor)
  end
end
function DiscountBuyBtnPriceItem:SetHoveredTextColor()
  if self.HoveredTextColor and self.Text_Price then
    self.Text_Price:SetColorAndOpacity(self.HoveredTextColor)
  end
end
return DiscountBuyBtnPriceItem
