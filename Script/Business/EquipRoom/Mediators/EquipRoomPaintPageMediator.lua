local EquipRoomPaintPageMediator = class("EquipRoomPaintPageMediator", PureMVC.Mediator)
function EquipRoomPaintPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.EquipRoomUpdatePaintData,
    NotificationDefines.EquipRoomShowPaint,
    NotificationDefines.EquipRoomUpdatePaintEquipSlot,
    NotificationDefines.UpdateItemOperateState,
    NotificationDefines.OnResEquipDecal,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function EquipRoomPaintPageMediator:OnRegister()
  self.super:OnRegister()
  if self:GetViewComponent().GridsPanel then
    self:GetViewComponent().GridsPanel.clickItemEvent:Add(self.OnClickItem, self)
    self:GetViewComponent().GridsPanel.onitemDoubleClickEvent:Add(self.OnitemDoubleClick, self)
  end
  self:GetViewComponent().ItemOperateStatePanel.clickEquipEvent:Add(self.EquipPaint, self)
  self:GetViewComponent().DecalDropSlotPanel.clickItemEvent:Add(self.GetItemOperateState, self)
  self:GetViewComponent().DecalDropSlotPanel.dropItemEvent:Add(self.SendEquipPaintCmd, self)
  self:GetViewComponent().onCloseAnimationFinishEvent:Add(self.ColsePage, self)
  if self:GetViewComponent().ItemOperateStatePanel then
    self:GetViewComponent().ItemOperateStatePanel:SetPageName(UIPageNameDefine.EquipRoomMainPage)
  end
end
function EquipRoomPaintPageMediator:OnRemove()
  if self:GetViewComponent().GridsPanel then
    self:GetViewComponent().GridsPanel.clickItemEvent:Remove(self.OnClickItem, self)
    self:GetViewComponent().GridsPanel.onitemDoubleClickEvent:Remove(self.OnitemDoubleClick, self)
  end
  self:GetViewComponent().ItemOperateStatePanel.clickEquipEvent:Remove(self.EquipPaint, self)
  self:GetViewComponent().DecalDropSlotPanel.clickItemEvent:Remove(self.GetItemOperateState, self)
  self:GetViewComponent().DecalDropSlotPanel.dropItemEvent:Remove(self.SendEquipPaintCmd, self)
  self:GetViewComponent().onCloseAnimationFinishEvent:Remove(self.ColsePage, self)
end
function EquipRoomPaintPageMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdatePaintData then
    self:GetViewComponent():UpdateGridPanel(notifyBody.paintItemData)
    self:GetViewComponent():SetDefaultSelectItem(notifyBody.defaultSelectIndex)
  elseif notifyName == NotificationDefines.EquipRoomShowPaint then
    self:GetViewComponent():ShowPaint(notifyBody)
    self:UpdateDecalDropSlotUnlcokState(notifyBody.itemID)
    self:GetItemOperateState()
  elseif notifyName == NotificationDefines.EquipRoomUpdatePaintEquipSlot then
    self:GetViewComponent().DecalDropSlotPanel:UpdateDecalSoltItem(notifyBody)
  elseif notifyName == NotificationDefines.UpdateItemOperateState then
    self:GetViewComponent().ItemOperateStatePanel:UpdateOperateState(notifyBody)
  elseif notifyName == NotificationDefines.OnResEquipDecal then
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintDataCmd)
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlotCmd)
    self:GetItemOperateState()
  elseif notifyName == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed and notifyBody.IsSuccessed and notifyBody.PageName == UIPageNameDefine.EquipRoomMainPage then
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintDataCmd)
    self:GetItemOperateState()
    self:UpdateItemRedDot()
  end
end
function EquipRoomPaintPageMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlotCmd)
  local defaultSelectIndex = 1
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintDataCmd, defaultSelectIndex)
end
function EquipRoomPaintPageMediator:ColsePage()
  self:GetViewComponent():ReturnPage()
end
function EquipRoomPaintPageMediator:UpdateDecalDropSlotUnlcokState(itemID)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(itemID)
  if nil == decalRowData then
    LogError("EquipRoomPaintPageMediator", "decalRowData is nil,id is %s", itemID)
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
function EquipRoomPaintPageMediator:OnClickItem(itemID)
  self:UpdateItemRedDot()
  if self.currentSelectItemID == itemID then
    return
  end
  self.currentSelectItemID = itemID
  GameFacade:SendNotification(NotificationDefines.EquipRoomShowPaintCmd, itemID)
end
function EquipRoomPaintPageMediator:OnitemDoubleClick(item)
  if nil == item then
    LogWarn("EquipRoomPaintPageMediator:OnitemDoubleClick", "item is nil")
    return
  end
  if item:GetUnlock() == false then
    LogWarn("EquipRoomPaintPageMediator:OnitemDoubleClick", "item is not Unlock")
    return
  end
  if false == item:GetSelectState() then
    LogWarn("EquipRoomPaintPageMediator:OnitemDoubleClick", "item is NOT select")
    return false
  end
  self:EquipPaint()
end
function EquipRoomPaintPageMediator:UpdateItemRedDot()
  if self:GetViewComponent().GridsPanel then
    local redDotId = self:GetViewComponent().GridsPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
      self:GetViewComponent().GridsPanel:SetSelectItemRedDotID(0)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.Decal, -1)
    end
  end
end
function EquipRoomPaintPageMediator:EquipPaint()
  local paintItem = self:GetViewComponent().GridsPanel:GetSelectItem()
  local soltItem = self:GetViewComponent().DecalDropSlotPanel:GetCurrentClickItem()
  if paintItem:GetItemID() == soltItem:GetItemID() then
    return
  end
  local equipPaintData = {}
  equipPaintData.useState = soltItem:GetDecalUseState()
  equipPaintData.decalID = paintItem:GetItemID()
  self:SendEquipPaintCmd(equipPaintData)
end
function EquipRoomPaintPageMediator:SendEquipPaintCmd(equipPaintData)
  if nil == equipPaintData and nil == equipPaintData.useState and nil == equipPaintData.decalID then
    LogError("SendEquipPaintCmd", "equipPaintData is nil")
    return
  end
  GameFacade:SendNotification(NotificationDefines.ReqEquipDecalCmd, equipPaintData)
end
function EquipRoomPaintPageMediator:GetItemOperateState()
  local decalItem = self:GetViewComponent().GridsPanel:GetSelectItem()
  local soltItem = self:GetViewComponent().DecalDropSlotPanel:GetCurrentClickItem()
  local notifyBody = {}
  notifyBody.itemType = UE4.EItemIdIntervalType.Decal
  notifyBody.itemID = decalItem:GetItemID()
  notifyBody.soltItemID = soltItem:GetItemID()
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, notifyBody)
end
return EquipRoomPaintPageMediator
