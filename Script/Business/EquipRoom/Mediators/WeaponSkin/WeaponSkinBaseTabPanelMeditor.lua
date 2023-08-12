local TabBasePanelMeditor = require("Business/EquipRoom/Mediators/TabBasePanel/TabBasePanelMeditor")
local WeaponSkinBaseTabPanelMeditor = class("WeaponSkinBaseTabPanelMeditor", TabBasePanelMeditor)
local RoleProxy, EquipRoomProxy, EquipRoomPrepareProxy, WeaponProxy
function WeaponSkinBaseTabPanelMeditor:ListNotificationInterests()
  local list = WeaponSkinBaseTabPanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateWeaponSkinList)
  table.insert(list, NotificationDefines.OnResEquipWeapon)
  table.insert(list, NotificationDefines.OnResEquipWeaponFxNtf)
  return list
end
function WeaponSkinBaseTabPanelMeditor:OnRegister()
  WeaponSkinBaseTabPanelMeditor.super.OnRegister(self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  EquipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  self.weaponSlotType = nil
  self.bDefaultSelect = true
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel.onSelectItemEvent:Add(self.OnSkinUpItemSelected, self)
  end
end
function WeaponSkinBaseTabPanelMeditor:OnRemove()
  WeaponSkinBaseTabPanelMeditor.super.OnRemove(self)
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel.onSelectItemEvent:Remove(self.OnSkinUpItemSelected, self)
  end
end
function WeaponSkinBaseTabPanelMeditor:HandleNotification(notify)
  WeaponSkinBaseTabPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateWeaponSkinList then
    self:UpdateItemList(notifyBody)
    if self.bDefaultSelect then
      self:SelectDefaultItem()
    end
    self.bDefaultSelect = true
  elseif notifyName == NotificationDefines.OnResEquipWeapon then
    self:OnResEquipWeapon(notifyBody)
  elseif notifyName == NotificationDefines.OnResEquipWeaponFxNtf then
    self:OnResEquipWeaponFx(notifyBody)
  end
end
function WeaponSkinBaseTabPanelMeditor:OnShowPanel()
  WeaponSkinBaseTabPanelMeditor.super.OnShowPanel(self)
  self:ClearPanel()
  self:SendUpdateWeaponSkinListCmd()
end
function WeaponSkinBaseTabPanelMeditor:OnHidePanel()
  WeaponSkinBaseTabPanelMeditor.super.OnHidePanel(self)
end
function WeaponSkinBaseTabPanelMeditor:SendUpdateWeaponSkinListCmd()
  local body = {}
  body.roleID = EquipRoomProxy:GetSelectRoleID()
  body.weaponSubType = self:GetEquipWeapon(body.roleID, self.weaponSlotType)
  if body.weaponSubType == nil then
    LogError("WeaponSkinBaseTabPanelMeditor:SendUpdateWeaponSkinListCmd", "weaponSubType is nil")
    return
  end
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinListCmd, body)
end
function WeaponSkinBaseTabPanelMeditor:GetEquipWeapon(roleID, weaponSoltType)
  local bHasRole = RoleProxy:IsOwnRole(roleID)
  local weaponID
  if bHasRole then
    weaponID = EquipRoomPrepareProxy:GetEquipWeaponIDByWeaponSlotType(roleID, weaponSoltType)
  else
    local slotTypeData = EquipRoomPrepareProxy:GetDefaultEquipWeaponMapByRoleID(roleID)
    weaponID = slotTypeData[weaponSoltType].weapon_id
  end
  if nil == weaponID then
    LogError("WeaponSkinBaseTabPanelMeditor:GetEquipWeapon", "weaponID is nil")
    return
  end
  local weaponRow = WeaponProxy:GetWeapon(weaponID)
  if weaponRow then
    return weaponRow.SubType
  end
  return nil
end
function WeaponSkinBaseTabPanelMeditor:UpdateItemList(data)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:UpdatePanel(data)
    itemListPanel:UpdateItemNumStr(data)
  end
end
function WeaponSkinBaseTabPanelMeditor:SelectDefaultItem()
  local roleID = EquipRoomProxy:GetSelectRoleID()
  local bHasRole = RoleProxy:IsOwnRole(roleID)
  if bHasRole then
    local weaponID = EquipRoomPrepareProxy:GetEquipWeaponIDByWeaponSlotType(roleID, self.weaponSlotType)
    self:GetViewComponent():SetDefaultSelectItemByItemID(weaponID)
  else
    self:GetViewComponent():SetDefaultSelectItemByIndex(1)
  end
end
function WeaponSkinBaseTabPanelMeditor:SetItemSelectState(itemID)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:SetSelectedStateByItemID(itemID)
  end
