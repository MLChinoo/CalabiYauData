local GoodsBaseItem = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBaseItem")
local GridItem = class("GridItem", GoodsBaseItem)
function GridItem:OnInitialized()
  GridItem.super.OnInitialized(self)
  self:InitItem()
end
function GridItem:InitItem()
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
end
function GridItem:SetEmptyState(bEmptyState)
  if self.WidgetSwitcher_Empty then
    local emptyState = 0
    if bEmptyState then
      emptyState = 1
    end
    self.WidgetSwitcher_Empty:SetActiveWidgetIndex(emptyState)
  else
    LogError("GridItem", "WidgetSwitcher_Empty is null")
  end
  self.bEmptyState = bEmptyState
end
function GridItem:SetItemImage(softTexture)
  self:SetImageByTexture2D(self.Img_ItemIcon, softTexture)
end
function GridItem:SetItemQuality(quality)
  if self.Img_Quality then
    if quality then
      local itemQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(quality)
      self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.color)))
    else
      self.Img_Quality:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GridItem:SetItemCount(Count)
  if self.Overlay_ItemCount == nil then
    return
  end
  if nil == Count then
    self:HideUWidget(self.Overlay_ItemCount)
    return
  end
  if 1 == Count then
    self:HideUWidget(self.Overlay_ItemCount)
    return
  end
  self:ShowUWidget(self.Overlay_ItemCount)
  self.Tex_ItemCount:SetText("X" .. Count)
end
function GridItem:SetDragItem(dragItem)
  local texture = UE4.UWidgetBlueprintLibrary.GetBrushResource(self.Img_ItemIcon.Brush)
  dragItem:SetDragItemIcon(texture, true)
  return dragItem
end
function GridItem:IsDrag()
  if self.bCanDrag == nil or self.bCanDrag == false then
    return false
  end
  if nil == self.bEmptyState or self.bEmptyState == true then
    return false
  end
  if false == self.bUnlock then
    return false
  end
  return true
end
function GridItem:ResetItem()
  GridItem.super.ResetItem(self)
  self:SetItemCount(nil)
  self:SetEmptyState(true)
  if self.Selected_Effect then
    self:StopAnimation(self.Selected_Effect)
  end
end
function GridItem:OnLuaItemClick()
  if self.itemID then
    GridItem.super.OnLuaItemClick(self)
  end
end
function GridItem:SetSelectStateExtend(bSelect)
  if self.Selected_Effect then
    if true == bSelect then
      self:PlayAnimation(self.Selected_Effect, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      self:StopAnimation(self.Selected_Effect)
    end
  end
end
return GridItem
