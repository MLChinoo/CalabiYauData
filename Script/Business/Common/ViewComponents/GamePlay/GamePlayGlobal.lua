local GamePlayGlobal = class("GamePlayGlobal")
GamePlayGlobal.ResultType = {}
GamePlayGlobal.ResultType.Victory = 1
GamePlayGlobal.ResultType.Defeat = 2
GamePlayGlobal.ResultType.Dogfall = 3
function GamePlayGlobal:GetGSAndFirstPCAndFirstPS(WorldContext)
  local GameState = UE4.UGameplayStatics.GetGameState(WorldContext)
  if not GameState then
    LogWarn("Get GameState fail")
  end
  local MyPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(WorldContext, 0)
  if not MyPlayerController then
    LogWarn("Get First PlayerContrller fail")
  end
  local MyPlayerState = MyPlayerController and MyPlayerController.PlayerState or nil
  if not MyPlayerState then
    LogWarn("Get First PlayerState fail")
  end
  return GameState, MyPlayerController, MyPlayerState
end
function GamePlayGlobal:GetMatchScore(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  return self:GetPlayerMatchScore(WorldContext, MyPlayerState)
end
function GamePlayGlobal:GetPlayerMatchScore(WorldContext, PlayerState)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not GameState.GetModeType then
    return
  end
  local Scores
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    Scores = GameState.TeamWinTurns
  elseif GameState:GetModeType() == UE4.EPMGameModeType.Spar then
    Scores = GameState.TeamSparNum
  else
    Scores = GameState.TeamScores
  end
  for i = 1, Scores:Length() do
    LogDebug("MatchScore", "%s=%s", i, Scores:Get(i))
  end
  local MyTeamId = PlayerState.AttributeTeamID
  local EnTeamId = 1 - MyTeamId
  local MyTeamScore = 0
  local EnTeamScore = 0
  if Scores:IsValidIndex(MyTeamId + 1) then
    MyTeamScore = Scores:Get(MyTeamId + 1)
  end
  if Scores:IsValidIndex(EnTeamId + 1) then
    EnTeamScore = Scores:Get(EnTeamId + 1)
  end
  return MyTeamScore, EnTeamScore
end
function GamePlayGlobal:GetTeamMatchScore(WorldContext, TeamId)
  local MatchScores = {}
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return MatchScores
  end
  if not GameState.GetModeType then
    return MatchScores
  end
  local Scores
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    Scores = GameState.TeamWinTurns
  elseif GameState:GetModeType() == UE4.EPMGameModeType.Spar then
    Scores = GameState.TeamSparNum
  else
    Scores = GameState.TeamScores
  end
  if not Scores then
    return MatchScores
  end
  local MyTeamId = TeamId
  if Scores:IsValidIndex(MyTeamId + 1) then
    table.insert(MatchScores, Scores:Get(MyTeamId + 1))
  end
  for i = 1, Scores:Length() do
    LogDebug("MatchScore", "%s=%s", i, Scores:Get(i))
    if i ~= MyTeamId + 1 then
      table.insert(MatchScores, Scores:Get(i))
    end
  end
  return MatchScores
end
function GamePlayGlobal:GetAttackDefenseScore(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not GameState.GetModeType then
    return
  end
  if GameState:GetModeType() ~= UE4.EPMGameModeType.Bomb then
    return
  end
  local Scores = GameState.TeamWinTurns
  for i = 1, Scores:Length() do
    LogDebug("MatchScore", "%s=%s", i, Scores:Get(i))
  end
  local AttackerTeamId = GameState.BombOwnerTeam
  local DefenseTeamId = 1 - AttackerTeamId
  local AttackScore = 0
  local DefenseScore = 0
  if Scores:IsValidIndex(AttackerTeamId + 1) then
    AttackScore = Scores:Get(AttackerTeamId + 1)
  end
  if Scores:IsValidIndex(DefenseTeamId + 1) then
    DefenseScore = Scores:Get(DefenseTeamId + 1)
  end
  return AttackScore, DefenseScore
end
function GamePlayGlobal:IsInValidPlayer(playerState)
  local PlayerPropertys = {
    "NumKills",
    "NumDeaths",
    "NumAssist",
    "TeamIndex",
    "NumKills",
    "NumKills",
    "NumKills"
  }
  if not playerState.NumKills then
    return true
  end
end
function GamePlayGlobal:GetTeam(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Spar then
    local Team = {}
    for i = 1, GameState.PlayerArray:Length() do
      local playerState = GameState.PlayerArray:Get(i)
      if not playerState.bOnlySpectator and 0 ~= playerState.SelectRoleId then
        table.insert(Team, playerState)
      end
    end
    return Team
  else
    local MyTeamId = MyPlayerState.AttributeTeamID
    local MyTeam = {}
    local EnTeam = {}
    for i = 1, GameState.PlayerArray:Length() do
      local playerState = GameState.PlayerArray:Get(i)
      if not playerState.bOnlySpectator and 0 ~= playerState.SelectRoleId then
        if playerState.AttributeTeamID == MyTeamId then
          table.insert(MyTeam, playerState)
        else
          table.insert(EnTeam, playerState)
        end
      end
    end
    return MyTeam, EnTeam
  end
end
function GamePlayGlobal:GetAttackDefenseTeam(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local AttackTeam = {}
  local DefenseTeam = {}
  for i = 1, GameState.PlayerArray:Length() do
    local playerState = GameState.PlayerArray:Get(i)
    if not playerState.bOnlySpectator and 0 ~= playerState.SelectRoleId then
      if playerState.AttributeTeamID == GameState.BombOwnerTeam then
        table.insert(AttackTeam, playerState)
      else
        table.insert(DefenseTeam, playerState)
      end
    end
  end
  return AttackTeam, DefenseTeam
end
function GamePlayGlobal:CreateWidget(widgetContext, WidgetClass, CurTimes, OnCreate)
  if CurTimes > 50 then
    OnCreate(nil)
    return
  end
  local Widget = UE4.UWidgetBlueprintLibrary.Create(widgetContext, WidgetClass)
  if not Widget then
    TimerMgr:AddTimeTask(0.1, 0, 1, function()
      self:CreateWidget(widgetContext, WidgetClass, CurTimes + 1, OnCreate)
    end)
  else
    OnCreate(Widget)
  end
end
function GamePlayGlobal:LuaHandleKeyEvent(worldContext, key, inputEvent)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("Scoreboard", arr)
  local keyNames = {}
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    if ele then
      table.insert(keyNames, UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
    end
  end
  local inputKeyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if table.index(keyNames, inputKeyName) then
    if inputEvent == UE4.EInputEvent.IE_Pressed then
      ViewMgr:OpenPage(worldContext, UIPageNameDefine.ScorePage)
    elseif inputEvent == UE4.EInputEvent.IE_Released then
      ViewMgr:HidePage(worldContext, UIPageNameDefine.ScorePage)
    end
    return true
  end
  return false
end
function GamePlayGlobal:GetResultType(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState.WinnerTeam < 0 then
    return self.ResultType.Dogfall
  end
  local TeamId = MyPlayerState.AttributeTeamID
  if MyPlayerState.bOnlySpectator then
    TeamId = MyPlayerController:GetCurrentSpectatorTeamId()
  end
  if GameState.WinnerTeam == TeamId or GameState.SecondWinnerTeam == TeamId then
    return self.ResultType.Victory
  else
    return self.ResultType.Defeat
  end
end
function GamePlayGlobal:GetTeamId(WorldContext)
  local GameState, MyPlayerController, MyPlayerState = self:GetGSAndFirstPCAndFirstPS(WorldContext)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local TeamId = MyPlayerState.AttributeTeamID
  if MyPlayerState.bOnlySpectator then
    TeamId = MyPlayerController:GetCurrentSpectatorTeamId()
  end
  return TeamId
end
return GamePlayGlobal
