local ResultScoreListItem_PC = require("Business/BattleResult/ViewComponents/Common/ResultScoreListItem_PC")
local ResultTeamScoreListItem_PC = class("ResultTeamScoreListItem_PC", ResultScoreListItem_PC)
function ResultTeamScoreListItem_PC:Construct()
  LogDebug("ResultTeamScoreListItem_PC", "Construct ")
  ResultTeamScoreListItem_PC.super.Construct(self)
  self.PMTextBlock_Name:SetText("——")
  self.TextBlock_CompositeScore:SetText("——")
  self.TextBlock_Kill:SetText("——")
  self.TextBlock_Death:SetText("——")
  self.TextBlock_Assist:SetText("——")
  self.TextBlock_TotalDamage:SetText("——")
  self.Headicon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function ResultTeamScoreListItem_PC:Destruct()
  LogDebug("ResultTeamScoreListItem_PC", "Destruct")
  ResultTeamScoreListItem_PC.super.Construct(self)
end
function ResultTeamScoreListItem_PC:Update(PlayerState)
  LogDebug("ResultTeamScoreListItem_PC", "setInfo ")
  self.PlayerState = PlayerState
  ResultTeamScoreListItem_PC.super.Update(PlayerState)
  if not self.PlayerState then
    return
  end
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  self.WidgetSwitcher_ItemBg:SetActiveWidgetIndex(PlayerState.player_id == MyPlayerInfo.player_id and 1 or 0)
  local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(PlayerState.icon)
  if avatarIcon then
    self.Headicon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Headicon:SetBrushFromSoftTexture(avatarIcon)
  else
    LogError("ResultTeamScoreListItem_PC", "Player icon or config error")
  end
  self.PMTextBlock_Name:SetText(PlayerState.nick)
  self.WidgetSwitcher_MVP:SetActiveWidgetIndex(PlayerState.RealMvp)
  self.TextBlock_CompositeScore:SetText(math.floor(PlayerState.scores))
  self.TextBlock_TotalDamage:SetText(math.floor(PlayerState.damage))
  self.TextBlock_Kill:SetText(PlayerState.kill_num)
  self.TextBlock_Death:SetText(PlayerState.dead_num)
  self.TextBlock_Assist:SetText(PlayerState.assists_num)
  if self.PlayerState.player_id == MyPlayerInfo.player_id then
    self.PMTextBlock_Name:SetColorAndOpacity(self.TextColor_Self)
    self.TextBlock_CompositeScore:SetColorAndOpacity(self.TextColor_Self)
    self.TextBlock_TotalDamage:SetColorAndOpacity(self.TextColor_Self)
    self.TextBlock_Kill:SetColorAndOpacity(self.TextColor_Self)
    self.TextBlock_Death:SetColorAndOpacity(self.TextColor_Self)
    self.TextBlock_Assist:SetColorAndOpacity(self.TextColor_Self)
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.PMTextBlock_Name:SetColorAndOpacity(self.TextColor_Other)
    self.TextBlock_CompositeScore:SetColorAndOpacity(self.TextColor_Other)
    self.TextBlock_TotalDamage:SetColorAndOpacity(self.TextColor_Other)
    self.TextBlock_Kill:SetColorAndOpacity(self.TextColor_Other)
    self.TextBlock_Death:SetColorAndOpacity(self.TextColor_Other)
    self.TextBlock_Assist:SetColorAndOpacity(self.TextColor_Other)
    self.WidgetSwitcher_Priaise:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
return ResultTeamScoreListItem_PC
