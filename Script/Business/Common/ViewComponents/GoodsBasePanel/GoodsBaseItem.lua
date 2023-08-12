local GoodsBaseItem = class("GoodsBaseItem", PureMVC.ViewComponentPanel)
function GoodsBaseItem:OnInitialized()
  GoodsBaseItem.super.OnInitialized(self)
end
function GoodsBaseItem:InitializeLuaEvent()
  GoodsBaseItem.super.InitializeLuaEvent(self)
  self.itemClickEvent = LuaEvent.new(self)
  self.onStartDragEvent = LuaEvent.new()
  self.onitemDoubleClickEvent = LuaEvent.new()
end
function GoodsBaseItem:SetSelectState(bSelect)
  if self.Img_Selected == nil then
  end
  if bSelect then
    self:ShowUWidget(self.Img_Selected)
  else
    self:HideUWidget(self.Img_Selected)
  end
  self:SetSelectStateExtend(bSelect)
  self.bSelect = bSelect
end
function GoodsBaseItem:SetSelectStateExtend(bSelect)
end
function GoodsBaseItem:GetSelectState()
  return self.bSelect
end
function GoodsBaseItem:OnMouseEnterExpend()
end
function GoodsBaseItem:SetEquipState(bEquip)
  if self.Img_Equip == nil then
    return
  end
  if nil == bEquip then
    self:HideUWidget(self.Img_Equip)
    return
  end
  if bEquip then
    self:ShowUWidget(self.Img_Equip)
  else
    self:HideUWidget(self.Img_Equip)
  end
  self.bEquip = bEquip
  self:OnEquipStateExpend(bEquip)
end
function GoodsBaseItem:OnEquipStateExpend(bEquip)
end
function GoodsBaseItem:GetEquipState()
  return self.bEquip
end
function GoodsBaseItem:SetItemUnlockState(bUnlock)
  if self.Canvas_Lock == nil then
  end
  if nil == bUnlock then
    self:HideUWidget(self.Canvas_Lock)
    return
  end
  if bUnlock then
    self:HideUWidget(self.Canvas_Lock)
  else
    self:ShowUWidget(self.Canvas_Lock)
  end
  self.bUnlock = bUnlock
  self:SetItemUnlockStateExtend(bUnlock)
end
function GoodsBaseItem:SetItemUnlockStateExtend(bUnlock)
end
function GoodsBaseItem:GetUnlock()
  return self.bUnlock
end
function GoodsBaseItem:SetItemID(inItemID)
  self.itemID = inItemID
end
function GoodsBaseItem:GetItemID()
  return self.itemID
end
function GoodsBaseItem:SetRedDotVisible(bShow)
  if self.Overlay_RedDot then
    if bShow then
      self.Overlay_RedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Overlay_RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GoodsBaseItem:SetRedDotID(InRedDotID)
  self.redDotID = InRedDotID
  self:SetRedDotVisible(self.redDotID ~= nil and 0 ~= self.redDotID)
end
function GoodsBaseItem:GetRedDotID()
  return self.redDotID
end
function GoodsBaseItem:SetSelfBeClick(bIgnoreID)
  if (nil == bIgnoreID or false == bIgnoreID) and nil == self.itemID then
    LogWarn("GoodsBaseItem:SetSelfBeClick", "itemID is nil")
    return
  end
  self:itemClickEvent(self)
end
function GoodsBaseItem:SetSelfBeHovered()
  self:ShowUWidget(self.Img_Hovered)
  self:OnMouseEnterExpend()
end
function GoodsBaseItem:SetDargState(bCanDrag)
  self.bCanDrag = bCanDrag
end
function GoodsBaseItem:SetDragItem(dragItem)
  return dragItem
end
function GoodsBaseItem:SetItemSpecial(data)
  if nil == data then
    if self.CanvasPanel_Special then
      self.CanvasPanel_Special:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.SpecialType = nil
    return
  end
  if self.CanvasPanel_Special then
    self.CanvasPanel_Special:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if data.PrivilegeType == UE4.ECyPrivilegeType.QQCafe then
    self:SetQQInternetBarSpecial(data)
  end
end
function GoodsBaseItem:SetQQInternetBarSpecial(data)
  self:HideUWidget(self.Canvas_Lock)
  self.SpecialType = UE4.ECyPrivilegeType.QQCafe
end
function GoodsBaseItem:IsQQInternetBarSpecial()
  return self.SpecialType == UE4.ECyPrivilegeType.QQCafe
end
function GoodsBaseItem:IsSpecialOwn()
  return self.SpecialType ~= nil
end
function GoodsBaseItem:IsOwn()
  return self:GetUnlock() or self:IsSpecialOwn()
end
function GoodsBaseItem:ResetItem()
  self.itemID = nil
  self.bUnlock = nil
  self.bEquip = nil
  self.bCanDrag = nil
end
function GoodsBaseItem:IsDrag()
  return false
end
function GoodsBaseItem:OnLuaItemHovered()
  if self.Img_Hovered then
    self:ShowUWidget(self.Img_Hovered)
  end
  self:OnMouseEnterExpend()
end
function GoodsBaseItem:OnLuaItemUnhovered()
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
end
function GoodsBaseItem:OnLuaItemClick()
  LogDebug("GoodsBaseItem:OnLuaItemClick", "current Item : %s,  ID: %s", self.__cname, self.itemID)
  self:itemClickEvent(self)
end
function GoodsBaseItem:OnLuaItemDoubleClick()
  LogDebug("GoodsBaseItem:OnLuaItemDoubleClick", "current Item : %s,  ID: %s", self.__cname, self.itemID)
  self.onitemDoubleClickEvent(self)
end
function GoodsBaseItem:OnMouseButtonDown(myGeometry, mouseEvent)
  if self:IsDrag() == false then
    return UE4.UWidgetBlueprintLibrary.UnHandled()
  end
  local mouseKey = UE4.FKey()
  mouseKey.KeyName = "LeftMouseButton"
  return UE4.UWidgetBlueprintLibrary.DetectDragIfPressed(mouseEvent, self, mouseKey)
end
function GoodsBaseItem:OnDragDetected(myGeometry, inPointerEvent)
  local dragItem = UE4.UWidgetBlueprintLibrary.Create(self:GetWorld(), self.DragItemMode)
  if dragItem then
    dragItem = self:SetDragItem(dragItem)
  else
    LogDebug("GoodsBaseItem", "dragItem is nil")
  end
  local dropOperation = UE4.UWidgetBlueprintLibrary.CreateDragDropOperation()
  dropOperation.DefaultDragVisual = dragItem
  dropOperation.Pivot = UE4.EDragPivot.CenterCenter
  dropOperation.Payload = self
  self.onStartDragEvent(self)
  return dropOperation
end
return GoodsBaseItem
