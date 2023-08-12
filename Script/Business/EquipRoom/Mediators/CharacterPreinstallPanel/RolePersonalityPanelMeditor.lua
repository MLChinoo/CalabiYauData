local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local RolePersonalityPanelMeditor = class("RolePersonalityPanelMeditor", RoleTabBasePanelMeditor)
local EPanelModel = {Emote = 0, Action = 1}
local RoleProxy, EquiproomProxy, RolePersonalityProxy
function RolePersonalityPanelMeditor:ListNotificationInterests()
  local list = RolePersonalityPanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleCommunicationActionList)
  table.insert(list, NotificationDefines.OnResEquipPersonality)
  table.insert(list, NotificationDefines.Setting.SettingChangeCompleteNtf)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleEmoteList)
  table.insert(list, NotificationDefines.EquipRoomUpdatePersonalityRoulette)
  return list
end
function RolePersonalityPanelMeditor:OnRegister()
  RolePersonalityPanelMeditor.super.OnRegister(self)
  self:GetViewComponent().NavigationBar.onItemClickEvent:Add(self.OnChangeTab, self)
  if self:GetViewComponent().EmoteGridsPanel then
    self:GetViewComponent().EmoteGridsPanel.clickItemEvent:Add(self.OnItemClick, self)
  end
  if self:GetViewComponent().ActionGridsPanel then
    self:GetViewComponent().ActionGridsPanel.clickItemEvent:Add(self.OnItemClick, self)
  end
  if self:GetViewComponent().RoulettePanel then
    self:GetViewComponent().RoulettePanel.onItemDropEvent:Add(self.OnItemDrop, self)
    self:GetViewComponent().RoulettePanel.onItemDropInRoulettePanelEvent:Add(self.OnItemDropInRoulettePanel, self)
    self:GetViewComponent().RoulettePanel.onItemDragCancelledEvent:Add(self.OnItemDragCancelled, self)
    self:GetViewComponent().RoulettePanel.onItemClickEvent:Add(self.OnRouletteItemClick, self)
  end
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  EquiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  RolePersonalityProxy = GameFacade:RetrieveProxy(ProxyNames.RolePersonalityCommunicationProxy)
  if self:GetViewComponent().allCharacterEquipEvent then
    self:GetViewComponent().allCharacterEquipEvent:Add(self.AllCharacterEquip, self)
  end
end
function RolePersonalityPanelMeditor:OnRemove()
  RolePersonalityPanelMeditor.super.OnRemove(self)
  if self:GetViewComponent().EmoteGridsPanel then
    self:GetViewComponent().EmoteGridsPanel.clickItemEvent:Remove(self.OnItemClick, self)
  end
  if self:GetViewComponent().ActionGridsPanel then
    self:GetViewComponent().ActionGridsPanel.clickItemEvent:Remove(self.OnItemClick, self)
  end
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar.onItemClickEvent:Remove(self.OnChangeTab, self)
  end
  if self:GetViewComponent().RoulettePanel then
    self:GetViewComponent().RoulettePanel.onItemDropEvent:Remove(self.OnItemDrop, self)
    self:GetViewComponent().RoulettePanel.onItemDropInRoulettePanelEvent:Remove(self.OnItemDrop, self)
    self:GetViewComponent().RoulettePanel.onItemDragCancelledEvent:Remove(self.OnItemDragCancelled, self)
    self:GetViewComponent().RoulettePanel.onItemClickEvent:Remove(self.OnRouletteItemClick, self)
  end
  if self:GetViewComponent().allCharacterEquipEvent then
    self:GetViewComponent().allCharacterEquipEvent:Remove(self.AllCharacterEquip, self)
  end
end
function RolePersonalityPanelMeditor:HandleNotification(notify)
  RolePersonalityPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleCommunicationActionList then
    if self:GetViewComponent().ActionGridsPanel then
      self:GetViewComponent().ActionGridsPanel:UpdatePanel(notifyBody)
    end
  elseif notifyName == NotificationDefines.EquipRoomUpdateRoleEmoteList then
    if self:GetViewComponent().EmoteGridsPanel then
      self:GetViewComponent().EmoteGridsPanel:UpdatePanel(notifyBody)
    end
  elseif notifyName == NotificationDefines.Setting.SettingChangeCompleteNtf then
    self:SetKeyName()
  elseif notifyName == NotificationDefines.OnResEquipPersonality then
    self:OnResEquipPersonality()
  elseif notifyName == NotificationDefines.EquipRoomUpdatePersonalityRoulette then
    self:UpdateRoulettePanel(notifyBody)
  end
