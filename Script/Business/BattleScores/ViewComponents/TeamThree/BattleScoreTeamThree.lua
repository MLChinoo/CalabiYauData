local BattleScoreTeamThree = class("BattleScoreTeamThree", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local BattleScoreDefine = require("Business/BattleScores/Proxies/BattleScoresDefine")
function BattleScoreTeamThree:Construct()
  BattleScoreTeamThree.super.Construct(self)
  self.BombTeam = -1
  self.UpdateInterval = 0.125
  self.Timelapse = 0
  self.MyTeamSorted = nil
  self.EnTeamSorted1 = nil
  self.EnTeamSorted2 = nil
  self:TickPanel()
  if self.Txt_ModeName then
    local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
    if not (GameState and MyPlayerController) or not MyPlayerState then
      return
    end
    local BattleScoresProxy = GameFacade:RetrieveProxy(ProxyNames.BattleScoresProxy)
    self.Txt_ModeName:SetText(string.format("%s-%s", BattleScoresProxy:GetMapName(GameState.MapId), BattleScoresProxy:GetMapTypeName(GameState.MapId)))
  end
  if self.btn_screen_close then
    self.btn_screen_close.OnClicked:Add(self, self.OnExitButtonClicked)
  end
  if self.btn_close then
    self.btn_close.OnClicked:Add(self, self.OnExitButtonClicked)
  end
  if not self.OpIdx then
    self.OpIdx = BattleScoreDefine.OpIdxVoice
    self:UpdateOpUI()
  end
  if self.btn_jubao then
    self.btn_jubao.OnClicked:Add(self, self.OnClickOpJuBao)
  end
  if self.btn_voice then
    self.btn_voice.OnClicked:Add(self, self.OnClickOpVoice)
  end
  if self.btn_friend then
    self.btn_friend.OnClicked:Add(self, self.OnClickOpFriend)
  end
end
function BattleScoreTeamThree:Destruct()
  BattleScoreTeamThree.super.Destruct(self)
  if self.btn_screen_close then
    self.btn_screen_close.OnClicked:Remove(self, self.OnExitButtonClicked)
  end
  if self.btn_close then
    self.btn_close.OnClicked:Remove(self, self.OnExitButtonClicked)
  end
  if self.btn_jubao then
    self.btn_jubao.OnClicked:Remove(self, self.OnClickOpJuBao)
  end
  if self.btn_voice then
    self.btn_voice.OnClicked:Remove(self, self.OnClickOpVoice)
  end
  if self.btn_friend then
    self.btn_friend.OnClicked:Remove(self, self.OnClickOpFriend)
  end
end
function BattleScoreTeamThree:UpdateOpUI()
  if self.switch_jubao and self.switch_voice and self.switch_friend then
    self.switch_jubao:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxJuBao and 1 or 0)
    self.switch_voice:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxVoice and 1 or 0)
    self.switch_friend:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxFriend and 1 or 0)
  end
end
function BattleScoreTeamThree:OnClickOpJuBao()
  self.OpIdx = BattleScoreDefine.OpIdxJuBao
  self:UpdateOpUI()
end
function BattleScoreTeamThree:OnClickOpVoice()
  self.OpIdx = BattleScoreDefine.OpIdxVoice
  self:UpdateOpUI()
end
function BattleScoreTeamThree:OnClickOpFriend()
  self.OpIdx = BattleScoreDefine.OpIdxFriend
  self:UpdateOpUI()
end
function BattleScoreTeamThree:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.ScorePage)
end
function BattleScoreTeamThree:Tick(MyGeometry, InDeltaTime)
  if self.Timelapse < self.UpdateInterval then
    self.Timelapse = self.Timelapse + InDeltaTime
  else
    self.Timelapse = 0
    self:TickPanel()
  end