end
function WeaponSkinBaseTabPanelMeditor:OnItemClick(itemID)
  if self:GetViewComponent().ItemListPanel == nil then
    return
  end
  self:UpdateItemRedDot()
  self:UpdateSkinUpgradePanel(itemID)
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  local body = {}
  body.itemType = UE4.EItemIdIntervalType.Weapon
  body.itemID = itemID
  body.roleID = EquipRoomProxy:GetSelectRoleID()
  body.weaponSoltType = self.weaponSlotType
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateItemDescCmd, body)
  self:SendUpdateItemOperateSatateCmd(itemID)
  self:SendUpdateWeaponModel(itemID)
end
function WeaponSkinBaseTabPanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  if self:IsCanUpgrade() then
    local upItem = self:GetUpgradePanelSelectItem()
    local skinListItem = self:GetViewComponent():GetSelectItem()
    if upItem and skinListItem then
      local body = {}
      body.itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(upItem:GetItemID())
      body.itemID = upItem:GetItemID()
      body.baseSkinID = skinListItem:GetItemID()
      body.roleID = EquipRoomProxy:GetSelectRoleID()
      GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
    end
  else
    local body = {}
    body.itemType = UE4.EItemIdIntervalType.Weapon
    body.itemID = itemID
    body.roleID = EquipRoomProxy:GetSelectRoleID()
    GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
  end
end
function WeaponSkinBaseTabPanelMeditor:UpdateItemOperateState(data)
  self:GetViewComponent():UpdateItemOperateState(data)
  local skinListItem = self:GetViewComponent():GetSelectItem()
  if skinListItem then
    local bShow = skinListItem:GetEquipState() == false and skinListItem:IsSpecialOwn()
    self:SetPrivilegeEquipBtnVisible(bShow)
  end
end
function WeaponSkinBaseTabPanelMeditor:OnEquipClick()
  self.bDefaultSelect = false
  if not RoleProxy:IsOwnRole(EquipRoomProxy:GetSelectRoleID()) then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_1")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    return
  end
  local skinListItem = self:GetViewComponent():GetSelectItem()
  if nil == skinListItem then
    return
  end
  local baseWeaponID = skinListItem:GetItemID()
  if self:IsCanUpgrade() then
    local upItem = self:GetUpgradePanelSelectItem()
    local upItemID = upItem:GetItemID()
    if upItem then
      local itemType = upItem:GetUIItemType()
      if itemType == UE4.ECyWeaponSkinUpgradeUIItemType.FinalEffect then
        if upItem:GetIsEquip() then
          self:SendEquipFx(baseWeaponID, UE4.EWeaponUpgradeFxType.Final, 0)
        else
          self:SendEquipFx(baseWeaponID, UE4.EWeaponUpgradeFxType.Final, upItemID)
        end
      elseif itemType == UE4.ECyWeaponSkinUpgradeUIItemType.AdvancedEffect then
        if upItem:GetIsEquip() then
          self:SendEquipFx(baseWeaponID, UE4.EWeaponUpgradeFxType.Advanced, 0)
        else
          self:SendEquipFx(baseWeaponID, UE4.EWeaponUpgradeFxType.Advanced, upItemID)
        end
      elseif itemType == UE4.ECyWeaponSkinUpgradeUIItemType.Advanced then
        self:SendEquipWeaponCmd(upItemID)
      elseif itemType == UE4.ECyWeaponSkinUpgradeUIItemType.Base then
        self:SendEquipWeaponCmd()
      end
    end
  else
    self:SendEquipWeaponCmd()
  end
end
function WeaponSkinBaseTabPanelMeditor:SendEquipWeaponCmd(advancedSkinID)
  local item = self:GetViewComponent():GetSelectItem()
  if item then
    local itemID = item:GetItemID()
    if advancedSkinID then
      local equipWeaponData = {}
      equipWeaponData.itemID = itemID
      equipWeaponData.weaponSoltType = self.weaponSlotType
      equipWeaponData.roleID = EquipRoomProxy:GetSelectRoleID()
      equipWeaponData.advancedSkinID = advancedSkinID
      GameFacade:SendNotification(NotificationDefines.ReqEquipWeaponCmd, equipWeaponData)
    elseif item:IsOwn() then
      local equipWeaponData = {}
      equipWeaponData.itemID = itemID
      equipWeaponData.weaponSoltType = self.weaponSlotType
      equipWeaponData.roleID = EquipRoomProxy:GetSelectRoleID()
      equipWeaponData.advancedSkinID = advancedSkinID
      GameFacade:SendNotification(NotificationDefines.ReqEquipWeaponCmd, equipWeaponData)
    end
  end
