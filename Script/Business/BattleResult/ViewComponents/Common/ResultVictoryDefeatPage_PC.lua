local ResultVictoryDefeatPage_PC = class("ResultVictoryDefeatPage_PC", PureMVC.ViewComponentPage)
local BattleResultVictoryDefeatMediator = require("Business/BattleResult/Mediators/BattleResultVictoryDefeatMediator")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultVictoryDefeatPage_PC:ListNeededMediators()
  return {BattleResultVictoryDefeatMediator}
end
function ResultVictoryDefeatPage_PC:ReturnLobby()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  local GoToLobby = function()
    if GameState.RequestFinishAndExitToMainMenu then
      LogDebug("ResultVictoryDefeatPage_PC RequestFinishAndExitToMainMenu", "RequestFinishAndExitToMainMenu")
      GameState:RequestFinishAndExitToMainMenu()
    end
  end
  pcall(GoToLobby)
end
function ResultVictoryDefeatPage_PC:OnOpen(luaOpenData, nativeOpenData)
  ResultVictoryDefeatPage_PC.super.OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ResultVictoryDefeatPage_PC", "OnOpen")
  self.OpenAnimFinished = false
  self.OverAnimStarted = false
  self:StopAllAnimations()
  self:PlayAnimation(self.Anim_start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self:IsPlayingLocalReplayFile() then
    self.bReactiveFocusable = true
    self.PlayerInputModeWhenReactiveFocus = UE.EPMPlayerInputMode.OnlyInUI
    MyPlayerController:SetGameInput(self.PlayerInputModeWhenReactiveFocus)
    self.Btn_Quit:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Quit.Btn_Item:SetClickMethod(UE.EButtonClickMethod.MouseDown)
    self.Btn_Quit.OnClickEvent:Add(self, ResultVictoryDefeatPage_PC.OnClickQuit)
    self.Btn_Replay:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Replay.Btn_Item:SetClickMethod(UE.EButtonClickMethod.MouseDown)
    self.Btn_Replay.OnClickEvent:Add(self, ResultVictoryDefeatPage_PC.OnClickReplay)
  else
    self.TimerReturnLobby = TimerMgr:AddTimeTask(15, 0, 1, function()
      self:ReturnLobby()
    end)
  end
  if MyPlayerController.PlayMatchEndVoice then
    MyPlayerController:PlayMatchEndVoice()
  end
  local TeamId = MyPlayerState.AttributeTeamID
  if MyPlayerState.bOnlySpectator then
    TeamId = MyPlayerController:GetCurrentSpectatorTeamId()
  end
  local AudioEvent
  local ResultType = GamePlayGlobal:GetResultType(self)
  if ResultType == GamePlayGlobal.ResultType.Victory then
    AudioEvent = self.AudioEvent_Win
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Victory")
    self.TextBlock_Result:SetText(str)
    self.TextBlock_Red_Result:SetText(str)
  elseif ResultType == GamePlayGlobal.ResultType.Defeat then
    AudioEvent = self.AudioEvent_Fail
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Defeat")
    self.TextBlock_Result:SetText(str)
    self.TextBlock_Red_Result:SetText(str)
  else
    AudioEvent = self.AudioEvent_Draw
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Draw")
    self.TextBlock_Result:SetText(str)
    self.TextBlock_Red_Result:SetText(str)
  end
  self:K2_PostAkEvent(self.AudioEvent_Result, true)
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    self.Logo_WidgetSwitcher_wjh:SetActiveWidgetIndex(TeamId == GameState.BombOwnerTeam and 1 or 0)
  elseif GameState.DefaultNumTeams >= 3 then
    self.Logo_WidgetSwitcher_wjh:SetActiveWidgetIndex(ResultType == GamePlayGlobal.ResultType.Victory and 0 or 1)
  else
    self.Logo_WidgetSwitcher_wjh:SetActiveWidgetIndex(1 == TeamId and 0 or 1)
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Spar then
    self.HB_VictoryScore:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HB_FailScore:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.HB_VictoryScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HB_FailScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local MatchScores = GamePlayGlobal:GetTeamMatchScore(self, TeamId)
    local margin2 = UE4.FMargin()
    margin2.Left = 80
    margin2.Right = 80
    local margin3 = UE4.FMargin()
    margin3.Left = 40
    margin3.Right = 40
    local margin = {
      [0] = margin3,
      [2] = margin2,
      [3] = margin3
    }
    for key, value in pairs(MatchScores) do
      self["VictoryScore_" .. key]:SetText(value)
      self["FailScore_" .. key]:SetText(value)
      self["VictoryScore_" .. key]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self["FailScore_" .. key]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self["VictoryScore_" .. key].Slot:SetPadding(margin[#MatchScores] or margin[0])
      self["FailScore_" .. key].Slot:SetPadding(margin[#MatchScores] or margin[0])
      if self["ImgDiv_" .. key - 1] then
        self["ImgDiv_" .. key - 1]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self["ImgDivFail_" .. key - 1] then
        self["ImgDivFail_" .. key - 1]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function ResultVictoryDefeatPage_PC:OnClose()
  if self.TimerReturnLobby then
    self.TimerReturnLobby:EndTask()
    self.TimerReturnLobby = nil
  end
end
function ResultVictoryDefeatPage_PC:OnRecvMatchEndData()
  local GameState, MyPlayerController = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not GameState or not MyPlayerController then
    return
  end
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  if battleResultProxy.MyObTeamId then
    MyPlayerController:PlayMatchEnd()
    local Success = MyPlayerController:BindSequenceTarget()
    if Success then
      MyPlayerController:ViewSequenceTarget()
      self:PlayAnimation(self.Anim_Over, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    else
      MyPlayerController:OnMatchEndLSFinished()
    end
    return
  end
  MyPlayerController.LastRoleSkinId = battleResultProxy:GetLastRoleSkinId()
  MyPlayerController.LastWeaponSkinId = battleResultProxy:GetLastWeaponSkinId()
  MyPlayerController:PlayMatchEnd()
  local Success = MyPlayerController:BindSequenceTarget()
  if Success then
    if self.TimerReturnLobby then
      self.TimerReturnLobby:EndTask()
      self.TimerReturnLobby = nil
    end
    self:PlayAnimation(self.Anim_Over, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    MyPlayerController:OnMatchEndLSFinished()
  end
end
function ResultVictoryDefeatPage_PC:OnAnimFinishFinish()
  LogDebug("OnAnimFinishFinish")
  self.OpenAnimFinished = true
end
function ResultVictoryDefeatPage_PC:OnAnimStartFinish()
  LogDebug("OnAnimStartFinish")
  self:PlayAnimation(self.Anim_Finish, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function ResultVictoryDefeatPage_PC:OnAnimOverFinish()
  LogDebug("OnAnimOverFinish")
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  if BattleResultProxy.MyObTeamId then
    local GameState, MyPlayerController = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
    if not GameState or not MyPlayerController then
      return
    end
    local Success = MyPlayerController:BindSequenceTarget()
    if Success then
      MyPlayerController:ViewSequenceTarget()
    end
    MyPlayerController:OnMatchEndLSFinished()
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.ResultCharacterPage)
  end
end
function ResultVictoryDefeatPage_PC:OnClickQuit()
  local GameInstance = UE.UGameplayStatics.GetGameInstance(self)
  GameInstance:GotoLobbyScene()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  ReplayProxy:QuitDemoReplay()
end
function ResultVictoryDefeatPage_PC:OnClickReplay()
  local MyPlayerController = self:GetOwningPlayer()
  if MyPlayerController then
    MyPlayerController:ReplayGotoTime(0)
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.GameFinishPage)
end
return ResultVictoryDefeatPage_PC