end
function BattleScoreTeamThree:TickPanel()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local MyTeamId = MyPlayerState.AttributeTeamID
  local EnemyTeamId1, EnemyTeamId2
  for i = 0, 2 do
    if i ~= MyTeamId then
      if not EnemyTeamId1 then
        EnemyTeamId1 = i
      else
        EnemyTeamId2 = EnemyTeamId2 or i
      end
    end
  end
  local Scores = GameState.TeamScores
  self.MyTeamScore:SetText(Scores:Get(MyTeamId + 1))
  self.EnemyTeamScore1:SetText(Scores:Get(EnemyTeamId1 + 1))
  self.EnemyTeamScore2:SetText(Scores:Get(EnemyTeamId2 + 1))
  if not self.MyTeamSorted or not self.EnTeamSorted1 then
    local MyTeam = {}
    local EnTeam1 = {}
    local EnTeam2 = {}
    for i = 1, GameState.PlayerArray:Length() do
      local playerState = GameState.PlayerArray:Get(i)
      if not playerState.bOnlySpectator and 0 ~= playerState.SelectRoleId then
        if playerState.AttributeTeamID == MyTeamId then
          table.insert(MyTeam, playerState)
        elseif playerState.AttributeTeamID == EnemyTeamId1 then
          table.insert(EnTeam1, playerState)
        else
          table.insert(EnTeam2, playerState)
        end
      end
    end
    local CompareFunc = function(a, b)
      if a and b and a.NumKills and b.NumKills and a.NumDeaths and b.NumDeaths and a.NumAssist and b.NumAssist and a.TeamIndex and b.TeamIndex then
        if a.NumKills ~= b.NumKills then
          return a.NumKills > b.NumKills
        end
        if a.NumDeaths ~= b.NumDeaths then
          return a.NumDeaths < b.NumDeaths
        end
        if a.NumAssist ~= b.NumAssist then
          return a.NumAssist > b.NumAssist
        end
        return a.TeamIndex < b.TeamIndex
      end
      return false
    end
    table.sort(MyTeam, CompareFunc)
    table.sort(EnTeam1, CompareFunc)
    table.sort(EnTeam2, CompareFunc)
    self.MyTeamSorted = MyTeam
    self.EnTeamSorted1 = EnTeam1
    self.EnTeamSorted2 = EnTeam2
    local TeamNameChar = {
      [0] = "A",
      [1] = "B",
      [2] = "C"
    }
    local MyTeamName = "我方队伍"
    local EnemyTeamName = "敌方队伍"
    self.Text_TeamName1:SetText(MyTeamName)
    self.Text_TeamName2:SetText(EnemyTeamName)
    self.Text_TeamName3:SetText(EnemyTeamName)
  end
  self:UpdateTeamList(self.MyTeamList, self.MyTeamSorted)
  self:UpdateTeamList(self.EnemyTeamList1, self.EnTeamSorted1)
  self:UpdateTeamList(self.EnemyTeamList2, self.EnTeamSorted2)
  self.MyTeamScore:SetColorAndOpacity(self.TextColorBlue)
  self.EnemyTeamScore1:SetColorAndOpacity(self.TextColorRed)
  self.EnemyTeamScore2:SetColorAndOpacity(self.TextColorRed)
end
function BattleScoreTeamThree:UpdateTeamList(TeamListPanel, Team)
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomPlayerList = RoomProxy:GetRoomMemberList()
  if not roomPlayerList then
    LogDebug("roomPlayerList", "roomPlayerList is nil")
  end
  for i = 1, 5 do
    local PlayerPanel = TeamListPanel:GetChildAt(i - 1)
    local playerState = Team[i]
    if PlayerPanel then
      PlayerPanel:SetOpIdx(self.OpIdx)
      PlayerPanel:Update(playerState)
    end
    if playerState then
      local ReadyState
      for key, value in pairs(roomPlayerList or {}) do
        if playerState.UID == value.playerId then
          ReadyState = value.offline
          break
        end
      end
      PlayerPanel:UpdateConnectionState(ReadyState)
    end
  end
end
return BattleScoreTeamThree
