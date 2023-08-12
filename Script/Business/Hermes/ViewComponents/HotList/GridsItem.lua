local HermesGridsItem = class("HermesGridsItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesGridsItem:OnListItemObjectSet(itemObj)
  self:Init(itemObj)
end
function HermesGridsItem:BP_OnItemSelectionChanged(isSelected)
  if isSelected then
    self:ClickedItem()
  else
    self:ResetItem()
  end
end
function HermesGridsItem:Init(ItemData)
  self.ItemId = ItemData.ItemId
  self:ResetItem()
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local StoreGoodsCfg = HermesProxy:GetAnyStoreGoodsDataByStoreId(ItemData.ItemId)
  local itemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemInfoById(self.ItemId)
  local itemQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(itemConfig.quality)
  local imgQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.color))
  Valid = self.Img_Quality and self.Img_Quality:SetColorAndOpacity(imgQualityColor)
  Valid = self.Img_ItemIcon and self:SetImageByTexture2D(self.Img_ItemIcon, itemConfig.image)
  Valid = ItemData.ItemNum > 1 and self.ItemNum and self.ItemNum:SetText("X" .. ItemData.ItemNum)
  Valid = self.ItemNum and self.ItemNum:SetVisibility(ItemData.ItemNum > 1 and SelfHitTestInvisible or Collapsed)
  Valid = StoreGoodsCfg and self.Overlay_GiftAway and self.Overlay_GiftAway:SetVisibility(StoreGoodsCfg.store_param == GlobalEnumDefine.EStoreType.GiftAway and SelfHitTestInvisible or Collapsed)
  Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(ItemsProxy:GetAnyItemOwned(ItemData.ItemId) and SelfHitTestInvisible or Collapsed)
end
function HermesGridsItem:ClickedItem()
  self.clickItemEvent(self.ItemId)
  self:SelectedItem()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function HermesGridsItem:ResetItem()
  self:HideUWidget(self.Img_Hovered)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(Collapsed)
  Valid = self.Selected_Effect and self:StopAnimation(self.Selected_Effect)
end
function HermesGridsItem:SelectedItem()
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(SelfHitTestInvisible)
  Valid = self.Selected_Effect and self:PlayAnimation(self.Selected_Effect, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function HermesGridsItem:UpdateState()
  if GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemOwned(self.ItemId) then
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(SelfHitTestInvisible)
  else
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(Collapsed)
  end
end
function HermesGridsItem:OnLuaItemHovered()
  self:ShowUWidget(self.Img_Hovered)
end
function HermesGridsItem:OnLuaItemUnhovered()
  self:HideUWidget(self.Img_Hovered)
end
function HermesGridsItem:InitializeLuaEvent()
  self.clickItemEvent = LuaEvent.new()
end
function HermesGridsItem:Construct()
  HermesGridsItem.super.Construct(self)
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Bind(self, self.ClickedItem)
end
function HermesGridsItem:Destruct()
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Unbind()
  HermesGridsItem.super.Destruct(self)
end
return HermesGridsItem
