local ResultTeamScoreListTitle_PC = class("ResultTeamScoreListTitle_PC", PureMVC.ViewComponentPanel)
function ResultTeamScoreListTitle_PC:SetTeam(bInIsMyTeam)
  LogDebug("ResultTeamScoreListTitle_PC", "SetTeam")
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  if SettleBattleGameData.bomb_win_turns ~= "" then
    if bInIsMyTeam then
      self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(MyPlayerInfo.team_id == SettleBattleGameData.attack_camp_id and 1 or 0)
    else
      self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(MyPlayerInfo.team_id == SettleBattleGameData.attack_camp_id and 0 or 1)
    end
  elseif bInIsMyTeam then
    self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 1 or 0)
  else
    self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 0 or 1)
  end
end
return ResultTeamScoreListTitle_PC
