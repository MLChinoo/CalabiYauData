local HermesPurchaseGoodsCombination = class("HermesPurchaseGoodsCombination", PureMVC.ViewComponentPanel)
local Valid
function HermesPurchaseGoodsCombination:Update(StoreId)
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local StorePriceData = HermesProxy:GetStoreGoodsPriceData(StoreId)
  local bIsOwned = HermesProxy:GetStoreGoodsOwned(StoreId)
  if nil == StorePriceData or nil == StorePriceData.priceList or bIsOwned then
    return nil
  end
  self.StorePriceData = StorePriceData
  self.PriceItemMap = {}
  self.PriceLimitNumMap = {}
  self.CurSelectedPriceItemIndex = nil
  local Item
  for i = 1, StorePriceData.PriceTypeNum do
    self.CurSelectedPriceItemIndex = self.CurSelectedPriceItemIndex or i
    Item = nil
    Item = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
    Valid = Item and Item:SetCurrentPrice(i, StorePriceData.priceList[i])
    Valid = Item and Item:SetOriginPrice(StorePriceData.bHasDiscount[i], StorePriceData.PriceOrigin[i], StorePriceData.DiscountNum[i])
    Valid = Item and Item:SetTimeLeft(StorePriceData.TimeLeft)
    Valid = Item and Item.clickItemEvent:Add(self.ClickedItem, self)
    self.PriceLimitNumMap[i] = HermesProxy:GetLimitNumCurrency(StorePriceData.priceList[i].currencyID, StorePriceData.priceList[i].currencyNum)
    self.PriceItemMap[i] = Item
  end
  Valid = self.PriceItemMap[self.CurSelectedPriceItemIndex] and self.PriceItemMap[self.CurSelectedPriceItemIndex]:OnClickCurrencyButton()
end
function HermesPurchaseGoodsCombination:GetLimitNumMap()
  if self.PriceLimitNumMap[1] then
    return self.PriceLimitNumMap[1]
  end
end
function HermesPurchaseGoodsCombination:GetCurPrice()
  return self.StorePriceData and self.StorePriceData.priceList[self.CurSelectedItemId]
end
function HermesPurchaseGoodsCombination:FixedPriceByNum(Num)
  for i, v in pairs(self.PriceItemMap or {}) do
    v:FixedCurrentPrice(Num)
  end
end
function HermesPurchaseGoodsCombination:ClickedItem(ItemIndex)
  Valid = self.PriceItemMap[self.CurSelectedItemId] and self.PriceItemMap[self.CurSelectedItemId]:UnlockButton()
  self.CurSelectedItemId = ItemIndex
end
function HermesPurchaseGoodsCombination:Destruct()
  for i, v in pairs(self.PriceItemMap or {}) do
    v.clickItemEvent:Remove(self.ClickedItem, self)
  end
  HermesPurchaseGoodsCombination.super.Destruct(self)
end
return HermesPurchaseGoodsCombination
