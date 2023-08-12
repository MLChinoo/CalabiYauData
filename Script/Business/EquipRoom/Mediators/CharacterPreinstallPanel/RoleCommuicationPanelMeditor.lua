local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local RoleCommuicationPanelMeditor = class("RoleCommuicationPanelMeditor", RoleTabBasePanelMeditor)
local EPanelModel = {Voice = 0, Action = 1}
local RoleProxy, EquiproomProxy
function RoleCommuicationPanelMeditor:ListNotificationInterests()
  local list = RoleCommuicationPanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleCommunicationVoiceList)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleCommunicationActionList)
  table.insert(list, NotificationDefines.EquipRoomUpdateEquipCommunicationList)
  table.insert(list, NotificationDefines.Setting.SettingChangeCompleteNtf)
  return list
end
function RoleCommuicationPanelMeditor:OnRegister()
  RoleCommuicationPanelMeditor.super.OnRegister(self)
  self:GetViewComponent().NavigationBar.onItemClickEvent:Add(self.OnChangeTab, self)
  self:GetViewComponent().GridsPanel.clickItemEvent:Add(self.OnItemClick, self)
  self:GetViewComponent().RoulettePanel.onItemDropEvent:Add(self.OnItemDrop, self)
  self:GetViewComponent().RoulettePanel.onItemDropInRoulettePanelEvent:Add(self.OnItemDropInRoulettePanel, self)
  self:GetViewComponent().RoulettePanel.onItemDragCancelledEvent:Add(self.OnItemDragCancelled, self)
  self:GetViewComponent().RoulettePanel.onItemClickEvent:Add(self.OnRouletteItemClick, self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  EquiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
end
function RoleCommuicationPanelMeditor:OnRemove()
  RoleCommuicationPanelMeditor.super.OnRemove(self)
  self:GetViewComponent().NavigationBar.onItemClickEvent:Remove(self.OnChangeTab, self)
  self:GetViewComponent().GridsPanel.clickItemEvent:Remove(self.OnItemClick, self)
  self:GetViewComponent().RoulettePanel.onItemDropEvent:Remove(self.OnItemDrop, self)
  self:GetViewComponent().RoulettePanel.onItemDropInRoulettePanelEvent:Remove(self.OnItemDrop, self)
  self:GetViewComponent().RoulettePanel.onItemDragCancelledEvent:Remove(self.OnItemDragCancelled, self)
  self:GetViewComponent().RoulettePanel.onItemClickEvent:Remove(self.OnRouletteItemClick, self)
end
function RoleCommuicationPanelMeditor:HandleNotification(notify)
  RoleCommuicationPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleCommunicationVoiceList then
    self:UpdateRoleVoiceList(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateRoleCommunicationActionList then
    self:GetViewComponent().GridsPanel:UpdatePanel(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateEquipCommunicationList then
    self:UpdateRoulettePanel(notifyBody)
    self:SendUpdateRoleVoiceListCmd()
    self:SendUpdateRoleActionListCmd()
  elseif notifyName == NotificationDefines.Setting.SettingChangeCompleteNtf then
    self:SetKeyName()
  end
end
function RoleCommuicationPanelMeditor:OnShowPanel()
  RoleCommuicationPanelMeditor.super.OnShowPanel(self)
  GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel)
  self:ClearPanel()
  self:SendUpdateRoleVoiceListCmd()
  self:SendUpdateRoleActionListCmd()
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar:SelectBarByCustomType(EPanelModel.Voice)
  end
  self:SendUpdateEquipCommunicationListCmd()
end
function RoleCommuicationPanelMeditor:OnHidePanel()
  RoleCommuicationPanelMeditor.super.OnHidePanel(self)
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar:ClearPanel()
  end
end
function RoleCommuicationPanelMeditor:OnChangeTab(tabType)
  self:GetViewComponent():ClearItemDescPanel()
  self:GetViewComponent():ClearItemOperateStatePanel()
  self.currentPanelModel = tabType
  self:GetViewComponent().WidgetSwitcher_List:SetActiveWidgetIndex(tabType)
  if EPanelModel.Voice == tabType then
    self.goodsBasePanel = self:GetViewComponent().ItemListPanel
  elseif EPanelModel.Action == tabType then
    self.goodsBasePanel = self:GetViewComponent().GridsPanel
  end
  self.goodsBasePanel:SetDefaultSelectItem(1)
end
function RoleCommuicationPanelMeditor:SendUpdateRoleVoiceListCmd()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleCommunicationVoiceListCmd, roleID)
end
function RoleCommuicationPanelMeditor:SendUpdateRoleActionListCmd()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleCommunicationActionListCmd, roleID)
end
function RoleCommuicationPanelMeditor:UpdateRoleVoiceList(data)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:UpdatePanel(data)
    itemListPanel:UpdateItemNumStr(data)
  end
