local BattleScorePlayer = require("Business/BattleScores/ViewComponents/Common/BattleScorePlayer")
local BattleScorePlayerBomb = class("BattleScorePlayerBomb", BattleScorePlayer)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function BattleScorePlayerBomb:Reset()
  BattleScorePlayerBomb.super.Reset(self)
  self.SaveText:SetText("")
  self.BombIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function BattleScorePlayerBomb:UpdatePlayer()
  BattleScorePlayerBomb.super.UpdatePlayer(self)
  self:UpdateBombOwner()
  self:UpdateSave(self.PlayerState.RescueCount)
  self:UpdateGrowth()
end
function BattleScorePlayerBomb:UpdateGrowth()
  local func = function()
    if not self.PlayerState then
      return
    end
    self.CanvasPanel_Growth:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.PlayerState.SelectRoleId <= 0 then
      self.WeaponPartLv:SetText("0")
      self.SkillLv:SetText("0")
      self.Shield:SetText("0")
    else
      local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
      self.WeaponPartLv:SetText(GrowthProxy:GetWeaponPartMaxLvNum(self.PlayerState))
      self.SkillLv:SetText(GrowthProxy:GetSkillMaxLvNum(self.PlayerState))
      self.Shield:SetText(GrowthProxy:GetShieldMaxLvNum(self.PlayerState))
    end
    self.CanvasPanel_Growth:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.PlayerState.GrowthComponent and self.PlayerState.GrowthComponent.IsArousalActivating then
      local WakeSkillActive1 = self.PlayerState.GrowthComponent:IsArousalActivating(1)
      local WakeSkillActive2 = self.PlayerState.GrowthComponent:IsArousalActivating(2)
      local WakeSkillActive3 = self.PlayerState.GrowthComponent:IsArousalActivating(3)
      self.growth_arrow:SetVisibility((WakeSkillActive1 or WakeSkillActive2 or WakeSkillActive3) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
      self.Overlay_WakeSkill1:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.Overlay_WakeSkill2:SetVisibility(UE4.ESlateVisibility.Hidden)
      local idx = 1
      if WakeSkillActive1 then
        self["Overlay_WakeSkill" .. idx]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self["WakeSkill" .. idx]:SetText(1)
        idx = idx + 1
      end
      if WakeSkillActive2 then
        self["Overlay_WakeSkill" .. idx]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self["WakeSkill" .. idx]:SetText(2)
        idx = idx + 1
      end
      if (not WakeSkillActive1 or not WakeSkillActive2) and WakeSkillActive3 then
        self["Overlay_WakeSkill" .. idx]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self["WakeSkill" .. idx]:SetText(3)
        idx = idx + 1
      end
    end
  end
  pcall(func)
end
function BattleScorePlayerBomb:UpdateSave(Value)
  self.SaveText:SetText(Value)
end
function BattleScorePlayerBomb:UpdateSlotStyle()
  BattleScorePlayerBomb.super.UpdateSlotStyle(self)
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
  local bIsAlive = true
  if self.PlayerState.PawnPrivate and self.PlayerState.PawnPrivate.IsAlive then
    bIsAlive = self.PlayerState.PawnPrivate:IsAlive(false)
  else
    bIsAlive = false
  end
  local TextStyle = bIsLocalControlly and self.TextColorSelf or bIsAlive and self.TextColorNormal or self.TextColorDead
  self.SaveText:SetColorAndOpacity(TextStyle)
end
function BattleScorePlayerBomb:UpdateBombOwner()
  if not self.PlayerState then
    return
  end
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.PlayerState.TeamIndex and MyPlayerState.AttributeTeamID and self.PlayerState.AttributeTeamID then
    if GameState.GetModeType and GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
      if MyPlayerState.AttributeTeamID == GameState.BombOwnerTeam then
        local bIsBombKeeper = self.PlayerState.AttributeTeamID == GameState.BombOwnerTeam and self.PlayerState.TeamIndex == GameState.BombOwnerPlayerIndex
        self.BombIcon:SetVisibility(bIsBombKeeper and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
      else
        self.BombIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.BombIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function BattleScorePlayerBomb:UpdateChargeText(CurrentValue, MaxValue)
  if self.ChargeText then
    local Current = math.floor(CurrentValue)
    local Max = math.floor(MaxValue)
    if Current < Max or 0 == Max then
      self.ChargeText:SetText(string.format("%s / %s", Current, Max))
    else
      self.ChargeText:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "FullCharge"))
    end
  end
end
return BattleScorePlayerBomb
