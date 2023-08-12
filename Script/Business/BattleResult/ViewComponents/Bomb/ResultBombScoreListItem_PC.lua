local ResultScoreListItem_PC = require("Business/BattleResult/ViewComponents/Common/ResultScoreListItem_PC")
local ResultBombScoreListItem_PC = class("ResultBombScoreListItem_PC", ResultScoreListItem_PC)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function ResultBombScoreListItem_PC:Construct()
  LogDebug("ResultBombScoreListItem_PC", "Construct ")
  ResultBombScoreListItem_PC.super.Construct(self)
  self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(0)
  self.PMTextBlock_Name:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_CompositeScore:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_TotalDamage:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Kill:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Death:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Assist:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Rescue:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_PlaceBomb:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_RemoveBomb:SetColorAndOpacity(self.TextColor_Other)
  self.PMTextBlock_Name:SetText("——")
  self.TextBlock_CompositeScore:SetText("——")
  self.TextBlock_Kill:SetText("——")
  self.TextBlock_Death:SetText("——")
  self.TextBlock_Assist:SetText("——")
  self.TextBlock_TotalDamage:SetText("——")
  self.TextBlock_Rescue:SetText("——")
  self.TextBlock_PlaceBomb:SetText("——")
  self.TextBlock_RemoveBomb:SetText("——")
  self.PMTextBlock_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_CompositeScore:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Kill:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Death:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Assist:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_TotalDamage:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Rescue:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_PlaceBomb:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_RemoveBomb:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Head:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(2)
end
function ResultBombScoreListItem_PC:Update(PlayerState)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  self.PlayerState = PlayerState
  LogDebug("ResultBombScoreListItem_PC", "setInfo ")
  ResultBombScoreListItem_PC.super.Update(self, PlayerState)
  if not self.PlayerState then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  if BattleResultProxy.MyObTeamId then
    self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(0)
  else
    self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(PlayerState.player_id == MyPlayerInfo.player_id and 1 or 0)
  end
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local Role = RoleProxy:GetRole(self.PlayerState.final_role_id)
  if Role then
    local SkinRow = RoleProxy:GetRoleSkin(Role.RoleSkin)
    if SkinRow then
      self.Head:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Headicon:SetBrushFromSoftTexture(SkinRow.IconRoleScoreboard)
    else
      LogError("ResultBombScoreListItem_PC", "Get role skin table error, roleid=%s", self.PlayerState.final_role_id)
    end
  else
    LogError("ResultBombScoreListItem_PC", "Get role fail, roleid=%s", self.PlayerState.final_role_id)
  end
  self.PMTextBlock_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_CompositeScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Kill:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Death:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Assist:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_TotalDamage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Rescue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_PlaceBomb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_RemoveBomb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PMTextBlock_Name:SetText(PlayerState.nick)
  self.WidgetSwitcher_MVP:SetActiveWidgetIndex(PlayerState.RealMvp)
  if 1 == PlayerState.RealMvp then
    self:PlayAnimation(self.Ani_MVP, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  elseif 2 == PlayerState.RealMvp then
    self:PlayAnimation(self.Ani_SVP, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
  self.TextBlock_CompositeScore:SetText(math.floor(PlayerState.scores))
  self.TextBlock_TotalDamage:SetText(math.floor(PlayerState.damage))
  self.TextBlock_Kill:SetText(PlayerState.kill_num)
  self.TextBlock_Death:SetText(PlayerState.dead_num)
  self.TextBlock_Assist:SetText(PlayerState.assists_num)
  if SettleBattleGameData.bomb_win_turns ~= "" then
    self.TextBlock_Rescue:SetText(PlayerState.relive_num)
    self.TextBlock_PlaceBomb:SetText(PlayerState.place_bomb_num)
    self.TextBlock_RemoveBomb:SetText(PlayerState.remove_bomb_num)
  else
    self.TextBlock_Rescue:SetText("——")
    self.TextBlock_PlaceBomb:SetText("——")
    self.TextBlock_RemoveBomb:SetText("——")
  end
  if BattleResultProxy.MyObTeamId or self.PlayerState.player_id ~= MyPlayerInfo.player_id then
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
return ResultBombScoreListItem_PC
