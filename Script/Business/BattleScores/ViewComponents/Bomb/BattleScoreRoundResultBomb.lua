local BattleScoreRoundResultBomb = class("BattleScoreRoundResultBomb", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function BattleScoreRoundResultBomb:OnInitialized()
  BattleScoreRoundResultBomb.super.OnInitialized(self)
  self:Reset()
end
function BattleScoreRoundResultBomb:Construct()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  self:OnRoundResultChanged(GameState.RoundResult)
end
function BattleScoreRoundResultBomb:Reset()
  if self.BlueIconBrush:Length() > 0 then
    local Default = self.BlueIconBrush:Get(1)
    for i = 1, 32 do
      self["Image_" .. i]:SetBrush(Default)
    end
  end
end
function BattleScoreRoundResultBomb:OnRoundResultChanged(MatchRoundResults)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not MatchRoundResults then
    return
  end
  self:Reset()
  local RedTeamNum = GameState.BombOwnerTeam
  local MyTeamID = MyPlayerState.AttributeTeamID
  if MyPlayerState.bOnlySpectator then
    local AttackScore, DefenseScore = GamePlayGlobal:GetAttackDefenseScore(self)
    local IsFirstHalf = AttackScore + DefenseScore < 8
    if IsFirstHalf then
      MyTeamID = 1 - RedTeamNum
    else
      MyTeamID = RedTeamNum
    end
  end
  for i = 1, MatchRoundResults:Length() do
    local RoundResult = MatchRoundResults:Get(i)
    local IconBrush = RedTeamNum ~= RoundResult.WonTeam and self.BlueIconBrush or self.RedIconBrush
    local BrushIndex = RoundResult.Result
    local Icon = MyTeamID == RoundResult.WonTeam and self["Image_" .. i] or self["Image_" .. i + 16]
    if Icon and IconBrush:IsValidIndex(BrushIndex + 1) then
      Icon:SetBrush(IconBrush:Get(BrushIndex + 1))
    end
  end
end
function BattleScoreRoundResultBomb:OnBombOwnerTeamChanged(GameState)
  self:OnRoundResultChanged(GameState.RoundResult)
end
return BattleScoreRoundResultBomb
