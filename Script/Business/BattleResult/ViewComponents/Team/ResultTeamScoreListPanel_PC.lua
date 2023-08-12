local ResultTeamScoreListPanel_PC = class("ResultTeamScoreListPanel_PC", PureMVC.ViewComponentPanel)
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function ResultTeamScoreListPanel_PC:Construct()
  LogDebug("ResultTeamScoreListPanel_PC", "Construct ")
  ResultTeamScoreListPanel_PC.super.Construct(self)
  self:Update()
end
function ResultTeamScoreListPanel_PC:Destruct()
  LogDebug("ResultTeamScoreListPanel_PC", "Destruct ")
end
function ResultTeamScoreListPanel_PC:Update()
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  local MapTableRow = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy):GetMapTableRow(SettleBattleGameData.map_id)
  if MapTableRow then
    self.TextMapName:SetText(MapTableRow.Name)
  end
  local GameTime = SettleBattleGameData.fight_time
  self.TextTimeUsed:SetText(os.date("!%H:%M:%S", GameTime))
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local MyTeamNum = MyPlayerInfo.team_id
  local OtherTeamNum = 1 == MyTeamNum and 2 or 1
  local bIsMyTeamWin = SettleBattleGameData.winner_team_id == MyTeamNum
  local MyTeamPlayerStates = {}
  local OtherTeamPlayerStates = {}
  for key, PlayerInfo in pairs(SettleBattleGameData.players) do
    if MyTeamNum == PlayerInfo.team_id then
      table.insert(MyTeamPlayerStates, PlayerInfo)
    else
      table.insert(OtherTeamPlayerStates, PlayerInfo)
    end
  end
  self.TextBlock_Top_TeamScoreNum:SetText(SettleBattleGameData.scores[MyTeamNum] or 0)
  self.TextBlock_Bottom_TeamScoreNum:SetText(SettleBattleGameData.scores[OtherTeamNum] or 0)
  self.WBP_Top_ScoreTitle:SetTeam(true)
  self.WBP_Bottom_ScoreTitle:SetTeam(false)
  for i = 1, 5 do
    if i <= table.count(MyTeamPlayerStates) then
      self["WBP_Top_ScoreItem_" .. i]:Update(MyTeamPlayerStates[i])
    end
    if i <= table.count(OtherTeamPlayerStates) then
      self["WBP_Bottom_ScoreItem_" .. i]:Update(OtherTeamPlayerStates[i])
    end
  end
end
return ResultTeamScoreListPanel_PC
