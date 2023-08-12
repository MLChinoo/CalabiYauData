local BattleScoreSpar = class("BattleScoreSpar", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function BattleScoreSpar:Construct()
  BattleScoreSpar.super.Construct(self)
  self.UpdateInterval = 0.125
  self.Timelapse = 0
  self.NomalSort = false
  self.PeakMomentSort = false
  self:TickPanel()
end
function BattleScoreSpar:Tick(MyGeometry, InDeltaTime)
  if self.Timelapse < self.UpdateInterval then
    self.Timelapse = self.Timelapse + InDeltaTime
  else
    self.Timelapse = 0
    self:TickPanel()
  end
end
function BattleScoreSpar:TickPanel()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local CompareFunc = function(a, b)
    if a and b and a.SavedSparNum and b.SavedSparNum and a.AttributeTeamId and b.AttributeTeamId then
      if a.SavedSparNum ~= b.SavedSparNum then
        return a.SavedSparNum > b.SavedSparNum
      end
      return a.AttributeTeamId < b.AttributeTeamId
    end
    return false
  end
  if GameState.RunningSparState == UE4.ECySparState.PeakMoment then
    if not self.PeakMomentSort then
      self.PeakMomentSort = true
      self.TopList = {}
      local TopArray = GameState.TopPlayerData.TopPlayerArray
      for i = 1, TopArray:Length() do
        local ps = TopArray:Get(i)
        if not ps.bOnlySpectator and 0 ~= ps.SelectRoleId then
          table.insert(self.TopList, ps)
        end
      end
      if 0 == #self.TopList then
        LogDebug("BattleScoreSpar", "//GameState.RunningSparState == UE4.ECySparState.PeakMoment ,采矿王数组为空！！")
      end
      self.BottomList = {}
      for i = 1, GameState.PlayerArray:Length() do
        local ps = GameState.PlayerArray:Get(i)
        if not ps.bOnlySpectator and 0 ~= ps.SelectRoleId then
          local found = false
          for j = 1, #self.TopList do
            local topPS = self.TopList[j]
            if ps == topPS then
              found = true
              break
            end
          end
          if not found then
            table.insert(self.BottomList, ps)
          end
        end
      end
      table.sort(self.BottomList, CompareFunc)
      if self.WS_Title_Stage then
        self.WS_Title_Stage:SetActiveWidgetIndex(1)
      end
      if self.WS_ScoreTile_Bottom then
        self.WS_ScoreTile_Bottom:SetActiveWidgetIndex(1)
      end
      if self.Text_Top then
        self.Text_Top:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "SparTopTeam"))
      end
      if self.Text_Bottom then
        self.Text_Bottom:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "SparBottomTeam"))
      end
    end
    local sparCnt = 0
    for j = 1, #self.BottomList do
      local bottomPS = self.BottomList[j]
      sparCnt = sparCnt + bottomPS.SavedSparNum
    end
    if self.Text_SparNum then
      self.Text_SparNum:SetText(sparCnt)
    end
    self.isPeakMoment = true
  elseif not self.NomalSort then
    self.NomalSort = true
    local hightCnt = GameState:GetTopPlayerNum()
    self.TopList = {}
    self.BottomList = {}
    local psList = {}
    for i = 1, GameState.PlayerArray:Length() do
      local ps = GameState.PlayerArray:Get(i)
      if not ps.bOnlySpectator and 0 ~= ps.SelectRoleId then
        table.insert(psList, ps)
      end
    end
    table.sort(psList, CompareFunc)
    for j = 1, #psList do
      if j <= hightCnt then
        table.insert(self.TopList, psList[j])
      else
        table.insert(self.BottomList, psList[j])
      end
    end
  end
  self:UpdataItemtList(self.VB_TopList, self.TopList)
  self:UpdataItemtList(self.VB_BottomList, self.BottomList, #self.TopList)
end
function BattleScoreSpar:UpdataItemtList(ListPanel, Team, TopCnt)
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomPlayerList = RoomProxy:GetRoomMemberList()
  if not roomPlayerList then
    LogDebug("roomPlayerList", "roomPlayerList is nil")
  end
  if ListPanel then
    for i = 1, ListPanel:GetChildrenCount() do
      local playerPanel = ListPanel:GetChildAt(i - 1)
      local ps = Team[i]
      playerPanel:Update(ps)
      local showIndex = i
      if TopCnt then
        showIndex = showIndex + TopCnt
      end
      if self.isPeakMoment then
        showIndex = ""
      end
      playerPanel.RankText:SetText(showIndex)
      if ps then
        local ReadyState
        for key, value in pairs(roomPlayerList or {}) do
          if ps.UID == value.playerId then
            ReadyState = value.offline
            break
          end
        end
        playerPanel:UpdateConnectionState(ReadyState)
      end
    end
  end
end
return BattleScoreSpar
