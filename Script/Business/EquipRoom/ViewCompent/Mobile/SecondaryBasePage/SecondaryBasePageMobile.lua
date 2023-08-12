local SecondaryBasePageMobile = class("SecondaryBasePageMobileMobile", PureMVC.ViewComponentPage)
function SecondaryBasePageMobile:InitializeLuaEvent()
  self.OnReturnEvent = LuaEvent.new()
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Add(self, self.ColsePage)
  end
  self.OnChangeTabEvent = LuaEvent.new()
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar.OnItemCheckEvent:Add(self.OnChangeTab, self)
  end
  if self.RoleListClickBG then
    self.RoleListClickBG.OnClickedEvent:Add(self, self.OnRoleListBGClick)
  end
  self:HideRoleListPanel()
end
function SecondaryBasePageMobile:OnChangeTab(tabType)
  self:HideRoleListPanel()
  self.OnChangeTabEvent(tabType)
  self:SetReturnBtnName(tabType)
end
function SecondaryBasePageMobile:OnClose()
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Remove(self, self.ColsePage)
  end
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar.OnItemCheckEvent:Remove(self.OnChangeTab, self)
  end
  if self.RoleListClickBG then
    self.RoleListClickBG.OnClickedEvent:Remove(self, self.OnRoleListBGClick)
  end
end
function SecondaryBasePageMobile:ColsePage()
  self.OnReturnEvent()
end
function SecondaryBasePageMobile:SelectBarByCustomType(customType)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:SelectBarByCustomType(customType)
  end
end
function SecondaryBasePageMobile:ReturnPage()
end
function SecondaryBasePageMobile:SetTabInfo(functionType, barDataMap)
  local basicFunctionProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  local configRow = basicFunctionProxy:GetFunctionMobileById(functionType)
  if configRow then
    local barData = {}
    barData.barName = configRow.Name
    barData.customType = functionType
    barData.barIcon = configRow.IconItem
    table.insert(barDataMap, barData)
  end
end
function SecondaryBasePageMobile:UpdateCurrTabRoleListReDot()
end
function SecondaryBasePageMobile:UpdateRoleListRedDot(customType)
end
function SecondaryBasePageMobile:SetReturnBtnName(tabType)
  if self.ReturnButton then
    local basicFunctionProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
    local configRow = basicFunctionProxy:GetFunctionMobileById(tabType)
    if configRow then
      self.ReturnButton:SetButtonName(configRow.Name)
    end
  end
end
function SecondaryBasePageMobile:OpenRoleListPanel()
  if self.bShowRoleList == nil or self.bShowRoleList then
    self:HideRoleListPanel()
  else
    self:UpdateCurrTabRoleListReDot()
    self:ShowRoleListPanel()
  end
end
function SecondaryBasePageMobile:ShowRoleListPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.bShowRoleList = true
  end
  if self.RoleListClickBG then
    self.RoleListClickBG:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function SecondaryBasePageMobile:HideRoleListPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bShowRoleList = false
  end
  if self.RoleListClickBG then
    self.RoleListClickBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SecondaryBasePageMobile:OnSelectRole(roleID)
end
function SecondaryBasePageMobile:OnRoleListBGClick()
  self:HideRoleListPanel()
end
function SecondaryBasePageMobile:HermesJumpToBuyCrystal()
end
return SecondaryBasePageMobile
