local BattleRecordDataProxy = class("BattleRecordDataProxy", PureMVC.Proxy)
local battleList = {}
local battleInfoMap = {}
local reqBattleInfoRoomId = 0
function BattleRecordDataProxy:OnRegister()
  LogDebug("BattleRecordDataProxy", "Register Battle Record Data Proxy")
  BattleRecordDataProxy.super.OnRegister(self)
  self.targetPlayerId = 0
  self.tempStandingsList = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIST_RES, FuncSlot(self.OnResBattleRecord, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STANDINGS_INFO_RES, FuncSlot(self.OnResBattleInfo, self))
  end
end
function BattleRecordDataProxy:OnRemove()
  battleList = {}
  battleInfoMap = {}
  reqBattleInfoRoomId = 0
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIST_RES, FuncSlot(self.OnResBattleRecord, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STANDINGS_INFO_RES, FuncSlot(self.OnResBattleInfo, self))
  end
  BattleRecordDataProxy.super.OnRemove(self)
end
function BattleRecordDataProxy:OnResBattleRecord(data)
  LogDebug("BattleRecordDataProxy", "On receive standings list")
  local standingsList = pb.decode(Pb_ncmd_cs_lobby.standings_list_res, data)
  if 0 ~= standingsList.code then
    return
  end
  for _, value in pairs(standingsList.titles) do
    battleList[value.room_id] = value
    table.insert(self.tempStandingsList, value)
  end
  if 0 ~= self.targetPlayerId then
    for _, value in pairs(standingsList.titles) do
      if table.containsValue(value.teams, self.targetPlayerId) then
        self:JumpToBattleRecord(standingsList.titles, value.room_id)
      end
    end
    self.targetPlayerId = 0
    return
  end
  GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.RequireRecordData, standingsList.titles)
end
function BattleRecordDataProxy:JumpToBattleRecord(standingTitles, roomId)
  for key, value in pairs(standingTitles) do
    if value.room_id == roomId then
      self:ReqBattleInfo(value.room_id)
      local battleShown = {standings = standingTitles, selectedBattle = value}
      GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.HasAvailableRecord, battleShown)
      local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
      if platform == GlobalEnumDefine.EPlatformType.Mobile then
        ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.BattleRecordPage, battleShown, true)
      else
        local body = {
          target = UIPageNameDefine.BattleRecordPage,
          exData = battleShown
        }
        GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, body)
      end
      return
    end
  end
  GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.NoAvailableRecord)
end
function BattleRecordDataProxy:ReqBattleRecord(pageIndex, playerId)
  LogDebug("BattleRecordDataProxy", "Request battle record, page: " .. pageIndex)
  self.tempStandingsList = {}
  local data = {
    player_id = playerId or 0,
    index = pageIndex
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIST_REQ, pb.encode(Pb_ncmd_cs_lobby.standings_list_req, data))
end
function BattleRecordDataProxy:OnResBattleInfo(data)
  LogDebug("BattleRecordDataProxy", "On receive battle info")
  local battleInfo = pb.decode(Pb_ncmd_cs_lobby.standings_info_res, data)
  LogDebug("BattleRecordDataProxy", TableToString(battleInfo))
  if 0 == battleInfo.code and battleInfo.standings then
    local roomId = battleInfo.room_id or reqBattleInfoRoomId
    reqBattleInfoRoomId = roomId
    battleInfoMap[roomId] = battleInfo.standings.players
  end
  GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.OnResBattleInfoCmd, battleInfoMap[reqBattleInfoRoomId], battleInfo.code)
end
function BattleRecordDataProxy:ReqBattleInfo(roomId, playerId)
  LogDebug("BattleRecordDataProxy", "Require battle info")
  reqBattleInfoRoomId = roomId
  if battleInfoMap[roomId] then
    GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.OnResBattleInfoCmd, battleInfoMap[roomId], 0)
    return
  end
  local data = {
    player_id = playerId or 0,
    room_id = roomId
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_STANDINGS_INFO_REQ, pb.encode(Pb_ncmd_cs_lobby.standings_info_req, data))
end
function BattleRecordDataProxy:GetRoomStanding()
  return battleList[reqBattleInfoRoomId]
end
function BattleRecordDataProxy:GetRecentBattleRecord(targetPlayerId)
  self.targetPlayerId = targetPlayerId
  self:ReqBattleRecord(1)
end
function BattleRecordDataProxy:ShowBattleRecord(roomId)
  if battleList[roomId] then
    self:JumpToBattleRecord(self.tempStandingsList, roomId)
  else
    GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.NoAvailableRecord)
  end
end
return BattleRecordDataProxy
