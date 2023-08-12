local GoodsBaseItem = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBaseItem")
local EquipWeaponGridItem = class("EquipWeaponGridItem", GoodsBaseItem)
function EquipWeaponGridItem:OnInitialized()
  EquipWeaponGridItem.super.OnInitialized(self)
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
  self.OnHoveredEvent = LuaEvent.new()
end
function EquipWeaponGridItem:SetItemImage(softTexture)
  if self.soltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 or self.soltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
    self:ShowUWidget(self.Img_Grenade)
    self:HideUWidget(self.Img_ItemIcon)
    self:SetImageByTexture2D(self.Img_Grenade, softTexture)
  else
    self:ShowUWidget(self.Img_ItemIcon)
    self:HideUWidget(self.Img_Grenade)
    self:SetImageByTexture2D(self.Img_ItemIcon, softTexture)
  end
end
function EquipWeaponGridItem:SetUnlockInfo(unlockInfo)
  if unlockInfo and self.TXT_UnlockCondition then
    self:ShowUWidget(self.TXT_UnlockCondition)
    self.TXT_UnlockCondition:SetText(unlockInfo)
  elseif self.TXT_UnlockCondition then
    self:HideUWidget(self.TXT_UnlockCondition)
  end
end
function EquipWeaponGridItem:SetItemName(itemName)
  self.itemName = itemName
end
function EquipWeaponGridItem:GetItemName()
  return self.itemName
end
function EquipWeaponGridItem:SetItemNameText(itemName)
  if itemName and self.Txt_ItemName then
    self.Txt_ItemName:SetText(itemName)
    self:SetItemName(itemName)
  end
end
function EquipWeaponGridItem:SetEquipState(equipState)
  if self.WidgetSwitcher_Equip == nil then
    return
  end
  if equipState.bEquip then
    self:ShowUWidget(self.WidgetSwitcher_Equip)
    self.WidgetSwitcher_Equip:SetActiveWidgetIndex(equipState.equipType)
  else
    self:HideUWidget(self.WidgetSwitcher_Equip)
  end
  self.bEquip = equipState.bEquip
end
function EquipWeaponGridItem:SetSwitcherIconVisible(bShow)
  if bShow then
    self:ShowUWidget(self.Overlay_CanChange)
  else
    self:HideUWidget(self.Overlay_CanChange)
  end
end
function EquipWeaponGridItem:SetItemIndex(itemIndex)
  if itemIndex and self.TXT_Index then
    self.TXT_Index:SetText(itemIndex)
  end
end
function EquipWeaponGridItem:SetItemDesc(itemDesc)
  self.itemDesc = itemDesc
end
function EquipWeaponGridItem:GetItemDesc(itemDesc)
  return self.itemDesc
end
function EquipWeaponGridItem:SetItemSoltType(soltType)
  self.soltType = soltType
end
function EquipWeaponGridItem:GetItemSoltType()
  return self.soltType
end
function EquipWeaponGridItem:SetSelectStateExtend(bSelect)
  if bSelect then
    self:HideUWidget(self.Img_CanChange_Nomal)
    self:ShowUWidget(self.Img_CanChange_Select)
  else
    self:ShowUWidget(self.Img_CanChange_Nomal)
    self:HideUWidget(self.Img_CanChange_Select)
  end
end
function EquipWeaponGridItem:OnMouseEnterExpend()
  self.OnHoveredEvent(self)
end
function EquipWeaponGridItem:SetSelectState(bSelect)
  EquipWeaponGridItem.super.SetSelectState(self, bSelect)
  if bSelect and self.TXT_Index and self.Color_IndexSelected then
    self.TXT_Index:SetColorAndOpacity(self.Color_IndexSelected)
  elseif not bSelect and self.TXT_Index and self.Color_IndexNormal then
    self.TXT_Index:SetColorAndOpacity(self.Color_IndexNormal)
  end
end
return EquipWeaponGridItem
