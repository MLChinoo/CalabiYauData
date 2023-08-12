local GoodsBaseItem = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBaseItem")
local DropSlotItem = class("DropSlotItem", GoodsBaseItem)
function DropSlotItem:OnInitialized()
  DropSlotItem.super.OnInitialized(self)
  self:HideUWidget(self.Img_Hovered)
  self.itemDropEvent = LuaEvent.new()
end
function DropSlotItem:SetDragItemIcon(texture)
  local activeIndex = 0
  if texture then
    self:SetImageByTexture2D(self.Img_Item, texture)
    activeIndex = 1
  end
  self.WidgetSwitcher_Item:SetActiveWidgetIndex(activeIndex)
end
function DropSlotItem:SetItemImage(softTexture)
  if nil == softTexture then
    self:HideUWidget(self.Img_ItemIcon)
    return
  end
  self:ShowUWidget(self.Img_ItemIcon)
  self:SetImageByTexture2D(self.Img_ItemIcon, softTexture)
end
function DropSlotItem:OnDrop(myGeometry, pointerEvent, operation)
  local dropResult = false
  if self.bUnlock == false then
    return dropResult
  end
  if operation.Payload == nil then
    return dropResult
  end
  local dragItem = operation.Payload
  if self.itemID == dragItem:GetItemID() then
    return dropResult
  end
  self.itemDropEvent(self)
  return true
end
function DropSlotItem:GetDecalUseState()
  return self.DecalUseState
end
function DropSlotItem:ResetItem()
  self.itemID = nil
  self:SetItemImage(nil)
end
return DropSlotItem
