local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local DecalPanelMediator = class("DecalPanelMediator", RoleTabBasePanelMeditor)
local RoleProxy, EquipRoomProxy
function DecalPanelMediator:ListNotificationInterests()
  local list = DecalPanelMediator.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdatePaintData)
  table.insert(list, NotificationDefines.EquipRoomUpdatePaintEquipSlot)
  table.insert(list, NotificationDefines.OnResEquipDecal)
  return list
end
function DecalPanelMediator:OnRegister()
  DecalPanelMediator.super.OnRegister(self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  if self:GetViewComponent().GridsPanel then
    self:GetViewComponent().GridsPanel.clickItemEvent:Add(self.OnClickItem, self)
    self:GetViewComponent().GridsPanel.onitemDoubleClickEvent:Add(self.OnitemDoubleClick, self)
  end
  if self:GetViewComponent().DecalDropSlotPanel then
    self:GetViewComponent().DecalDropSlotPanel.clickItemEvent:Add(self.SendUpdateItemOperateSatateCmd, self)
    self:GetViewComponent().DecalDropSlotPanel.dropItemEvent:Add(self.OnEquipClick, self)
  end
  if self:GetViewComponent().allCharacterEquipEvent then
    self:GetViewComponent().allCharacterEquipEvent:Add(self.AllCharacterEquip, self)
  end
end
function DecalPanelMediator:OnRemove()
  DecalPanelMediator.super.OnRemove(self)
  if self:GetViewComponent().GridsPanel then
    self:GetViewComponent().GridsPanel.clickItemEvent:Remove(self.OnClickItem, self)
    self:GetViewComponent().GridsPanel.onitemDoubleClickEvent:Remove(self.OnitemDoubleClick, self)
  end
  if self:GetViewComponent().DecalDropSlotPanel then
    self:GetViewComponent().DecalDropSlotPanel.clickItemEvent:Remove(self.SendUpdateItemOperateSatateCmd, self)
    self:GetViewComponent().DecalDropSlotPanel.dropItemEvent:Remove(self.OnEquipClick, self)
  end
  if self:GetViewComponent().allCharacterEquipEvent then
    self:GetViewComponent().allCharacterEquipEvent:Remove(self.AllCharacterEquip, self)
  end
end
function DecalPanelMediator:HandleNotification(notify)
  DecalPanelMediator.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdatePaintData then
    self:UpdateDecalList(notifyBody.paintItemData)
  elseif notifyName == NotificationDefines.EquipRoomUpdatePaintEquipSlot then
    self:UpdateEquipSlotContent(notifyBody)
  elseif notifyName == NotificationDefines.OnResEquipDecal then
    self:OnResEquipDecal(notifyBody)
  end
end
function DecalPanelMediator:OnShowPanel()
  DecalPanelMediator.super.OnShowPanel(self)
  self:SendUpdateDecalListCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlotCmd)
  if self.lastSelectItemID ~= nil then
    GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchDecal, self.lastSelectItemID)
  end
end
function DecalPanelMediator:SendUpdateDecalListCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintDataCmd)
end
function DecalPanelMediator:UpdateDecalList(data)
  local gridPanel = self:GetViewComponent().GridsPanel
  if gridPanel then
    gridPanel:UpdatePanel(data)
    gridPanel:UpdateItemNumStr(data)
    if self.lastSelectItemID == nil or 0 == self.lastSelectItemID then
      gridPanel:SetDefaultSelectItem(1)
    else
      gridPanel:SetDefaultSelectItemByItemID(self.lastSelectItemID)
    end
  end
end
function DecalPanelMediator:UpdateEquipSlotContent(data)
  if self:GetViewComponent().DecalDropSlotPanel then
    self:GetViewComponent().DecalDropSlotPanel:UpdateDecalSoltItem(data)
  end
end
function DecalPanelMediator:UpdateDecalDropSlotUnlcokState(itemID)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(itemID)
  if nil == decalRowData then
    LogError("DecalPanelMediator", "decalRowData is nil,id is %s", itemID)
    return
  end
  local decalUseStates = decalRowData.AvailableType
  local unlockData = {}
  for i = 1, 3 do
    local isUse = false
    for index = 1, decalUseStates:Length() do
      if i == decalUseStates:Get(index) then
        isUse = true
      end
    end
    unlockData[i] = isUse
  end
  self:GetViewComponent().DecalDropSlotPanel:UpdateSlotsUnlcokState(unlockData)
end
function DecalPanelMediator:OnClickItem(itemID)
  self:UpdateItemRedDot()
  self:SetAllEquipBtnVisible()
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.Decal)
  self:UpdateDecalDropSlotUnlcokState(self.lastSelectItemID)
  self:SendUpdateItemOperateSatateCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchDecal, itemID)
  self:SetAllEquipBtnVisible()
end
function DecalPanelMediator:OnitemDoubleClick(item)
  if nil == item then
    LogWarn("DecalPanelMediator:OnitemDoubleClick", "item is nil")
    return
  end
  if item:GetUnlock() == false then
    LogWarn("DecalPanelMediator:OnitemDoubleClick", "item is not Unlock")
    return
  end
  if false == item:GetSelectState() then
    LogWarn("DecalPanelMediator:OnitemDoubleClick", "item is NOT select")
    return false
  end
  self:OnEquipClick()
end
function DecalPanelMediator:OnItemDrop()
  self:OnEquipClick()
