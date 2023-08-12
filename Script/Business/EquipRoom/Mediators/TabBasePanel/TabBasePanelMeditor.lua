local TabBasePanelMeditor = class("TabBasePanelMeditor", PureMVC.Mediator)
function TabBasePanelMeditor:ListNotificationInterests()
  return {
    NotificationDefines.EquipRoomUpdateItemDesc,
    NotificationDefines.UpdateItemOperateState,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function TabBasePanelMeditor:HandleNotification(notify)
  TabBasePanelMeditor.super.HandleNotification(self, notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if self.bShow == false then
    return
  end
  if notifyName == NotificationDefines.EquipRoomUpdateItemDesc then
    self:UpdateItemDesc(notifyBody)
  elseif notifyName == NotificationDefines.UpdateItemOperateState then
    self:UpdateItemOperateState(notifyBody)
  elseif notifyName == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed and notifyBody.IsSuccessed and notifyBody.PageName == UIPageNameDefine.EquipRoomMainPage then
    self:OnBuyGoodsSuccessed(notifyBody)
  end
end
function TabBasePanelMeditor:OnRegister()
  TabBasePanelMeditor.super.OnRegister(self)
  self:GetViewComponent().onShowPanelEvent:Add(self.OnShowPanel, self)
  self:GetViewComponent().onHidePanelEvent:Add(self.OnHidePanel, self)
  if self:GetViewComponent().ItemListPanel then
    self:GetViewComponent().ItemListPanel.clickItemEvent:Add(self.OnItemClick, self)
    self:GetViewComponent().ItemListPanel.onitemDoubleClickEvent:Add(self.OnitemDoubleClick, self)
  end
  self:GetViewComponent().ItemOperateStatePanel.clickEquipEvent:Add(self.OnEquipClick, self)
  self:GetViewComponent().ItemOperateStatePanel.clickUnlockEvent:Add(self.OnUnlockClick, self)
  self.bShow = false
  if self:GetViewComponent().Btn_OpenRoleListPanel then
    self.OnOpenRoleListHandle = DelegateMgr:AddDelegate(self:GetViewComponent().Btn_OpenRoleListPanel.OnClicked, self, "OnOpenRoleListPanel")
  end
  if self:GetViewComponent().onSelectRoleEvent then
    self:GetViewComponent().onSelectRoleEvent:Add(self.UpdatePanelBySelctRoleID, self)
  end
  if self:GetViewComponent().ItemOperateStatePanel then
    self:GetViewComponent().ItemOperateStatePanel:SetPageName(UIPageNameDefine.EquipRoomMainPage)
  end
  if self:GetViewComponent().onPrivilegeEquipEvent then
    self:GetViewComponent().onPrivilegeEquipEvent:Add(self.OnPrivilegeEquip, self)
  end
end
function TabBasePanelMeditor:OnRemove()
  TabBasePanelMeditor.super.OnRemove(self)
  self:GetViewComponent().onShowPanelEvent:Remove(self.OnShowPanel, self)
  self:GetViewComponent().onHidePanelEvent:Remove(self.OnHidePanel, self)
  if self:GetViewComponent().ItemListPanel then
    self:GetViewComponent().ItemListPanel.clickItemEvent:Remove(self.OnItemClick, self)
    self:GetViewComponent().ItemListPanel.onitemDoubleClickEvent:Remove(self.OnitemDoubleClick, self)
  end
  self:GetViewComponent().ItemOperateStatePanel.clickEquipEvent:Remove(self.OnEquipClick, self)
  self:GetViewComponent().ItemOperateStatePanel.clickUnlockEvent:Remove(self.OnUnlockClick, self)
  if self:GetViewComponent().Btn_OpenRoleListPanel then
    DelegateMgr:RemoveDelegate(self:GetViewComponent().Btn_OpenRoleListPanel.OnClicked, self.OnOpenRoleListHandle)
  end
  if self:GetViewComponent().onSelectRoleEvent then
    self:GetViewComponent().onSelectRoleEvent:Remove(self.UpdatePanelBySelctRoleID, self)
  end
  if self:GetViewComponent().onPrivilegeEquipEvent then
    self:GetViewComponent().onPrivilegeEquipEvent:Remove(self.OnPrivilegeEquip, self)
  end
end
function TabBasePanelMeditor:OnShowPanel()
  self.bShow = true
  self:GetViewComponent():PlayOpenAnimation()
end
function TabBasePanelMeditor:OnHidePanel()
  self.bShow = false
end
function TabBasePanelMeditor:OnItemClick(itemID)
end
function TabBasePanelMeditor:OnitemDoubleClick(item)
  if nil == item then
    LogWarn("TabBasePanelMeditor:OnitemDoubleClick", "item is nil")
    return false
  end
  if item:GetUnlock() == false then
    LogWarn("TabBasePanelMeditor:OnitemDoubleClick", "item is not Unlock")
    return false
  end
  if item:GetEquipState() then
    LogWarn("TabBasePanelMeditor:OnitemDoubleClick", "item is already Equiped")
    return false
  end
  if false == item:GetSelectState() then
    LogWarn("TabBasePanelMeditor:OnitemDoubleClick", "item is NOT select")
    return false
  end
  self:OnEquipClick()
  return true
end
function TabBasePanelMeditor:UpdateItemDesc(data)
  self:GetViewComponent():UpdateItemDesc(data)
end
function TabBasePanelMeditor:UpdateItemOperateState(data)
  self:GetViewComponent():UpdateItemOperateState(data)
end
function TabBasePanelMeditor:OnEquipClick(data)
end
function TabBasePanelMeditor:OnUnlockClick()
end
function TabBasePanelMeditor:ClearPanel()
  self:GetViewComponent():ClearPanel()
  self.lastSelectItemID = nil
end
function TabBasePanelMeditor:SendUpdateItemDescCmd(itemID, itemIdIntervalType)
  local body = {}
  body.itemType = itemIdIntervalType
  body.itemID = itemID
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateItemDescCmd, body)
end
function TabBasePanelMeditor:OnBuyGoodsSuccessed(data)
end
function TabBasePanelMeditor:UpdatePanelBySelctRoleID(roleID)
end
function TabBasePanelMeditor:OnOpenRoleListPanel()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateShowRoleListPanel)
end
function TabBasePanelMeditor:SetCharacterEnableLeisure(bEnable)
  if self:GetViewComponent().MainPage and self:GetViewComponent().MainPage.WBP_ItemDisplayKeys then
    self:GetViewComponent().MainPage.WBP_ItemDisplayKeys:SetCharacterEnableLeisure(bEnable)
  end