end
function RolePersonalityPanelMeditor:OnShowPanel()
  RolePersonalityPanelMeditor.super.OnShowPanel(self)
  GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchRoleSkinModel)
  self:ClearPanel()
  self:SendUpdateRoleEmoteListCmd()
  self:SendUpdateRoleActionListCmd()
  self:SendUpdateRouletteCmd(true)
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar:SelectBarByCustomType(EPanelModel.Emote)
  end
  self:GetViewComponent():SetCharacterEnableLeisure(false)
end
function RolePersonalityPanelMeditor:OnHidePanel()
  RolePersonalityPanelMeditor.super.OnHidePanel(self)
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar:ClearPanel()
  end
  self:GetViewComponent():StopCharacterAction()
  self:GetViewComponent():RestEmote()
end
function RolePersonalityPanelMeditor:OnChangeTab(tabType)
  self:GetViewComponent():ClearItemDescPanel()
  self:GetViewComponent():ClearItemOperateStatePanel()
  self:GetViewComponent():RestEmote()
  self:GetViewComponent():StopCharacterAction()
  self.currentPanelModel = tabType
  self.lastSelectItemID = nil
  self:GetViewComponent():ResetItemDisplayPanel()
  self:GetViewComponent().WidgetSwitcher_List:SetActiveWidgetIndex(tabType)
  if EPanelModel.Emote == tabType then
    self.goodsBasePanel = self:GetViewComponent().EmoteGridsPanel
  elseif EPanelModel.Action == tabType then
    self.goodsBasePanel = self:GetViewComponent().ActionGridsPanel
  end
  if self.goodsBasePanel then
    self.goodsBasePanel:SetDefaultSelectItem(1)
  end
  self:SetAllEquipBtnVisible()
end
function RolePersonalityPanelMeditor:SendUpdateRoleEmoteListCmd()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleEmoteListCmd, roleID)
end
function RolePersonalityPanelMeditor:SendUpdateRoleActionListCmd()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleCommunicationActionListCmd, roleID)
end
function RolePersonalityPanelMeditor:OnItemClick(itemID)
  if EPanelModel.Emote == self.currentPanelModel then
    self:PlayEmote(itemID)
  elseif EPanelModel.Action == self.currentPanelModel then
    self:PlayRoleAction(itemID)
  end
  self:UpdateItemRedDot()
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  if EPanelModel.Emote == self.currentPanelModel then
    self:SendUpdateItemDescCmd(itemID, UE4.EItemIdIntervalType.RoleEmote)
  elseif EPanelModel.Action == self.currentPanelModel then
    self:SendUpdateItemDescCmd(itemID, UE4.EItemIdIntervalType.RoleAction)
  end
  self:SendUpdateItemOperateSatateCmd(itemID)
  self:SetAllEquipBtnVisible()
end
function RolePersonalityPanelMeditor:PlayRandomAction(voiceID)
  local actionID = RoleProxy:GetRoleVoiceRandomActionID(voiceID)
  if actionID then
    self:PlayRoleAction(actionID)
  end
end
function RolePersonalityPanelMeditor:PlayEmote(itemID)
  self:GetViewComponent():ShowCharacterEmote(itemID)
end
function RolePersonalityPanelMeditor:PlayRoleAction(roleActionID)
  GameFacade:SendNotification(NotificationDefines.EquipRoomPlayVoiceRandomAction, roleActionID)
end
function RolePersonalityPanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  local body = {}
  if EPanelModel.Emote == self.currentPanelModel then
    body.itemType = UE4.EItemIdIntervalType.RoleEmote
  elseif EPanelModel.Action == self.currentPanelModel then
    body.itemType = UE4.EItemIdIntervalType.RoleAction
  end
  body.itemID = itemID
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
end
function RolePersonalityPanelMeditor:OnEquipClick()
  local rouletteItem = self:GetViewComponent().RoulettePanel:GetCurrentItem()
  if rouletteItem then
    local itemID = self.lastSelectItemID
    if itemID == rouletteItem:GetItemID() then
      return
    end
    local roleID = EquiproomProxy:GetSelectRoleID()
    local bHasRole = RoleProxy:IsOwnRole(roleID)
    if false == bHasRole then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_4")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    self:SetEquipPersonality(rouletteItem:GetItemIndex(), itemID)
  end
