local ResultTimeDilationPage_PC = class("ResultTimeDilationPage_PC", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultTimeDilationPage_PC:ListNeededMediators()
  return {}
end
function ResultTimeDilationPage_PC:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ResultTimeDilationPage_PC", "OnOpen")
  self.DilationTime = 0
  self.OpenVictoryDefeatPage = false
  self.OpenRoleSequence = false
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  MyPlayerController.bAutoManageActiveCameraTarget = false
  MyPlayerController.PlayerCameraManager.bClientSimulatingViewTarget = true
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  if MyPlayerState.bOnlySpectator then
    local TeamId = MyPlayerController:GetCurrentSpectatorTeamId()
    if BattleResultProxy then
      BattleResultProxy.MyObTeamId = TeamId
      LogDebug("ResultTimeDilationPage_PC", "BattleResultProxy.MyObTeamId is %s", BattleResultProxy.MyObTeamId)
    end
  end
  if BattleResultProxy then
    for i = 1, GameState.PlayerArray:Length() do
      local PlayerState = GameState.PlayerArray:Get(i)
      if not PlayerState.bOnlySpectator then
        BattleResultProxy:SaveCachedPlayerInfo(PlayerState)
      end
    end
  end
  local AudioEvent
  local ResultType = GamePlayGlobal:GetResultType(self)
  if ResultType == GamePlayGlobal.ResultType.Victory then
    AudioEvent = self.AudioEvent_Win
  elseif ResultType == GamePlayGlobal.ResultType.Defeat then
    AudioEvent = self.AudioEvent_Fail
  else
    AudioEvent = self.AudioEvent_Draw
  end
  if AudioEvent then
    if self.playMusicTimer then
      self.playMusicTimer:EndTask()
      self.playMusicTimer = nil
    end
    self.playMusicTimer = TimerMgr:AddTimeTask(self.PlayMusicTime, 0, 0, function()
      self:K2_PostAkEvent(AudioEvent, false)
    end)
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.SelectRoleTeamPage)
end
function ResultTimeDilationPage_PC:OnClose()
  LogDebug("ResultTimeDilationPage_PC", "OnClose")
  UE4.UGameplayStatics.SetGlobalTimeDilation(self, 1)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  MyPlayerController.bAutoManageActiveCameraTarget = true
  MyPlayerController.PlayerCameraManager.bClientSimulatingViewTarget = false
  if self.playMusicTimer then
    self.playMusicTimer:EndTask()
    self.playMusicTimer = nil
  end
end
function ResultTimeDilationPage_PC:Tick(MyGeometry, InDeltaTime)
  self.DilationTime = self.DilationTime + InDeltaTime
  local DilationValue = self.Curve_TimeDilation:GetFloatValue(self.DilationTime)
  UE4.UGameplayStatics.SetGlobalTimeDilation(self, DilationValue)
  if not self.OpenVictoryDefeatPage and self.DilationTime >= self.OpenVictoryDefeatPageTime then
    local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
    if not battleResultProxy then
      return
    end
    ViewMgr:OpenPage(self, UIPageNameDefine.GameFinishPage)
    self.OpenVictoryDefeatPage = true
  end
end
return ResultTimeDilationPage_PC
