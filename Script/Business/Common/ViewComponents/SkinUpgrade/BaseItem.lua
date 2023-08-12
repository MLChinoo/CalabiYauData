local BaseItem = class("BaseItem", PureMVC.ViewComponentPanel)
function BaseItem:Construct()
  BaseItem.super.Construct(self)
  self.onClickEvent = LuaEvent.new()
  self:OnLuaItemUnhovered()
  self:SetUnLockIconVisibility(false)
  self:SetEquipIconVisibility(false)
  self:SetSelectState(false)
end
function BaseItem:Destruct()
  BaseItem.super.Destruct(self)
end
function BaseItem:OnLuaItemClick()
  self.onClickEvent(self)
end
function BaseItem:OnLuaItemHovered()
  if self.Overlay_Hoverd then
    self.Overlay_Hoverd:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BaseItem:OnLuaItemUnhovered()
  if self.Overlay_Hoverd then
    self.Overlay_Hoverd:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function BaseItem:UpdateItemData(data)
  if nil == data then
    return
  end
  self.itemData = data
  self:SetUnLockIconVisibility(data.bUnlock)
  self:SetEquipIconVisibility(data.bEquip)
  self:SetItemName()
end
function BaseItem:ResetItem()
  self.itemData = nil
  self.bSelect = false
  self:SetUnLockIconVisibility(false)
  self:SetEquipIconVisibility(false)
  self:SetSelectState(false)
end
function BaseItem:GetItemData()
  return self.itemData
end
function BaseItem:GetIsUnlock()
  if self.itemData then
    return self.itemData.bUnlock
  end
  return false
end
function BaseItem:GetIsEquip()
  if self.itemData then
    return self.itemData.bEquip
  end
  return false
end
function BaseItem:GetItemID()
  if self.itemData then
    return self.itemData.InItemID
  end
  return 0
end
function BaseItem:SetSelectState(bSelect)
  self.bSelect = bSelect
  self:SetSelectIconVisibility(bSelect)
end
function BaseItem:GetItemIdIntervalType()
  local itemID = self:GetItemID()
  if 0 == itemID or nil == itemID then
    return nil
  end
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(self:GetItemID())
end
function BaseItem:GetUIItemType()
  return self.SkinUpgradeUIItemType
end
function BaseItem:SetUnLockIconVisibility(bUnlock)
  if self.Overlay_Lock then
    self.Overlay_Lock:SetVisibility(bUnlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BaseItem:SetEquipIconVisibility(bEquip)
  if self.Overlay_Equip then
    self.Overlay_Equip:SetVisibility(bEquip and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function BaseItem:SetSelectIconVisibility(bSelect)
  if self.Overlay_Select then
    self.Overlay_Select:SetVisibility(bSelect and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Img_Select_Icon then
    self.Img_Select_Icon:SetVisibility(bSelect and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Img_Nomal_Icon then
    self.Img_Nomal_Icon:SetVisibility(not bSelect and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function BaseItem:SetItemName()
  if self.Text_ItemName then
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(self:GetItemID())
    if itemType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
      local row = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy):GetFxWeaponRow(self:GetItemID())
      if row then
        self.Text_ItemName:SetText(row.Name)
      end
    else
      local itemName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, self.UpgradeUITypeName .. "_" .. tonumber(self.SkinUpgradeUIItemType))
      self.Text_ItemName:SetText(itemName)
    end
  end
end
return BaseItem
