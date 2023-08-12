local ResultScoreListPanelSpar = class("ResultScoreListPanelSpar", PureMVC.ViewComponentPanel)
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function ResultScoreListPanelSpar:Construct()
  LogDebug("ResultScoreListPanelSpar", "Construct " .. tostring(self))
  ResultScoreListPanelSpar.super.Construct(self)
  self:Update()
  self:PlayAnimation(self.NewAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function ResultScoreListPanelSpar:Update()
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.TextMapName:SetText(roomDataProxy:GetMapName(SettleBattleGameData.map_id))
  self.TextBlock_Mode:SetText(roomDataProxy:GetMapTypeName(SettleBattleGameData.map_id))
  local GameTime = SettleBattleGameData.fight_time
  self.TextTimeUsed:SetText(os.date("!%H:%M:%S", GameTime))
  self.WBP_Top_ScoreTitle.Text_Title:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "SparTopTeam"))
  self.WBP_Bottom_ScoreTitle.Text_Title:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "SparBottomTeam"))
  self.WBP_Bottom_ScoreTitle.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(0)
  local TopPlayerStates = {}
  local BottomPlayerStates = {}
  for key, PlayerInfo in pairs(SettleBattleGameData.players) do
    if 1 == PlayerInfo.team_id then
      table.insert(TopPlayerStates, PlayerInfo)
    else
      table.insert(BottomPlayerStates, PlayerInfo)
    end
  end
  for i = 1, 3 do
    if i <= table.count(TopPlayerStates) then
      self["WBP_Top_ScoreItem_" .. i]:Update(TopPlayerStates[i], i)
    end
  end
  for i = 1, 7 do
    if i <= table.count(BottomPlayerStates) then
      self["WBP_Bottom_ScoreItem_" .. i]:Update(BottomPlayerStates[i], i)
    end
  end
end
return ResultScoreListPanelSpar
