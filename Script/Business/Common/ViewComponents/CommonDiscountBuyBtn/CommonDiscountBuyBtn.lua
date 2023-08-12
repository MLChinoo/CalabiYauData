local CommonDiscountBuyBtn = class("CommonDiscountBuyBtn", PureMVC.ViewComponentPanel)
function CommonDiscountBuyBtn:InitializeLuaEvent()
  self.clickUnlockEvent = LuaEvent.new()
end
function CommonDiscountBuyBtn:Construct()
  CommonDiscountBuyBtn.super.Construct(self)
  if self.Btn_Buy then
    self.Btn_Buy.OnClicked:Add(self, self.OnClick)
    self.Btn_Buy.OnHovered:Add(self, self.OnHover)
    self.Btn_Buy.OnUnHovered:Add(self, self.OnUnHover)
    self.Btn_Buy.OnPressed:Add(self, self.OnPress)
  end
  self:SetDiscountTitle()
end
function CommonDiscountBuyBtn:Destruct()
  CommonDiscountBuyBtn.super.Destruct(self)
  if self.Btn_Buy then
    self.Btn_Buy.OnClicked:Remove(self, self.OnClick)
    self.Btn_Buy.OnHovered:Remove(self, self.OnHover)
    self.Btn_Buy.OnUnHovered:Remove(self, self.OnUnHover)
    self.Btn_Buy.OnPressed:Remove(self, self.OnPress)
  end
end
function CommonDiscountBuyBtn:OnClick()
  self.clickUnlockEvent()
end
function CommonDiscountBuyBtn:OnHover()
  if self.PriceItem_2 then
    self.PriceItem_2:SetHoveredTextColor()
  end
  if self.PriceItem_1 then
    self.PriceItem_1:SetHoveredTextColor()
  end
end
function CommonDiscountBuyBtn:OnUnHover()
  if self.PriceItem_2 then
    self.PriceItem_2:SetNormalTextColor()
  end
  if self.PriceItem_1 then
    self.PriceItem_1:SetNormalTextColor()
  end
end
function CommonDiscountBuyBtn:OnPress()
  if self.PriceItem_2 then
    self.PriceItem_2:SetNormalTextColor()
  end
  if self.PriceItem_1 then
    self.PriceItem_1:SetNormalTextColor()
  end
end
function CommonDiscountBuyBtn:UpdateView(storeID)
  local priceListData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsPriceData(storeID)
  if nil == priceListData then
    self:SetIsEnabled(false)
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self:SetIsEnabled(true)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:SetDiscountPanelVisible(priceListData.bHasDiscount[1])
  self:SetDiscountTime(priceListData.TimeLeft)
  self:SetOnePrice(priceListData.priceList[1])
  self:SetTwoPrice(priceListData.priceList[2])
end
function CommonDiscountBuyBtn:SetDiscountPanelVisible(bShow)
  if self.Overlay_Discount then
    self.Overlay_Discount:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function CommonDiscountBuyBtn:SetDiscountTitle()
  if self.Text_Title then
    local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Discount")
    self.Text_Title:SetText(name)
  end
end
function CommonDiscountBuyBtn:SetDiscountTime(time)
  if self.Text_Time and time then
    self.Text_Time:SetText(time)
  end
end
function CommonDiscountBuyBtn:SetOnePrice(priceData)
  if self.PriceItem_1 and priceData and table.count(priceData) >= 1 then
    self.PriceItem_1:UpdatePrice(priceData)
  end
end
function CommonDiscountBuyBtn:SetTwoPrice(priceData)
  if self.PriceItem_2 then
    local bDataNull = nil == priceData or table.count(priceData) < 2
    local visible = bDataNull and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible
    self.PriceItem_2:SetVisibility(visible)
    if self.Img_line then
      self.Img_line:SetVisibility(visible)
    end
    if bDataNull then
      return
    end
    self.PriceItem_2:UpdatePrice(priceData)
  end
end
return CommonDiscountBuyBtn
