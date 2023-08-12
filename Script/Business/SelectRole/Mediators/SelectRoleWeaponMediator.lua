local SelectRoleWeaponMediator = class("SelectRoleWeaponMediator", PureMVC.Mediator)
local ERoleViewMode = {PreviewMode = 1, NormalMode = 2}
local Display3DModelResult, EquipRoomProxy, RoleProxy, WeaponProxy
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function SelectRoleWeaponMediator:ListNotificationInterests()
  return {
    NotificationDefines.EquipRoomUpdateWeaponEquipSolt,
    NotificationDefines.EquipRoomUpdateWeaponList,
    NotificationDefines.OnResEquipWeapon,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function SelectRoleWeaponMediator:OnRegister()
  if self:GetViewComponent().OnClickWeaponSoltItemEvent then
    self:GetViewComponent().OnClickWeaponSoltItemEvent:Add(self.OnClickSoltItem, self)
  end
  if self:GetViewComponent().OnClickWeaponListItemEvent then
    self:GetViewComponent().OnClickWeaponListItemEvent:Add(self.OnClickWeaponListItem, self)
  end
end
function SelectRoleWeaponMediator:OnRemove()
  if self:GetViewComponent().OnClickWeaponSoltItemEvent then
    self:GetViewComponent().OnClickWeaponSoltItemEvent:Remove(self.OnClickSoltItem, self)
  end
  if self:GetViewComponent().OnClickWeaponListItemEvent then
    self:GetViewComponent().OnClickWeaponListItemEvent:Remove(self.OnClickWeaponListItem, self)
  end
end
function SelectRoleWeaponMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateWeaponEquipSolt then
    self:UpdateEquipSlot(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateWeaponList then
    local weaponListData = {}
    local index = 1
    for key, value in pairs(notifyBody) do
      if value.bUnlock then
        weaponListData[index] = value
        index = index + 1
      end
    end
    if table.count(weaponListData) > 0 then
      self:GetViewComponent().EquipWeaponPanel:UpdateWeaponList(weaponListData)
      self:GetViewComponent():ShowWeaponListPanel()
    end
  elseif notifyName == NotificationDefines.OnResEquipWeapon then
    local roleID = notifyBody.roleID
    local soltItem = self:GetViewComponent().EquipWeaponPanel:GetSelectSoltItem()
    if soltItem then
      self:SendUpdateWeaponListCmd(roleID, soltItem:GetItemSoltType())
      GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponEquipSoltCmd, roleID)
    end
  elseif notifyName == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed and notifyBody.IsSuccessed and notifyBody.PageName == UIPageNameDefine.EquipRoomMainPage then
    self:OnBuyGoodsSuccessed(notifyBody)
  end
end
function SelectRoleWeaponMediator:UpdateEquipSlot(weaponSoltData)
  self:GetViewComponent().EquipWeaponPanel:UpdateEquipSlot(weaponSoltData)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self:GetViewComponent())
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Team then
    for index, value in pairs(weaponSoltData) do
      if index == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
        MyPlayerController:ServerChangeRoleWeapon(self:GetViewComponent().RoleId, index, value.itemID)
      end
    end
  else
    for index, value in pairs(weaponSoltData) do
      if index ~= UE4.EWeaponSlotTypes.WeaponSlot_Primary then
        MyPlayerController:ServerChangeRoleWeapon(self:GetViewComponent().RoleId, index, value.itemID)
      end
    end
  end
end
function SelectRoleWeaponMediator:OnClickSoltItem(soltItem)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self:GetViewComponent())
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.currentWeaponSoltType and self.currentWeaponSoltType == soltItem:GetItemSoltType() then
    if self.currentWeaponSoltType ~= UE4.EWeaponSlotTypes.WeaponSlot_Primary then
      self:ShowWeaponListPanel()
    end
    LogDebug("SelectRoleWeaponMediator:OnClickSoltItem", "lastSoltType and slotItem SoltType equips,type : " .. tostring(soltItem:GetItemSoltType()))
    return
  end
  if soltItem:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
    self:GetViewComponent():HideWeaponListPanel()
  else
    local roleID = self:GetViewComponent().RoleId
    local weaponSlotType = soltItem:GetItemSoltType()
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local bHasRole = roleProxy:IsUnlockRole(roleID)
    if not bHasRole then
      self:ShowDefaultWeaponListPanel(roleID, weaponSlotType)
    else
      self:SendUpdateWeaponListCmd(roleID, weaponSlotType)
    end
  end
  self.currentWeaponSoltType = soltItem:GetItemSoltType()