end
function RolePersonalityPanelMeditor:SetEquipPersonality(index, itemID)
  local roleID = EquiproomProxy:GetSelectRoleID()
  if RolePersonalityProxy:GetRoleRouletteItemIDByIndex(roleID, index) == itemID then
    LogDebug("RolePersonalityPanelMeditor:OnResEquipPersonality", "Current Index " .. tostring(index) .. "itemID is " .. tostring(itemID))
    return
  end
  RolePersonalityProxy:ReqSetsPersonality(roleID, index, itemID)
end
function RolePersonalityPanelMeditor:ReqSwapPersonality(index1, index2)
  local roleID = EquiproomProxy:GetSelectRoleID()
  if index1 == index2 and nil == index1 then
    LogError("RolePersonalityPanelMeditor:OnResEquipPersonality", "index1 is nil ")
    return
  end
  RolePersonalityProxy:ReqSwapPersonality(roleID, index1, index2)
end
function RolePersonalityPanelMeditor:OnResEquipPersonality(data)
  LogDebug("RolePersonalityPanelMeditor:OnResEquipPersonality", "RolePersonalityPanelMeditor:OnResEquipPersonality")
  if self.currentPanelModel == EPanelModel.Emote then
    self:SendUpdateRoleEmoteListCmd()
  else
    self:SendUpdateRoleActionListCmd()
  end
  self:SendUpdateRouletteCmd()
end
function RolePersonalityPanelMeditor:UpdatePanelBySelctRoleID(roleID)
  RolePersonalityPanelMeditor.super.UpdatePanelBySelctRoleID(self, roleID)
  self:ClearPanel()
  self:GetViewComponent():ClearItemDescPanel()
  self:GetViewComponent():ClearItemOperateStatePanel()
  self:GetViewComponent():RestEmote()
  self:SendUpdateRoleEmoteListCmd()
  self:SendUpdateRoleActionListCmd()
  self:SendUpdateRouletteCmd(true)
  self:GetViewComponent():SetCharacterEnableLeisure(false)
  if self.goodsBasePanel then
    self.goodsBasePanel:SetDefaultSelectItem(1)
  end
  self:GetViewComponent():UpdatePanelRedDot()
end
function RolePersonalityPanelMeditor:SendUpdateRouletteCmd(bDefaultSelect)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePersonalityRouletteCmd, EquiproomProxy:GetSelectRoleID())
  if bDefaultSelect and self:GetViewComponent().RoulettePanel then
    self:GetViewComponent().RoulettePanel:SetDefaultSelectItemByIndex(1)
  end
end
function RolePersonalityPanelMeditor:UpdateRoulettePanel(data)
  if self:GetViewComponent().RoulettePanel then
    self:GetViewComponent().RoulettePanel:UpdatePanel(data)
  end
  self:SetAllEquipBtnVisible()
end
function RolePersonalityPanelMeditor:OnItemDrop(dropItem)
  if dropItem then
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local roleID = equiproomProxy:GetSelectRoleID()
    local bHasRole = RoleProxy:IsUnlockRole(roleID)
    if false == bHasRole then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_4")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    if self.goodsBasePanel and self.goodsBasePanel:GetCurrentDragItem() then
      local dragItem = self.goodsBasePanel:GetCurrentDragItem()
      if dragItem then
        self:SetEquipPersonality(dropItem:GetItemIndex(), dragItem:GetItemID())
      end
    end
  end
end
function RolePersonalityPanelMeditor:OnItemDropInRoulettePanel(dragItem, dropItem)
  if dragItem and dropItem then
    self:ReqSwapPersonality(dropItem:GetItemIndex(), dragItem:GetItemIndex())
  end
end
function RolePersonalityPanelMeditor:OnItemDragCancelled(dragItem)
  if dragItem then
    self:SetEquipPersonality(dragItem:GetItemIndex(), 0)
  end
end
function RolePersonalityPanelMeditor:OnRouletteItemClick(item)
  if nil == item then
    return
  end
  self:SetAllEquipBtnVisible()
