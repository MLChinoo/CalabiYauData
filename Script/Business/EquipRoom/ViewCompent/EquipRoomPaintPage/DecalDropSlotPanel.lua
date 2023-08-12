local DecalDropSlotPanel = class("DecalDropSlotPanel", PureMVC.ViewComponentPanel)
function DecalDropSlotPanel:OnInitialized()
  DecalDropSlotPanel.super.OnInitialized(self)
  self.dropSlotItems = {}
  self.clickItemEvent = LuaEvent.new()
  self.dropItemEvent = LuaEvent.new()
  self:InitDropSoltItems()
end
function DecalDropSlotPanel:Construct()
  DecalDropSlotPanel.super.Construct(self)
  self.dropSlotItems[1]:SetSelfBeClick(true)
end
function DecalDropSlotPanel:InitDropSoltItems()
  local allChild = self.HorizontalBox_DropSlotItems:GetAllChildren()
  local childNum = allChild:Length()
  for i = 1, childNum do
    local item = allChild:Get(i)
    item.itemDropEvent:Add(self.OnDecalSlotDrop, self)
    item.itemClickEvent:Add(self.OnClickDropSlotItem, self)
    self.dropSlotItems[item:GetDecalUseState()] = item
  end
end
function DecalDropSlotPanel:UpdateSlotsUnlcokState(unlockDatas)
  for key, value in pairs(unlockDatas) do
    local dropSlotItem = self.dropSlotItems[key]
    dropSlotItem:SetItemUnlockState(unlockDatas.bUnlock)
  end
end
function DecalDropSlotPanel:UpdateDecalSoltItem(DecalSoltItemDatas)
  for key, value in pairs(DecalSoltItemDatas) do
    local dropSlotItem = self.dropSlotItems[key]
    dropSlotItem:SetItemID(value.itemID)
    dropSlotItem:SetItemImage(value.sortTexture)
  end
end
function DecalDropSlotPanel:OnDecalSlotDrop(dropSlotItem)
  if self.lastClickItem then
    self.lastClickItem:SetSelectState(false)
  end
  dropSlotItem:SetSelectState(true)
  self.lastClickItem = dropSlotItem
  self.dropItemEvent(dropSlotItem)
  self:UpdateCurrentSelectSlotName(dropSlotItem:GetDecalUseState())
end
function DecalDropSlotPanel:OnClickDropSlotItem(dropSlotItem)
  if self.lastClickItem then
    self.lastClickItem:SetSelectState(false)
  end
  dropSlotItem:SetSelectState(true)
  self.lastClickItem = dropSlotItem
  self.clickItemEvent(dropSlotItem:GetDecalUseState())
  self:UpdateCurrentSelectSlotName(dropSlotItem:GetDecalUseState())
end
function DecalDropSlotPanel:GetCurrentClickItem()
  return self.lastClickItem
end
function DecalDropSlotPanel:UpdateCurrentSelectSlotName(useState)
  if self.Txt_PaintUseName then
    local printUseStateName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PaintUseStateName_" .. useState)
    self.Txt_PaintUseName:SetText(printUseStateName)
  end
end
function DecalDropSlotPanel:ShowDecalShortcutKey(text)
  if self.Txt_PaintKeyName then
    self.Txt_PaintKeyName:SetText(text)
  end
end
function DecalDropSlotPanel:ResetPanel()
  for key, value in pairs(self.dropSlotItems) do
    if value then
      value:ResetItem()
    end
  end
end
return DecalDropSlotPanel
