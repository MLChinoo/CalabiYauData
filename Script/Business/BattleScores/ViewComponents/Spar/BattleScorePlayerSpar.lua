local BattleScorePlayer = require("Business/BattleScores/ViewComponents/Common/BattleScorePlayer")
local BattleScorePlayerSpar = class("BattleScorePlayerSparBomb", BattleScorePlayer)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local DeadIconOpacity = 0.3
local MemberBGDefault = 0
local MemberBGBlue = 1
local MemberBGRed = 2
local MemberBGDead = 3
local MemberBGSelf = 4
function BattleScorePlayerSpar:Reset()
  BattleScorePlayerSpar.super.Reset(self)
  self.RankText:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function BattleScorePlayerSpar:UpdatePlayer()
  BattleScorePlayerSpar.super.UpdatePlayer(self)
  self.RankText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateSparNum()
end
function BattleScorePlayerSpar:UpdateSparNum()
  self.ChargeText:SetText(self.PlayerState.SavedSparNum)
end
function BattleScorePlayerSpar:UpdateSlotStyle()
  if not self.PlayerState then
    return
  end
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local bIsLocalControlly = false
  if self.PlayerState.GetOwner and self.PlayerState:GetOwner() == MyPlayerState then
    bIsLocalControlly = true
  elseif self.PlayerState.PawnPrivate and self.PlayerState.PawnPrivate.IsLocallyControlled then
    bIsLocalControlly = self.PlayerState.PawnPrivate:IsLocallyControlled()
  end
  local MyTeamNum = MyPlayerState.AttributeTeamID
  local bIsFriendly = bIsLocalControlly or self.PlayerState.AttributeTeamID == MyTeamNum
  local bIsAlive = true
  if self.PlayerState.PawnPrivate and self.PlayerState.PawnPrivate.IsAlive then
    bIsAlive = self.PlayerState.PawnPrivate:IsAlive(false)
  else
    bIsAlive = false
  end
  local TextStyle = self.TextColorNormal
  if bIsLocalControlly then
    TextStyle = bIsAlive and self.TextColorSelf or self.TextColorDead
  else
    TextStyle = bIsAlive and self.TextColorNormal or self.TextColorDead
  end
  self.PlayerNameText:SetColorAndOpacity(TextStyle)
  self.ChargeText:SetColorAndOpacity(TextStyle)
  self.DamageText:SetColorAndOpacity(TextStyle)
  self.PingText:SetColorAndOpacity(TextStyle)
  self.KdaText:SetColorAndOpacity(TextStyle)
  self.ImageDeath:SetVisibility(bIsAlive and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ImageRole:SetOpacity(bIsAlive and 1.0 or DeadIconOpacity)
  local bBlueBrush = bIsFriendly
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    bBlueBrush = self.PlayerState.AttributeTeamID ~= GameState.BombOwnerTeam
  elseif 3 == GameState.DefaultNumTeams then
    bBlueBrush = self.PlayerState.AttributeTeamID == MyTeamNum
  else
    bBlueBrush = 1 == self.PlayerState.AttributeTeamID
  end
  if bIsLocalControlly then
    self.WidgetSwitcher_Bg:SetActiveWidgetIndex(MemberBGSelf)
    if self.GrowthBg then
      self.GrowthBg:SetColorAndOpacity(self.GrowthBgColorSelf)
    end
  else
    self.WidgetSwitcher_Bg:SetActiveWidgetIndex(bIsAlive and MemberBGRed or MemberBGDead)
    if self.GrowthBg then
      self.GrowthBg:SetColorAndOpacity(bIsAlive and (bBlueBrush and self.GrowthBgColorBlue or self.GrowthBgColorRed) or self.GrowthBgColorDead)
    end
  end
end
return BattleScorePlayerSpar