end
function DecalPanelMediator:UpdateItemRedDot()
  if self:GetViewComponent().GridsPanel then
    local redDotId = self:GetViewComponent().GridsPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      local redDotProxy = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy)
      redDotProxy:ReadRedDot(redDotId)
      self:GetViewComponent().GridsPanel:SetSelectItemRedDotID(0)
      if redDotProxy:GetRedDotPass(redDotId) then
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.Decal, -1)
      end
    end
  end
end
function DecalPanelMediator:OnEquipClick()
  local bHasRole = RoleProxy:IsUnlockRole(EquipRoomProxy:GetSelectRoleID())
  if false == bHasRole then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "DecalNotUnlockTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    return
  end
  local paintItem = self:GetViewComponent().GridsPanel:GetSelectItem()
  local soltItem = self:GetViewComponent().DecalDropSlotPanel:GetCurrentClickItem()
  if paintItem:GetItemID() == soltItem:GetItemID() then
    return
  end
  local soltUseState = soltItem:GetDecalUseState()
  local decalRow = GameFacade:RetrieveProxy(ProxyNames.DecalProxy):GetDecalTableDataByItemID(paintItem:GetItemID())
  if nil == decalRow then
    LogError("SendEquipPaintCmd", "decalRow is nil")
    return
  end
  local useTypeArray = decalRow.AvailableType
  local bUse = false
  local count = useTypeArray:Length()
  for i = 1, count do
    if soltUseState == useTypeArray:Get(i) then
      bUse = true
      break
    end
  end
  if false == bUse then
    if soltUseState == UE4.EDecalUseState.InBattle then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "DecalNotUseTips")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    end
    return
  end
  local equipPaintData = {}
  equipPaintData.useState = soltItem:GetDecalUseState()
  equipPaintData.decalID = paintItem:GetItemID()
  equipPaintData.roleID = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy):GetSelectRoleID()
  self:SendEquipPaintCmd(equipPaintData)
end
function DecalPanelMediator:SendEquipPaintCmd(equipPaintData)
  if nil == equipPaintData and nil == equipPaintData.useState and nil == equipPaintData.decalID then
    LogError("SendEquipPaintCmd", "equipPaintData is nil")
    return
  end
  GameFacade:SendNotification(NotificationDefines.ReqEquipDecalCmd, equipPaintData)
end
function DecalPanelMediator:OnResEquipDecal(notifyBody)
  self:SendUpdateDecalListCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlotCmd)
  self:SendUpdateItemOperateSatateCmd()
end
function DecalPanelMediator:SendUpdateItemOperateSatateCmd()
  local decalItem = self:GetViewComponent().GridsPanel:GetSelectItem()
  local soltItem = self:GetViewComponent().DecalDropSlotPanel:GetCurrentClickItem()
  local notifyBody = {}
  notifyBody.itemType = UE4.EItemIdIntervalType.Decal
  notifyBody.itemID = decalItem:GetItemID()
  notifyBody.soltItemID = soltItem:GetItemID()
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, notifyBody)
end
function DecalPanelMediator:OnBuyGoodsSuccessed(data)
  self:SendUpdateDecalListCmd()
  self:SendUpdateItemOperateSatateCmd()
  self:UpdateItemRedDot()
end
function DecalPanelMediator:UpdatePanelBySelctRoleID(roleID)
  LogDebug("DecalPanelMediator:UpdatePanelBySelctRoleID", "currentRoleID is " .. tostring(roleID))
  DecalPanelMediator.super.UpdatePanelBySelctRoleID(self, roleID)
  if self:GetViewComponent().DecalDropSlotPanel then
    self:GetViewComponent().DecalDropSlotPanel:ResetPanel()
  end
  self.lastSelectItemID = nil
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlotCmd, roleID)
  self:SendUpdateDecalListCmd()
end
function DecalPanelMediator:AllCharacterEquip()
  local paintItem = self:GetViewComponent().GridsPanel:GetSelectItem()
  local soltItem = self:GetViewComponent().DecalDropSlotPanel:GetCurrentClickItem()
  local soltUseState = soltItem:GetDecalUseState()
  local decalRow = GameFacade:RetrieveProxy(ProxyNames.DecalProxy):GetDecalTableDataByItemID(paintItem:GetItemID())
  if nil == decalRow then
    LogError("SendEquipPaintCmd", "decalRow is nil")
    return
  end
  local useTypeArray = decalRow.AvailableType
  local bUse = false
  local count = useTypeArray:Length()
  for i = 1, count do
    if soltUseState == useTypeArray:Get(i) then
      bUse = true
      break
    end
  end
  if false == bUse then
    if soltUseState == UE4.EDecalUseState.InBattle then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "DecalNotUseTips")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    end
    return
  end
  local equipPaintData = {}
  equipPaintData.useState = soltItem:GetDecalUseState()
  equipPaintData.decalID = paintItem:GetItemID()
  equipPaintData.roleID = 0
  self:SendEquipPaintCmd(equipPaintData)
end
function DecalPanelMediator:SetAllEquipBtnVisible()
  local bHasRole = RoleProxy:IsUnlockRole(EquipRoomProxy:GetSelectRoleID())
  local bUnlock = false
  if self:GetViewComponent().GridsPanel then
    local paintItem = self:GetViewComponent().GridsPanel:GetSelectItem()
    if paintItem then
      bUnlock = paintItem:GetUnlock()
    end
  end
  local visiable = bHasRole and bUnlock
  if self:GetViewComponent().Btn_AllCharacterEquip then
    self:GetViewComponent().Btn_AllCharacterEquip:SetVisibility(visiable and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return DecalPanelMediator
