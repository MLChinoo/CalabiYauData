local EscMainPage = class("EscMainPage", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function EscMainPage:ListNeededMediators()
  return {}
end
function EscMainPage:InitializeLuaEvent()
  self.CommonKeyButton_ESC.OnClickEvent:Add(self, EscMainPage.OnEscClicked)
  self.BP_CommonButton_Setting.OnClickEvent:Add(self, EscMainPage.OnSettingClicked)
  self.BP_CommonButton_BackToGame.OnClickEvent:Add(self, EscMainPage.OnBackToGameClicked)
  self.BP_CommonButton_SkipGuide.OnClickEvent:Add(self, EscMainPage.OnSkipGuideClicked)
  self.BP_CommonButton_Surrend.OnClickEvent:Add(self, EscMainPage.OnSurrendClicked)
  self.BP_CommonButton_Communicate.OnClickEvent:Add(self, EscMainPage.OnClickCommunicate)
  if self:IsPlayingLocalReplayFile() then
    self.BP_CommonButton_BackToLobby.OnClickEvent:Add(self, EscMainPage.OnReplayBackToLobbyClicked)
  else
    self.BP_CommonButton_BackToLobby.OnClickEvent:Add(self, EscMainPage.OnBackToLobbyClicked)
  end
  self.BP_CommonButton_BackToRoom.OnClickEvent:Add(self, EscMainPage.OnBackToRoomClicked)
  self.BP_CommonButton_SkipNewGuide.OnClickEvent:Add(self, EscMainPage.OnSkipNewGuideClicked)
  self.BP_CommonButton_BackToReplay.OnClickEvent:Add(self, EscMainPage.OnBackToGameClicked)
  self:FlushPressedKey()
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  if SettingCombatProxy then
    if SettingCombatProxy:CheckIsCustomRoomMode() or self:IsPlayingLocalReplayFile() then
      self.BP_CommonButton_BackToLobby:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BP_CommonButton_BackToLobby:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local isInGame = SettingCombatProxy:CheckIsInGame()
    local GameState = UE4.UGameplayStatics.GetGameState(self)
    local GameModeType = GameState and GameState.GetModeType and GameState:GetModeType() or UE4.EPMGameModeType.None
    if isInGame and GameModeType ~= UE4.EPMGameModeType.Practice and not self:IsPlayingLocalReplayFile() and not self:CheckGuideMode() then
      self.BP_CommonButton_Communicate:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BP_CommonButton_Communicate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local bNeedSurrend = self:CheckBombMode()
  if self.IsOnlyASpectator and self:IsOnlyASpectator() then
    if self:IsPlayingLocalReplayFile() then
      self.WS_BackGame:SetActiveWidgetIndex(1)
    end
    bNeedSurrend = false
  end
  if bNeedSurrend then
    self.BP_CommonButton_Surrend:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BP_CommonButton_Surrend:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:CheckGuideMode() then
    self.BP_CommonButton_SkipGuide:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BP_CommonButton_SkipGuide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if RoomProxy and RoomProxy:GetEnterPracticeStatus() then
    self.WS_BackToLobbyOrRoom:SetVisibility(UE4.ESlateVisibility.Visible)
    self.WS_BackToLobbyOrRoom:SetActiveWidgetIndex(1)
  end
  if self:CheckNewGuideMode() and not self:CheckGuideMode() then
    self.WS_BackToLobbyOrRoom:SetActiveWidgetIndex(2)
  end
end
function EscMainPage:RefreshUIPosition()
  local startPosY = -104
  local difY = 60
  local btnList = {
    self.BP_CommonButton_Setting,
    self.BP_CommonButton_BackToGame,
    self.BP_CommonButton_BackToLobby,
    self.BP_CommonButton_SkipGuide,
    self.BP_CommonButton_Surrend
  }
  local cnt = 0
  for i, v in ipairs(btnList) do
    if v:GetVisibility() ~= UE4.ESlateVisibility.Collapsed or v:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
      v.Slot:SetPosition(UE4.FVector2D(0, startPosY + difY * cnt))
      cnt = cnt + 1
    end
  end
end
function EscMainPage:LuaHandleKeyEvent(key, inputEvent)
  if GamePlayGlobal and GamePlayGlobal:LuaHandleKeyEvent(self, key, inputEvent) then
    return
  end
  return self.CommonKeyButton_ESC:MonitorKeyDown(key, inputEvent)
end
function EscMainPage:OnSettingClicked()
  ViewMgr:ClosePage(self, UIPageNameDefine.Esc)
  ViewMgr:OpenPage(self, UIPageNameDefine.SettingPage)
end
function EscMainPage:OnClickCommunicate()
  local SettingPageOpenParam = {
    PageOrderParam = {
      SettingEnum.PanelTypeStr.Combat
    },
    bHideTab = true,
    SettingTitle = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "46")
  }
  ViewMgr:ClosePage(self, UIPageNameDefine.Esc)
  ViewMgr:OpenPage(self, UIPageNameDefine.SettingPage, false, SettingPageOpenParam)