end
function WeaponSkinBaseTabPanelMeditor:SendEquipFx(weaponID, fxType, fxID)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  weaponProxy:ReqEquipWeponFx(weaponID, fxType, fxID)
end
function WeaponSkinBaseTabPanelMeditor:OnResEquipWeapon(data)
  self.bDefaultSelect = false
  self:SendUpdateWeaponSkinListCmd()
  self:SetItemSelectState(self.lastSelectItemID)
  self:UpdateSkinUpgradePanelByEquipOrBuy(self.lastSelectItemID)
  self:SendUpdateItemOperateSatateCmd(data.itemID)
end
function WeaponSkinBaseTabPanelMeditor:OnResEquipWeaponFx(data)
  if data.weapon_id == self.lastSelectItemID then
    self:UpdateSkinUpgradePanelByEquipOrBuy(self.lastSelectItemID)
    self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
  end
end
function WeaponSkinBaseTabPanelMeditor:SendUpdateWeaponModel(weaponID)
  if self:IsCanUpgrade() then
    local upItem = self:GetUpgradePanelSelectItem()
    if nil == upItem then
      GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinModel, weaponID)
      return
    end
    local upItemID = upItem:GetItemID()
    local itemIdIntervalType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(upItemID)
    if itemIdIntervalType == UE4.EItemIdIntervalType.Weapon then
      GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinModel, upItemID)
    elseif itemIdIntervalType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
      self:SetWeaponFx(upItemID, weaponID)
    else
      GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinModel, weaponID)
    end
  else
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinModel, weaponID)
  end
end
function WeaponSkinBaseTabPanelMeditor:OnBuyGoodsSuccessed(data)
  local bHasRole = RoleProxy:IsOwnRole(EquipRoomProxy:GetSelectRoleID())
  if bHasRole then
    self.bDefaultSelect = false
    self:SendUpdateWeaponSkinListCmd()
    self:SetItemSelectState(self.lastSelectItemID)
    self:UpdateItemRedDot()
    self:OnEquipClick()
  else
    self.bDefaultSelect = false
    self:SendUpdateWeaponSkinListCmd()
    self:SetItemSelectState(self.lastSelectItemID)
    self:UpdateSkinUpgradePanelByEquipOrBuy(self.lastSelectItemID)
    local body = {}
    body.itemType = UE4.EItemIdIntervalType.Weapon
    body.itemID = self.lastSelectItemID
    body.roleID = EquipRoomProxy:GetSelectRoleID()
    body.weaponSoltType = self.weaponSlotType
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateItemDescCmd, body)
    self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
    self:UpdateItemRedDot()
  end
end
function WeaponSkinBaseTabPanelMeditor:UpdatePanelBySelctRoleID(roleID)
  self:ClearPanel()
  self:SendUpdateWeaponSkinListCmd()
end
function WeaponSkinBaseTabPanelMeditor:UpdateItemRedDot()
  if self:GetViewComponent().ItemListPanel then
    local redDotId = self:GetViewComponent().ItemListPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):RemoveLocalRedDot(redDotId, UE4.EItemIdIntervalType.Weapon)
      GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
      self:GetViewComponent().ItemListPanel:SetSelectItemRedDotID(0)
      if GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDotPass(redDotId) then
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin, -1)
      end
    end
  end
end
function WeaponSkinBaseTabPanelMeditor:UpdateSkinUpgradePanel(inSkinID)
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel:UpdatePanel(inSkinID)
  end
end
function WeaponSkinBaseTabPanelMeditor:UpdateSkinUpgradePanelByEquipOrBuy(inSkinID)
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel:UpdatePanelByEquipOrBuy(inSkinID)
  end
end
function WeaponSkinBaseTabPanelMeditor:IsCanUpgrade()
  if self:GetViewComponent().SkinUpgradePanel then
    return self:GetViewComponent().SkinUpgradePanel:IsCanUpgrade()
  end
  return false
end
function WeaponSkinBaseTabPanelMeditor:GetUpgradePanelSelectItem()
  if self:GetViewComponent().SkinUpgradePanel then
    return self:GetViewComponent().SkinUpgradePanel:GetSelectItem()
  end
  return nil
end
function WeaponSkinBaseTabPanelMeditor:GetUpgradePanelBaseItemID()
  if self:GetViewComponent().SkinUpgradePanel then
    return self:GetViewComponent().SkinUpgradePanel:GetBaseItemID()
  end
  return 0
end
function WeaponSkinBaseTabPanelMeditor:OnSkinUpItemSelected(item)
  if nil == item then
    return
  end
  self:SendUpdateItemOperateSatateCmd(item:GetItemID())
  self:SendUpdateWeaponModel(self.lastSelectItemID)
end
function WeaponSkinBaseTabPanelMeditor:OnPrivilegeEquip()
  self:OnEquipClick()
end
return WeaponSkinBaseTabPanelMeditor
