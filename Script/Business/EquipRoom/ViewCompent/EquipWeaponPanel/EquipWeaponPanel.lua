local EquipWeaponPanel = class("EquipWeaponPanel", PureMVC.ViewComponentPanel)
function EquipWeaponPanel:OnInitialized()
  EquipWeaponPanel.super.OnInitialized(self)
  self.OnClickSoltItemEvent = LuaEvent.new()
  self.OnClickListItemEvent = LuaEvent.new()
  self.weaponEquipSlotMap = {}
  self.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Primary] = self.PrimaryWeapon
  self.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Secondary] = self.SecondaryWeapon
  self.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1] = self.Grenade_1
  self.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2] = self.Grenade_2
  for index, value in pairs(self.weaponEquipSlotMap) do
    local item = self.weaponEquipSlotMap[index]
    if item then
      item.itemClickEvent:Add(self.OnEquipSoltItemClick, self)
      item.OnHoveredEvent:Add(self.OnEquipSoltItemHovered, self)
    end
  end
  self.WeaponListPanel.OnHoveredEvent:Add(self.OnEquipSoltItemHovered, self)
  self.WeaponListPanel.OnItemClickEvent:Add(self.OnListItemClick, self)
end
function EquipWeaponPanel:UpdateEquipSlot(slotDta)
  for index, value in pairs(slotDta) do
    local item = self.weaponEquipSlotMap[index]
    if item then
      item:SetItemID(value.itemID)
      item:SetItemSoltType(index)
      item:SetItemDesc(value.itemDesc)
      item:SetItemIndex(value.itemIndex)
      item:SetSwitcherIconVisible(value.bShowSwitcherIcon)
      item:SetItemName(value.itemName)
      item:SetItemNameText(value.itemName)
      item:SetItemImage(value.sortTexture)
    end
  end
end
function EquipWeaponPanel:DefalutSelectSoltItem(soltType)
  if self.lastClickSlotItem then
    self.lastClickSlotItem:SetSelectState(false)
  end
  self.lastClickSlotItem = nil
  self.weaponEquipSlotMap[soltType]:SetSelfBeClick()
end
function EquipWeaponPanel:OnEquipSoltItemClick(soltItem)
  if self.lastClickSlotItem then
    self.lastClickSlotItem:SetSelectState(false)
  end
  self.OnClickSoltItemEvent(soltItem)
  self:UpdateWeaponDesc(soltItem)
  self.lastClickSlotItem = soltItem
  soltItem:SetSelectState(true)
end
function EquipWeaponPanel:GetSelectSoltItem()
  return self.lastClickSlotItem
end
function EquipWeaponPanel:OnListItemClick(item)
  if item:GetUnlock() == false then
    LogDebug("EquipWeaponPanel:OnListItemClick", "item no unlock ID:%s", item:GetItemID())
  end
  if item:GetEquipState() == true then
    if item:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 or item:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      if item:GetItemID() == self.lastClickSlotItem:GetItemID() then
        LogDebug("EquipWeaponPanel:OnListItemClick", "item is equip, ID:%s", item:GetItemID())
        return
      end
    else
      LogDebug("EquipWeaponPanel:OnListItemClick", "item is equip, ID:%s", item:GetItemID())
      return
    end
  end
  local data = {}
  data.itemID = item:GetItemID()
  data.weaponSoltType = self.lastClickSlotItem:GetItemSoltType()
  data.bUnlock = item:GetUnlock()
  self.OnClickListItemEvent(data)
end
function EquipWeaponPanel:UpdateWeaponList(weaponListData)
  if self.WeaponListPanel then
    self.WeaponListPanel:UpdateWeaponList(weaponListData)
  end
end
function EquipWeaponPanel:HideWeaponListPanel()
  if self.WeaponListPanel then
    self:HideUWidget(self.WeaponListPanel)
  end
end
function EquipWeaponPanel:ShowWeaponListPanel()
  if self.WeaponListPanel:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible and self.Ani_OpenWeaponList then
    self:PlayAnimation(self.Ani_OpenWeaponList)
  end
  if self.WeaponListPanel then
    self:ShowUWidget(self.WeaponListPanel)
  end
end
function EquipWeaponPanel:OnEquipSoltItemHovered(soltItem)
  self:UpdateWeaponDesc(soltItem)
end
function EquipWeaponPanel:UpdateWeaponDesc(item)
  if nil == item then
    LogError("EquipWeaponPanel", "UpdateWeaponDesc item is nil")
    return
  end
  if self.Txt_ItemName then
    self.Txt_ItemName:SetText(item:GetItemName())
  end
  if self.Txt_ItemDesc then
    self.Txt_ItemDesc:SetText(item:GetItemDesc())
  end
end
return EquipWeaponPanel