end
function EscMainPage:OnBackToGameClicked()
  ViewMgr:ClosePage(self, UIPageNameDefine.Esc)
end
function EscMainPage:OnSkipGuideClicked()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_SkipComos")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_Default")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel")
  function pageData.cb(bConfirm)
    if bConfirm then
      self:SureSkipGuide()
    else
      self:CloseSelf()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function EscMainPage:CloseSelf()
  ViewMgr:ClosePage(self, UIPageNameDefine.Esc)
end
function EscMainPage:OnEscClicked()
  self:CloseSelf()
end
function EscMainPage:CheckNewGuideMode()
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  return NewPlayerGuideProxy:IsAllGuideComplete() == false
end
function EscMainPage:OnBackToLobbyClicked()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_BackToLobby")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_BackToLobby")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel_BackToLobby")
  function pageData.cb(bConfirm)
    if bConfirm then
      local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
      SettingProxy:ReturnToLobby()
    else
      self:CloseSelf()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function EscMainPage:OnReplayBackToLobbyClicked()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "Content_QuitReplay")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_BackToLobby")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "Cancel_ContinueReplay")
  function pageData.cb(bConfirm)
    if bConfirm then
      local GameInstance = UE.UGameplayStatics.GetGameInstance(self)
      GameInstance:GotoLobbyScene()
      local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
      ReplayProxy:QuitDemoReplay()
    else
      self:CloseSelf()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function EscMainPage:OnSkipNewGuideClicked()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_SkipTeamSupport")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_Default")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel")
  function pageData.cb(bConfirm)
    if bConfirm then
      local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
      SettingProxy:ReturnToLobby()
      UE4.UCyClientEventTrackSubsystem.Get(LuaGetWorld()):OnTeamGuideSkip()
    else
      self:CloseSelf()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function EscMainPage:OnBackToRoomClicked()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_BackToRoom")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_BackToRoom")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel_BackToRoom")
  function pageData.cb(bConfirm)
    if bConfirm then
      local GameState = UE4.UGameplayStatics.GetGameState(self)
      if not GameState then
        return
      end
      if GameState:GetModeType() == UE4.EPMGameModeType.Practice then
        local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
        RoomProxy:ReqTeamLeavePractice()
      elseif GameState:GetModeType() < UE4.EPMGameModeType.NoviceGuide then
        local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
        SettingProxy:ReturnToLobby()
      end
    else
      self:CloseSelf()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function EscMainPage:OnSurrendClicked()
  local tip = self:DoSurrender()
  if "" ~= tip then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
  end
  self:CloseSelf()
end
function EscMainPage:CheckGuideMode()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  return UE4.EPMGameModeType.NoviceGuide == GameState:GetModeType()
end
function EscMainPage:OnClose()
  LogInfo("EscMainPage", "OnClose")
end
function EscMainPage:SureSkipGuide()
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if PlayerController and PlayerController.SkipGuide then
    PlayerController:SkipGuide()
  end
end
return EscMainPage
