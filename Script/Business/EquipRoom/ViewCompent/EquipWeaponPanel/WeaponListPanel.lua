local WeaponListPanel = class("WeaponListPanel", PureMVC.ViewComponentPanel)
function WeaponListPanel:OnInitialized()
  WeaponListPanel.super.OnInitialized(self)
  self.weaponListItemMap = {}
  self.OnItemClickEvent = LuaEvent.new()
  self.OnHoveredEvent = LuaEvent.new()
end
function WeaponListPanel:UpdateWeaponList(weaponListData)
  local dataNum = table.count(weaponListData)
  self:CheckDynamicEntryNum(dataNum)
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  for i = 1, EntryNum do
    local item = self.weaponListItemMap[i]
    if i <= dataNum then
      local value = weaponListData[i]
      if item and value then
        self:ShowUWidget(item)
        item:SetSelectState(false)
        item:SetItemID(value.itemID)
        item:SetItemSoltType(value.slotType)
        item:SetItemDesc(value.itemDesc)
        item:SetItemUnlockState(value.bUnlock)
        item:SetSwitcherIconVisible(value.bShowSwitcherIcon)
        item:SetItemNameText(value.itemName)
        item:SetItemImage(value.sortTexture)
        item:SetUnlockInfo(value.unlockInfo)
        item:SetEquipState(value)
        if value.weaponListSoltType == value.currentEquipSoltType then
          self.lastClickItem = item
          item:SetSelectState(true)
        end
      end
    else
      self:HideUWidget(item)
    end
  end
end
function WeaponListPanel:CheckDynamicEntryNum(GoodDataNum)
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  local SurplusNum = GoodDataNum - EntryNum
  if SurplusNum > 0 then
    for i = 1, SurplusNum do
      local Widget = self:GenerateItem()
      self.weaponListItemMap[EntryNum + i] = Widget
    end
  end
  return self.weaponListItemMap
end
function WeaponListPanel:OnItemClick(item)
  if self.lastClickItem then
    self.lastClickItem:SetSelectState(false)
  end
  item:SetSelectState(true)
  self.lastClickItem = item
  self.OnItemClickEvent(item)
end
function WeaponListPanel:OnItemHovered(item)
  self.OnHoveredEvent(item)
end
function WeaponListPanel:GenerateItem()
  local itemWidget = self.DynamicEntryBox_Item:BP_CreateEntry()
  itemWidget.itemClickEvent:Add(self.OnItemClick, self)
  itemWidget.OnHoveredEvent:Add(self.OnItemHovered, self)
  return itemWidget
end
return WeaponListPanel
