local ResultScoreListItem_PC = require("Business/BattleResult/ViewComponents/Common/ResultScoreListItem_PC")
local ResultScoreListItemSpar = class("ResultScoreListItemSpar", ResultScoreListItem_PC)
function ResultScoreListItemSpar:Construct()
  LogDebug("ResultScoreListItemSpar", "Construct ")
  ResultScoreListItemSpar.super.Construct(self)
  self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(0)
  self.PMTextBlock_Name:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_CompositeScore:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_TotalDamage:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Kill:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Death:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_Assist:SetColorAndOpacity(self.TextColor_Other)
  self.TextBlock_SparNum:SetColorAndOpacity(self.TextColor_Other)
  self.PMTextBlock_Name:SetText("——")
  self.TextBlock_CompositeScore:SetText("——")
  self.TextBlock_Kill:SetText("——")
  self.TextBlock_Death:SetText("——")
  self.TextBlock_Assist:SetText("——")
  self.TextBlock_TotalDamage:SetText("——")
  self.TextBlock_SparNum:SetText("——")
  self.PMTextBlock_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_CompositeScore:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Kill:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Death:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_Assist:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_TotalDamage:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBlock_SparNum:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Head:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(2)
  self.TextRank:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Idx = 1
end
function ResultScoreListItemSpar:Update(PlayerState, Idx)
  self.Idx = Idx
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  self.PlayerState = PlayerState
  LogDebug("ResultScoreListItemSpar", "setInfo ")
  ResultScoreListItemSpar.super.Update(self, PlayerState)
  if not self.PlayerState then
    return
  end
  self.TextRank:SetText("")
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
      LogError("ResultScoreListItemSpar", "Get role skin table error, roleid=%s", self.PlayerState.final_role_id)
    end
  else
    LogError("ResultScoreListItemSpar", "Get role fail, roleid=%s", self.PlayerState.final_role_id)
  end
  self.PMTextBlock_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_CompositeScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Kill:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Death:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_Assist:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_TotalDamage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_SparNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
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
  self.TextBlock_SparNum:SetText(PlayerState.mine)
  if BattleResultProxy.MyObTeamId or self.PlayerState.player_id ~= MyPlayerInfo.player_id then
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
return ResultScoreListItemSpar
