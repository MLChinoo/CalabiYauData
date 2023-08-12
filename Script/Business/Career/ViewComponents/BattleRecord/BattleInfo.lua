local BattleInfoMediator = require("Business/Career/Mediators/BattleRecord/BattleInfoMediator")
local BattleInfo = class("BattleInfo", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function BattleInfo:ListNeededMediators()
  return {BattleInfoMediator}
end
function BattleInfo:Construct()
  BattleInfo.super.Construct(self)
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyID)
  end
  if self.ScrollBox_Team then
    self.teamInfoPanels = self.ScrollBox_Team:GetAllChildren()
  end
end
function BattleInfo:Destrcut()
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyID)
  end
  BattleInfo.super.Destruct(self)
end
function BattleInfo:UpdateInfoShown(roomInfo, battleInfo)
  if nil == roomInfo then
    return
  end
  if self.Image_Map and self.TextBlock_Map and roomInfo.map_id then
    local mapCfg = GameFacade:RetrieveProxy(ProxyNames.MapProxy):GetMapCfg(roomInfo.map_id)
    if mapCfg then
      self:SetImageByTexture2D_MatchSize(self.Image_Map, mapCfg.IconMapCareerTitle)
      self.TextBlock_Map:SetText(mapCfg.Name)
    else
      LogWarn("BattleInfo", "Map:%s config is missing", roomInfo.map_id)
    end
  end
  if self.TextBlock_Time and roomInfo.fight_time then
    local minute = math.floor(roomInfo.fight_time / 60)
    local second = roomInfo.fight_time % 60
    local minuteString = tostring(minute)
    local secondString = tostring(second)
    if minute < 10 then
      minuteString = "0" .. minuteString
    end
    if second < 10 then
      secondString = "0" .. secondString
    end
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "BattleDuration")
    local stringMap = {
      [0] = minuteString,
      [1] = secondString
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_Time:SetText(text)
  end
  if self.Text_RoomId then
    self.Text_RoomId:SetText(roomInfo.room_id)
  end
  local teamNum = 2
  local battleMode = CareerEnumDefine.BattleMode.None
  if roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_BOMB or roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_RANK_BOMB then
    battleMode = CareerEnumDefine.BattleMode.Bomb
  elseif roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM or roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_5V5V5 or roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_3V3V3 then
    battleMode = CareerEnumDefine.BattleMode.Team
    teamNum = 3
  elseif roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
    battleMode = CareerEnumDefine.BattleMode.Mine
  elseif roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM then
    if roomInfo.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_BOMB then
      battleMode = CareerEnumDefine.BattleMode.Bomb
    elseif roomInfo.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM or roomInfo.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM_5V5V5 or roomInfo.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM_3V3V3 then
      battleMode = CareerEnumDefine.BattleMode.Team
      teamNum = 3
    elseif roomInfo.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_MINE then
      battleMode = CareerEnumDefine.BattleMode.Mine
    end
  end
  if self.ReplayDownloadButton then
    self.ReplayDownloadButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if battleMode == CareerEnumDefine.BattleMode.Bomb then
      self.ReplayDownloadButton:InitView({
        room_id = roomInfo.room_id,
        map_id = roomInfo.map_id,
        end_time = roomInfo.time
      }, true)
      self.ReplayDownloadButton:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.teamInfoPanels and battleInfo and self.WidgetSwitcher_Mode then
    battleInfo.myTeam = roomInfo.my_team
    if battleMode == CareerEnumDefine.BattleMode.Mine and self.BattleInfo_Mine then
      local data = {
        battleMode = battleMode,
        myId = battleInfo.playerId,
        teamInfo = battleInfo.battlePlayersInfo,
        bIsRoom = roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM
      }
      self.BattleInfo_Mine:UpdateInfo(data)
      self.WidgetSwitcher_Mode:SetActiveWidgetIndex(1)
      return
    end
    local panelNum = self.teamInfoPanels:Length()
    local teamsInfo = {}
    for i = 1, teamNum do
      teamsInfo[i] = {}
    end
    for key, value in pairs(battleInfo.battlePlayersInfo) do
      if nil == teamsInfo[value.team_id] then
        teamsInfo[value.team_id] = {}
      end
      table.insert(teamsInfo[value.team_id], value)
    end
    local panelIndex = 1
    local bHasCamp = false
    if battleMode == CareerEnumDefine.BattleMode.Bomb then
      bHasCamp = true
    end
    local bDraw = 0 == #roomInfo.winner_team
    for key, value in pairsByKeys(teamsInfo, function(a, b)
      return a < b
    end) do
      if panelNum >= panelIndex then
        local data = {
          score = roomInfo.scores[key],
          battleMode = battleMode,
          myId = battleInfo.playerId,
          bMyTeam = battleInfo.myTeam == key,
          campId = bHasCamp and (key == roomInfo.attack_camp_id and 1 or 2) or 0,
          teamInfo = value,
          bIsRoom = roomInfo.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM,
          winType = bDraw and CareerEnumDefine.winType.draw or table.containsValue(roomInfo.winner_team, key) and CareerEnumDefine.winType.win or CareerEnumDefine.winType.lose,
          drawMVPTeam = battleInfo.bestPlayerTeam
        }
        self.teamInfoPanels:Get(panelIndex):UpdateTeamInfo(data)
        self.teamInfoPanels:Get(panelIndex):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        panelIndex = panelIndex + 1
      end
    end
    if panelNum >= panelIndex then
      for i = panelIndex, panelNum do
        self.teamInfoPanels:Get(panelIndex):SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.WidgetSwitcher_Mode:SetActiveWidgetIndex(0)
  end
end
function BattleInfo:OnClickCopyID()
  if self.Text_RoomId then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(self.Text_RoomId:GetText())
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "CopyRoomId")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
return BattleInfo
