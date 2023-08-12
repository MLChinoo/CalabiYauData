local TeamApplyAndInviteProxy = class("TeamApplyAndInviteProxy", PureMVC.Proxy)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function TeamApplyAndInviteProxy:OnRegister()
  self.teamApplyAndInviteStack = {}
  self.refuseApplyIDs = {}
  self.refuseInviteIDs = {}
  self.teamApplyCache = {}
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_NTF, FuncSlot(self.OnNtfTeamApply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_NTF, FuncSlot(self.OnNtfTeamInvite, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_REPLY_NTF, FuncSlot(self.OnNtfTeamReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_REPLY_RES, FuncSlot(self.OnResTeamReply, self))
end
function TeamApplyAndInviteProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_NTF, FuncSlot(self.OnNtfTeamApply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_NTF, FuncSlot(self.OnNtfTeamInvite, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_REPLY_NTF, FuncSlot(self.OnNtfTeamReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_REPLY_RES, FuncSlot(self.OnResTeamReply, self))
end
function TeamApplyAndInviteProxy:OnNtfTeamApply(data)
  local team_apply_ntf = DeCode(Pb_ncmd_cs_lobby.team_apply_ntf, data)
  if team_apply_ntf.player_id and GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsShieldList(team_apply_ntf.player_id) then
    return
  end
  if self.refuseApplyIDs then
    for key, value in pairs(self.refuseApplyIDs) do
      if value and team_apply_ntf.player_id == value.PlayerID then
        LogDebug("OnNtfTeamApply", "current player is refuse,PlayerID：%s", value.PlayerID)
        return
      end
    end
  end
  self:UpdateTeamApplyInfo(team_apply_ntf)
end
function TeamApplyAndInviteProxy:ReqTeamApplyReply(team_id, ReplyID, sure)
  local team_apply_reply_req = {}
  team_apply_reply_req.team_id = team_id
  team_apply_reply_req.player_id = ReplyID
  team_apply_reply_req.sure = sure
  SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_REQ, pb.encode(Pb_ncmd_cs_lobby.team_apply_reply_req, team_apply_reply_req))
end
function TeamApplyAndInviteProxy:OnResTeamReply(data)
  local team_reply_res = DeCode(Pb_ncmd_cs_lobby.team_reply_res, data)
  if 0 ~= team_reply_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, team_reply_res.code)
  end
end
function TeamApplyAndInviteProxy:OnNtfTeamInvite(data)
  local teamInvite_ntf = DeCode(Pb_ncmd_cs_lobby.team_invite_ntf, data)
  if teamInvite_ntf.player_id and GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsShieldList(teamInvite_ntf.player_id) then
    return
  end
  teamInvite_ntf.InviteType = RoomEnum.InviteType.Team
  if self.refuseInviteIDs then
    for key, value in pairs(self.refuseInviteIDs) do
      if value and teamInvite_ntf.player_id == value.PlayerID then
        LogDebug("TeamApplyAndInviteProxy:OnNtfTeamInvite", "current player is refuse,PlayerID：%s", value.PlayerID)
        return
      end
    end
  end
  local arg1 = UE4.FFormatArgumentData()
  arg1.ArgumentName = "0"
  arg1.ArgumentValue = teamInvite_ntf.nick
  arg1.ArgumentValueType = 4
  local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
  inArgsTarry:Add(arg1)
  local playerInviteYouText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PlayerInviteYou")
  playerInviteYouText = UE4.UKismetTextLibrary.Format(playerInviteYouText, inArgsTarry)
  GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, playerInviteYouText)
  self:UpdateTeamApplyInfo(teamInvite_ntf)
end
function TeamApplyAndInviteProxy:UpdateTeamApplyInfo(teamApplyInfo)
  if table.count(self.teamApplyAndInviteStack) >= 9 then
    LogDebug("TeamApplyAndInviteProxy:UpdateTeamApplyInfo", "TeamApplyer Num already > 8")
    return
  end
  local applyData = {}
  table.insert(self.teamApplyAndInviteStack, teamApplyInfo)
  applyData.DataIndex = table.index(self.teamApplyAndInviteStack, teamApplyInfo)
  applyData.AppleyData = teamApplyInfo
  local gamestate = LuaGetWorld().GameState
  if gamestate and gamestate.GetModeType and gamestate:GetModeType() ~= UE4.EPMGameModeType.FrontEnd then
    local func = function()
      GameFacade:SendNotification(NotificationDefines.ShowPlayerApplyTeamPopPageCmd, applyData)
    end
    self:RecordTeamApplyInfo(func)
  else
    GameFacade:SendNotification(NotificationDefines.ShowPlayerApplyTeamPopPageCmd, applyData)
  end
end
function TeamApplyAndInviteProxy:RecordTeamApplyInfo(func)
  table.insert(self.teamApplyCache, func)
end
function TeamApplyAndInviteProxy:ShowTeamApplyInfo()
  for i, v in ipairs(self.teamApplyCache) do
    if type(v) == "function" then
      v()
    end
  end
  self.teamApplyCache = {}
end
function TeamApplyAndInviteProxy:ReqTeamReply(team_id, invite_uid, sure)
  local team_reply_req = {}
  team_reply_req.team_id = team_id
  team_reply_req.player_id = invite_uid
  team_reply_req.sure = sure
  local req = pb.encode(Pb_ncmd_cs_lobby.team_reply_req, team_reply_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_REPLY_REQ, req)
end
function TeamApplyAndInviteProxy:ReqRoomReply(RoomId, InviteID, Pos, bReply)
  local room_reply_req = {}
  room_reply_req.room_id = RoomId
  room_reply_req.invite_id = InviteID
  room_reply_req.pos = Pos
  room_reply_req.reply = bReply
  local req = pb.encode(Pb_ncmd_cs_lobby.room_reply_req, room_reply_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_ROOM_REPLY_REQ, req)
end
function TeamApplyAndInviteProxy:ReqRoomApply(RoomId, playerId)
  local room_apply_req = {}
  room_apply_req.room_id = RoomId
  room_apply_req.player_id = playerId
  local req = pb.encode(Pb_ncmd_cs_lobby.room_apply_req, room_apply_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_ROOM_APPLY_REQ, req)
end
function TeamApplyAndInviteProxy:ReqRoomApplyReply(RoomId, PlayerId, bSure)
  local team_apply_reply_req = {}
  team_apply_reply_req.team_id = RoomId
  team_apply_reply_req.player_id = PlayerId
  team_apply_reply_req.sure = bSure
  local req = pb.encode(Pb_ncmd_cs_lobby.team_apply_reply_req, team_apply_reply_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_REQ, req)
end
function TeamApplyAndInviteProxy:OnTeamApplyReplyNtfCallback(inReply)
  if inReply.sure == RoomEnum.TeamMemberStatusType.NotReady then
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RefuseApplyDCText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function TeamApplyAndInviteProxy:OnNtfTeamReply(data)
  local team_reply_ntf = DeCode(Pb_ncmd_cs_lobby.team_reply_ntf, data)
  if 1 == team_reply_ntf.sure then
    local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "TeamInvitePlayerSuccedTips")
    local stringMap = {
      [0] = playerAttrProxy:GetPlayerNick(),
      [1] = team_reply_ntf.nick
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  end
end
function TeamApplyAndInviteProxy:StartAutoRefuseApply(playerID)
  local autoRefuseInviteAndApplyData = {}
  autoRefuseInviteAndApplyData.PlayerID = playerID
  autoRefuseInviteAndApplyData.Time = 300
  table.insert(self.refuseApplyIDs, autoRefuseInviteAndApplyData)
  LogDebug("TeamApplyAndInviteProxy", "StartAutoRefuseApply PlayerID: %s", playerID)
  self.refuseApplyTimer = TimerMgr:AddTimeTask(1, 1, 0, function()
    self:RefuseApplyTime()
  end)
end
function TeamApplyAndInviteProxy:RefuseApplyTime()
  local num = table.count(self.refuseApplyIDs)
  for index = 1, num do
    local value = self.refuseApplyIDs[index]
    if value then
      if value.Time > 0 then
        value.Time = value.Time - 1
        LogDebug("TeamApplyAndInviteProxy", "RefuseApplyTime Time is %s", value.Time)
      else
        self.refuseApplyIDs[index] = nil
      end
    end
  end
  num = table.count(self.refuseApplyIDs)
  if 0 == num then
    LogDebug("TeamApplyAndInviteProxy", "refuseApplyIDs num is 0 ,stop refuseApplyTimer")
    self.refuseApplyTimer:EndTask()
    self.refuseApplyTimer = nil
  end
end
function TeamApplyAndInviteProxy:StartAutoRefuseInvite(playerID)
  local autoRefuseInviteAndApplyData = {}
  autoRefuseInviteAndApplyData.PlayerID = playerID
  autoRefuseInviteAndApplyData.Time = 300
  table.insert(self.refuseInviteIDs, autoRefuseInviteAndApplyData)
  LogDebug("TeamApplyAndInviteProxy", "StartAutoRefuseInvite PlayerID: %s", playerID)
  self.refuseInviteTimer = TimerMgr:AddTimeTask(1, 1, 0, function()
    self:RefuseInviteTime()
  end)
end
function TeamApplyAndInviteProxy:RefuseInviteTime()
  local num = table.count(self.refuseInviteIDs)
  for index = 1, num do
    local value = self.refuseInviteIDs[index]
    if value then
      if value.Time > 0 then
        value.Time = value.Time - 1
        LogDebug("TeamApplyAndInviteProxy:RefuseInviteTime", "RefuseInviteTime Time is %s", value.Time)
      else
        self.refuseInviteIDs[index] = nil
      end
    end
  end
  num = table.count(self.refuseInviteIDs)
  if 0 == num then
    LogDebug("TeamApplyAndInviteProxy", "refuseInviteIDs num is 0 ,stop refuseInviteTimer")
    self.refuseInviteTimer:EndTask()
    self.refuseInviteTimer = nil
  end
end
function TeamApplyAndInviteProxy:ClearAllTeamApply()
  self.teamApplyAndInviteStack = {}
end
function TeamApplyAndInviteProxy:RemoveApplyStack(index)
  LogDebug("TeamApplyAndInviteProxy:RemoveApplyStack", "Remove Index:%s", index)
  local data = self.teamApplyAndInviteStack[index]
  if data then
    self.teamApplyAndInviteStack[index] = nil
  end
end
return TeamApplyAndInviteProxy
