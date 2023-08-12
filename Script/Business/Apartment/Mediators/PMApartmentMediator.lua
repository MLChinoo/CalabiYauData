local PMApartmentMediator = class("PMApartmentMediator", PureMVC.Mediator)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
local ApartmentMapName = {
  [1] = "Envi_Wlbl",
  [2] = "Envi_lounge_Prop",
  [3] = "Envi_Wlbl"
}
local ApartmentCameraName = {
  [1] = "Wlbl_Camera_Movable",
  [2] = "Lounge_Camera",
  [3] = "Wlbl_Camera_Movable"
}
local ApartmentRootName = {
  [1] = "ApartmentRoot_Wlbl",
  [2] = "ApartmentRoot_Wlbl",
  [3] = "ApartmentRoot_Wlbl"
}
local ApartmentMapID = {
  [1] = 10000000,
  [2] = 10000001,
  [3] = 10000000
}
local EnumClickButton = {
  Promise = 0,
  Information = 1,
  Memory = 2,
  Gift = 3
}
local ApartmentRoomProxy
function PMApartmentMediator:ListNotificationInterests()
  return {
    NotificationDefines.PMApartmentMainCmd,
    NotificationDefines.ApartmentContract,
    NotificationDefines.GivePageClose,
    NotificationDefines.ApartmentStateSwitch,
    NotificationDefines.ApartmentStateMachine.EnterSincerityInteractionState,
    NotificationDefines.ApartmentStateMachine.ExitSincerityInteractionState,
    NotificationDefines.ApartmentRoleInfoChanged,
    NotificationDefines.ApartmentSetLookAtEnable,
    NotificationDefines.ApartmentSpeakBubbleClicked,
    NotificationDefines.NewPlayerGuide.GuideStepUpdate,
    NotificationDefines.ShowPlayerGuideCurrentIndex,
    NotificationDefines.HideGiftBtn,
    NotificationDefines.EnterCharacterApartmentRoom,
    NotificationDefines.SetApartmentRoleInfo,
    NotificationDefines.ApartmentTurnOnBgm,
    NotificationDefines.ApartmentTurnOffBgm,
    NotificationDefines.ApartmentMainPageToGiftPage
  }
end
function PMApartmentMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  self.MainPageOpenData = luaData
  if self.MainPageOpenData and self.MainPageOpenData.bEnterNewRoleRoom then
    self:EnterNewRoom()
  else
    LogDebug("PMApartmentMediator:LoadApartmentScene", "Nomal Enter")
    UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):OnShowLoadingPage()
    self:LoadApartmentScene()
  end
end
function PMApartmentMediator:OnRegister()
  self.super:OnRegister()
  self.bEnterNewRoleRoom = false
  self.loadCharacterComplete = false
  local SettingDataCenter = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  if SettingDataCenter then
    SettingDataCenter:OnEnterApartment()
  end
  ApartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy)
  self:GetViewComponent().actionOnClickGiftBtn:Add(self.OnClickGiftBtn, self)
  self:GetViewComponent().actionOnClickPreviewBtn:Add(self.OnClickPreviewBtn, self)
  self:GetViewComponent().actionOnSwitchCamera:Add(self.OnLoadSceneCallBack, self)
  self:GetViewComponent().actionOnClickOthersApartment:Add(self.GotoOthersApartment, self)
  ApartmentRoomProxy:SetCurrentPageType(GlobalEnumDefine.EApartmentPageType.Main)
  self.IsPreviewing = false
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):BindDelegateForApartment()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnLoadingLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnLoadingLobbyCharacterDelegate, self, "OnSpawnCharacterCallBack")
  end
end
function PMApartmentMediator:OnRemove()
  self.super:OnRemove()
  self:GetViewComponent().actionOnClickGiftBtn:Remove(self.OnClickGiftBtn, self)
  self:GetViewComponent().actionOnClickPreviewBtn:Remove(self.OnClickPreviewBtn, self)
  self:GetViewComponent().actionOnSwitchCamera:Remove(self.OnLoadSceneCallBack, self)
  self:GetViewComponent().actionOnClickOthersApartment:Remove(self.GotoOthersApartment, self)
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):OnCloseLoadingPage()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):StopStateMachine()
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):ExitApartmentRoom()
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.LongTimeNotLogginCond)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnLoadingLobbyCharacterDelegate, self.OnLoadingLobbyCharacterDelegate)
  end
  self:StopChandRoleLoadingTimer()
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):UnBindDelegateForApartment()
  if self.waitCallBackTimer then
    self.waitCallBackTimer:EndTask()
    self.waitCallBackTimer = nil
  end
  local SettingDataCenter = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  if SettingDataCenter then
    SettingDataCenter:OnLeaveApartment()
  end
