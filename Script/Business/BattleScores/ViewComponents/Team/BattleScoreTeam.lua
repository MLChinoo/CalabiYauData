local BattleScoreTeam = class("BattleScoreTeam", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function BattleScoreTeam:Construct()
  BattleScoreTeam.super.Construct(self)
  self.BombTeam = -1
  self.UpdateInterval = 0.125
  self.Timelapse = 0
  self.MyTeamSorted = nil
  self.EnTeamSorted = nil
  self:TickPanel()
  if self.btn_screen_close then
    self.btn_screen_close.OnClicked:Add(self, self.OnExitButtonClicked)
  end
end
function BattleScoreTeam:Destruct()
  BattleScoreTeam.super.Destruct(self)
  if self.btn_screen_close then
    self.btn_screen_close.OnClicked:Remove(self, self.OnExitButtonClicked)
  end
end
function BattleScoreTeam:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.ScorePage)
end
function BattleScoreTeam:Tick(MyGeometry, InDeltaTime)
  if self.Timelapse < self.UpdateInterval then
    self.Timelapse = self.Timelapse + InDeltaTime
  else
    self.Timelapse = 0
    self:TickPanel()
  end
end
function BattleScoreTeam:TickPanel()
  local MyTeamScore, EnTeamScore = GamePlayGlobal:GetMatchScore(self)
  self.BlueTeamScore:SetText(MyTeamScore)
  self.RedTeamScore:SetText(EnTeamScore)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not self.MyTeamSorted or not self.EnTeamSorted then
    local MyTeam, EnTeam = GamePlayGlobal:GetTeam(self)
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
  if not self.TitleBlueColor then
    self.TitleBlueColor = UE4.FLinearColor(self.Border_MyTeam.BrushColor.R, self.Border_MyTeam.BrushColor.G, self.Border_MyTeam.BrushColor.B, self.Border_MyTeam.BrushColor.A)
    self.TitleRedColor = UE4.FLinearColor(self.Border_Enemy.BrushColor.R, self.Border_Enemy.BrushColor.G, self.Border_Enemy.BrushColor.B, self.Border_Enemy.BrushColor.A)
  end
  if self.TitleBlueColor then
    self.Border_MyTeam:SetBrushColor(1 == MyPlayerState.AttributeTeamID and self.TitleBlueColor or self.TitleRedColor)
    self.Border_Enemy:SetBrushColor(1 ~= MyPlayerState.AttributeTeamID and self.TitleBlueColor or self.TitleRedColor)
    self.BlueTeamScore:SetColorAndOpacity(1 == MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
    self.RedTeamScore:SetColorAndOpacity(1 ~= MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
    self.TextBlock_MyTeam:SetColorAndOpacity(1 == MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
    self.TextBlock_EnemyTeam:SetColorAndOpacity(1 ~= MyPlayerState.AttributeTeamID and self.TextColorBlue or self.TextColorRed)
  end
end
function BattleScoreTeam:UpdateTeamList(TeamListPanel, Team)
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomPlayerList = RoomProxy:GetRoomMemberList()
  if not roomPlayerList then
    LogDebug("roomPlayerList", "roomPlayerList is nil")
  end
  for i = 1, 5 do
    local PlayerPanel = TeamListPanel:GetChildAt(i - 1)
    local playerState = Team[i]
    PlayerPanel:Update(playerState)
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
return BattleScoreTeam