end
function RoleCommuicationPanelMeditor:OnItemClick(itemID)
  if EPanelModel.Voice == self.currentPanelModel then
    self:PlayRoleVoice(itemID)
  elseif EPanelModel.Action == self.currentPanelModel then
    self:PlayRoleAction(itemID)
  end
  self:UpdateItemRedDot()
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  if EPanelModel.Voice == self.currentPanelModel then
    self:SendUpdateItemDescCmd(itemID, UE4.EItemIdIntervalType.RoleVoice)
  elseif EPanelModel.Action == self.currentPanelModel then
    self:SendUpdateItemDescCmd(itemID, UE4.EItemIdIntervalType.RoleAction)
  end
  self:SendUpdateItemOperateSatateCmd(itemID)
end
function RoleCommuicationPanelMeditor:PlayRandomAction(voiceID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local actionID = roleProxy:GetRoleVoiceRandomActionID(voiceID)
  if actionID then
    self:PlayRoleAction(actionID)
  end
end
function RoleCommuicationPanelMeditor:PlayRoleAction(roleActionID)
  GameFacade:SendNotification(NotificationDefines.EquipRoomPlayVoiceRandomAction, roleActionID)
end
function RoleCommuicationPanelMeditor:PlayRoleVoice(roleVoiceID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleVoiceRow = roleProxy:GetRoleVoice(roleVoiceID)
  if roleVoiceRow and self:GetViewComponent().MainPage and self:GetViewComponent().MainPage.WBP_ItemDisplayKeys then
    self:GetViewComponent().MainPage.WBP_ItemDisplayKeys:SetItemDisplayed({itemId = roleVoiceID, show3DBackground = true})
  end
end
function RoleCommuicationPanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  local body = {}
  if EPanelModel.Voice == self.currentPanelModel then
    body.itemType = UE4.EItemIdIntervalType.RoleVoice
  elseif EPanelModel.Action == self.currentPanelModel then
    body.itemType = UE4.EItemIdIntervalType.RoleAction
  end
  body.itemID = itemID
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
end
function RoleCommuicationPanelMeditor:UpdateItemOperateState(data)
  self:GetViewComponent():UpdateItemOperateState(data)
end
function RoleCommuicationPanelMeditor:OnEquipClick()
  local rouletteItem = self:GetViewComponent().RoulettePanel:GetCurrentItem()
  if rouletteItem then
    local itemID = self.lastSelectItemID
    if itemID == rouletteItem:GetItemID() then
      return
    end
    local roleID = EquiproomProxy:GetSelectRoleID()
    local bHasRole = RoleProxy:IsOwnRole(roleID)
    if false == bHasRole then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_3")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    local itemType = GlobalEnumDefine.ECommunicationType.RoleVoice
    if EPanelModel.Voice == self.currentPanelModel then
      itemType = GlobalEnumDefine.ECommunicationType.RoleVoice
    elseif EPanelModel.Action == self.currentPanelModel then
      itemType = GlobalEnumDefine.ECommunicationType.RoleAction
    end
    RoleProxy:ReqUpdateRoleEquipCommunications(roleID, rouletteItem:GetItemIndex(), itemType, itemID)
  end
end
function RoleCommuicationPanelMeditor:UpdatePanelBySelctRoleID(roleID)
  RoleCommuicationPanelMeditor.super.UpdatePanelBySelctRoleID(self, roleID)
  self:ClearPanel()
  self:SendUpdateRoleVoiceListCmd()
  self:SendUpdateRoleActionListCmd()
  self:SendUpdateEquipCommunicationListCmd()
  if self.goodsBasePanel then
    self.goodsBasePanel:SetDefaultSelectItem(1)
  end
end
function RoleCommuicationPanelMeditor:SendUpdateEquipCommunicationListCmd()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateEquipCommunicationListCmd, roleID)
end
function RoleCommuicationPanelMeditor:UpdateRoulettePanel(data)
  if self:GetViewComponent().RoulettePanel then
    self:GetViewComponent().RoulettePanel:UpdatePanel(data)
  end
end
function RoleCommuicationPanelMeditor:OnItemDrop(dropItem)
  if dropItem then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local roleID = equiproomProxy:GetSelectRoleID()
    local bHasRole = RoleProxy:IsUnlockRole(roleID)
    if false == bHasRole then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_3")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    local itemType = UE4.EItemIdIntervalType.RoleVoice
    if EPanelModel.Voice == self.currentPanelModel then
      itemType = GlobalEnumDefine.ECommunicationType.RoleVoice
    elseif EPanelModel.Action == self.currentPanelModel then
      itemType = GlobalEnumDefine.ECommunicationType.RoleAction
    end
    if self.goodsBasePanel and self.goodsBasePanel:GetCurrentDragItem() then
      local dragItem = self.goodsBasePanel:GetCurrentDragItem()
      roleProxy:ReqUpdateRoleEquipCommunications(roleID, dropItem:GetItemIndex(), itemType, dragItem:GetItemID())
      local item = self.goodsBasePanel:GetSingleItemByItemID(dragItem:GetItemID())
      if item then
        item:SetEquipState(true)
      end
    end
  end
end
function RoleCommuicationPanelMeditor:OnItemDropInRoulettePanel(dragItem, dropItem)
  if dropItem then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local roleID = equiproomProxy:GetSelectRoleID()
    if dragItem and dropItem then
      local itemType = dragItem:GetItemType()
      roleProxy:ReqUpdateRoleEquipCommunications(roleID, dropItem:GetItemIndex(), itemType, dragItem:GetItemID())
    end
  end
end
function RoleCommuicationPanelMeditor:OnItemDragCancelled(dragItem)
  if dragItem then
    local roleID = EquiproomProxy:GetSelectRoleID()
    local itemID = dragItem:GetItemID()
    RoleProxy:ReqUpdateRoleEquipCommunications(roleID, dragItem:GetItemIndex(), 0, 0)
    local item = self.goodsBasePanel:GetSingleItemByItemID(itemID)
    if item then
      item:SetEquipState(false)
    end
  end
end
function RoleCommuicationPanelMeditor:OnRouletteItemClick(item)
  if nil == item then
    return
  end
  local itemOperateStatePanel = self:GetViewComponent().ItemOperateStatePanel
  if nil == itemOperateStatePanel then
    return
  end
  itemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if 0 ~= item:GetItemID() then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Replace")
    itemOperateStatePanel:SetEquipBtnName(text)
  else
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Adopted")
    itemOperateStatePanel:SetEquipBtnName(text)
  end
end
function RoleCommuicationPanelMeditor:OnBuyGoodsSuccessed(data)
  if self.currentPanelModel == EPanelModel.Voice then
    self:SendUpdateRoleVoiceListCmd()
  else
    self:SendUpdateRoleActionListCmd()
  end
  self:SendUpdateItemDescCmd(self.lastSelectItemID)
  self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
  if self.goodsBasePanel then
    self.goodsBasePanel:SetSelectedStateByItemID(self.lastSelectItemID)
  end
end
function RoleCommuicationPanelMeditor:UpdateItemRedDot()
  if EPanelModel.Voice == self.currentPanelModel and self:GetViewComponent().ItemListPanel then
    local redDotId = self:GetViewComponent().ItemListPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):RemoveLocalRedDot(redDotId, UE4.EItemIdIntervalType.RoleVoice)
      self:GetViewComponent().ItemListPanel:SetSelectItemRedDotID(0)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuicationVoice, -1)
    end
  end
end
function RoleCommuicationPanelMeditor:SetKeyName()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.PC then
    self:GetViewComponent():UpdateKetTips()
  end
end
function RoleCommuicationPanelMeditor:UpdateItemOperateState(data)
  RoleCommuicationPanelMeditor.super.UpdateItemOperateState(self, data)
  local itemOperateStatePanel = self:GetViewComponent().ItemOperateStatePanel
  if nil == itemOperateStatePanel then
    return
  end
  local rouletteItem = self:GetViewComponent().RoulettePanel:GetCurrentItem()
  if rouletteItem then
    if self:GetViewComponent().ItemOperateStatePanel then
      self:GetViewComponent().ItemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if 0 ~= rouletteItem:GetItemID() then
        local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Replace")
        itemOperateStatePanel:SetEquipBtnName(text)
      else
        local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Adopted")
        itemOperateStatePanel:SetEquipBtnName(text)
      end
    end
  else
    if nil == self.goodsBasePanel then
      return
    end
    local item = self.goodsBasePanel:GetSelectItem()
    if nil == item then
      return
    end
    if item:GetUnlock() == true then
      itemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return RoleCommuicationPanelMeditor
