local ApartmentPageMobile = class("ApartmentPageMobile", PureMVC.ViewComponentPage)
local apartmentMediator = require("Business/Apartment/Mediators/PMApartmentMediator")
local Valid
function ApartmentPageMobile:ListNeededMediators()
  return {apartmentMediator}
end
function ApartmentPageMobile:InitializeLuaEvent()
  self.actionOnClickGiftBtn = LuaEvent.new()
  self.actionOnClickPreviewBtn = LuaEvent.new()
  self.actionOnSwitchCamera = LuaEvent.new()
  self.actionOnClosePage = LuaEvent.new()
  local gameMode = UE4.UGameplayStatics.GetGameMode(self:GetWorld())
  if gameMode then
    gameMode.LobbyCameraHandle:Add(self, self.OnSwitchCamera)
  end
  self.isEnterSincerityInteractionState = false
end
function ApartmentPageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.Gift_Btn then
    self.Gift_Btn.OnClicked:Add(self, self.OnClickGiftBtn)
    self.Gift_Btn.OnHovered:Add(self, self.OnHoveredGiftBtn)
    self.Gift_Btn.OnUnhovered:Add(self, self.OnUnhoveredGiftBtn)
    self.Gift_Btn.OnPressed:Add(self, self.OnPressedGiftBtn)
    self.Gift_Btn.OnReleased:Add(self, self.OnReleasedGiftBtn)
  end
  Valid = self.Normal and self:PlayAnimationForward(self.Normal, 1, false)
  Valid = self.Preview_Btn and self.Preview_Btn.OnClicked:Add(self, self.OnClickPreviewBtn)
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
function ApartmentPageMobile:UpdatePromiseRedDot(cnt)
  self.PromiseRedDotPanel:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentPageMobile:UpdateLevelText()
  local CurrentRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  local RoleProperties = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(CurrentRoleId)
  Valid = RoleProperties and self.TextBlock_RoleLevel and self.TextBlock_RoleLevel:SetText(RoleProperties.intimacy_lv)
end
function ApartmentPageMobile:OnClickGiftBtn()
  self.actionOnClickGiftBtn()
end
function ApartmentPageMobile:OnHoveredGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(1)
  Valid = self.Mouseover and self:PlayAnimationForward(self.Mouseover, 1, false)
end
function ApartmentPageMobile:OnUnhoveredGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(0)
  Valid = self.Mouseover and self:PlayAnimation(self.Mouseover, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function ApartmentPageMobile:OnPressedGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(2)
end
function ApartmentPageMobile:OnReleasedGiftBtn()
  self.WidgetSwitcher_Gift_Btn:SetActiveWidgetIndex(0)
end
function ApartmentPageMobile:OnClickPreviewBtn()
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
function ApartmentPageMobile:OnSwitchCamera()
  self.actionOnSwitchCamera()
end
function ApartmentPageMobile:OnClose()
  if self.Gift_Btn then
    self.Gift_Btn.OnClicked:Remove(self, self.OnClickGiftBtn)
  end
  if self.Preview_Btn then
    self.Preview_Btn.OnClicked:Remove(self, self.OnClickPreviewBtn)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnClickPreviewBtn)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Promise)
end
function ApartmentPageMobile:LuaHandleKeyEvent(key, inputEvent)
  if GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):GetCurrentPageType() ~= GlobalEnumDefine.EApartmentPageType.Main then
    return false
  end
  if self.isEnterSincerityInteractionState == true then
    return false
  end
  return false
end
function ApartmentPageMobile:SetMainPageAllButtonVisible(visible)
  if self.CanvasPanel_Business then
    self.CanvasPanel_Business:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ApartmentPageMobile:SetGiftBtnVisibility(bEnable)
  if self.Gift_Panel then
    if bEnable then
      self.Gift_Panel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Gift_Panel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function ApartmentPageMobile:EnterSincerityInteractionState()
  self.isEnterSincerityInteractionState = true
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, false)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function ApartmentPageMobile:ExitSincerityInteractionState()
  self.isEnterSincerityInteractionState = false
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, true)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
end
function ApartmentPageMobile:SetTopBarVisible(visible)
  if true == visible then
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, true)
  else
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, false)
  end
end
function ApartmentPageMobile:SetChatVisible(visible)
  if true == visible then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  else
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
end
function ApartmentPageMobile:SetModuleEntranceVisible(visible)
  if self.CanvasPanel_ModuleEntrance then
    self.CanvasPanel_ModuleEntrance:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ApartmentPageMobile:EnterPriview()
  self:SetModuleEntranceVisible(false)
  self:SetTopBarVisible(false)
  self:SetChatVisible(false)
  if self.WidgetSwitcher_Preview then
    self.WidgetSwitcher_Preview:SetActiveWidgetIndex(1)
  end
end
function ApartmentPageMobile:ExitPriview()
  self:SetModuleEntranceVisible(true)
  self:SetTopBarVisible(true)
  self:SetChatVisible(true)
  if self.WidgetSwitcher_Preview then
    self.WidgetSwitcher_Preview:SetActiveWidgetIndex(0)
  end
end
function ApartmentPageMobile:HideMainPage()
  self:SetTopBarVisible(false)
  self:SetMainPageAllButtonVisible(false)
end
function ApartmentPageMobile:ShowMainPage()
  self:SetTopBarVisible(true)
  self:SetMainPageAllButtonVisible(true)
end
function ApartmentPageMobile:CloseLoading()
  LogDebug("CloseLoading", "CloseLoadingPage")
  local delayFrame = UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):GetDelayFrame()
  LogDebug("CloseLoading", "CloseLoadingPage delayFrame is %s", tostring(delayFrame))
  self.waitCallBackTimer = TimerMgr:AddFrameTask(delayFrame, 0, 1, function()
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):OnCloseLoadingPage()
    UE4.UPMLoginSubSystem.GetInstance(LuaGetWorld()):LoadingAfterLoginDone()
  end)
end
return ApartmentPageMobile