end
function PMApartmentMediator:HandleNotification(notification)
  local type = notification:GetType()
  local data = notification:GetBody()
  local NtfName = notification:GetName()
  if type == NotificationDefines.UpdateApartmentScene.ShowRoleUpgrade then
    if ApartmentRoomProxy:GetCurrentPageType() ~= GlobalEnumDefine.EApartmentPageType.Promise and GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):CheckContractAnimUpgrade() then
      GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):SwitchFavorabilityUpState()
    end
  elseif type == NotificationDefines.ApartmentContract.ContractUpGradePageClosed then
    self:UpdateInmacityAnimCondi()
    GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):OnScreenEffectsCallBack()
  end
  if NtfName == NotificationDefines.GivePageClose then
    if ApartmentRoomProxy:GetCurrentPageType() == GlobalEnumDefine.EApartmentPageType.Promise then
      self:HandlePromiseColse()
    end
  elseif NtfName == NotificationDefines.ApartmentStateSwitch then
    self:UpdatePrimeseBtnState(data)
  elseif NtfName == NotificationDefines.ApartmentStateMachine.EnterSincerityInteractionState then
    self:GetViewComponent():EnterSincerityInteractionState()
  elseif NtfName == NotificationDefines.ApartmentStateMachine.ExitSincerityInteractionState then
    self:GetViewComponent():ExitSincerityInteractionState()
  elseif NtfName == NotificationDefines.ApartmentSetLookAtEnable then
    self:SetHeadLookAtEnable(data)
  elseif NtfName == NotificationDefines.ApartmentSpeakBubbleClicked then
    self:OnSpeakBubbleClicked()
  elseif NtfName == NotificationDefines.NewPlayerGuide.GuideStepUpdate then
    GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):GuideStepUpdate()
  elseif NtfName == NotificationDefines.ShowPlayerGuideCurrentIndex then
    self:OnShowPlayerGuide(data)
  elseif NtfName == NotificationDefines.HideGiftBtn then
    self:CallRevertGiftBack()
  elseif NtfName == NotificationDefines.EnterCharacterApartmentRoom then
    self:EnterNewRoom()
  elseif NtfName == NotificationDefines.SetApartmentRoleInfo then
    self:GetViewComponent():UpdateLevelText()
  elseif NtfName == NotificationDefines.ApartmentTurnOnBgm then
    self:TurnOnApartmentBGM()
  elseif NtfName == NotificationDefines.ApartmentTurnOffBgm then
    self:TurnOffApartmentBGM()
  elseif NtfName == NotificationDefines.ApartmentMainPageToGiftPage then
    self:OnClickGiftBtn(data)
  end
end
function PMApartmentMediator:HandlePromiseColse()
  ApartmentRoomProxy:SetCurrentPageType(GlobalEnumDefine.EApartmentPageType.Main)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:PopPage(self:GetViewComponent(), UIPageNameDefine.ApartmentMainPage)
  else
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.ApartmentMainPage)
  end
  self:GetViewComponent():ShowMainPage()
  if self.bEnterNewRoleRoom then
    return
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ExitPromiseState()
end
function PMApartmentMediator:UpdatePrimeseBtnState(bShow)
  self:GetViewComponent():SetGiftBtnVisibility(bShow)
end
function PMApartmentMediator:UpdateInmacityAnimCondi()
  local roleIntimacyLv
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  if KaPhoneProxy.RolesProperties then
    local properties = KaPhoneProxy.RolesProperties[self.roleId]
    if properties then
      roleIntimacyLv = properties.intimacy_lv
    end
  end
  if roleIntimacyLv then
    local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
    RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.IntimacyLvAnimCond)
  end
