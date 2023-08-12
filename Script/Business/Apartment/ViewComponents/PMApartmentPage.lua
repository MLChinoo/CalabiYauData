local PMApartmentPage = class("PMApartmentPage", PureMVC.ViewComponentPage)
local apartmentMediator = require("Business/Apartment/Mediators/PMApartmentMediator")
local Valid
function PMApartmentPage:ListNeededMediators()
  return {apartmentMediator}
end
function PMApartmentPage:InitializeLuaEvent()
  self.actionOnClickGiftBtn = LuaEvent.new()
  self.actionOnClickPreviewBtn = LuaEvent.new()
  self.actionOnSwitchCamera = LuaEvent.new()
  self.actionOnClickOthersApartment = LuaEvent.new()
  self.actionOnClosePage = LuaEvent.new()
  local gameMode = UE4.UGameplayStatics.GetGameMode(self:GetWorld())
  if gameMode then
    gameMode.LobbyCameraHandle:Add(self, self.OnSwitchCamera)
  end
  self.isEnterSincerityInteractionState = false
end
function PMApartmentPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Gift_Btn then
    self.Gift_Btn.OnClicked:Add(self, self.OnClickGiftBtn)
    self.Gift_Btn.OnHovered:Add(self, self.OnHoveredGiftBtn)
    self.Gift_Btn.OnUnhovered:Add(self, self.OnUnhoveredGiftBtn)
    self.Gift_Btn.OnPressed:Add(self, self.OnPressedGiftBtn)
    self.Gift_Btn.OnReleased:Add(self, self.OnReleasedGiftBtn)
  end
  if self.BtnOthersApartment then
    self.BtnOthersApartment.OnClicked:Add(self, self.OnClickOthersApartmentBtn)
  end
  Valid = self.Normal and self:PlayAnimationForward(self.Normal, 1, false)
  Valid = self.Preview_Btn and self.Preview_Btn.OnClickEvent:Add(self, self.OnClickPreviewBtn)
  local CurrentRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  local RoleProperties = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(CurrentRoleId)
  Valid = RoleProperties and self.TextBlock_RoleLevel and self.TextBlock_RoleLevel:SetText(RoleProperties.intimacy_lv)
  Valid = self.Button_Esc and self.Button_Esc.OnClickEvent:Add(self, self.OnClickPreviewBtn)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Promise, function(cnt)
    self:UpdatePromiseRedDot(cnt)
  end)
  self:UpdatePromiseRedDot(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Promise))
  self.isPreview = false
end
function PMApartmentPage:UpdatePromiseRedDot(cnt)
  self.PromiseRedDotPanel:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function PMApartmentPage:UpdateLevelText()
  local CurrentRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  local RoleProperties = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(CurrentRoleId)
  Valid = RoleProperties and self.TextBlock_RoleLevel and self.TextBlock_RoleLevel:SetText(RoleProperties.intimacy_lv)
end
function PMApartmentPage:OnClickGiftBtn()
  self.actionOnClickGiftBtn()
end
function PMApartmentPage:OnHoveredGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(1)
  Valid = self.Mouseover and self:PlayAnimationForward(self.Mouseover, 1, false)
end
function PMApartmentPage:OnUnhoveredGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(0)
  Valid = self.Mouseover and self:PlayAnimation(self.Mouseover, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function PMApartmentPage:OnPressedGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(2)
end
function PMApartmentPage:OnReleasedGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(0)
end
function PMApartmentPage:OnClickPreviewBtn()
  if self.isEnterSincerityInteractionState == true then
    return
  end
  if true == self.isPreview then
    self.isPreview = false
    self:ExitPriview()
  else
    self.isPreview = true
    self:EnterPriview()
  end
  self.actionOnClickPreviewBtn()
end
function PMApartmentPage:OnSwitchCamera()
  self.actionOnSwitchCamera()
end
function PMApartmentPage:OnClickOthersApartmentBtn()
  self.actionOnClickOthersApartment()
end
function PMApartmentPage:OnClose()
  if self.Gift_Btn then
    self.Gift_Btn.OnClicked:Remove(self, self.OnClickGiftBtn)
  end
  if self.Preview_Btn then
    self.Preview_Btn.OnClickEvent:Remove(self, self.OnClickPreviewBtn)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnClickPreviewBtn)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Promise)
end
function PMApartmentPage:LuaHandleKeyEvent(key, inputEvent)
  if GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):GetCurrentPageType() ~= GlobalEnumDefine.EApartmentPageType.Main then
    return false
  end
  if self.isEnterSincerityInteractionState == true then
    return false
  end
  if self.WidgetSwitcher_Preview then
    if 0 == self.WidgetSwitcher_Preview:GetActiveWidgetIndex() then
      if self.Preview_Btn then
        return self.Preview_Btn:MonitorKeyDown(key, inputEvent)
      end
    elseif self.Button_Esc then
      return self.Button_Esc:MonitorKeyDown(key, inputEvent)
    end
  end
  return false
end
function PMApartmentPage:SetMainPageAllButtonVisible(visible)
  if self.CanvasPanel_Business then
    self.CanvasPanel_Business:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function PMApartmentPage:SetGiftBtnVisibility(bEnable)
  if self.Gift_Panel then
    if bEnable then
      self.Gift_Panel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Gift_Panel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function PMApartmentPage:EnterSincerityInteractionState()
  self.isEnterSincerityInteractionState = true
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function PMApartmentPage:ExitSincerityInteractionState()
  self.isEnterSincerityInteractionState = false
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
end
function PMApartmentPage:SetTopBarVisible(visible)
  if true == visible then
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty, true)
  else
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty, false)
  end
end
function PMApartmentPage:SetChatVisible(visible)
  if true == visible then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  else
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
end
function PMApartmentPage:SetModuleEntranceVisible(visible)
  if self.CanvasPanel_ModuleEntrance then
    self.CanvasPanel_ModuleEntrance:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function PMApartmentPage:EnterPriview()
  self:SetModuleEntranceVisible(false)
  self:SetTopBarVisible(false)
  self:SetChatVisible(false)
  if self.WidgetSwitcher_Preview then
    self.WidgetSwitcher_Preview:SetActiveWidgetIndex(1)
  end
end
function PMApartmentPage:ExitPriview()
  self:SetModuleEntranceVisible(true)
  self:SetTopBarVisible(true)
  self:SetChatVisible(true)
  if self.WidgetSwitcher_Preview then
    self.WidgetSwitcher_Preview:SetActiveWidgetIndex(0)
  end
end
function PMApartmentPage:HideMainPage()
  self:SetTopBarVisible(false)
  self:SetMainPageAllButtonVisible(false)
end
function PMApartmentPage:ShowMainPage()
  self:SetTopBarVisible(true)
  self:SetMainPageAllButtonVisible(true)
end
function PMApartmentPage:CloseLoading()
  LogDebug("CloseLoading", "CloseLoadingPage")
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):OnCloseLoadingPage()
  local LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(LuaGetWorld())
  LoginSubsystem:LoadingAfterLoginDone()
  LoginSubsystem:CheckJuvenilesLoginMsg()
end
return PMApartmentPage