end
function RolePersonalityPanelMeditor:OnBuyGoodsSuccessed(data)
  if self.currentPanelModel == EPanelModel.Emote then
    self:SendUpdateRoleEmoteListCmd()
    self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleEmote)
  else
    self:SendUpdateRoleActionListCmd()
    self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleAction)
  end
  if self.goodsBasePanel then
    self.goodsBasePanel:SetSelectedStateByItemID(self.lastSelectItemID)
    self:UpdateItemRedDot()
  end
  self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
end
function RolePersonalityPanelMeditor:SetKeyName()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.PC then
    self:GetViewComponent():UpdateKetTips()
  end
end
function RolePersonalityPanelMeditor:UpdateItemOperateState(data)
  RolePersonalityPanelMeditor.super.UpdateItemOperateState(self, data)
  self:SetAllEquipBtnVisible()
  local itemOperateStatePanel = self:GetViewComponent().ItemOperateStatePanel
  if nil == itemOperateStatePanel then
    return
  end
  local rouletteItem = self:GetViewComponent().RoulettePanel:GetCurrentItem()
  if rouletteItem then
    if self:GetViewComponent().ItemOperateStatePanel then
      self:GetViewComponent().ItemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    if nil == self.goodsBasePanel then
      return
    end
    local item = self.goodsBasePanel:GetSelectItem()
    if nil == item then
      return
    end
    if item:GetUnlock() then
      itemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      itemOperateStatePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function RolePersonalityPanelMeditor:ClearPanel()
  if self:GetViewComponent().ActionGridsPanel then
    self:GetViewComponent().ActionGridsPanel:ClearPanel()
  end
  if self:GetViewComponent().EmoteGridsPanel then
    self:GetViewComponent().EmoteGridsPanel:ClearPanel()
  end
  self.lastSelectItemID = nil
end
function RolePersonalityPanelMeditor:UpdateItemRedDot()
  if self.goodsBasePanel == nil then
    return
  end
  local redDotId = self.goodsBasePanel:GetSelectItemRedDotID()
  if EPanelModel.Emote == self.currentPanelModel then
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
      self.goodsBasePanel:SetSelectItemRedDotID(0)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote, -1)
    end
  elseif EPanelModel.Action == self.currentPanelModel and nil ~= redDotId and 0 ~= redDotId then
    GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):RemoveLocalRedDot(redDotId, UE4.EItemIdIntervalType.RoleAction)
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
    self.goodsBasePanel:SetSelectItemRedDotID(0)
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuicationAction, -1)
  end
end
function RolePersonalityPanelMeditor:AllCharacterEquip()
  local rouletteItem = self:GetViewComponent().RoulettePanel:GetCurrentItem()
  if rouletteItem then
    local roleID = EquiproomProxy:GetSelectRoleID()
    local bHasRole = RoleProxy:IsUnlockRole(roleID)
    if false == bHasRole then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_4")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    if itemProxy:GetItemIdIntervalType(self.lastSelectItemID) ~= UE4.EItemIdIntervalType.RoleEmote then
      LogError("RolePersonalityPanelMeditor:AllCharacterEquip", "current ItemType is not RoleEmote,itemID : " .. tostring(self.lastSelectItemID))
      return
    end
    RolePersonalityProxy:ReqSetsPersonality(0, rouletteItem:GetItemIndex(), self.lastSelectItemID)
  end
end
function RolePersonalityPanelMeditor:SetAllEquipBtnVisible()
  local bHasRole = RoleProxy:IsUnlockRole(EquiproomProxy:GetSelectRoleID())
  local bUnlock = false
  if self.goodsBasePanel then
    local paintItem = self.goodsBasePanel:GetSelectItem()
    if paintItem then
      bUnlock = paintItem:GetUnlock()
    end
  end
  local bSelectRoulette = false
  if self:GetViewComponent().RoulettePanel and self:GetViewComponent().RoulettePanel:GetCurrentItem() then
    bSelectRoulette = true
  end
  local visiable = bHasRole and bUnlock and EPanelModel.Emote == self.currentPanelModel and bSelectRoulette
  if self:GetViewComponent().Btn_AllCharacterEquip then
    self:GetViewComponent().Btn_AllCharacterEquip:SetVisibility(visiable and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return RolePersonalityPanelMeditor