end
function PMApartmentMediator:LoadApartmentScene()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  self.roleId = kaNavigationProxy:GetCurrentRoleId()
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):SetApartmentCurRoleId(self.roleId, 0)
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):SetApartmentCurRoleSkinId(ApartmentRoomProxy:GetRoleWearSkinID(self.roleId))
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProfile = roleProxy:GetRoleProfile(self.roleId)
  local mapName = ApartmentMapName[1]
  local mapId = ApartmentMapID[1]
  if nil ~= roleProfile then
    mapName = ApartmentMapName[roleProfile.Team]
    mapId = ApartmentMapID[roleProfile.Team]
  end
  LogDebug("PMApartmentMediator:LoadApartmentScene", "Start LoadApartmentLevel  , LevelName : " .. mapName)
  if nil ~= mapName and "" ~= mapName then
    local gameMode = UE4.UGameplayStatics.GetGameMode(self:GetViewComponent():GetWorld())
    if gameMode and gameMode.OnLoadStreamLevel then
      gameMode:OnLoadStreamLevel(mapName)
    end
  end
end
function PMApartmentMediator:OnLoadSceneCallBack()
  LogDebug("PMApartmentMediator:OnLoadSceneCallBack", "Load Scene CallBack")
  self:SpawnCharacter()
end
function PMApartmentMediator:SpawnCharacter()
  LogDebug("PMApartmentMediator:SpawnCharacter", "Start Spawn Character , RoleID :" .. tostring(self.roleId))
  self.loadCharacterComplete = false
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):SpawnApartmentCharacter(self.roleId, 0)
end
function PMApartmentMediator:OnSpawnCharacterCallBack(eventData)
  if eventData.RoleWidgetType ~= UE4.ERoleWidgetType.RestRoomWiget then
    return
  end
  self.loadCharacterComplete = true
  if nil == eventData then
    LogError("PMApartmentMediator:OnSpawnCharacterCallBack", "eventData is nil ")
    return
  end
  if eventData.bLoadSucceed then
    LogDebug("PMApartmentMediator:OnSpawnCharacterCallBack", "Loaded Character is succeed, roleID: " .. eventData.RoleID)
    if self.bEnterNewRoleRoom and self.changeRoleLoadingTimer then
      return
    end
    self:StartApartmentStateMachine()
  else
    LogError("PMApartmentMediator:OnSpawnCharacterCallBack", "Loaded Character Fail, roleID: " .. eventData.RoleID)
  end
  self:GetViewComponent():CloseLoading()
  self.bEnterNewRoleRoom = false
end
function PMApartmentMediator:StartApartmentStateMachine()
  LogDebug("PMApartmentMediator:StartApartmentStateMachine", "Start Apartment StateMachine")
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):StartStateMachine()
  if self.MainPageOpenData and self.MainPageOpenData.EnumClickButton == EnumClickButton.Gift then
    self.MainPageOpenData.EnumClickButton = nil
    self:OnClickGiftBtn(EnumClickButton.Gift)
  end
end
function PMApartmentMediator:ResetGiftBlurMask()
  local curWorld = self:GetViewComponent():GetWorld()
  if not curWorld then
    return
  end
  GameFacade:SendNotification(NotificationDefines.PMApartmentMainCmd, {world = curWorld, isShow = false}, NotificationDefines.UpdateApartmentScene.ShowGiftBlurMask)
end
function PMApartmentMediator:OnClickGiftBtn(OpenPageData)
  ApartmentRoomProxy:SetCurrentPageType(GlobalEnumDefine.EApartmentPageType.Promise)
  local viewPage = self:GetViewComponent()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):SwitchPromiseState()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
    GameFacade:SendNotification(NotificationDefines.NavigationBar.LiveApartmentPage)
    ViewMgr:PushPage(viewPage, UIPageNameDefine.ApartmentMainPage, nil, OpenPageData)
  else
    ViewMgr:OpenPage(viewPage, UIPageNameDefine.ApartmentMainPage, nil, OpenPageData)
  end
  viewPage:HideMainPage()
  GameFacade:SendNotification(NotificationDefines.ApartmentRoleInfoChangedCmd)
end
function PMApartmentMediator:OnClickPreviewBtn()
  local viewPage = self:GetViewComponent()
  if self.IsPreviewing then
    self.IsPreviewing = false
  else
    self.IsPreviewing = true
  end
end
function PMApartmentMediator:SetHeadLookAtEnable(bEnable)
  local modelShow3DWidget = self:GetViewComponent().ModelShow3DWidget
  if modelShow3DWidget and modelShow3DWidget:GetRotateImage() then
    modelShow3DWidget:GetRotateImage():SetLookAtEnable(bEnable)
  end
