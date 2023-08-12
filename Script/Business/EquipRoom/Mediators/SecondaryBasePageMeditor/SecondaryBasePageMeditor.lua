local SecondaryBasePageMeditor = class("SecondaryBasePageMeditor", PureMVC.Mediator)
function SecondaryBasePageMeditor:ListNotificationInterests()
  return {
    NotificationDefines.EquipRoomUpdateRoleList,
    NotificationDefines.EquipRoomUpdateShowRoleListPanel,
    NotificationDefines.HermesJumpToBuyCrystal
  }
end
function SecondaryBasePageMeditor:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleList then
    self:UpdateRoleList(notifyBody.ItemData)
    self:SetRoleGridPanelDefaultSelect()
  elseif notifyName == NotificationDefines.EquipRoomUpdateShowRoleListPanel then
    self:OpenRoleListPanel()
  elseif notifyName == NotificationDefines.HermesJumpToBuyCrystal then
    self:HermesJumpToBuyCrystal()
  end
end
function SecondaryBasePageMeditor:OnRegister()
  SecondaryBasePageMeditor.super.OnRegister(self)
  self.tabPanelMap = {}
  self:GetViewComponent().OnChangeTabEvent:Add(self.OnChangeTab, self)
  self:UpdateNavigationBar()
  self:AddTabPanel()
  self:InitTabPanel()
  self:GetViewComponent().OnReturnEvent:Add(self.OnEscHotKeyClick, self)
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  if self:GetViewComponent().SelectRoleGridPanel then
    self:GetViewComponent().SelectRoleGridPanel.clickItemEvent:Add(self.OnSelectRole, self)
  end
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStartPreview:Add(self.EnterPreviewMode, self)
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStopPreview:Add(self.QuitPreviewMode, self)
  end
  self:UpdateModuleTitle()
end
function SecondaryBasePageMeditor:OnRemove()
  SecondaryBasePageMeditor.super.OnRemove(self)
  self:GetViewComponent().OnChangeTabEvent:Remove(self.OnChangeTab, self)
  self:GetViewComponent().OnReturnEvent:Remove(self.OnEscHotKeyClick, self)
  if self:GetViewComponent().SelectRoleGridPanel then
    self:GetViewComponent().SelectRoleGridPanel.clickItemEvent:Remove(self.OnSelectRole, self)
  end
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStartPreview:Remove(self.EnterPreviewMode, self)
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStopPreview:Remove(self.QuitPreviewMode, self)
  end
end
function SecondaryBasePageMeditor:UpdateModuleTitle()
end
function SecondaryBasePageMeditor:SetModuleTitle(name)
  if self:GetViewComponent().Txt_ModuleTitle then
    self:GetViewComponent().Txt_ModuleTitle:SetText(name)
  end
end
function SecondaryBasePageMeditor:EnterPreviewMode()
end
function SecondaryBasePageMeditor:QuitPreviewMode()
end
function SecondaryBasePageMeditor:UpdateNavigationBar()
  self:GetViewComponent():UpdateBar()
end
function SecondaryBasePageMeditor:AddTabPanel()
  self:GetViewComponent():AddTabPanel(self.tabPanelMap)
end
function SecondaryBasePageMeditor:InitTabPanel()
  for key, value in pairs(self.tabPanelMap) do
    if value then
      value:HidePanel()
      value:InitPanel(self:GetViewComponent())
      value.onCloseAnimationFinishEvent:Add(self.OnTabPanelCloseAnimationFinish, self)
    end
  end
end
function SecondaryBasePageMeditor:OnChangeTab(tabType)
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  self.currentTabPanelType = tabType
  if self.currentTabPanel then
    self.currentTabPanel:RemoveColseAnimationFinishedCallback()
    self.currentTabPanel:PlayColseAnimationWithCallBack()
  else
    self:OnTabPanelCloseAnimationFinish()
  end
end
function SecondaryBasePageMeditor:OnTabPanelCloseAnimationFinish()
  if self.bExitPage then
    self:ColsePage()
  else
    if self.currentTabPanel then
      self.currentTabPanel:HidePanel()
      LogDebug("SecondaryBasePageMeditor:OnTabPanelCloseAnimationFinish", "Panel Play CloseAnimationFinish, Panel: %s", self.currentTabPanel.__cname)
    end
    local panel = self.tabPanelMap[self.currentTabPanelType]
    if panel then
      panel:ShowPanel()
      self.currentTabPanel = panel
      self:OnTabPanelCloseAnimationFinishExtend()
    else
      LogError("SecondaryBasePageMeditor:OnTabPanelCloseAnimationFinish", "Panel is nil, currentTabPanelType: %s", tostring(self.currentTabPanelType))
    end
  end
end
function SecondaryBasePageMeditor:OnTabPanelCloseAnimationFinishExtend()
end
function SecondaryBasePageMeditor:SelectTab(customType)
  LogDebug("SecondaryBasePageMeditor:SelectTab", "Current Page: %s ,Current TabType: %s", self.__cname, customType)
  self:GetViewComponent():SelectBarByCustomType(customType)
end
function SecondaryBasePageMeditor:GetCurrentTabType()
  return self.currentTabPanelType
end
function SecondaryBasePageMeditor:OnEscHotKeyClick()
  if self.bExitPage then
    return
  end
  if self.currentTabPanel then
    if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Preview then
      self:ColsePage()
    else
      self.bExitPage = true
      self.currentTabPanel:PlayColseAnimationWithCallBack()
    end
  end
end
function SecondaryBasePageMeditor:ColsePage()
  self:GetViewComponent():ReturnPage()
end
function SecondaryBasePageMeditor:UpdateCurrentTabPanelByRoleID(roleID)
  if self.currentTabPanel then
    self.currentTabPanel:UpdatePanelBySelctRoleID(roleID)
  end
end
function SecondaryBasePageMeditor:GetRoleList()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleListCmd)
end
function SecondaryBasePageMeditor:UpdateRoleList(data)
  if self:GetViewComponent().SelectRoleGridPanel then
    self:GetViewComponent().SelectRoleGridPanel:UpdatePanel(data)
  end
end
function SecondaryBasePageMeditor:OnSelectRole(roleId)
  self:GetViewComponent():OnSelectRole(roleId)
end
function SecondaryBasePageMeditor:SetRoleGridPanelDefaultSelect()
  local equipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  if self:GetViewComponent().SelectRoleGridPanel then
    self:GetViewComponent().SelectRoleGridPanel:SetSelectedStateByItemID(equipRoomProxy:GetSelectRoleID())
  end
end
function SecondaryBasePageMeditor:OpenRoleListPanel()
  self:GetViewComponent():OpenRoleListPanel()
end
function SecondaryBasePageMeditor:HideRoleListPanel()
  self:GetViewComponent():HideRoleListPanel()
end
function SecondaryBasePageMeditor:HermesJumpToBuyCrystal()
  self:GetViewComponent():HermesJumpToBuyCrystal()
end
return SecondaryBasePageMeditor
