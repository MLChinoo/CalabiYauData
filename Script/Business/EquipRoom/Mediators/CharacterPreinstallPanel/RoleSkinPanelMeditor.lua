local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local RoleSkinPanelMeditor = class("RoleSkinPanelMeditor", RoleTabBasePanelMeditor)
local RoleProxy, EquipRoomProxy
function RoleSkinPanelMeditor:ListNotificationInterests()
  local list = RoleSkinPanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleSkinList)
  table.insert(list, NotificationDefines.OnResRoleSkinSelect)
  return list
end
function RoleSkinPanelMeditor:OnRegister()
  RoleSkinPanelMeditor.super.OnRegister(self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  self.bDefaultSelect = true
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel.onSelectItemEvent:Add(self.OnSkinUpItemSelected, self)
  end
  if self:GetViewComponent().OnShowCharacterDrawingEvent then
    self:GetViewComponent().OnShowCharacterDrawingEvent:Add(self.OnShowCharacterDrawing, self)
  end
end
function RoleSkinPanelMeditor:OnRemove()
  RoleSkinPanelMeditor.super.OnRemove(self)
  if self:GetViewComponent().OnShowCharacterDrawingEvent then
    self:GetViewComponent().OnShowCharacterDrawingEvent:Remove(self.OnShowCharacterDrawing, self)
  end
end
function RoleSkinPanelMeditor:HandleNotification(notify)
  RoleSkinPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleSkinList then
    self:UpdateRoleSkinList(notifyBody)
  elseif notifyName == NotificationDefines.OnResRoleSkinSelect then
    self:OnResRoleSkinEquip(notifyBody)
  end
end
function RoleSkinPanelMeditor:OnShowPanel()
  RoleSkinPanelMeditor.super.OnShowPanel(self)
  self:SendUpdateRoleSkinListCmd(true)
  self:SetCharacterEnableLeisure(true)
end
function RoleSkinPanelMeditor:OnHidePanel()
  RoleSkinPanelMeditor.super.OnHidePanel(self)
end
function RoleSkinPanelMeditor:SendUpdateRoleSkinListCmd(bDefaultSelect)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleSkinListCmd, bDefaultSelect)
end
function RoleSkinPanelMeditor:UpdateRoleSkinList(data)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:UpdatePanel(data.skinDataMap)
    itemListPanel:UpdateItemNumStr(data.skinDataMap)
    if self.bDefaultSelect then
      self:SelectDefaultItem()
    end
    self.bDefaultSelect = true
  end
end
function RoleSkinPanelMeditor:SelectDefaultItem()
  local bHasRole = RoleProxy:IsUnlockRole(EquipRoomProxy:GetSelectRoleID())
  if bHasRole then
    local skinID = RoleProxy:GetRoleCurrentWearSkinID(EquipRoomProxy:GetSelectRoleID())
    self:GetViewComponent():SetDefaultSelectItemByItemID(skinID)
  else
    self:GetViewComponent():SetDefaultSelectItemByIndex(1)
  end
end
function RoleSkinPanelMeditor:OnItemClick(itemID)
  if self:GetViewComponent().ItemListPanel == nil then
    return
  end
  self:UpdateItemRedDot()
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel:UpdatePanel(itemID)
    local skinUpgradeItem = self:GetViewComponent().SkinUpgradePanel:GetSelectItem()
    if skinUpgradeItem and skinUpgradeItem:GetUIItemType() == UE4.ECyCharacterSkinUpgradeUIItemType.Advanced then
      GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel, skinUpgradeItem:GetItemID())
    else
      GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel, itemID)
    end
  else
    GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel, itemID)
  end
  self:UpdateDrawBtnState(itemID)
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleSkin)
  self:SendUpdateItemOperateSatateCmd(itemID)