end
function PMApartmentMediator:OnSpeakBubbleClicked()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):SwitchStateByStateID(UE4.ECyApartmentState.SincerityInteraction)
end
function PMApartmentMediator:EnterNewRoom()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local newRoleID = kaNavigationProxy:GetCurrentRoleId()
  LogDebug("PMApartmentMediator:EnterNewRoom", "start enter role room,roleID : " .. tostring(newRoleID))
  if newRoleID == self.roleId then
    LogError("PMApartmentMediator:EnterNewRoom", "already enter role room,roleID : " .. tostring(newRoleID))
    return
  end
  self.bEnterNewRoleRoom = true
  UE4.UCyLoadingStream.Get(self:GetViewComponent():GetWorld()):Start(UE4.ECyLoadingStyle.Apartment, newRoleID, UE4.ECyProgressStyle.Actual)
  self:StartChandRoleLoadingTimer()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):StopStateMachine()
  UE4.UPMApartmentSubsystem.Get(self:GetViewComponent():GetWorld()):ExitApartmentRoom()
  self:LoadApartmentScene()
end
function PMApartmentMediator:StartChandRoleLoadingTimer()
  UE4.UCyLoadingStream.Get(self:GetViewComponent():GetWorld()):Percent(90)
  self.changeRoleLoadingTimer = TimerMgr:AddTimeTask(2, 0, 1, function()
    self:SimulateLoadingTimeComplete()
  end)
end
function PMApartmentMediator:SimulateLoadingTimeComplete()
  LogDebug("PMApartmentMediator:SimulateLoadingTimeComplete", "SimulateLoadingTimeComplete ")
  if self.loadCharacterComplete then
    UE4.UCyLoadingStream.Get(self:GetViewComponent():GetWorld()):Stop(UE4.ECyLoadingStyle.Apartment)
    self:StartApartmentStateMachine()
    self.bEnterNewRoleRoom = false
  end
  self:StopChandRoleLoadingTimer()
end
function PMApartmentMediator:StopChandRoleLoadingTimer()
  if self.changeRoleLoadingTimer then
    self.changeRoleLoadingTimer:EndTask()
    self.changeRoleLoadingTimer = nil
  end
  LogDebug("PMApartmentMediator:StopChandRoleLoadingTimer", "StopChandRoleLoadingTimer")
end
function PMApartmentMediator:OnShowPlayerGuide(step)
  if step == NewPlayerGuideEnum.GuideStep.Gift then
    local viewpage = self:GetViewComponent()
    local WidgetSwitcher_PreviewVis = viewpage.WidgetSwitcher_Preview:GetVisibility()
    local ViewpageVis = viewpage:GetVisibility()
    viewpage.WidgetSwitcher_Preview:SetVisibility(UE4.ESlateVisibility.Collapsed)
    viewpage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    function self.RevertGiftBack()
      viewpage.WidgetSwitcher_Preview:SetVisibility(WidgetSwitcher_PreviewVis)
      viewpage:SetVisibility(ViewpageVis)
    end
    NewPlayerGuideProxy:ShowStepGuideUI(viewpage.Gift_Btn, function()
      if type(self.RevertGiftBack) == "function" then
        self.RevertGiftBack()
        self.RevertGiftBack = nil
      end
      viewpage:OnClickGiftBtn()
    end, viewpage, step, {
      sizeoffsets = UE4.FVector2D(20, 20)
    })
  end
end
function PMApartmentMediator:CallRevertGiftBack()
  if type(self.RevertGiftBack) == "function" then
    self.RevertGiftBack()
    self.RevertGiftBack = nil
  end
end
function PMApartmentMediator:GotoOthersApartment()
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.KaPhonePage
  })
  GameFacade:SendNotification(NotificationDefines.NtfKaPhoneOpenNavigation)
end
function PMApartmentMediator:TurnOffApartmentBGM()
  local viewPage = self:GetViewComponent()
  if viewPage and viewPage.AkEventEmpty and viewPage.AkEventEmpty:IsValid() then
    viewPage:K2_PostAkEvent(viewPage.AkEventEmpty)
    self.BGMTurnOn = false
  end
end
function PMApartmentMediator:TurnOnApartmentBGM()
  if self.BGMTurnOn then
    return
  end
  local viewPage = self:GetViewComponent()
  if viewPage and viewPage.AkEventEmpty and viewPage.AkEventEmpty:IsValid() then
    viewPage:PostAkShowEvents()
    self.BGMTurnOn = true
  end
end
return PMApartmentMediator
