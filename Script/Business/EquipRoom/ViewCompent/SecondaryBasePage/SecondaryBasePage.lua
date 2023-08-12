local SecondaryBasePage = class("SecondaryBasePage", PureMVC.ViewComponentPage)
function SecondaryBasePage:InitializeLuaEvent()
  self.OnReturnEvent = LuaEvent.new()
  self.OnChangeTabEvent = LuaEvent.new()
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar.onItemClickEvent:Add(self.OnChangeTab, self)
  end
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnReturn:Add(self.OnEscHotKeyClick, self)
    self.WBP_ItemDisplayKeys.actionOnStartScreenShot:Add(self.OnStartScreenShot, self)
    self.WBP_ItemDisplayKeys.actionOnStopScreenShot:Add(self.OnStopScreenShot, self)
  end
  self:HideRoleListPanel()
end
function SecondaryBasePage:OnChangeTab(tabType)
  self:HideRoleListPanel()
  self.currentTabType = tabType
  self.OnChangeTabEvent(tabType)
end
function SecondaryBasePage:OnClose()
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar.onItemClickEvent:Remove(self.OnChangeTab, self)
  end
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnReturn:Remove(self.OnEscHotKeyClick, self)
    self.WBP_ItemDisplayKeys.actionOnStartScreenShot:Remove(self.OnStartScreenShot)
    self.WBP_ItemDisplayKeys.actionOnStopScreenShot:Remove(self.OnStopScreenShot)
  end
end
function SecondaryBasePage:OnEscHotKeyClick()
  self.OnReturnEvent()
end
function SecondaryBasePage:SelectBarByCustomType(customType)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:SelectBarByCustomType(customType)
  end
end
function SecondaryBasePage:SetTabInfo(functionType, barDataMap)
  local basicFunctionProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  local configRow = basicFunctionProxy:GetFunctionById(functionType)
  if configRow then
    local barData = {}
    barData.barName = configRow.Name
    barData.customType = functionType
    table.insert(barDataMap, barData)
  end
end
function SecondaryBasePage:ReturnPage()
  ViewMgr:ClosePage(self)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
end
function SecondaryBasePage:LuaHandleKeyEvent(key, inputEvent)
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function SecondaryBasePage:UpdateCurrTabRoleListReDot()
  self:UpdateRoleListRedDot(self.currentTabType)
end
function SecondaryBasePage:UpdateRoleListRedDot(customType)
end
function SecondaryBasePage:IsCurrentRoleInfluenece(customType)
  local equipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local redProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
  local roleID = equipRoomProxy:GetSelectRoleID()
  local roleIDList = {}
  if customType == UE4.EPMFunctionTypes.EquipRoomRoleSkin then
    roleIDList = redProxy:GetRoleIDListBySkinRedDot()
  elseif customType == UE4.EPMFunctionTypes.EquipRoomRoleVoice then
    roleIDList = redProxy:GetRoleIDListByVoiceRedDot()
  elseif customType == UE4.EPMFunctionTypes.EquipRoomCommunication then
    roleIDList = redProxy:GetRoleIDListByCommunicationRedDot()
  elseif customType == UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin then
    roleIDList = redProxy:GetRoleIDListByPrimaryWeaponSkin()
  elseif customType == UE4.EPMFunctionTypes.EquipRoomPersonality then
    roleIDList = redProxy:GetRoleIDListByCommunicationActionRedDot()
  end
  for key, value in pairs(roleIDList) do
    if value == roleID then
      return true
    end
  end
  return false
end
function SecondaryBasePage:OpenRoleListPanel()
  if self.bShowRoleList == nil or self.bShowRoleList then
    self:HideRoleListPanel()
  else
    self:UpdateCurrTabRoleListReDot()
    self:ShowRoleListPanel()
  end
end
function SecondaryBasePage:ShowRoleListPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.bShowRoleList = true
  end
end
function SecondaryBasePage:HideRoleListPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bShowRoleList = false
  end
end
function SecondaryBasePage:OnSelectRole(roleID)
  self:HideRoleListPanel()
end
function SecondaryBasePage:ShowCanvasPanelTop(bShow)
  if self.CanvasPanel_Top then
    self.CanvasPanel_Top:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function SecondaryBasePage:ShowBottomKey(bShow)
  if self.WBP_ItemDisplayKeys.HorizontalBox_BottomKey then
    self.WBP_ItemDisplayKeys.HorizontalBox_BottomKey:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function SecondaryBasePage:ShowChat(bShow)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, bShow and NotificationDefines.ChatState.Show or NotificationDefines.ChatState.Hide)
end
function SecondaryBasePage:ShowScreenShot(bScreenShot)
  if self.WBP_ItemDisplayKeys then
    local isPreviewing = self.WBP_ItemDisplayKeys.isPreviewing
    if not isPreviewing then
      local tabPanel = self.tabPanelMap[self.currentTabType]
      if tabPanel then
        tabPanel:ShowScreenShot(bScreenShot)
      end
    end
    self:ShowChat(not bScreenShot)
    self:ShowCanvasPanelTop(not bScreenShot)
    self:ShowBottomKey(not bScreenShot)
  end
end
function SecondaryBasePage:OnStartScreenShot()
  self:ShowScreenShot(true)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.WarRoom)
end
function SecondaryBasePage:OnStopScreenShot()
  self:ShowScreenShot(false)
end
function SecondaryBasePage:HermesJumpToBuyCrystal()
  ViewMgr:ClosePage(self)
end
return SecondaryBasePage
