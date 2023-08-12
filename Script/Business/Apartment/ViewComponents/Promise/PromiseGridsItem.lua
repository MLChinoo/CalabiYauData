local PromiseRewardGridItem = class("PromiseRewardGridItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function PromiseRewardGridItem:BP_OnItemSelectionChanged(isSelected)
  if isSelected then
    self:ClickedItem()
  else
    self:ResetItem()
  end
end
function PromiseRewardGridItem:Init(ItemData)
  self.ItemId = ItemData.ItemId
  self:ResetItem()
  local itemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemInfoById(self.ItemId)
  local itemQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(itemConfig.quality)
  local imgQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.color))
  Valid = self.Img_Quality and self.Img_Quality:SetColorAndOpacity(imgQualityColor)
  Valid = self.Img_ItemIcon and self:SetImageByTexture2D(self.Img_ItemIcon, itemConfig.image)
  if ItemData.ItemAmount and ItemData.ItemAmount >= 2 then
    Valid = self.ItemNum and self.ItemNum:SetText(ItemData.ItemAmount)
    Valid = self.ItemNum and self.ItemNum:SetVisibility(SelfHitTestInvisible)
  else
    Valid = self.ItemNum and self.ItemNum:SetVisibility(Collapsed)
  end
end
function PromiseRewardGridItem:ClickedItem()
  self.clickItemEvent(self.ItemId)
  self:SelectedItem()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function PromiseRewardGridItem:ResetItem()
  self:HideUWidget(self.Img_Hovered)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(Collapsed)
  Valid = self.Selected_Effect and self:StopAnimation(self.Selected_Effect)
end
function PromiseRewardGridItem:SelectedItem()
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(SelfHitTestInvisible)
  Valid = self.Selected_Effect and self:PlayAnimation(self.Selected_Effect, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function PromiseRewardGridItem:UpdateState()
  if GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemOwned(self.ItemId) then
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(SelfHitTestInvisible)
  else
    Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(Collapsed)
  end
end
function PromiseRewardGridItem:OnLuaItemHovered()
  self:ShowUWidget(self.Img_Hovered)
end
function PromiseRewardGridItem:OnLuaItemUnhovered()
  self:HideUWidget(self.Img_Hovered)
end
function PromiseRewardGridItem:InitializeLuaEvent()
  self.clickItemEvent = LuaEvent.new()
end
function PromiseRewardGridItem:Construct()
  PromiseRewardGridItem.super.Construct(self)
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Bind(self, self.ClickedItem)
end
function PromiseRewardGridItem:Destruct()
  Valid = self.Border_Click and self.Border_Click.OnMouseButtonUpEvent:Unbind()
  PromiseRewardGridItem.super.Destruct(self)
end
return PromiseRewardGridItem