end
function RoleSkinPanelMeditor:UpdateItemRedDot()
  if self:GetViewComponent().ItemListPanel then
    local redDotId = self:GetViewComponent().ItemListPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):RemoveLocalRedDot(redDotId, UE4.EItemIdIntervalType.RoleSkin)
      GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
      self:GetViewComponent().ItemListPanel:SetSelectItemRedDotID(0)
      if GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDotPass(redDotId) then
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleSkin, -1)
      end
    end
  end
end
function RoleSkinPanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  if self:IsShowUpgradeSkinPanel() then
    self:SendUpSkinItemOperateStateCmd()
  else
    local body = {}
    body.itemType = UE4.EItemIdIntervalType.RoleSkin
    body.itemID = itemID
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    body.roleID = equiproomProxy:GetSelectRoleID()
    GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
  end
end
function RoleSkinPanelMeditor:OnEquipClick()
  self:HideRoleListPanel()
  local bHasRole = RoleProxy:IsOwnRole(EquipRoomProxy:GetSelectRoleID())
  if false == bHasRole then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleNotUnlockTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    return
  end
  local skinListItem = self:GetViewComponent():GetSelectItem()
  if nil == skinListItem then
    return
  end
  if self:IsShowUpgradeSkinPanel() then
    local skinUpgradeItem = self:GetViewComponent().SkinUpgradePanel:GetSelectItem()
    if skinUpgradeItem then
      local uiItemType = skinUpgradeItem:GetUIItemType()
      local roleSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.RoleSkinUpgradeProxy)
      if uiItemType == UE4.ECyCharacterSkinUpgradeUIItemType.Base then
        self:SendEquipRoleSkinReq(skinListItem:GetItemID())
      elseif uiItemType == UE4.ECyCharacterSkinUpgradeUIItemType.FlyEffect then
        if skinUpgradeItem:GetIsEquip() then
          roleSkinUpgradeProxy:ReqRoleSelectFlutterSkin(self.lastSelectItemID, 0)
        else
          roleSkinUpgradeProxy:ReqRoleSelectFlutterSkin(self.lastSelectItemID, skinUpgradeItem:GetItemID())
        end
      elseif uiItemType == UE4.ECyCharacterSkinUpgradeUIItemType.Advanced then
        self:SendEquipRoleSkinReq(skinListItem:GetItemID(), skinUpgradeItem:GetItemID())
      end
    end
  else
    self:SendEquipRoleSkinReq(skinListItem:GetItemID())
  end
end
function RoleSkinPanelMeditor:SendEquipRoleSkinReq(roleSkinID, advancedSkinID)
  RoleProxy:ReqRoleSkinSelect(EquipRoomProxy:GetSelectRoleID(), roleSkinID, advancedSkinID)
end
function RoleSkinPanelMeditor:OnResRoleSkinEquip(data)
  if self:IsShowUpgradeSkinPanel() then
    self:UpdateSkinUpPanelByEquipOrBuy(self.lastSelectItemID)
    local upItem = self:GetViewComponent().SkinUpgradePanel:GetSelectItem()
    if upItem and upItem:GetUIItemType() == UE4.ECyCharacterSkinUpgradeUIItemType.FlyEffect then
      self:SendUpSkinItemOperateStateCmd(upItem)
    else
      self:SendUpdateRoleSkinListCmd(false)
    end
  else
    self:SendUpdateRoleSkinListCmd(false)
  end
  self:SendUpdateItemOperateSatateCmd(data.role_skin_id)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleListCmd)
end
function RoleSkinPanelMeditor:OnUnlockClick()
end
function RoleSkinPanelMeditor:UpdatePanelBySelctRoleID(roleID)
  RoleSkinPanelMeditor.super.UpdatePanelBySelctRoleID(self, roleID)
  self:SendUpdateRoleSkinListCmd(true)
