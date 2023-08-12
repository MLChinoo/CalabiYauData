local GoodsBaseItem = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBaseItem")
local ListItem = class("ListItem", GoodsBaseItem)
function ListItem:OnInitialized()
  ListItem.super.OnInitialized(self)
  self:InitItem()
end
function ListItem:InitItem()
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
end
function ListItem:SetItemName(itemName)
  if self.Txt_ItemName then
    self.Txt_ItemName:SetText(itemName)
  end
end
function ListItem:SetQualityName(itemName)
  if nil == itemName then
    if self.Overlay_Quality then
      self.Overlay_Quality:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  if self.Overlay_Quality then
    self.Overlay_Quality:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Txt_QualityName then
    self.Txt_QualityName:SetText(itemName)
  end
end
function ListItem:SetQualityImgColor(qulityColor)
  if nil == qulityColor then
    if self.Overlay_Quality then
      self.Overlay_Quality:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  if self.Overlay_Quality then
    self.Overlay_Quality:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Img_ItemQualityBg then
    self.Img_ItemQualityBg:SetColorAndOpacity(qulityColor)
  end
end
function ListItem:SetDragItem(dragItem)
  dragItem:SetDragItemIcon(nil)
  return dragItem
end
function ListItem:IsDrag()
  if self.bCanDrag == nil or self.bCanDrag == false then
    return false
  end
  if false == self.bUnlock then
    return false
  end
  return true
end
function ListItem:SetSelectStateExtend(bSelect)
  if bSelect then
    if self.bEquip then
      if self.Img_EquipBG then
        self.Img_EquipBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self.Txt_ItemName:SetColorAndOpacity(self.ItemNameSelectColor)
    end
  elseif self.bEquip then
    if self.Img_EquipBG then
      self.Img_EquipBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.Txt_ItemName:SetColorAndOpacity(self.ItemNameNotSelectColor)
  end
end
function ListItem:OnEquipStateExpend(bEquip)
  if bEquip then
    self.Txt_ItemName:SetColorAndOpacity(self.ItemNameNotSelectColor)
    if self.Img_EquipBG then
      self.Img_EquipBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.Txt_ItemName:SetColorAndOpacity(self.ItemNameSelectColor)
    if self.Img_EquipBG then
      self.Img_EquipBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function ListItem:SetItemUnlockStateExtend(bUnlock)
  if bUnlock then
    self:HideUWidget(self.Img_LockMask)
  else
    self:ShowUWidget(self.Img_LockMask)
  end
end
function ListItem:ResetItem()
  ListItem.super.ResetItem(self)
  self:SetItemName("")
end
return ListItem
