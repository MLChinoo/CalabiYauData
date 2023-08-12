local CommonNavigationBarItem = class("CommonNavigationBarItem", PureMVC.ViewComponentPanel)
function CommonNavigationBarItem:OnInitialized()
  CommonNavigationBarItem.super.OnInitialized(self)
  self.onClickEvent = LuaEvent.new()
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Image_Hover then
    self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CommonNavigationBarItem:OnLuaItemClick()
  self.onClickEvent(self)
end
function CommonNavigationBarItem:OnLuaItemHovered()
  if not self.bSelected then
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParHover:SetReactivate(true)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function CommonNavigationBarItem:OnLuaItemUnhovered()
  if not self.bSelected then
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function CommonNavigationBarItem:SetCustomType(customType)
  self.customType = customType
end
function CommonNavigationBarItem:GetCustomType()
  return self.customType
end
function CommonNavigationBarItem:SetBarName(barName)
  if self.Txt_itemName then
    self.Txt_itemName:SetText(barName)
  end
end
function CommonNavigationBarItem:SetSelectState(bSelect)
  self.bSelected = bSelect
  if self.bSelected then
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParSelect:SetReactivate(true)
    end
    if self.TxtUnSelect and self.TextBlock_UILabel then
      self.TextBlock_UILabel:SetColorAndOpacity(self.TxtUnSelect)
    end
    if self.NameSelectColor and self.Txt_itemName then
      self.Txt_itemName:SetColorAndOpacity(self.NameSelectColor)
    end
  else
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.NameNormalColor and self.Txt_itemName then
      self.Txt_itemName:SetColorAndOpacity(self.NameNormalColor)
    end
  end
end
function CommonNavigationBarItem:SetBarType(barType)
  self.WidgetSwitcher_Item:SetActiveWidgetIndex(barType)
  self.barType = barType
end
function CommonNavigationBarItem:SetSlefBeSelect()
  self.onClickEvent(self)
end
function CommonNavigationBarItem:SetRedDotVisible(bShow)
  if self.Overlay_RedDot then
    self.Overlay_RedDot:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return CommonNavigationBarItem