end
function RoleSkinPanelMeditor:OnBuyGoodsSuccessed(data)
  local bHasRole = RoleProxy:IsUnlockRole(EquipRoomProxy:GetSelectRoleID())
  if bHasRole then
    self:OnEquipClick()
  else
    self.bDefaultSelect = false
    self:SendUpdateRoleSkinListCmd(false)
    local itemListPanel = self:GetViewComponent().ItemListPanel
    if itemListPanel then
      itemListPanel:SetSelectedStateByItemID(self.lastSelectItemID)
    end
    self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleSkin)
    self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
    self:UpdateItemRedDot()
  end
end
function RoleSkinPanelMeditor:OnSkinUpItemSelected(item)
  if nil == item then
    return
  end
  self:SendUpSkinItemOperateStateCmd(item)
  if item:GetUIItemType() == UE4.ECyCharacterSkinUpgradeUIItemType.FlyEffect then
    GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchFlyEffect, {
      baseSkinID = self.lastSelectItemID,
      flyEffectID = item:GetItemID()
    })
  else
    GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel, item:GetItemID())
  end
end
function RoleSkinPanelMeditor:UpdateSkinUpPanelByEquipOrBuy(itemID)
  if self:GetViewComponent().SkinUpgradePanel then
    self:GetViewComponent().SkinUpgradePanel:UpdatePanelByEquipOrBuy(itemID)
  end
end
function RoleSkinPanelMeditor:IsShowUpgradeSkinPanel()
  if self:GetViewComponent().SkinUpgradePanel then
    return self:GetViewComponent().SkinUpgradePanel:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function RoleSkinPanelMeditor:SendUpSkinItemOperateStateCmd(item)
  if nil == item and self:GetViewComponent().SkinUpgradePanel then
    item = self:GetViewComponent().SkinUpgradePanel:GetSelectItem()
  end
  if nil == item then
    LogError("RoleSkinPanelMeditor:SendUpSkinItemOperateStateCmd", "item is nil")
    return
  end
  local body = {}
  body.itemType = item:GetItemIdIntervalType()
  body.itemID = item:GetItemID()
  body.baseSkinID = self.lastSelectItemID
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  body.roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
end
function RoleSkinPanelMeditor:UpdateDrawBtnState(itemID)
  if nil == itemID then
    LogError("RoleSkinPanelMeditor:UpdateDrawBtnState", "roleSkinID is nil")
    self:GetViewComponent():SetShowCharacterDrawingBtnVisible(false)
    return
  end
  local roleSkinRow = RoleProxy:GetRoleSkin(itemID)
  if nil == roleSkinRow then
    LogError("RoleSkinPanelMeditor:UpdateDrawBtnState", "roleSkinRow is nil,roleSkinID is " .. tostring(itemID))
    self:GetViewComponent():SetShowCharacterDrawingBtnVisible(false)
    return
  end
  local bShow = roleSkinRow.Quality == UE4.ECyItemQualityType.Red or roleSkinRow.Quality == UE4.ECyItemQualityType.PrivateClothing
  self:GetViewComponent():SetShowCharacterDrawingBtnVisible(bShow)
end
function RoleSkinPanelMeditor:OnShowCharacterDrawing()
  if RoleProxy:IsUnlockRoleSkin(self.lastSelectItemID) == false then
    local roleSkinNoUnlockDrawingTips = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleSkinNoUnlockDrawingTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, roleSkinNoUnlockDrawingTips)
    return
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.CharacterDrawingPage, false, {
    roleSkinID = self.lastSelectItemID
  })
end
function RoleSkinPanelMeditor:UpdateItemOperateState(data)
  RoleSkinPanelMeditor.super.UpdateItemOperateState(self, data)
  local skinListItem = self:GetViewComponent():GetSelectItem()
  if skinListItem then
    local bShow = skinListItem:GetEquipState() == false and skinListItem:IsSpecialOwn()
    self:SetPrivilegeEquipBtnVisible(bShow)
  end
end
function RoleSkinPanelMeditor:OnPrivilegeEquip()
  self:OnEquipClick()
end
return RoleSkinPanelMeditor
