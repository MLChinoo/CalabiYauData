local TabBasePanel = class("TabBasePanel", PureMVC.ViewComponentPanel)
function TabBasePanel:OnInitialized()
  TabBasePanel.super.OnInitialized(self)
  self.onShowPanelEvent = LuaEvent.new()
  self.onHidePanelEvent = LuaEvent.new()
  self.onCloseAnimationFinishEvent = LuaEvent.new()
  self.onSelectRoleEvent = LuaEvent.new()
  self.onPrivilegeEquipEvent = LuaEvent.new()
  self.MainPage = nil
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel.onJumpSceenEvent:Add(self.OnJumpSceenButtonClick, self)
  end
  if self.Btn_PrivilegeEquip then
    self.Btn_PrivilegeEquip.OnClickEvent:Add(self, self.OnPrivilegeEquip)
  end
end
function TabBasePanel:Destruct()
  TabBasePanel.super.Destruct(self)
  if self.Btn_PrivilegeEquip then
    self.Btn_PrivilegeEquip.OnClickEvent:Remove(self, self.OnPrivilegeEquip)
  end
end
function TabBasePanel:InitPanel(mainPage)
  self.MainPage = mainPage
end
function TabBasePanel:ShowPanel()
  self:ShowUWidget(self)
  self.onShowPanelEvent()
  self:OnShowPanel()
end
function TabBasePanel:HidePanel()
  self.onHidePanelEvent()
  self:HideUWidget(self)
  self:OnHidePanel()
end
function TabBasePanel:OnShowPanel()
end
function TabBasePanel:OnHidePanel()
end
function TabBasePanel:PlayColseAnimationWithCallBack()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayCloseAnimation({
      self,
      self.OnCloseAnimationFinishCallBack
    })
  end
end
function TabBasePanel:OnCloseAnimationFinishCallBack()
  self.onCloseAnimationFinishEvent()
end
function TabBasePanel:PlayColseAnimation()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayCloseAnimation()
  end
end
function TabBasePanel:PlayOpenAnimation()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayOpenAnimation()
  end
end
function TabBasePanel:RemoveColseAnimationFinishedCallback()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:RemoveCloseAnimationFinishedCallback()
  end
end
function TabBasePanel:UpdateItemDesc(data)
  if self.ItemDescPanel then
    self.ItemDescPanel:UpdatePanel(data)
  end
end
function TabBasePanel:UpdateItemOperateState(data)
  if self.ItemOperateStatePanel then
    self:ShowUWidget(self.ItemOperateStatePanel)
    self.ItemOperateStatePanel:UpdateOperateState(data)
  end
end
function TabBasePanel:UpdatePanelBySelctRoleID(roleID)
  self.onSelectRoleEvent(roleID)
end
function TabBasePanel:ClearPanel()
  self:ClearItemDescPanel()
  self:ClearItemOperateStatePanel()
  self:ClearGridsPanel()
  if self.itemListPanel then
    self.itemListPanel:ClearPanel()
  end
  self:ClearPanelExpend()
end
function TabBasePanel:ClearPanelExpend()
end
function TabBasePanel:ClearItemDescPanel()
  if self.ItemDescPanel then
    self.ItemDescPanel:ClearPanel()
  end
end
function TabBasePanel:ClearItemOperateStatePanel()
  if self.ItemOperateStatePanel then
    self:HideUWidget(self.ItemOperateStatePanel)
  end
end
function TabBasePanel:ClearGridsPanel()
  if self.GridsPanel then
    self.GridsPanel:ClearPanel()
  end
end
function TabBasePanel:SetDefaultSelectItemByItemID(itemID)
  if self.itemListPanel then
    self.itemListPanel:SetDefaultSelectItemByItemID(itemID)
  end
end
function TabBasePanel:SetDefaultSelectItemByIndex(index)
  if self.itemListPanel then
    self.itemListPanel:SetDefaultSelectItem(index)
  end
end
function TabBasePanel:SetEquipBtnState(bEnable)
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel:SetEquipBtnState(bEnable)
  end
end
function TabBasePanel:SetEquipBtnName(name)
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel:SetEquipBtnName(name)
  end
end
function TabBasePanel:SetSwitchRoleBtnRedDotVisible(bShow)
  if self.Overlay_RedDot then
    self.Overlay_RedDot:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function TabBasePanel:OnJumpSceenButtonClick()
  if self.MainPage then
    ViewMgr:ClosePage(self.MainPage)
  end
end
function TabBasePanel:ShowScreenShot(bShow)
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel:SetVisibility(not bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.SkinUpgradePanel then
    local bCanUpgrade = self.SkinUpgradePanel:IsCanUpgrade()
    local visible = not bShow and bCanUpgrade
    self.SkinUpgradePanel:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function TabBasePanel:ShowScreenShotKey(bShow)
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    self.MainPage.WBP_ItemDisplayKeys:ShowScreenShot(bShow)
  end
end
function TabBasePanel:ResetItemDisplayPanel()
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    self.MainPage.WBP_ItemDisplayKeys:RestPanel()
  end
end
function TabBasePanel:OnPrivilegeEquip()
  self.onPrivilegeEquipEvent()
end
return TabBasePanel