end
function SelectRoleWeaponMediator:ShowDefaultWeaponListPanel(roleID, weaponSlotType)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local panel = self:GetViewComponent().EquipWeaponPanel
  local item = panel.weaponEquipSlotMap[weaponSlotType]
  local SlotItemId = item:GetItemID()
  local SlotType = weaponSlotType
  if SlotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
    SlotType = UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1
  end
  local weaponList = weaponProxy:GetWeaponListByWeaponSlotType(roleID, SlotType)
  if nil == weaponList then
    LogError("EquipRoomUpdateWeaponListCmd", "weaponList is nil")
    return
  end
  local weaponListData = {}
  local index = 1
  for key, value in pairs(weaponList) do
    local singleSoltData = {}
    singleSoltData.itemID = value.Id
    singleSoltData.itemName = value.Name
    singleSoltData.itemDesc = value.Tips
    singleSoltData.sortTexture = value.IconWhite
    singleSoltData.slotType = SlotType
    singleSoltData.bUnlock = true
    if singleSoltData.itemID == SlotItemId then
      singleSoltData.bEquip = true
      singleSoltData.equipType = 0
      if weaponSlotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
        singleSoltData.equipType = 1
      elseif weaponSlotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
        singleSoltData.equipType = 2
      end
    else
      singleSoltData.bEquip = false
    end
    singleSoltData.currentEquipSoltType = weaponSlotType
    weaponListData[index] = singleSoltData
    index = index + 1
  end
  if table.count(weaponListData) > 0 then
    self:GetViewComponent().EquipWeaponPanel:UpdateWeaponList(weaponListData)
    self:GetViewComponent():ShowWeaponListPanel()
  end
end
function SelectRoleWeaponMediator:ShowWeaponListPanel()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self:GetViewComponent())
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self:GetViewComponent().EquipWeaponPanel.WeaponListPanel:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self:GetViewComponent():ShowWeaponListPanel()
  else
    self:GetViewComponent():HideWeaponListPanel()
  end
end
function SelectRoleWeaponMediator:SendUpdateWeaponListCmd(roleID, weaponSlotType)
  local body = {}
  body.weaponSlotType = weaponSlotType
  body.roleID = roleID
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponListCmd, body)
end
function SelectRoleWeaponMediator:OnClickWeaponListItem(data)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self:GetViewComponent())
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local bHasRole = roleProxy:IsUnlockRole(self:GetViewComponent().RoleId)
  if not bHasRole then
    local panel = self:GetViewComponent().EquipWeaponPanel
    if data.weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
      local item1 = panel.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1]
      local item2 = panel.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2]
      if item2.itemID == data.itemID then
        self:SingleUpdateEquipSlot(UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2, item1.itemID)
        MyPlayerController:ServerChangeRoleWeapon(self:GetViewComponent().RoleId, UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2, item1.itemID)
      end
    end
    if data.weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      local item1 = panel.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1]
      local item2 = panel.weaponEquipSlotMap[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2]
      if item1.itemID == data.itemID then
        self:SingleUpdateEquipSlot(UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1, item2.itemID)
        MyPlayerController:ServerChangeRoleWeapon(self:GetViewComponent().RoleId, UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1, item2.itemID)
      end
    end
    self:SingleUpdateEquipSlot(data.weaponSoltType, data.itemID)
    MyPlayerController:ServerChangeRoleWeapon(self:GetViewComponent().RoleId, data.weaponSoltType, data.itemID)
    self:ShowDefaultWeaponListPanel(self:GetViewComponent().RoleId, data.weaponSoltType)
  elseif data.bUnlock then
    data.roleID = self:GetViewComponent().RoleId
    GameFacade:SendNotification(NotificationDefines.ReqEquipWeaponCmd, data)
  else
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomNoUnlockTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  end
end
function SelectRoleWeaponMediator:SingleUpdateEquipSlot(weaponSoltType, itemID)
  local panel = self:GetViewComponent().EquipWeaponPanel
  local item = panel.weaponEquipSlotMap[weaponSoltType]
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponTableData = weaponProxy:GetWeapon(itemID)
  local singleSoltData = {}
  if weaponTableData then
    singleSoltData.itemID = weaponTableData.Id
    local sub = weaponProxy:GetWeapon(weaponTableData.SubType)
    if sub then
      singleSoltData.itemName = sub.Name
      singleSoltData.itemDesc = sub.Tips
    end
    singleSoltData.sortTexture = weaponTableData.IconWhite
    singleSoltData.bShowSwitcherIcon = true
    if weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
      singleSoltData.bShowSwitcherIcon = false
      singleSoltData.itemIndex = 1
    elseif weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
      singleSoltData.itemIndex = 2
    elseif weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
      singleSoltData.itemIndex = 3
    elseif weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      singleSoltData.itemIndex = 4
    end
  end
  if item then
    item:SetItemID(singleSoltData.itemID)
    item:SetItemSoltType(weaponSoltType)
    item:SetItemDesc(singleSoltData.itemDesc)
    item:SetItemIndex(singleSoltData.itemIndex)
    item:SetSwitcherIconVisible(singleSoltData.bShowSwitcherIcon)
    item:SetItemName(singleSoltData.itemName)
    item:SetItemNameText(singleSoltData.itemName)
    item:SetItemImage(singleSoltData.sortTexture)
  end
end
function SelectRoleWeaponMediator:OnBuyGoodsSuccessed(data)
end
function SelectRoleWeaponMediator:PlayRoleEquipWeaponVoice(weaponID)
end
return SelectRoleWeaponMediator
