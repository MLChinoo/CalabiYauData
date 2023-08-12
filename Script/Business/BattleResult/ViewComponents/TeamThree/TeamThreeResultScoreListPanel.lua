local TeamThreeResultScoreListPanel = class("TeamThreeResultScoreListPanel", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function TeamThreeResultScoreListPanel:Construct()
  LogDebug("TeamThreeResultScoreListPanel", "Construct " .. tostring(self))
  TeamThreeResultScoreListPanel.super.Construct(self)
  self:Update()
end
function TeamThreeResultScoreListPanel:Update()
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.TextMapName:SetText(roomDataProxy:GetMapName(SettleBattleGameData.map_id))
  self.TextBlock_Mode:SetText(roomDataProxy:GetMapTypeName(SettleBattleGameData.map_id))
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  local GameTime = SettleBattleGameData.fight_time
  self.TextTimeUsed:SetText(os.date("!%H:%M:%S", GameTime))
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local MyTeamId = MyPlayerInfo.team_id
  local TeamId1 = 1
  local TeamId2 = 2
  local TeamId3 = 3
  local PlayerStates1 = {}
  local PlayerStates2 = {}
  local PlayerStates3 = {}
  for key, PlayerInfo in pairs(SettleBattleGameData.players) do
    if TeamId1 == PlayerInfo.team_id then
      table.insert(PlayerStates1, PlayerInfo)
    elseif TeamId2 == PlayerInfo.team_id then
      table.insert(PlayerStates2, PlayerInfo)
    elseif TeamId3 == PlayerInfo.team_id then
      table.insert(PlayerStates3, PlayerInfo)
    end
  end
  self.Txt_Score_1:SetText(SettleBattleGameData.scores[TeamId1] or 0)
  self.Txt_Score_2:SetText(SettleBattleGameData.scores[TeamId2] or 0)
  self.Txt_Score_3:SetText(SettleBattleGameData.scores[TeamId3] or 0)
  self.Switcher_TeamBg_1:SetActiveWidgetIndex(TeamId1 == MyTeamId and 0 or 1)
  self.Switcher_TeamBg_2:SetActiveWidgetIndex(TeamId2 == MyTeamId and 0 or 1)
  self.Switcher_TeamBg_3:SetActiveWidgetIndex(TeamId3 == MyTeamId and 0 or 1)
  if BattleResultProxy:IsDraw() then
    self.Swither_ResultType_1:SetActiveWidgetIndex(0)
    self.Swither_ResultType_2:SetActiveWidgetIndex(0)
    self.Swither_ResultType_3:SetActiveWidgetIndex(0)
  else
    self.Swither_ResultType_1:SetActiveWidgetIndex(BattleResultProxy:IsWinnerTeam(TeamId1) and 0 or 1)
    self.Swither_ResultType_2:SetActiveWidgetIndex(BattleResultProxy:IsWinnerTeam(TeamId2) and 0 or 1)
    self.Swither_ResultType_3:SetActiveWidgetIndex(BattleResultProxy:IsWinnerTeam(TeamId3) and 0 or 1)
  end
  self.WBP_ScoreTitle_1.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(TeamId1 == MyTeamId and 1 or 0)
  self.WBP_ScoreTitle_2.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(TeamId2 == MyTeamId and 1 or 0)
  self.WBP_ScoreTitle_3.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(TeamId3 == MyTeamId and 1 or 0)
  local TeamNameChar = {
    [1] = "A",
    [2] = "B",
    [3] = "C"
  }
  local MyTeamName = "我方队伍"
  local EnemyTeamName = "敌方队伍"
  self.WBP_ScoreTitle_1.Text_TeamName:SetText(string.format("%s%s", TeamId1 == MyTeamId and MyTeamName or EnemyTeamName, TeamNameChar[TeamId1]))
  self.WBP_ScoreTitle_2.Text_TeamName:SetText(string.format("%s%s", TeamId2 == MyTeamId and MyTeamName or EnemyTeamName, TeamNameChar[TeamId2]))
  self.WBP_ScoreTitle_3.Text_TeamName:SetText(string.format("%s%s", TeamId3 == MyTeamId and MyTeamName or EnemyTeamName, TeamNameChar[TeamId3]))
  for i = 1, 5 do
    if i <= table.count(PlayerStates1) and self["WBP_Top_ScoreItem_" .. i] then
      self["WBP_Top_ScoreItem_" .. i]:Update(PlayerStates1[i], true)
    end
    if i <= table.count(PlayerStates2) and self["WBP_Other_ScoreItem1_" .. i] then
      self["WBP_Other_ScoreItem1_" .. i]:Update(PlayerStates2[i], true)
    end
    if i <= table.count(PlayerStates3) and self["WBP_Other_ScoreItem2_" .. i] then
      self["WBP_Other_ScoreItem2_" .. i]:Update(PlayerStates3[i], true)
    end
  end
end
return TeamThreeResultScoreListPanel
