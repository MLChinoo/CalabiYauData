local TabBasePanelMobile = class("TabBasePanelMobile", PureMVC.ViewComponentPanel)
function TabBasePanelMobile:OnInitialized()
  TabBasePanelMobile.super.OnInitialized(self)
  self.onShowPanelEvent = LuaEvent.new()
  self.onHidePanelEvent = LuaEvent.new()
  self.onCloseAnimationFinishEvent = LuaEvent.new()
  self.onSelectRoleEvent = LuaEvent.new()
  self.MainPage = nil
end
function TabBasePanelMobile:InitPanel(mainPage)
  self.MainPage = mainPage
end
function TabBasePanelMobile:ShowPanel()
  self:ShowUWidget(self)
  self.onShowPanelEvent()
  self:OnShowPanel()
end
function TabBasePanelMobile:HidePanel()
  self.onHidePanelEvent()
  self:HideUWidget(self)
  self:OnHidePanel()
end
function TabBasePanelMobile:OnShowPanel()
end
function TabBasePanelMobile:OnHidePanel()
end
function TabBasePanelMobile:PlayColseAnimationWithCallBack()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayCloseAnimation({
      self,
      self.OnCloseAnimationFinishCallBack
    })
  end
end
function TabBasePanelMobile:OnCloseAnimationFinishCallBack()
  self.onCloseAnimationFinishEvent()
end
function TabBasePanelMobile:PlayColseAnimation()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayCloseAnimation()
  end
end
function TabBasePanelMobile:PlayOpenAnimation()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:PlayOpenAnimation()
  end
end
function TabBasePanelMobile:RemoveColseAnimationFinishedCallback()
  if self.ViewSwtichAnimation then
    self.ViewSwtichAnimation:RemoveCloseAnimationFinishedCallback()
  end
end
function TabBasePanelMobile:UpdateItemDesc(data)
  if self.ItemDescPanel then
    self.ItemDescPanel:UpdatePanel(data)
  end
end
function TabBasePanelMobile:UpdateItemOperateState(data)
  if self.ItemOperateStatePanel then
    self:ShowUWidget(self.ItemOperateStatePanel)
    self.ItemOperateStatePanel:UpdateOperateState(data)
  end
end
function TabBasePanelMobile:UpdatePanelBySelctRoleID(roleID)
  self.onSelectRoleEvent(roleID)
end
function TabBasePanelMobile:ClearPanel()
  self:ClearItemDescPanel()
  self:ClearItemOperateStatePanel()
  self:ClearGridsPanel()
  if self.itemListPanel then
    self.itemListPanel:ClearPanel()
  end
  self:ClearPanelExpend()
end
function TabBasePanelMobile:ClearPanelExpend()
end
function TabBasePanelMobile:ClearItemDescPanel()
  if self.ItemDescPanel then
    self.ItemDescPanel:ClearPanel()
  end
end
function TabBasePanelMobile:ClearItemOperateStatePanel()
  if self.ItemOperateStatePanel then
    self:HideUWidget(self.ItemOperateStatePanel)
  end
end
function TabBasePanelMobile:ClearGridsPanel()
  if self.GridsPanel then
    self.GridsPanel:ClearPanel()
  end
end
function TabBasePanelMobile:SetDefaultSelectItemByItemID(itemID)
  if self.itemListPanel then
    self.itemListPanel:SetDefaultSelectItemByItemID(itemID)
  end
end
function TabBasePanelMobile:SetDefaultSelectItemByIndex(index)
  if self.itemListPanel then
    self.itemListPanel:SetDefaultSelectItem(index)
  end
end
function TabBasePanelMobile:SetEquipBtnState(bEnable)
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel:SetEquipBtnState(bEnable)
  end
end
function TabBasePanelMobile:SetEquipBtnName(name)
  if self.ItemOperateStatePanel then
    self.ItemOperateStatePanel:SetEquipBtnName(name)
  end
end
function TabBasePanelMobile:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return TabBasePanelMobile
