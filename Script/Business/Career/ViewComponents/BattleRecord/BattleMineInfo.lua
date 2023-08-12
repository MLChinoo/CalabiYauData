local BattleMineInfo = class("BattleMineInfo", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local teamLessId = 1
local teamMoreId = 2
function BattleMineInfo:ListNeededMediators()
  return {}
end
function BattleMineInfo:UpdateInfo(data)
  local selfTeamId
  local team1 = {}
  local team2 = {}
  for key, value in pairs(data.teamInfo) do
    if value.team_id == teamLessId then
      table.insert(team1, value)
    end
    if value.team_id == teamMoreId then
      table.insert(team2, value)
    end
    if value.player_id == data.myId then
      selfTeamId = value.team_id
    end
  end
  if self.WidgetSwitcher_TeamBg_Top then
    self.WidgetSwitcher_TeamBg_Top:SetActiveWidgetIndex(selfTeamId == teamLessId and 1 or 0)
  end
  if self.WidgetSwitcher_TeamBg_Down then
    self.WidgetSwitcher_TeamBg_Down:SetActiveWidgetIndex(selfTeamId == teamLessId and 0 or 1)
  end
  if self.BattleTitle_Up and self.BattleTitle_Down then
    if self.BattleInfo_Title_Top then
      self.BattleInfo_Title_Top:SetTitle(CareerEnumDefine.BattleMode.Mine, self.BattleTitle_Up)
    end
    if self.BattleInfo_Title_Down then
      self.BattleInfo_Title_Down:SetTitle(CareerEnumDefine.BattleMode.Mine, self.BattleTitle_Down)
    end
  end
  local sortTeamInfo = function(t1, t2)
    if t1.scores and t2.scores and t1.scores ~= t2.scores then
      return t1.scores > t2.scores
    end
    if t1.damage and t2.damage and t1.damage ~= t2.damage then
      return t1.damage > t2.damage
    end
    if t1.kill_num and t2.kill_num and t1.kill_num ~= t2.kill_num then
      return t1.kill_num > t2.kill_num
    end
    if t1.dead_num and t2.dead_num and t1.dead_num ~= t2.dead_num then
      return t1.dead_num < t2.dead_num
    end
    if t1.player_id and t2.player_id and t1.player_id ~= t2.player_id then
      return tonumber(t1.player_id) < tonumber(t2.player_id)
    end
    return false
  end
  local playerCnt = 0
  for key, value in pairsByKeys(team1, function(a, b)
    return sortTeamInfo(team1[a], team1[b])
  end) do
    playerCnt = playerCnt + 1
    if self.playerDataPanels1[playerCnt] then
      self.playerDataPanels1[playerCnt]:SetInfoItemData(data.battleMode, data.myId, value, data.bIsRoom)
      self.playerDataPanels1[playerCnt]:ShowInfo(true)
    end
  end
  if playerCnt < table.count(self.playerDataPanels1) then
    for i = playerCnt + 1, table.count(self.playerDataPanels1) do
      self.playerDataPanels1[i]:ShowInfo(false)
    end
  end
  playerCnt = 0
  for key, value in pairsByKeys(team2, function(a, b)
    return sortTeamInfo(team2[a], team2[b])
  end) do
    playerCnt = playerCnt + 1
    if self.playerDataPanels2[playerCnt] then
      self.playerDataPanels2[playerCnt]:SetInfoItemData(data.battleMode, data.myId, value, data.bIsRoom)
      self.playerDataPanels2[playerCnt]:ShowInfo(true)
    end
  end
  if playerCnt < table.count(self.playerDataPanels2) then
    for i = playerCnt + 1, table.count(self.playerDataPanels2) do
      self.playerDataPanels2[i]:ShowInfo(false)
    end
  end
end
function BattleMineInfo:Construct()
  BattleMineInfo.super.Construct(self)
  if self.Button_Score_Up then
    self.Button_Score_Up.OnHovered:Add(self, self.OnHoverScoreUp)
    self.Button_Score_Up.OnUnhovered:Add(self, self.OnUnhoverScoreUp)
  end
  if self.MenuAnchor_Score_Up then
    self.MenuAnchor_Score_Up.OnGetMenuContentEvent:Bind(self, self.InitScoreTipUp)
  end
  if self.Button_Score_Down then
    self.Button_Score_Down.OnHovered:Add(self, self.OnHoverScoreDown)
    self.Button_Score_Down.OnUnhovered:Add(self, self.OnUnhoverScoreDown)
  end
  if self.MenuAnchor_Score_Down then
    self.MenuAnchor_Score_Down.OnGetMenuContentEvent:Bind(self, self.InitScoreTipDown)
  end
  self.playerDataPanels1 = {}
  self.playerDataPanels2 = {}
  if self.VB_Win then
    local panels = self.VB_Win:GetAllChildren()
    if panels:Length() > 0 then
      for i = 1, panels:Length() do
        table.insert(self.playerDataPanels1, panels:Get(i))
      end
    end
  end
  if self.VB_Lose then
    local panels = self.VB_Lose:GetAllChildren()
    if panels:Length() > 0 then
      for i = 1, panels:Length() do
        table.insert(self.playerDataPanels2, panels:Get(i))
      end
    end
  end
end
function BattleMineInfo:Destruct()
  if self.Button_Score_Up then
    self.Button_Score_Up.OnHovered:Remove(self, self.OnHoverScoreUp)
    self.Button_Score_Up.OnUnhovered:Remove(self, self.OnUnhoverScoreUp)
  end
  if self.MenuAnchor_Score_Up then
    self.MenuAnchor_Score_Up.OnGetMenuContentEvent:Unbind()
  end
  if self.Button_Score_Down then
    self.Button_Score_Down.OnHovered:Remove(self, self.OnHoverScoreDown)
    self.Button_Score_Down.OnUnhovered:Remove(self, self.OnUnhoverScoreDown)
  end
  if self.MenuAnchor_Score_Down then
    self.MenuAnchor_Score_Down.OnGetMenuContentEvent:Unbind()
  end
  BattleMineInfo.super.Destruct(self)
end
function BattleMineInfo:OnHoverScoreUp()
  if self.MenuAnchor_Score_Up then
    self.MenuAnchor_Score_Up:Open(true)
  end
end
function BattleMineInfo:OnUnhoverScoreUp()
  if self.MenuAnchor_Score_Up then
    self.MenuAnchor_Score_Up:Close()
  end
end
function BattleMineInfo:OnHoverScoreDown()
  if self.MenuAnchor_Score_Down then
    self.MenuAnchor_Score_Down:Open(true)
  end
end
function BattleMineInfo:OnUnhoverScoreDown()
  if self.MenuAnchor_Score_Down then
    self.MenuAnchor_Score_Down:Close()
  end
end
function BattleMineInfo:InitScoreTipUp()
  local scoreTipIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Score_Up.MenuClass)
  if scoreTipIns then
    local standingInfo = GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):GetRoomStanding()
    if standingInfo and standingInfo.map_id then
      scoreTipIns:SetTipType(standingInfo.map_id)
    end
    return scoreTipIns
  end
  return nil
end
function BattleMineInfo:InitScoreTipDown()
  local scoreTipIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Score_Down.MenuClass)
  if scoreTipIns then
    local standingInfo = GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):GetRoomStanding()
    if standingInfo and standingInfo.map_id then
      scoreTipIns:SetTipType(standingInfo.map_id)
    end
    return scoreTipIns
  end
  return nil
end
return BattleMineInfo
