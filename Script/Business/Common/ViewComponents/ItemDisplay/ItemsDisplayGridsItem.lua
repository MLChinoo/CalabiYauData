local ItemsDisplayGridsItem = class("ItemsDisplayGridsItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function ItemsDisplayGridsItem:OnListItemObjectSet(itemObj)
  self:Init(itemObj)
end
function ItemsDisplayGridsItem:BP_OnItemSelectionChanged(isSelected)
  if isSelected then
    self:ClickedItem()
  else
    self:ResetItem()
  end
end
function ItemsDisplayGridsItem:Init(itemData)
  self.itemId = itemData.itemId
  self:ResetItem()
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local imgQualityColor = itemData.qualityColor
  local itemImage = itemData.image
  local itemNum = itemData.itemNum
  Valid = self.Img_Quality and self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(imgQualityColor)))
  Valid = self.Img_ItemIcon and self:SetImageByTexture2D(self.Img_ItemIcon, itemImage)
  Valid = itemNum > 1 and self.ItemNum and self.ItemNum:SetText("X" .. itemNum)
  Valid = self.ItemNum and self.ItemNum:SetVisibility(itemNum > 1 and SelfHitTestInvisible or Collapsed)
  Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(itemsProxy:GetAnyItemOwned(itemData.itemId) and SelfHitTestInvisible or Collapsed)
end
function ItemsDisplayGridsItem:ClickedItem()
  self.clickItemEvent(self.itemId)
  self:SelectedItem()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ItemsDisplayGridsItem:ResetItem()
  self:HideUWidget(self.Img_Hovered)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(Collapsed)
  Valid = self.Selected_Effect and self:StopAnimation(self.Selected_Effect)
end
function ItemsDisplayGridsItem:SelectedItem()
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(SelfHitTestInvisible)
  Valid = self.Selected_Effect and self:PlayAnimation(self.Selected_Effect, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function ItemsDisplayGridsItem:UpdateState()
  if GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemOwned(self.itemId) then
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(SelfHitTestInvisible)
  else
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(Collapsed)
  end
end
function ItemsDisplayGridsItem:OnLuaItemHovered()
  self:ShowUWidget(self.Img_Hovered)
end
function ItemsDisplayGridsItem:OnLuaItemUnhovered()
  self:HideUWidget(self.Img_Hovered)
end
function ItemsDisplayGridsItem:InitializeLuaEvent()
  self.clickItemEvent = LuaEvent.new()
end
function ItemsDisplayGridsItem:Construct()
  ItemsDisplayGridsItem.super.Construct(self)
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Bind(self, self.ClickedItem)
end
function ItemsDisplayGridsItem:Destruct()
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Unbind()
  ItemsDisplayGridsItem.super.Destruct(self)
end
return ItemsDisplayGridsItem
