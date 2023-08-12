local BattleScoreBomb = class("BattleScoreBomb", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local BattleScoreDefine = require("Business/BattleScores/Proxies/BattleScoresDefine")
function BattleScoreBomb:Construct()
  BattleScoreBomb.super.Construct(self)
  self.BombTeam = -1
  self.UpdateInterval = 0.125
  self.Timelapse = 0
  self.MyTeamSorted = nil
  self.EnTeamSorted = nil
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
function BattleScoreBomb:Destruct()
  BattleScoreBomb.super.Destruct(self)
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
function BattleScoreBomb:UpdateOpUI()
  if self.switch_jubao and self.switch_voice and self.switch_friend then
    self.switch_jubao:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxJuBao and 1 or 0)
    self.switch_voice:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxVoice and 1 or 0)
    self.switch_friend:SetActiveWidgetIndex(self.OpIdx == BattleScoreDefine.OpIdxFriend and 1 or 0)
  end
end
function BattleScoreBomb:OnClickOpJuBao()
  self.OpIdx = BattleScoreDefine.OpIdxJuBao
  self:UpdateOpUI()
end
function BattleScoreBomb:OnClickOpVoice()
  self.OpIdx = BattleScoreDefine.OpIdxVoice
  self:UpdateOpUI()
end
function BattleScoreBomb:OnClickOpFriend()
  self.OpIdx = BattleScoreDefine.OpIdxFriend
  self:UpdateOpUI()
end
function BattleScoreBomb:Tick(MyGeometry, InDeltaTime)
  if self.Timelapse < self.UpdateInterval then
    self.Timelapse = self.Timelapse + InDeltaTime
  else
    self.Timelapse = 0
    self:TickPanel()
  end
end
function BattleScoreBomb:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.ScorePage)
end
function BattleScoreBomb:TickPanel()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not self.MyTeamSorted or not self.EnTeamSorted then
    local MyTeam, EnTeam = {}, {}
    if MyPlayerState.bOnlySpectator then
      local AttackScore, DefenseScore = GamePlayGlobal:GetAttackDefenseScore(self)
      local IsFirstHalf = AttackScore + DefenseScore < 8
      if IsFirstHalf then
        EnTeam, MyTeam = GamePlayGlobal:GetAttackDefenseTeam(self)
      else
        MyTeam, EnTeam = GamePlayGlobal:GetAttackDefenseTeam(self)
      end
    else
      MyTeam, EnTeam = GamePlayGlobal:GetTeam(self)
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
    table.sort(EnTeam, CompareFunc)
    self.MyTeamSorted = MyTeam
    self.EnTeamSorted = EnTeam
  end
  self:UpdateTeamList(self.BlueTeamList, self.MyTeamSorted)
  self:UpdateTeamList(self.RedTeamList, self.EnTeamSorted)
  self:UpdateTeamInfo()
  local MyTeamScore, EnTeamScore = 0, 0
  if MyPlayerState.bOnlySpectator then
    local AttackScore, DefenseScore = GamePlayGlobal:GetAttackDefenseScore(self)
    local IsFirstHalf = AttackScore + DefenseScore < 8
    if IsFirstHalf then
      MyTeamScore, EnTeamScore = DefenseScore, AttackScore
    else
      MyTeamScore, EnTeamScore = AttackScore, DefenseScore
    end
  else
    MyTeamScore, EnTeamScore = GamePlayGlobal:GetMatchScore(self)
  end
  self.BlueTeamScore:SetText(MyTeamScore)
  self.RedTeamScore:SetText(EnTeamScore)
end
function BattleScoreBomb:UpdateTeamList(TeamListPanel, Team)
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomPlayerList = RoomProxy:GetRoomMemberList()
  if not roomPlayerList then
    LogDebug("roomPlayerList", "roomPlayerList is nil")
  end
  for i = 1, 5 do
    local PlayerPanel = TeamListPanel:GetChildAt(i - 1)
    local playerState = Team[i]
    PlayerPanel:SetOpIdx(self.OpIdx)
    PlayerPanel:Update(playerState)
    if playerState and playerState:IsValid() then
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
function BattleScoreBomb:UpdateTeamInfo()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if MyPlayerState.IsOnlyASpectator then
  end
  if self.BombTeam ~= GameState.BombOwnerTeam then
    self.BombTeam = GameState.BombOwnerTeam
    local MyText, EnemyText = "", ""
    local bIsDefenseTeam = true
    if MyPlayerState.bOnlySpectator then
      local AttackScore, DefenseScore = GamePlayGlobal:GetAttackDefenseScore(self)
      local IsFirstHalf = AttackScore + DefenseScore < 8
      if IsFirstHalf then
        bIsDefenseTeam = true
        MyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "DefenderPlace")
        EnemyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "AttackerPlace")
      else
        bIsDefenseTeam = false
        MyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "AttackerPlace")
        EnemyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "DefenderPlace")
      end
    else
      MyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "MineTeam")
      EnemyText = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "EnemyTeam")
      bIsDefenseTeam = MyPlayerState.AttributeTeamID ~= self.BombTeam
    end
    local DefenseTeamName = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Opal")
    local AttackTeamName = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "handssors")
    self.TextBlock_MyTeamName:SetText(bIsDefenseTeam and DefenseTeamName or AttackTeamName)
    self.TextBlock_EnemyTeamName:SetText(not bIsDefenseTeam and DefenseTeamName or AttackTeamName)
    self.MyTeamIcon:SetBrush(bIsDefenseTeam and self.BlueIconBrush or self.RedIconBrush)
    self.EnTeamIcon:SetBrush(not bIsDefenseTeam and self.BlueIconBrush or self.RedIconBrush)
    self.BlueTeamScore:SetColorAndOpacity(bIsDefenseTeam and self.TextColorBlue or self.TextColorRed)
    self.RedTeamScore:SetColorAndOpacity(not bIsDefenseTeam and self.TextColorBlue or self.TextColorRed)
    self.MyTeamText:SetColorAndOpacity(bIsDefenseTeam and self.TextColorBlue or self.TextColorRed)
    self.EnTeamText:SetColorAndOpacity(not bIsDefenseTeam and self.TextColorBlue or self.TextColorRed)
    self.MyTeamText:SetText(MyText)
    self.EnTeamText:SetText(EnemyText)
    self.MyTeamTitleBG:SetBrushColor(bIsDefenseTeam and self.BlueColor or self.RedColor)
    self.EnTeamTitleBG:SetBrushColor(not bIsDefenseTeam and self.BlueColor or self.RedColor)
  end
end
return BattleScoreBomb
