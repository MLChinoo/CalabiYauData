local ResultPage_PC = class("ResultPage_PC", PureMVC.ViewComponentPage)
local ResultMediator = require("Business/BattleResult/Mediators/ResultMediator")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local AutoReturnLobbyTime = 120
function ResultPage_PC:ListNeededMediators()
  return {ResultMediator}
end
function ResultPage_PC:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ResultPage_PC", "OnOpen")
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  self.BgBlur:SetBlurStrength(0)
  self.Btn_Next.OnClickEvent:Add(self, self.OnClickNext)
  self.CurAutoReturnLobbyTime = AutoReturnLobbyTime
  self:UpdatePanelType()
  ViewMgr:ClosePage(self, UIPageNameDefine.GameFinishPage)
  ViewMgr:ClosePage(self, UIPageNameDefine.ResultMvpPage)
  ViewMgr:ClosePage(self, UIPageNameDefine.BattleDataPage)
  self.gameModeType = UE4.EPMGameModeType.None
  self.openShare = false
  local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if basicProxy then
    self.openShare = basicProxy:IsShareOpen()
  end
  local GameState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if GameState and GameState.GetModeType then
    self.gameModeType = GameState:GetModeType()
    if self.gameModeType == UE4.EPMGameModeType.TeamGuide then
      self.openShare = false
    end
  end
  if self.Btn_Share then
    if self.openShare then
      self.Btn_Share.OnClickEvent:Add(self, self.OnClickShare)
      self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
    else
      self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.ReplayDownloadPanel then
    self.ReplayDownloadPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local MyPlayerInfo = battleResultProxy:GetMyPlayerInfo()
  local SettleBattleGameData = battleResultProxy:GetSettleBattleGameData()
  if MyPlayerInfo and SettleBattleGameData then
    LogDebug("ResultPage_PC", "on_hook = %s ", MyPlayerInfo.on_hook)
    if MyPlayerInfo.on_hook and SettleBattleGameData.room_mode ~= GlobalEnumDefine.EGameModeType.Room then
      local showData = {
        contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "GameCheating"),
        bIsOneBtn = true
      }
      ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, showData)
    end
  end
end
function ResultPage_PC:UpdatePanelType()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local SettleBattleGameData = battleResultProxy:GetSettleBattleGameData()
  if not SettleBattleGameData then
    LogDebug("UpdatePanelType", "No result data")
    return
  end
  self.CurPanelType = BattleResultDefine.PanelType.Account
  if SettleBattleGameData.room_mode and (SettleBattleGameData.room_mode == GlobalEnumDefine.EGameModeType.RankBomb or SettleBattleGameData.room_mode == GlobalEnumDefine.EGameModeType.RankTeam) then
    self.CurPanelType = BattleResultDefine.PanelType.Rank
  end
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if MyPlayerState.bOnlySpectator then
    self.CurPanelType = BattleResultDefine.PanelType.KDA
  end
  self.WidgetSwitcher_Panel:SetActiveWidgetIndex(self.CurPanelType)
  self.WidgetSwitcher_Panel:GetActiveWidget():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:CheckStartScrollAK()
  self:OnUpdatePanelType()
end
function ResultPage_PC:OnUpdatePanelType()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.CurPanelType == BattleResultDefine.PanelType.KDA then
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Leave")
    self.Btn_Next:SetPanelName(str)
    self.Btn_Next:SetTimerIsShow(true)
    self.Btn_Next:SetTime(self.CurAutoReturnLobbyTime)
    self.CurAutoReturnLobbyTime = AutoReturnLobbyTime
    if self.AutoReturnLobbyTimer then
      self.AutoReturnLobbyTimer:EndTask()
      self.AutoReturnLobbyTimer = nil
    end
    self.AutoReturnLobbyTimer = TimerMgr:AddTimeTask(0, 1.0, self.CurAutoReturnLobbyTime, function()
      self:AutoReturnLobbyTimerFunc()
    end)
    MyPlayerController:HiddenMatchEndCharacter()
    self.BgBlur:SetBlurStrength(self.BlurStrength)
    self.WBP_ResultAchvPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.WidgetSwitcher_Panel:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.WBP_BombResultPage_ScorePage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.ReplayDownloadPanel then
      local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
      if self.gameModeType == UE4.EPMGameModeType.Bomb then
        self.ReplayDownloadPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.DownloadButton:InitView({
          room_id = battleResultProxy:GetRoomId(),
          map_id = battleResultProxy:GetMapId()
        })
      end
    end
  else
    self.WBP_BombResultPage_ScorePage:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.WidgetSwitcher_Panel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.WidgetSwitcher_Panel:SetActiveWidgetIndex(self.CurPanelType)
    self.WidgetSwitcher_Panel:GetActiveWidget():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ResultPage_PC:OnClose()
  LogDebug("ResultPage_PC", "OnClose")
  self.Btn_Next.OnClickEvent:Remove(self, self.OnClickNext)
  if self.AutoReturnLobbyTimer then
    self.AutoReturnLobbyTimer:EndTask()
    self.AutoReturnLobbyTimer = nil
  end
  if self.AKScoreRollTimer then
    self.AKScoreRollTimer:EndTask()
    self.AKScoreRollTimer = nil
  end
  if self.Btn_Share and self.openShare then
    self.Btn_Share.OnClickEvent:Remove(self, self.OnClickShare)
  end
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
end
function ResultPage_PC:LuaHandleKeyEvent(key, inputEvent)
  return self.Btn_Next:MonitorKeyDown(key, inputEvent)
