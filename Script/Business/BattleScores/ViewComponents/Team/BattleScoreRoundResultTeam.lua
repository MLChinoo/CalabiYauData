local BattleScoreRoundResultTeam = class("BattleScoreRoundResultTeam", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local MaxTeamScore = 50
local ProgressInterpSpeed = 1
function BattleScoreRoundResultTeam:Construct()
  BattleScoreRoundResultTeam.super.Construct(self)
  self.BlueScore = 0
  self.RedScore = 0
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState.WinnerSparTarget then
    MaxTeamScore = GameState.WinnerSparTarget
  end
  if GameState.OnTeamTotalKillNumChanged then
    GameState.OnTeamTotalKillNumChanged:Add(self, self.HandleTeamKillNumChanged)
  end
  self:ResetScore()
  self.BlueProgressBar.WidgetStyle.FillImage = 1 == MyPlayerState.AttributeTeamID and self.BrushBlue or self.BrushRed
  self.RedProgressBar.WidgetStyle.FillImage = 1 ~= MyPlayerState.AttributeTeamID and self.BrushBlue or self.BrushRed
  self.BlueNum:SetColorAndOpacity(1 == MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
  self.RedNum:SetColorAndOpacity(1 ~= MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
end
function BattleScoreRoundResultTeam:Destruct()
  BattleScoreRoundResultTeam.super.Destruct(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState.OnTeamTotalKillNumChanged then
    GameState.OnTeamTotalKillNumChanged:Remove(self, self.HandleTeamKillNumChanged)
  end
end
function BattleScoreRoundResultTeam:Tick(MyGeometry, InDeltaTime)
  self:UpdateProgressBar(self.BlueProgressBar, self.BlueNum:GetParent(), InDeltaTime, self.BlueScore)
  self:UpdateProgressBar(self.RedProgressBar, self.RedNum:GetParent(), InDeltaTime, self.RedScore)
end
function BattleScoreRoundResultTeam:UpdateProgressBar(ProgressBar, ChildWidget, InDeltaTime, Current)
  local Percent = ProgressBar.Percent
  local Target = Current / MaxTeamScore
  if Percent < Target then
    local InterpSpeed = ProgressInterpSpeed
    Percent = UE4.UKismetMathLibrary.FInterpTo_Constant(Percent, Target, InDeltaTime, InterpSpeed)
    ProgressBar:SetPercent(Percent)
  elseif Target < Percent then
    ProgressBar:SetPercent(Target)
  end
end
function BattleScoreRoundResultTeam:HandleTeamKillNumChanged(TeamNum, KillNum)
  self:UpdateTeamScore(TeamNum, KillNum)
end
function BattleScoreRoundResultTeam:UpdateTeamScore(TeamNum, Score)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local MyTeamID = MyPlayerState.AttributeTeamID
  local UpdateScoreText = TeamNum == MyTeamID and self.BlueNum or self.RedNum
  UpdateScoreText:SetText(Score)
  if TeamNum == MyTeamID then
    self.BlueScore = Score
  else
    self.RedScore = Score
  end
end
function BattleScoreRoundResultTeam:ResetScore()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local MyTeamId = MyPlayerState.AttributeTeamID
  local EnTeamId = 1 - MyTeamId
  local MyTeamScore, EnTeamScore = GamePlayGlobal:GetMatchScore(self)
  self:UpdateTeamScore(MyTeamId, MyTeamScore)
  self:UpdateTeamScore(EnTeamId, EnTeamScore)
end
return BattleScoreRoundResultTeam
