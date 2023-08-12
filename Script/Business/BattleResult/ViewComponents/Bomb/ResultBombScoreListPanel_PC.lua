local ResultBombScoreListPanel_PC = class("ResultBombScoreListPanel_PC", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function ResultBombScoreListPanel_PC:Construct()
  LogDebug("ResultBombScoreListPanel_PC", "Construct " .. tostring(self))
  ResultBombScoreListPanel_PC.super.Construct(self)
  self:Update()
  self:PlayAnimation(self.NewAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function ResultBombScoreListPanel_PC:Update()
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
  local MyTeamNum = MyPlayerInfo.team_id
  local OtherTeamNum = 1 == MyTeamNum and 2 or 1
  local bIsMyTeamAttack = SettleBattleGameData.attack_camp_id == MyTeamNum
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
  if SettleBattleGameData.bomb_win_turns ~= "" then
    self.WidgetSwitcher_Top_TeamBg:SetActiveWidgetIndex(bIsMyTeamAttack and 0 or 1)
    self.WidgetSwitcher_Bottom_TeamBg:SetActiveWidgetIndex(not bIsMyTeamAttack and 0 or 1)
  else
    self.WidgetSwitcher_Top_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 1 or 0)
    self.WidgetSwitcher_Bottom_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 0 or 1)
  end
  if BattleResultProxy:IsDraw() then
    self.WidgetSwitcher_Top_WinOrFail:SetActiveWidgetIndex(0)
    self.WidgetSwitcher_Bottom_WinOrFail:SetActiveWidgetIndex(0)
  else
    self.WidgetSwitcher_Top_WinOrFail:SetActiveWidgetIndex(BattleResultProxy:IsWinnerTeam(MyTeamNum) and 0 or 1)
    self.WidgetSwitcher_Bottom_WinOrFail:SetActiveWidgetIndex(BattleResultProxy:IsWinnerTeam(OtherTeamNum) and 0 or 1)
  end
  self.WBP_Top_ScoreTitle:SetTeam(bIsMyTeamAttack, true)
  self.WBP_Bottom_ScoreTitle:SetTeam(not bIsMyTeamAttack, false)
  for i = 1, 5 do
    if i <= table.count(MyTeamPlayerStates) then
      self["WBP_Top_ScoreItem_" .. i]:Update(MyTeamPlayerStates[i], true)
    end
    if i <= table.count(OtherTeamPlayerStates) then
      self["WBP_Bottom_ScoreItem_" .. i]:Update(OtherTeamPlayerStates[i], true)
    end
  end
end
return ResultBombScoreListPanel_PC