end
function ResultPage_PC:OnClickNext()
  LogDebug("ResultPage_PC", "OnClickNext CurPanelType = %s", self.CurPanelType)
  if not self.CurPanelType then
    LogDebug("OnClickNext", "No result data self.CurPanelType not set")
    return
  end
  if self.CurPanelType == BattleResultDefine.PanelType.KDA then
    self:ReturnLobby()
  else
    if self.CurPanelType == BattleResultDefine.PanelType.Account and self.WBP_ResultAccountAndRolePanel:IsProgressAniPlaying() then
      self.WBP_ResultAccountAndRolePanel:StopProgressAni()
      self:StopScrollAK()
      return
    end
    if self.CurPanelType == BattleResultDefine.PanelType.BattlePass and self.WBP_ResultBPPanel:IsProgressAniPlaying() then
      self.WBP_ResultBPPanel:StopProgressAni()
      self:StopScrollAK()
      return
    end
    self.CurPanelType = self.CurPanelType + 1
    self:CheckStartScrollAK()
    if self.CurPanelType == BattleResultDefine.PanelType.KDA then
      self:K2_PostAkEvent(self.AK_Map:Find("Settlement"), true)
    end
    self:OnUpdatePanelType()
  end
end
function ResultPage_PC:CheckStartScrollAK()
  self:StopScrollAK()
  if self.CurPanelType == BattleResultDefine.PanelType.Account then
    local MaxTime = self.WBP_ResultAccountAndRolePanel:GetProgressAniMaxTime()
    if MaxTime > 0 then
      if MaxTime < 0.15 then
        MaxTime = 0.15
      end
      LogDebug("ResultAccountAndRolePanel", "GetProgressAniMaxTime %s", MaxTime)
      LogDebug("ResultAccountAndRolePanel", "start ScoreRoll")
      self:K2_PostAkEvent(self.AK_Map:Find("ScoreRoll"), true)
      self.AKScoreRollTimer = TimerMgr:AddTimeTask(MaxTime, MaxTime, 1, function()
        LogDebug("ResultAccountAndRolePanel", "stop ScoreRoll")
        self:K2_StopAkEvent(self.AK_Map:Find("ScoreRoll"))
      end)
    end
  elseif self.CurPanelType == BattleResultDefine.PanelType.BattlePass then
    local MaxTime = self.WBP_ResultBPPanel:GetProgressAniMaxTime()
    if MaxTime > 0 then
      if MaxTime < 0.15 then
        MaxTime = 0.15
      end
      LogDebug("WBP_ResultBPPanel", "GetProgressAniMaxTime %s", MaxTime)
      LogDebug("WBP_ResultBPPanel", "start ScoreRoll")
      self:K2_PostAkEvent(self.AK_Map:Find("ScoreRoll"), true)
      self.AKScoreRollTimer = TimerMgr:AddTimeTask(MaxTime, MaxTime, 1, function()
        LogDebug("WBP_ResultBPPanel", "stop ScoreRoll")
        self:K2_StopAkEvent(self.AK_Map:Find("ScoreRoll"))
      end)
    end
  end
end
function ResultPage_PC:StopScrollAK()
  if self.AKScoreRollTimer then
    self.AKScoreRollTimer:EndTask()
    self.AKScoreRollTimer = nil
  end
  self:K2_StopAkEvent(self.AK_Map:Find("ScoreRoll"))
end
function ResultPage_PC:AutoReturnLobbyTimerFunc()
  self.CurAutoReturnLobbyTime = self.CurAutoReturnLobbyTime - 1
  self.Btn_Next:SetTime(self.CurAutoReturnLobbyTime)
  if self.CurAutoReturnLobbyTime <= 0 then
    if self.AutoReturnLobbyTimer then
      self.AutoReturnLobbyTimer:EndTask()
      self.AutoReturnLobbyTimer = nil
    end
    self:ReturnLobby()
  end
end
function ResultPage_PC:ReturnLobby()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.ResultTimeDilationPage)
  ViewMgr:ClosePage(self, UIPageNameDefine.DamageCauserPage)
  local GoToLobby = function()
    if GameState.RequestFinishAndExitToMainMenu then
      LogDebug("RequestFinishAndExitToMainMenu", "RequestFinishAndExitToMainMenu")
      GameState:RequestFinishAndExitToMainMenu()
    end
  end
  pcall(GoToLobby)
end
function ResultPage_PC:OnClickShare()
  if self.Btn_Share then
    self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Btn_Next then
    self.Btn_Next:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.Settlement)
end
function ResultPage_PC:OnCaptureScreenshotSuccess()
  if self.Btn_Share then
    self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.Btn_Next then
    self.Btn_Next:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
return ResultPage_PC
