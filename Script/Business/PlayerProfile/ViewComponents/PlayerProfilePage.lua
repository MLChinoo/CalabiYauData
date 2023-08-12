local PlayerProfilePage = class("PlayerProfilePage", PureMVC.ViewComponentPage)
local PlayerProfileMediator = require("Business/PlayerProfile/Mediators/PlayerProfileMediator")
function PlayerProfilePage:ListNeededMediators()
  return {PlayerProfileMediator}
end
function PlayerProfilePage:InitializeLuaEvent()
  LogDebug("PlayerProfilePage", "Init lua event")
end
function PlayerProfilePage:OnOpen(luaOpenData, nativeOpenData)
  self.playerProfileText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "PlayerProfile")
  self.editBCText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "EditBusinessCard")
  if self.SecondaryNavigationBar then
    local barDataMap = {}
    local playerProfile = {
      barName = self.playerProfileText,
      customType = 1
    }
    table.insert(barDataMap, playerProfile)
    local editBusinessCard = {
      barName = self.editBCText,
      customType = 2
    }
    table.insert(barDataMap, editBusinessCard)
    self.SecondaryNavigationBar:UpdateBar(barDataMap)
    self.SecondaryNavigationBar.onItemClickEvent:Add(self.ChooseSecondBar, self)
    self.SecondaryNavigationBar:SelectBarByCustomType(1)
  end
  if self.BCToolPanel then
    self.BCToolPanel.actionOnJumpPage:Add(self.ClosePage, self)
  end
  if self.WBP_HotKey_Esc then
    self.WBP_HotKey_Esc.OnClickEvent:Add(self, self.ClosePage)
  end
  if self.Button_Credit then
    self.Button_Credit.OnClicked:Add(self, self.OnClickCredit)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Add(self, self.OnClickedShare)
  end
  if self.Btn_ShowPlayerCardLevelMap then
    self.Btn_ShowPlayerCardLevelMap.OnClicked:Add(self, self.OnClickShowPlayerCardLevelMap)
  end
  self.ScreenPrintSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self, "OnScreenPrintSuccess")
  RedDotTree:Bind(RedDotModuleDef.ModuleName.BusinessCard, function(cnt)
    self:UpdateRedDotBusinessCard(cnt)
  end)
  self:UpdateRedDotBusinessCard(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.BusinessCard))
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):PauseStateMachine()
end
function PlayerProfilePage:OnClose()
  if self.BCToolPanel then
    self.BCToolPanel.actionOnJumpPage:Remove(self.ClosePage, self)
  end
  if self.WBP_HotKey_Esc then
    self.WBP_HotKey_Esc.OnClickEvent:Remove(self, self.ClosePage)
  end
  if self.Button_Credit then
    self.Button_Credit.OnClicked:Remove(self, self.OnClickCredit)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Remove(self, self.OnClickedShare)
  end
  if self.ScreenPrintSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self.ScreenPrintSuccessHandler)
    self.ScreenPrintSuccessHandler = nil
  end
  if self.Btn_ShowPlayerCardLevelMap then
    self.Btn_ShowPlayerCardLevelMap.OnClicked:Remove(self, self.OnClickShowPlayerCardLevelMap)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BusinessCard)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ReStartStateMachine()
end
function PlayerProfilePage:UpdateView(cardInfo, collectionInfo)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfo)
  end
  if self.CollectableDataPanel then
    self.CollectableDataPanel:UpdateView(collectionInfo)
  end
end
function PlayerProfilePage:ChooseSecondBar(customType)
  if 1 == customType then
    self:ShowData(true)
  elseif 2 == customType then
    self:ShowBC(true)
  end
end
function PlayerProfilePage:ShowData(isChecked)
  if isChecked then
    if self.WidgetSwitcher_PrimaryPanel then
      self.WidgetSwitcher_PrimaryPanel:SetActiveWidgetIndex(0)
    end
    if self.Information_Open then
      self:PlayAnimationForward(self.Information_Open)
    end
    if self.TextBlock_PageName then
      self.TextBlock_PageName:SetText(self.playerProfileText)
    end
    if self.HotKeyShare then
      self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd)
  end
end
function PlayerProfilePage:ShowBC(isChecked)
  if isChecked then
    if self.WidgetSwitcher_PrimaryPanel then
      self.WidgetSwitcher_PrimaryPanel:SetActiveWidgetIndex(1)
    end
    if self.TextBlock_PageName then
      self.TextBlock_PageName:SetText(self.editBCText)
    end
    if self.BCToolPanel then
      self.BCToolPanel:InitBCPage()
    end
    if self.HotKeyShare then
      self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function PlayerProfilePage:OnClickCredit()
  local bUseBrowser = false
  if self.CheckBox_UseBrowser then
    bUseBrowser = self.CheckBox_UseBrowser:IsChecked()
  end
  GameFacade:RetrieveProxy(ProxyNames.CreditProxy):OpenCreditPage(bUseBrowser)
end
function PlayerProfilePage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.WBP_HotKey_Esc and not ret then
    ret = self.WBP_HotKey_Esc:MonitorKeyDown(key, inputEvent)
  end
  if self.HotKeyShare and self.HotKeyShare:IsVisible() and not ret then
    ret = self.HotKeyShare:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function PlayerProfilePage:ClosePage()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  ViewMgr:ClosePage(self)
end
function PlayerProfilePage:UpdateRedDotBusinessCard(cnt)
  if self.SecondaryNavigationBar then
    local barItem = self.SecondaryNavigationBar:GetBarByCustomType(2)
    if barItem then
      barItem:SetRedDotVisible(cnt > 0)
    end
  end
end
function PlayerProfilePage:OnClickedShare()
  if self.CanvasActionBar then
    self.CanvasActionBar:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Credit then
    self.Button_Credit:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.PersonalData)
end
function PlayerProfilePage:OnScreenPrintSuccess()
  if self.CanvasActionBar then
    self.CanvasActionBar:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Button_Credit then
    self.Button_Credit:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
end
function PlayerProfilePage:OnClickShowPlayerCardLevelMap()
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PlayerCardLevelMapPage, false)
end
return PlayerProfilePage