end
function TabBasePanelMeditor:HideRoleListPanel()
  if self:GetViewComponent().MainPage then
    self:GetViewComponent().MainPage:HideRoleListPanel()
  end
end
function TabBasePanelMeditor:SetPrivilegeEquipBtnVisible(bShow)
  if self:GetViewComponent().Btn_PrivilegeEquip then
    if bShow then
      self:UpdatePrivilegeBtnName()
    end
    self:GetViewComponent().Btn_PrivilegeEquip:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function TabBasePanelMeditor:OnPrivilegeEquip()
end
function TabBasePanelMeditor:SetWeaponFx(weaponFxID, weaponID)
  if self:GetViewComponent().MainPage and self:GetViewComponent().MainPage.WBP_ItemDisplayKeys then
    local dataProp = {}
    dataProp.itemId = weaponFxID
    dataProp.weaponID = weaponID
    self:GetViewComponent().MainPage.WBP_ItemDisplayKeys:SetItemDisplayed(dataProp)
  end
end
function TabBasePanelMeditor:UpdatePrivilegeBtnName()
  if self:GetViewComponent().Btn_PrivilegeEquip then
    local name = GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):GetPrivilegeEquipBtnName()
    self:GetViewComponent().Btn_PrivilegeEquip:SetPanelName(name)
  end
end
return TabBasePanelMeditor
