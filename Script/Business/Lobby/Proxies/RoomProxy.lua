local RoomProxy = class("RoomProxy", PureMVC.Proxy)
local friendDataProxy, gameModeSelectProxy, VoiceManager
local LogInfo = _G.LogInfo
local FuncSlot = _G.FuncSlot
local Pb_ncmd_cs = _G.Pb_ncmd_cs
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function RoomProxy:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RoomProxy:OnRegister()
  self.super.OnRegister(self)
  self:InitParameters()
  self:RegistResponses()
  self.NetworkStateStringList = {}
end
function RoomProxy:GetNetworkStateStringList(NetworkStateImgList)
  if #self.NetworkStateStringList > 0 then
    return self.NetworkStateStringList
  else
    self.NetworkStateStringList = {}
    for key, value in pairs(NetworkStateImgList) do
      local str = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(value)
      LogDebug("RoomProxy", "NetworkStateStringList[%d] = %s", key, str)
      table.insert(self.NetworkStateStringList, str)
    end
    return self.NetworkStateStringList
  end
end
function RoomProxy:RegistResponses()
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MATCH_COMPLETE_NTF, FuncSlot(self.OnNtfMatchResult, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_NTF, FuncSlot(self.OnNtfRoomSwitch, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_NTF, FuncSlot(self.OnNtfTeamTransLeader, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_INFO_NTF, FuncSlot(self.OnNtfTeamInfo, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_NTF, FuncSlot(self.OnNtfTeamExit, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_NTF, FuncSlot(self.OnNtfTeamKick, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_NTF, FuncSlot(self.OnNtfMemberEnter, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_NTF, FuncSlot(self.OnNtfTeamReady, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MATCH_JOIN_RES, FuncSlot(self.OnResJoinMatch, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MATCH_JOIN_NTF, FuncSlot(self.OnNtfMatchJoin, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MATCH_QUIT_RES, FuncSlot(self.OnResQuitMatch, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MATCH_QUIT_NTF, FuncSlot(self.OnNtfMatchQuit, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ENTER_BATTLE_NTF, FuncSlot(self.OnNtfStartGame, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_NTF, FuncSlot(self.OnNtfTeamMode, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_RES, FuncSlot(self.OnResTeamApplyReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_NTF, FuncSlot(self.OnNtfTeamApplyReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PENALTY_TIME_NTF, FuncSlot(self.OnNtfPenaltyTime, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_RES, FuncSlot(self.OnResTeamExit, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_READY_CONFIRM_RES, FuncSlot(self.OnResReadyConfirm, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_READY_CONFIRM_NTF, FuncSlot(self.OnNtfReadyConfirm, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_RES, FuncSlot(self.OnResTeamInvite, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_QUIT_BATTLE_NTF, FuncSlot(self.OnNtfQuitBattle, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_CREATE_RES, FuncSlot(self.OnResTeamCreate, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_RES, FuncSlot(self.OnResTeamRobot, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_RES, FuncSlot(self.OnResTeamSwitch, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_BEGIN_RES, FuncSlot(self.OnResTeamBegin, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_PRACTICE_RES, FuncSlot(self.OnResTeamEnterPractice, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_PRACTICE_NTF, FuncSlot(self.OnNtfTeamEnterPractice, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_LEAVE_PRACTICE_RES, FuncSlot(self.OnResTeamLeavePractice, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_LEAVE_PRACTICE_NTF, FuncSlot(self.OnNtfTeamLeavePractice, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_SET_RES, FuncSlot(self.OnResTeamRobotSet, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_SET_NTF, FuncSlot(self.OnNtfTeamRobotSet, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_RES, FuncSlot(self.OnResTeamEnter, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAP_SYNC_NTF, FuncSlot(self.OnNtfMapSync, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_RES, FuncSlot(self.OnResPracticeRemind, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_NTF, FuncSlot(self.OnNtfPracticeRemind, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REPLY_RES, FuncSlot(self.OnResPracticeRemindReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REPLY_NTF, FuncSlot(self.OnNtfPracticeRemindReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_GEN_ROOM_CODE_RES, FuncSlot(self.OnResTeamGenRoomCode, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_MEMBER_OFFLINE_NTF, FuncSlot(self.OnNtfTeamMemberOffline, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROOM_MEMBER_OFFLINE_NTF, FuncSlot(self.OnNtfRoomMemberOffline, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_RES, FuncSlot(self.OnResTeamKick, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_RES, FuncSlot(self.OnResTeamReady, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_RES, FuncSlot(self.OnResTeamTransLeader, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_ANSWER_RES, FuncSlot(self.OnResTeamSwitchAnswer, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_RES, FuncSlot(self.OnResTeamMode, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_RES, FuncSlot(self.OnResTeamApply, self))
  local global_delegate_manager = GetGlobalDelegateManager()
  self.ResetRoomInfoHandler = DelegateMgr:AddDelegate(global_delegate_manager.ResetRoomInfo, self, "OnResetRoomInfo")
  self.ReqTeamLeavePracticeHandler = DelegateMgr:AddDelegate(global_delegate_manager.ReqTeamLeavePractice, self, "ReqTeamLeavePractice")
end
function RoomProxy:OnRemove()
  local global_delegate_manager = GetGlobalDelegateManager()
  DelegateMgr:RemoveDelegate(global_delegate_manager.ResetRoomInfo, self.ResetRoomInfoHandler)
  DelegateMgr:RemoveDelegate(global_delegate_manager.ReqTeamLeavePractice, self.ReqTeamLeavePracticeHandler)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MATCH_COMPLETE_NTF, FuncSlot(self.OnNtfMatchResult, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_NTF, FuncSlot(self.OnNtfRoomSwitch, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_NTF, FuncSlot(self.OnNtfTeamTransLeader, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_INFO_NTF, FuncSlot(self.OnNtfTeamInfo, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_NTF, FuncSlot(self.OnNtfTeamExit, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_NTF, FuncSlot(self.OnNtfTeamKick, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_NTF, FuncSlot(self.OnNtfMemberEnter, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_NTF, FuncSlot(self.OnNtfTeamReady, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MATCH_JOIN_RES, FuncSlot(self.OnResJoinMatch, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MATCH_JOIN_NTF, FuncSlot(self.OnNtfMatchJoin, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MATCH_QUIT_RES, FuncSlot(self.OnResQuitMatch, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MATCH_QUIT_NTF, FuncSlot(self.OnNtfMatchQuit, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ENTER_BATTLE_NTF, FuncSlot(self.OnNtfStartGame, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_NTF, FuncSlot(self.OnNtfTeamMode, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_RES, FuncSlot(self.OnResTeamApplyReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REPLY_NTF, FuncSlot(self.OnNtfTeamApplyReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PENALTY_TIME_NTF, FuncSlot(self.OnNtfPenaltyTime, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_RES, FuncSlot(self.OnResTeamExit, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_READY_CONFIRM_RES, FuncSlot(self.OnResReadyConfirm, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_READY_CONFIRM_NTF, FuncSlot(self.OnNtfReadyConfirm, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_RES, FuncSlot(self.OnResTeamInvite, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_QUIT_BATTLE_NTF, FuncSlot(self.OnNtfQuitBattle, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_CREATE_RES, FuncSlot(self.OnResTeamCreate, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_RES, FuncSlot(self.OnResTeamRobot, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_RES, FuncSlot(self.OnResTeamSwitch, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_BEGIN_RES, FuncSlot(self.OnResTeamBegin, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_PRACTICE_RES, FuncSlot(self.OnResTeamEnterPractice, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_PRACTICE_NTF, FuncSlot(self.OnNtfTeamEnterPractice, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_LEAVE_PRACTICE_NTF, FuncSlot(self.OnNtfTeamLeavePractice, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_SET_RES, FuncSlot(self.OnResTeamRobotSet, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_SET_NTF, FuncSlot(self.OnNtfTeamRobotSet, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_RES, FuncSlot(self.OnResTeamEnter, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAP_SYNC_NTF, FuncSlot(self.OnNtfMapSync, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_RES, FuncSlot(self.OnResPracticeRemind, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_NTF, FuncSlot(self.OnNtfPracticeRemind, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REPLY_RES, FuncSlot(self.OnResPracticeRemindReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REPLY_NTF, FuncSlot(self.OnNtfPracticeRemindReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_GEN_ROOM_CODE_RES, FuncSlot(self.OnResTeamGenRoomCode, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_MEMBER_OFFLINE_NTF, FuncSlot(self.OnNtfTeamMemberOffline, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROOM_MEMBER_OFFLINE_NTF, FuncSlot(self.OnNtfRoomMemberOffline, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_RES, FuncSlot(self.OnResTeamKick, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_RES, FuncSlot(self.OnResTeamReady, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_RES, FuncSlot(self.OnResTeamTransLeader, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_ANSWER_RES, FuncSlot(self.OnResTeamSwitchAnswer, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_RES, FuncSlot(self.OnResTeamMode, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_RES, FuncSlot(self.OnResTeamApply, self))
  self:ClearPenaltyTimerHandle()
end
function RoomProxy:InitParameters()
  gameModeSelectProxy = GameFacade:RetrieveProxy(ProxyNames.GameModeSelectProxy)
  friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  VoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  self.teamInviteStack = nil
  self.teamApplyStack = nil
  self.refuseInviteIDs = nil
  self.recentlySelectedMode = GameModeSelectNum.GameModeType.None
  self.bKeepIgnoreExchangePositionReq = false
  self:ClearData()
  self:SetModeDatas(nil)
  self.netCheckTime = 1
end
function RoomProxy:ClearData()
  self.RoomInvitePos = 2
  self.bUIReconnect = false
  self.roomList = nil
  self.tempRoomList = {}
  self.useClientPenaltyTime = 0
  self.matchResult = nil
  self.roomPlayerList = nil
  self.playerTeamMemberInfo = nil
  self.inviteInfo = nil
  self.teamInfo = nil
  self.ticket = 0
  self.bIsReqJoinMatch = false
  self.bLockEditRoomInfo = false
  self.bKeepIgnoreExchangePositionReq = false
  self.practiceRemindMap = {}
  LogInfo("RoomProxy", "ClearRoomData.")
end
function RoomProxy:OnNtfMapSync(data)
  local mapSyncNtf = DeCode(Pb_ncmd_cs_lobby.map_sync_ntf, data)
  LogInfo("OnNtfMapSync:", TableToString(mapSyncNtf))
  if mapSyncNtf.map_ids then
    self.mapList = mapSyncNtf.map_ids
  end
  if mapSyncNtf.mode_datas then
    self:SetModeDatas(mapSyncNtf.mode_datas)
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.GameModeDatasUpdate)
  end
end
function RoomProxy:OnResTeamEnter(data)
  self:SetNetCheckTimer(false)
  local teamEnterRes = DeCode(Pb_ncmd_cs_lobby.team_enter_res, data)
  LogInfo("OnResTeamEnter:", TableToString(teamEnterRes))
  if teamEnterRes.code and 0 ~= teamEnterRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamEnterRes.code)
  end
end
function RoomProxy:OnResTeamRobotSet(data)
  self:SetNetCheckTimer(false)
  local teamRobotSetRes = DeCode(Pb_ncmd_cs_lobby.team_robot_set_res, data)
  LogInfo("OnResTeamRobotSet:", TableToString(teamRobotSetRes))
  if teamRobotSetRes.code and 0 ~= teamRobotSetRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamRobotSetRes.code)
  end
end
function RoomProxy:OnNtfTeamRobotSet(data)
  local teamRobotSetNtf = DeCode(Pb_ncmd_cs_lobby.team_robot_set_ntf, data)
  LogInfo("OnNtfTeamRobotSet:", TableToString(teamRobotSetNtf))
  if teamRobotSetNtf and teamRobotSetNtf.difficulty then
    if self.teamInfo and self.teamInfo.difficulty then
      self.teamInfo.difficulty = teamRobotSetNtf.difficulty
    end
    GameFacade:SendNotification(NotificationDefines.TeamRoom.UpdateRoomAiLevel, teamRobotSetNtf.difficulty)
  end
end
function RoomProxy:OnNtfTeamEnterPractice(data)
  local teamEnterPracticeNtf = DeCode(Pb_ncmd_cs_lobby.team_enter_practice_ntf, data)
  LogInfo("OnNtfTeamEnterPractice:", TableToString(teamEnterPracticeNtf))
  local practicPlayerId = teamEnterPracticeNtf.player_id
  if practicPlayerId then
    local sendData = {}
    sendData.bEnter = true
    sendData.playerId = practicPlayerId
    GameFacade:SendNotification(NotificationDefines.Card.SetEnterPracticeStatus, sendData)
    if self.teamInfo and self.teamInfo.members then
      for key, value in pairs(self.teamInfo.members) do
        if value and value.playerId and practicPlayerId == value.playerId then
          value.bEnterPractice = true
          return
        end
      end
    end
  end
end
function RoomProxy:OnResTeamEnterPractice(data)
  self:SetNetCheckTimer(false)
  local teamEnterPracticeRes = DeCode(Pb_ncmd_cs_lobby.team_enter_practice_res, data)
  LogInfo("OnResTeamEnterPractice:", TableToString(teamEnterPracticeRes))
  if 0 ~= teamEnterPracticeRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamEnterPracticeRes.code)
  else
    local SM = UE4.UPMGlobalStateMachine.Get(LuaGetWorld())
    if SM then
      SM:TransferGlobalPlayingState_Practice()
    end
    self:SetEnterPracticeStatus(true)
  end
end
function RoomProxy:OnResTeamLeavePractice(data)
  self:SetNetCheckTimer(false)
  local team_leave_practice_res = DeCode(Pb_ncmd_cs_lobby.team_leave_practice_res, data)
  LogInfo("OnResTeamLeavePractice:", TableToString(team_leave_practice_res))
  if 0 == team_leave_practice_res.code then
    local gameInstance = UE4.UGameplayStatics.GetGameInstance(LuaGetWorld())
    if gameInstance then
      gameInstance:GotoLobbyScene()
    end
  end
end
function RoomProxy:OnNtfTeamLeavePractice(data)
  local teamLeavePracticeNtf = DeCode(Pb_ncmd_cs_lobby.team_leave_practice_ntf, data)
  LogInfo("OnNtfTeamLeavePractice:", TableToString(teamLeavePracticeNtf))
  local practicPlayerId = teamLeavePracticeNtf.player_id
  if teamLeavePracticeNtf.player_id then
    local sendData = {}
    sendData.bEnter = false
    sendData.playerId = practicPlayerId
    GameFacade:SendNotification(NotificationDefines.Card.SetEnterPracticeStatus, sendData)
    if self:GetPlayerID() == practicPlayerId then
      self:SetEnterPracticeStatus(false)
    elseif self.practiceRemindMap[practicPlayerId] ~= nil then
      self.practiceRemindMap[practicPlayerId] = nil
    end
    if self.teamInfo and self.teamInfo.members then
      for key, value in pairs(self.teamInfo.members) do
        if value and value.playerId and practicPlayerId == value.playerId then
          value.bEnterPractice = false
          return
        end
      end
    end
  end
end
function RoomProxy:OnResTeamBegin(data)
  self:SetNetCheckTimer(false)
  local team_begin_res = DeCode(Pb_ncmd_cs_lobby.team_begin_res, data)
  LogInfo("OnResTeamBegin", TableToString(team_begin_res))
  if 0 == team_begin_res.code then
    self.bIsReqJoinMatch = true
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, team_begin_res.code)
  end
end
function RoomProxy:OnReceiveLoginRes(data)
  local login_res = DeCode(Pb_ncmd_cs_lobby.login_res, data)
  LogInfo("OnReceiveLoginRes", TableToString(login_res))
  if login_res.player and login_res.player.team_id and 0 == login_res.player.team_id and login_res.player.room_id and 0 == login_res.player.room_id then
    GameFacade:SendNotification(NotificationDefines.Login.ReceiveLoginRes)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnNtfTeamExit)
    self:ClearData()
  end
end
function RoomProxy:OnNtfQuitBattle(data)
  local quitBattleRes = pb.decode(Pb_ncmd_cs_lobby.quit_battle_ntf, data)
  if quitBattleRes.status then
    local dsStatus = quitBattleRes.status
    if dsStatus == RoomEnum.DsStatus.DsStatus_UNCONNECT or dsStatus == RoomEnum.DsStatus.DsStatus_CRASH then
      local infoString = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "ConnectDsFailed")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, infoString)
    end
  end
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnQuitBattle)
  self:SetLockEditRoomInfo(false)
  self:ClearMatchResult()
end
function RoomProxy:OnResTeamInvite(data)
  self:SetNetCheckTimer(false)
  local teamInviteRes = pb.decode(Pb_ncmd_cs_lobby.team_invite_res, data)
  if 0 == teamInviteRes.code then
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamInviteRes.code)
  end
end
function RoomProxy:OnResTeamExit(data)
  self:SetNetCheckTimer(false)
  local teamQuitRes = pb.decode(Pb_ncmd_cs_lobby.team_exit_res, data)
  if 0 == teamQuitRes.code then
    if self.bIsReqJoinMatch then
      self:ReqQuitMatch()
    end
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamQuitRes.code)
  end
end
function RoomProxy:OnResTeamSwitch(data)
  self:SetNetCheckTimer(false)
  local teamSwitchRes = pb.decode(Pb_ncmd_cs_lobby.team_switch_res, data)
  if 0 ~= teamSwitchRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamSwitchRes.code)
  end
end
function RoomProxy:OnResetRoomInfo()
  LogInfo("OnResetRoomInfo", "Reset")
  self:ClearData()
end
function RoomProxy:OnNtfPenaltyTime(data)
  local penalty_time_ntf = pb.decode(Pb_ncmd_cs_lobby.penalty_time_ntf, data)
  LogInfo("OnNtfPenaltyTime callback code:", TableToString(penalty_time_ntf))
  self.ticket = 0
  self.bIsReqJoinMatch = false
  self:SetLockEditRoomInfo(false)
  local penaltyPlayerIDs = {}
  local size = #penalty_time_ntf.player_ids
  for index = 0, size - 1 do
    table.insert(penaltyPlayerIDs, penalty_time_ntf.player_ids[index])
  end
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnPenaltyTimeNtf, penaltyPlayerIDs)
end
function RoomProxy:OnNtfRoomSwitch(data)
  if self:GetKeepIgnoreExchangePositionReq() then
    return
  end
  local room_switch_ntf = pb.decode(Pb_ncmd_cs_lobby.team_switch_ntf, data)
  LogInfo("OnNtfRoomSwitch callback data:", TableToString(room_switch_ntf))
  local player = {}
  player.icon = room_switch_ntf.player.icon
  player.pos = room_switch_ntf.player.pos
  player.nick = room_switch_ntf.player.nick
  player.ready = room_switch_ntf.player.ready
  player.sex = room_switch_ntf.player.sex
  player.playerId = room_switch_ntf.player.player_id
  player.level = room_switch_ntf.player.level
  player.rank = room_switch_ntf.player.rank
  player.status = room_switch_ntf.player.status
  player.offline = room_switch_ntf.player.offline
  player.vcAvatarId = room_switch_ntf.player.vc_avatar_id
  player.vcFrameId = room_switch_ntf.player.vc_frame_id
  player.vcBorderId = room_switch_ntf.player.vc_border_id
  player.vcAchieId = room_switch_ntf.player.vc_achie_id
  player.stars = room_switch_ntf.player.stars
  player.robot = room_switch_ntf.player.robot
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ExchangePosPC, false)
  if self.teamInfo and self.teamInfo.teamId and self.teamInfo.teamId > 0 then
    local sendData = {}
    sendData.inRoomID = self.teamInfo.teamId
    sendData.inPlayer = player
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomSwitchNtf, sendData)
  end
end
function RoomProxy:OnNtfTeamTransLeader(data)
  local team_trans_leader_ntf = pb.decode(Pb_ncmd_cs_lobby.team_trans_leader_ntf, data)
  LogInfo("OnNtfTeamTransLeader callback data:", TableToString(team_trans_leader_ntf))
  local newLeaderId = team_trans_leader_ntf.leader_id
  self:OnTeamTransLeaderNtfCallback(newLeaderId)
end
function RoomProxy:OnNtfTeamInfo(data)
  local bIsFirstInit = true
  if self.teamInfo then
    bIsFirstInit = false
  end
  local tempTeamInfo = {}
  local team_info_ntf = pb.decode(Pb_ncmd_cs_lobby.team_info_ntf, data)
  LogInfo("OnNtfTeamInfo callback data:", TableToString(team_info_ntf))
  if 0 ~= team_info_ntf.team_id then
    tempTeamInfo.teamId = team_info_ntf.team_id
    tempTeamInfo.leaderId = team_info_ntf.leader_id
    tempTeamInfo.mode = team_info_ntf.mode
    tempTeamInfo.mapID = team_info_ntf.map_id
    tempTeamInfo.master = team_info_ntf.leader_id
    tempTeamInfo.difficulty = team_info_ntf.difficulty
    tempTeamInfo.roomCode = team_info_ntf.room_code
    tempTeamInfo.special = team_info_ntf.special
    local members = {}
    for key, value in pairs(team_info_ntf.members) do
      if value then
        local player = {}
        player.playerId = value.player_id
        player.nick = value.nick
        player.icon = value.icon
        player.sex = value.sex
        player.level = value.level
        player.pos = value.pos
        player.status = value.status
        player.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.UnPlayPrepareAnim
        player.offline = value.offline
        if bIsFirstInit and value.status == RoomEnum.TeamMemberStatusType.Ready then
          if value.player_id ~= self:GetPlayerID() then
            player.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim
          elseif value.player_id == self:GetPlayerID() then
            player.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.First
          end
        elseif self.teamInfo and self.teamInfo.members then
          for key1, value1 in pairs(self.teamInfo.members) do
            if value1.playerId == player.playerId and value1.status == RoomEnum.TeamMemberStatusType.Ready then
              player.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim
            end
          end
        end
        player.rank = value.rank
        player.avatarId = value.vc_avatar_id
        player.frameId = value.vc_border_id
        player.borderId = value.vc_border_id
        player.achievementId = value.vc_achie_id
        player.dsClusterIndex = value.ds_cluster
        player.dsClusterPingList = {}
        if value.ds_cluster_ping then
          for k, v in pairs(value.ds_cluster_ping) do
            player.dsClusterPingList[v.ds_cluster] = v.ping
          end
        end
        player.stars = value.stars
        player.bIsRobot = value.robot
        player.bEnterPractice = value.in_practice
        table.insert(members, player)
      end
    end
    table.sort(members, function(a, b)
      return a.pos < b.pos
    end)
    tempTeamInfo.members = members
    if self.teamInfo and self.teamInfo.members then
      local oldMembersInfo = self.teamInfo.members
      for key, value in pairs(oldMembersInfo) do
        for key1, value1 in pairs(tempTeamInfo.members) do
          if value.playerId == value1.playerId then
            value1.rankCardPlayAnimStatus = value.rankCardPlayAnimStatus
          end
        end
      end
    end
    local oldTeamId
    if self.teamInfo and self.teamInfo.teamId then
      oldTeamId = self.teamInfo.teamId
    end
    self.teamInfo = tempTeamInfo
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamInfoNtf, tempTeamInfo)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomInfoUpdate)
    if not self:CheckIsInGame() and 1 ~= tempTeamInfo.special and not self:GetIsInRankOrRoomUI() and (not oldTeamId or tempTeamInfo.teamId ~= oldTeamId) then
      if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
        GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
          target = UIPageNameDefine.GameModeSelectPage
        })
      elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
        local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
        if GameState and GameState.GetModeType then
          if GameState:GetModeType() == UE4.EPMGameModeType.FrontEnd then
            ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefModeine.GameModeSelectPage)
          end
        else
          ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.GameModeSelectPage)
        end
      end
      return
    end
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamUpdateNtf)
    TimerMgr:AddTimeTask(0.1, 0, 0, function()
      GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomMemberNtf)
    end)
    GameFacade:SendNotification(NotificationDefines.Common, self.teamInfo, NotificationDefines.Common.UpdateTeamInfo)
  elseif 0 == team_info_ntf.team_id then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.SwitchGameMode, GameModeSelectNum.GameModeType.None)
  end
end
function RoomProxy:GetLeaderInfo()
  if self.teamInfo and self.teamInfo.members and self.teamInfo.leaderId then
    for key, value in pairs(self.teamInfo.members) do
      if value.playerId == self.teamInfo.leaderId then
        return value
      end
    end
  else
    return nil
  end
end
function RoomProxy:GetLeaderDSClusterInfo()
  local LeaderInfo = self:GetLeaderInfo()
  if LeaderInfo then
    local dsClusterIndex = LeaderInfo.dsClusterIndex
    local ping = LeaderInfo.dsClusterPingList[LeaderInfo.dsClusterIndex]
    if nil == ping then
      ping = 50
    end
    local DsClusterName = ""
    LogDebug("LeaderInfo.dsClusterIndex", dsClusterIndex)
    LogDebug("LeaderInfo.ping", ping)
    local arrRows = ConfigMgr:GetDSClusterTableRows()
    if arrRows then
      local Row = arrRows:ToLuaTable()[tostring(dsClusterIndex)]
      if Row then
        LogDebug("LeaderInfo.DsClusterName", tostring(Row.DsClusterName))
        DsClusterName = Row.DsClusterName
      else
        DsClusterName = arrRows:ToLuaTable()["1"].DsClusterName
      end
    end
    return dsClusterIndex, ping, DsClusterName
  end
  return nil
end
function RoomProxy:OnNtfTeamExit(data)
  local team_exit_ntf = pb.decode(Pb_ncmd_cs_lobby.team_exit_ntf, data)
  LogInfo("OnNtfTeamExit callback data:", TableToString(team_exit_ntf))
  local quitPlayerId = team_exit_ntf.player_id
  if quitPlayerId ~= self:GetPlayerID() then
    self:ShowExitMsg(quitPlayerId)
    self:RemoveTeamMember(quitPlayerId)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamMemberQuitNtf, quitPlayerId)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomMemberNtf)
    if VoiceManager then
      VoiceManager:RemovePlayreForbidVoiceState(quitPlayerId)
    end
  else
    self:ClearData()
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnNtfTeamExit)
    self:RemoveTeamMember(quitPlayerId)
    if VoiceManager then
      VoiceManager:ClearPlayreForbidVoiceState()
    end
    VoiceManager:QuitAllVoiceRoom()
    local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
    if SettingCombatProxy then
      SettingCombatProxy:VoiceMapEmpty()
    end
  end
  if self.bIsReqJoinMatch then
    self:ReqQuitMatch()
  end
end
function RoomProxy:OnNtfTeamKick(data)
  local team_kick_ntf = pb.decode(Pb_ncmd_cs_lobby.team_kick_ntf, data)
  LogInfo("OnNtfTeamKick callback data:", TableToString(team_kick_ntf))
  local kickPlayerId = team_kick_ntf.player_id
  if kickPlayerId ~= self:GetPlayerID() then
    self:ShowKickMsg(kickPlayerId)
    local bIsRobot = false
    for key, value in pairs(self.teamInfo.members) do
      if value.playerId == kickPlayerId and value.bIsRobot then
        bIsRobot = true
      end
    end
    self:RemoveTeamMember(kickPlayerId)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamMemberQuitNtf, kickPlayerId)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomMemberNtf)
    if VoiceManager then
      VoiceManager:RemovePlayreForbidVoiceState(kickPlayerId)
    end
  else
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberKickedOutRoomText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnNtfTeamExit, 0)
    self:ClearData()
    if VoiceManager then
      VoiceManager:ClearPlayreForbidVoiceState()
    end
    VoiceManager:QuitAllVoiceRoom()
    local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
    if SettingCombatProxy then
      SettingCombatProxy:VoiceMapEmpty()
    end
  end
end
function RoomProxy:OnNtfTeamReady(data)
  local team_ready_ntf = pb.decode(Pb_ncmd_cs_lobby.team_ready_ntf, data)
  LogInfo("OnNtfTeamReady callback data:", TableToString(team_ready_ntf))
  if team_ready_ntf.readys then
    for key, value in pairs(team_ready_ntf.readys) do
      local playerId = value.player_id
      local inStatus = value.status
      if self.teamInfo and self.teamInfo.members then
        for key1, value1 in pairs(self.teamInfo.members) do
          if value1.playerId == playerId then
            if self:GetPlayerID() == playerId then
              if not self.playerTeamMemberInfo then
                self.playerTeamMemberInfo = {}
              end
              self.playerTeamMemberInfo.status = inStatus
              value1.status = inStatus
            else
              value1.status = inStatus
            end
            if value1.status == RoomEnum.TeamMemberStatusType.NotReady then
              value1.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.UnPlayPrepareAnim
            elseif value1.status == RoomEnum.TeamMemberStatusType.Ready then
              value1.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim
            end
            local sendData = {}
            sendData.playerId = playerId
            sendData.status = inStatus
            GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamMemberReadyNtf, sendData)
            GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomMemberNtf)
          end
        end
      end
    end
  end
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  SettingCombatProxy:SendTeamInvteReq()
end
function RoomProxy:OnResJoinMatch(data)
  self:SetNetCheckTimer(false)
  local match_join_res = pb.decode(Pb_ncmd_cs_lobby.match_join_res, data)
  LogInfo("OnResJoinMatch callback data:", TableToString(match_join_res))
  if 0 ~= match_join_res.code then
    self.bIsReqJoinMatch = false
    local penaltyTime = match_join_res.penalty_time
    if match_join_res.code == 1095 then
      local bankInfos = match_join_res.bank_infos
      if bankInfos and table.count(bankInfos) >= 1 then
        local bIsSelfSuspension = false
        local allSuspensionPlayerStr = ""
        for key, bankInfo in pairs(bankInfos) do
          local banRankBombPlayerId = bankInfo.ban_rank_bomb_player_id
          local banRankBombTime = bankInfo.ban_rank_bomb_time
          local banRankBombReason = bankInfo.ban_rank_bomb_reason
          if banRankBombPlayerId and banRankBombPlayerId > 0 then
            if self:GetPlayerID() and banRankBombPlayerId == self:GetPlayerID() then
              local tipStr = ""
              tipStr = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "NoticeOfSelfSuspension")
              local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
              if banRankBombReason then
                local arg1 = UE4.FFormatArgumentData()
                arg1.ArgumentName = "BanReason"
                arg1.ArgumentValue = banRankBombReason
                arg1.ArgumentValueType = 4
                inArgsTarry:Add(arg1)
              end
              if banRankBombTime and banRankBombTime > 0 then
                local yearStr = os.date("%Y", banRankBombTime)
                local monthStr = os.date("%m", banRankBombTime)
                local dayStr = os.date("%d", banRankBombTime)
                local hourStr = os.date("%H", banRankBombTime)
                local minuteStr = os.date("%M", banRankBombTime)
                local arg1 = UE4.FFormatArgumentData()
                arg1.ArgumentName = "year"
                arg1.ArgumentValue = yearStr
                arg1.ArgumentValueType = 4
                inArgsTarry:Add(arg1)
                local arg2 = UE4.FFormatArgumentData()
                arg2.ArgumentName = "month"
                arg2.ArgumentValue = monthStr
                arg2.ArgumentValueType = 4
                inArgsTarry:Add(arg2)
                local arg3 = UE4.FFormatArgumentData()
                arg3.ArgumentName = "day"
                arg3.ArgumentValue = dayStr
                arg3.ArgumentValueType = 4
                inArgsTarry:Add(arg3)
                local arg4 = UE4.FFormatArgumentData()
                arg4.ArgumentName = "hour"
                arg4.ArgumentValue = hourStr
                arg4.ArgumentValueType = 4
                inArgsTarry:Add(arg4)
                local arg5 = UE4.FFormatArgumentData()
                arg5.ArgumentName = "minute"
                arg5.ArgumentValue = minuteStr
                arg5.ArgumentValueType = 4
                inArgsTarry:Add(arg5)
              end
              tipStr = UE4.UKismetTextLibrary.Format(tipStr, inArgsTarry)
              GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipStr)
              bIsSelfSuspension = true
              break
            else
              local member = self:GetTeamMemberByPlayerID(banRankBombPlayerId)
              if member then
                if "" ~= allSuspensionPlayerStr then
                  allSuspensionPlayerStr = allSuspensionPlayerStr .. "、(" .. member.nick .. ")"
                else
                  allSuspensionPlayerStr = "(" .. member.nick .. ")"
                end
              end
            end
          end
        end
        if not bIsSelfSuspension then
          local tipStr = ""
          tipStr = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "NoticeOfTeammateSuspension")
          local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
          local arg1 = UE4.FFormatArgumentData()
          arg1.ArgumentName = "PlayerName"
          arg1.ArgumentValue = allSuspensionPlayerStr
          arg1.ArgumentValueType = 4
          inArgsTarry:Add(arg1)
          tipStr = UE4.UKismetTextLibrary.Format(tipStr, inArgsTarry)
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipStr)
        end
      end
    elseif penaltyTime and penaltyTime > 0 then
      local penaltyPlayerID = match_join_res.penalty_player_id
      self.cachedPenaltyTime = penaltyTime
      self:CalRemainPenaltyTime()
      if penaltyTime >= 2 then
        self.useClientPenaltyTime = 2
      else
        self.useClientPenaltyTime = penaltyTime
      end
      self.cachedPenaltyPlayerID = penaltyPlayerID
      self:ShowPenaltyTips(penaltyTime, penaltyPlayerID)
      TimerMgr:AddTimeTask(self.useClientPenaltyTime, 0, 1, function()
        self.useClientPenaltyTime = 0
      end)
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, match_join_res.code)
    end
  else
    self.bIsReqJoinMatch = true
  end
end
function RoomProxy:CalRemainPenaltyTime()
  self:ClearPenaltyTimerHandle()
  self.penaltyTimerHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
    self.cachedPenaltyTime = self.cachedPenaltyTime - 1
  end)
end
function RoomProxy:OnNtfMatchJoin(data)
  local match_join_ntf = pb.decode(Pb_ncmd_cs_lobby.match_join_ntf, data)
  if 0 == match_join_ntf.code then
    self:SetExpectMatchTime(match_join_ntf.expect)
    self.bIsReqJoinMatch = true
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnJoinMatchNtf, true)
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    if not self:IsTeamLeader() then
      local audio = UE4.UPMLuaAudioBlueprintLibrary
      audio.PostEvent(2467171692)
    end
  else
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnJoinMatchNtf, false)
  end
  self.ticket = match_join_ntf.ticket
end
function RoomProxy:OnResQuitMatch(data)
  self:SetNetCheckTimer(false)
  local match_quit_res = pb.decode(Pb_ncmd_cs_lobby.match_quit_res, data)
  LogInfo("OnResQuitMatch callback code:", tonumber(match_quit_res.code))
  if 0 ~= match_quit_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, match_quit_res.code)
  else
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    self.bIsReqJoinMatch = false
  end
end
function RoomProxy:OnNtfMatchQuit(data)
  local match_quit_ntf = pb.decode(Pb_ncmd_cs_lobby.match_quit_ntf, data)
  LogInfo("OnNtfMatchQuit callback code:", tonumber(match_quit_ntf.code))
  if 0 == match_quit_ntf.code then
    self.ticket = 0
    self.bIsReqJoinMatch = false
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnQuitMatchNtf, tostring(match_quit_ntf.code))
    self:OnQuitMatchNtfCallback()
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    if match_quit_ntf.reason and 2 == match_quit_ntf.reason then
      local MatchTimeoutStopStr = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MatchTimeoutStop")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, MatchTimeoutStopStr)
      GameFacade:SendNotification(NotificationDefines.Common.PlayVoice, {voiceType = "Failure"})
    end
  end
  self:ClearMatchResult()
end
function RoomProxy:OnNtfMatchResult(data)
  local match_complete_ntf = pb.decode(Pb_ncmd_cs_lobby.match_complete_ntf, data)
  LogInfo("OnNtfMatchResult callback code:", tonumber(match_complete_ntf.code))
  self:SetLockEditRoomInfo(false)
  self:ClearMatchResult()
  local bResult = 0 == match_complete_ntf.code
  if bResult then
    self.matchResult = {}
    self.matchResult.mapID = match_complete_ntf.map_id
    self.matchResult.playerNumPerTeam = match_complete_ntf.total
    self.matchResult.roomId = match_complete_ntf.room_id
    self.matchResult.gameMode = match_complete_ntf.mode
    self.matchResult.timeOut = match_complete_ntf.timeout
    self.matchResult.prepareLeftTime = match_complete_ntf.ready_left_time
    local playerNum = #match_complete_ntf.players
    self.matchResult.playerInfos = nil
    self.matchResult.playerInfos = {}
    for i = 1, playerNum do
      local player = match_complete_ntf.players[i]
      local playerInfo = {}
      playerInfo.teamId = player.campid
      playerInfo.playerId = player.player_id
      playerInfo.isRobot = player.robot
      playerInfo.nick = player.nick
      playerInfo.icon = player.icon
      playerInfo.sex = player.sex
      playerInfo.rank = player.rank
      playerInfo.status = player.status
      playerInfo.uIPos = player.pos
      playerInfo.level = player.level
      playerInfo.avatarId = player.vc_avatar_id
      playerInfo.frameId = player.vc_border_id
      playerInfo.borderId = player.vc_border_id
      playerInfo.achievementId = player.vc_achie_id
      playerInfo.stars = player.stars
      playerInfo.readyConfirm = player.ready_confirm
      playerInfo.offline = player.offline
      table.insert(self.matchResult.playerInfos, playerInfo)
    end
    if not self:CheckIsInGame() and self:GetGameModeType() ~= GameModeSelectNum.GameModeType.Room and match_complete_ntf.ready_left_time and match_complete_ntf.ready_left_time > 0 then
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
    end
    UE4.UPMLuaBridgeBlueprintLibrary.RestoreGameWindows(LuaGetWorld())
  end
  self:SetLockEditRoomInfo(bResult)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.MatchResultNtf, bResult)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnMatchResultNtf, bResult)
end
function RoomProxy:OnNtfStartGame(data)
  local enter_battle_ntf = pb.decode(Pb_ncmd_cs_lobby.enter_battle_ntf, data)
  LogInfo("OnNtfStartGame callback code:", tonumber(enter_battle_ntf.code))
  UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld()).CloseWebView()
  local bResult = 0 == enter_battle_ntf.code
  if 0 ~= enter_battle_ntf.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, enter_battle_ntf.code)
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
    self:SetLockEditRoomInfo(bResult)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnQuitMatchNtf)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnQuitBattle)
    self.bIsReqJoinMatch = false
  else
    self.roomId = enter_battle_ntf.room_id
    self.dsip = enter_battle_ntf.ip
    self.dsport = enter_battle_ntf.port
    self.token = enter_battle_ntf.token
  end
  self.ticket = 0
  self.bStartGame = true
  self.bIsReqJoinMatch = false
end
function RoomProxy:OnResFriendTeamInfo(data)
  local team_query_res = pb.decode(Pb_ncmd_cs_lobby.team_query_res, data)
  LogInfo("OnResFriendTeamInfo callback data:", TableToString(team_query_res))
  local bResult = 0 == team_query_res.code
  local tempTeamInfo = {}
  tempTeamInfo.teamId = team_query_res.team_id
  tempTeamInfo.leaderId = team_query_res.leader_id
  tempTeamInfo.teamIntimacy = 0
  for key, value in pairs(team_query_res.members) do
    local member = {}
    member.playerId = value.player_id
    member.nick = value.nick
    member.icon = value.icon
    member.sex = value.sex
    member.level = value.level
    member.pos = value.pos
    member.status = value.status
    member.rank = value.rank
    member.avatarId = value.vc_avatar_id
    member.frameId = value.vc_border_id
    member.borderId = value.vc_border_id
    member.achievementId = value.vc_achie_id
    member.stars = value.stars
    member.offline = value.offline
    table.insert(tempTeamInfo.members, member)
    local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
    if friendDataProxy and friendDataProxy.allFriendMap[member.playerId] then
      local memberFriend = friendDataProxy.allFriendMap[member.playerId]
      if memberFriend.friendType == FriendEnum.FriendType.Friend then
        tempTeamInfo.teamIntimacy = tempTeamInfo.teamIntimacy + memberFriend.intimacy
      end
    end
  end
  for key, value in pairs(tempTeamInfo.members) do
    local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
    if friendDataProxy and friendDataProxy.allFriendMap[value.playerId] then
      friendDataProxy.friendTeamInfoMap[value.playerId] = tempTeamInfo
    end
  end
end
function RoomProxy:OnResTeamCreate(data)
  local team_create_res = pb.decode(Pb_ncmd_cs_lobby.team_create_res, data)
  LogInfo("OnResTeamCreate callback data:", TableToString(team_create_res))
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomCreateRes, team_create_res)
  self:SetNetCheckTimer(false)
end
function RoomProxy:OnNtfMemberEnter(data)
  local team_enter_ntf = pb.decode(Pb_ncmd_cs_lobby.team_enter_ntf, data)
  LogInfo("OnNtfMemberEnter callback data:", TableToString(team_enter_ntf))
  local memberInfo = {}
  memberInfo.playerId = team_enter_ntf.member.player_id
  memberInfo.icon = team_enter_ntf.member.icon
  memberInfo.level = team_enter_ntf.member.level
  memberInfo.nick = team_enter_ntf.member.nick
  memberInfo.pos = team_enter_ntf.member.pos
  memberInfo.rank = team_enter_ntf.member.rank
  memberInfo.sex = team_enter_ntf.member.sex
  memberInfo.status = team_enter_ntf.member.status
  memberInfo.avatarId = team_enter_ntf.member.vc_avatar_id
  memberInfo.frameId = team_enter_ntf.member.vc_border_id
  memberInfo.borderId = team_enter_ntf.member.vc_border_id
  memberInfo.achievementId = team_enter_ntf.member.vc_achie_id
  memberInfo.dsClusterIndex = team_enter_ntf.member.ds_cluster
  memberInfo.dsClusterPingList = {}
  if team_enter_ntf.member.ds_cluster_ping then
    for k, v in pairs(team_enter_ntf.member.ds_cluster_ping) do
      memberInfo.dsClusterPingList[v.ds_cluster] = v.ping
    end
  end
  memberInfo.stars = team_enter_ntf.member.stars
  memberInfo.bIsRobot = team_enter_ntf.member.robot
  memberInfo.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.UnPlayPrepareAnim
  memberInfo.offline = team_enter_ntf.member.offline
  self:SetTeamMember(memberInfo)
  if not memberInfo.bIsRobot then
    local arg1 = UE4.FFormatArgumentData()
    arg1.ArgumentName = "0"
    arg1.ArgumentValue = memberInfo.nick
    arg1.ArgumentValueType = 4
    local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
    inArgsTarry:Add(arg1)
    local memberJoinTeamText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberJoinTeam")
    memberJoinTeamText = UE4.UKismetTextLibrary.Format(memberJoinTeamText, inArgsTarry)
    GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, memberJoinTeamText)
  end
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamMemberEnterNtf, memberInfo)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomMemberNtf)
end
function RoomProxy:OnNtfTeamMode(data)
  local team_mode_ntf = pb.decode(Pb_ncmd_cs_lobby.team_mode_ntf, data)
  LogInfo("OnNtfTeamMode callback data:", TableToString(team_mode_ntf))
  if self.teamInfo then
    self.teamInfo.mode = team_mode_ntf.mode
    self.teamInfo.mapID = team_mode_ntf.map_id
  else
    LogInfo("OnNtfTeamMode:", "teamInfo is nil")
  end
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.TeamModeModify, team_mode_ntf.mode)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomInfoUpdate)
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ChangeTeamMode, team_mode_ntf.mode)
end
function RoomProxy:OnResTeamRobot(data)
  self:SetNetCheckTimer(false)
  local team_robot_res = pb.decode(Pb_ncmd_cs_lobby.team_robot_res, data)
  LogInfo("OnResTeamRobot callback data:", TableToString(team_robot_res))
  local errorCode = team_robot_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamApplyReply(data)
  self:SetNetCheckTimer(false)
  local team_apply_reply_res = pb.decode(Pb_ncmd_cs_lobby.team_apply_reply_res, data)
  LogInfo("OnResTeamApplyReply callback data:", TableToString(team_apply_reply_res))
  local errorCode = team_apply_reply_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnNtfTeamApplyReply(data)
  local team_apply_reply_ntf = pb.decode(Pb_ncmd_cs_lobby.team_apply_reply_ntf, data)
  LogInfo("OnNtfTeamApplyReply callback data:", TableToString(team_apply_reply_ntf))
  local replyInfo = {}
  replyInfo.sure = team_apply_reply_ntf.sure
  replyInfo.uid = team_apply_reply_ntf.player_id
  replyInfo.nick = team_apply_reply_ntf.nick
  replyInfo.icon = team_apply_reply_ntf.icon
  if self.bIsReqJoinMatch then
    self:ReqQuitMatch()
  end
end
function RoomProxy:OnResReadyConfirm(data)
  self:SetNetCheckTimer(false)
  local ready_confirm_res = pb.decode(Pb_ncmd_cs_lobby.ready_confirm_res, data)
  LogInfo("OnResReadyConfirm callback data:", TableToString(ready_confirm_res))
  local sendData = {}
  sendData.bResult = true
  sendData.resCode = ready_confirm_res.code
  if 0 ~= ready_confirm_res.code then
    sendData.bResult = false
  end
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnReadyConfirmRes, sendData)
end
function RoomProxy:OnNtfReadyConfirm(data)
  local ready_confirm_ntf = pb.decode(Pb_ncmd_cs_lobby.ready_confirm_ntf, data)
  LogInfo("OnNtfReadyConfirm callback data:", TableToString(ready_confirm_ntf))
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnReadyConfirmNtf, ready_confirm_ntf.player_id)
end
function RoomProxy:OnResPracticeRemind(data)
  self:SetNetCheckTimer(false)
  local practice_remind_res = pb.decode(Pb_ncmd_cs_lobby.practice_remind_res, data)
  LogInfo("OnResPracticeRemind callback data:", TableToString(practice_remind_res))
  local errorCode = practice_remind_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnNtfPracticeRemind(data)
  local practice_remind_ntf = pb.decode(Pb_ncmd_cs_lobby.practice_remind_ntf, data)
  LogInfo("OnNtfPracticeRemind callback data:", TableToString(practice_remind_ntf))
  local playerId = practice_remind_ntf.player_id
  if not playerId or 0 == playerId then
    return
  end
  if playerId == self:GetPlayerID() then
    local pageData = {}
    pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "QuitPracticeRemindText")
    pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsConfirmText")
    pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsBackText")
    function pageData.cb(bConfirm)
      if bConfirm then
        self:ReqPracticeRemindReplyReq(true)
        self:ReqTeamLeavePractice()
      else
        self:ReqPracticeRemindReplyReq(false)
      end
    end
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
  else
    local sendData = {}
    sendData.playerId = playerId
    sendData.bClick = false
    GameFacade:SendNotification(NotificationDefines.Card.PracticeRemindClickStatus, sendData)
    self.practiceRemindMap[playerId] = true
  end
end
function RoomProxy:OnResPracticeRemindReply(data)
  self:SetNetCheckTimer(false)
  local practice_remind_reply_res = pb.decode(Pb_ncmd_cs_lobby.practice_remind_reply_res, data)
  LogInfo("OnResPracticeRemindReply callback data:", TableToString(practice_remind_reply_res))
  local errorCode = practice_remind_reply_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnNtfPracticeRemindReply(data)
  local practice_remind_reply_ntf = pb.decode(Pb_ncmd_cs_lobby.practice_remind_reply_ntf, data)
  LogInfo("OnNtfPracticeRemindReply callback data:", TableToString(practice_remind_reply_ntf))
  local playerId = practice_remind_reply_ntf.player_id
  local bAgree = practice_remind_reply_ntf.agree
  local sendData = {}
  sendData.playerId = playerId
  sendData.bClick = true
  if 0 ~= playerId then
    GameFacade:SendNotification(NotificationDefines.Card.PracticeRemindClickStatus, sendData)
  end
  self.practiceRemindMap[playerId] = false
end
function RoomProxy:OnResTeamGenRoomCode(data)
  self:SetNetCheckTimer(false)
  local team_gen_room_code_res = pb.decode(Pb_ncmd_cs_lobby.team_gen_room_code_res, data)
  LogInfo("OnResTeamGenRoomCode callback data:", TableToString(team_gen_room_code_res))
  local code = team_gen_room_code_res.code
  local roomCode = team_gen_room_code_res.room_code
  if 0 == code then
    self.teamInfo.roomCode = roomCode
    self:GetRoomCode()
  else
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RoomCodePasteFailed")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function RoomProxy:OnNtfTeamMemberOffline(data)
  local team_member_offline_ntf = pb.decode(Pb_ncmd_cs_lobby.team_member_offline_ntf, data)
  LogInfo("OnNtfTeamMemberOffline callback data:", TableToString(team_member_offline_ntf))
  local updatePlayerId = team_member_offline_ntf.player_id
  local updateOffline = team_member_offline_ntf.offline
  if self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      if value.playerId == updatePlayerId then
        value.offline = updateOffline
      end
    end
  end
end
function RoomProxy:OnNtfRoomMemberOffline(data)
  local room_member_offline_ntf = pb.decode(Pb_ncmd_cs_lobby.room_member_offline_ntf, data)
  LogInfo("OnNtfRoomMemberOffline callback data:", TableToString(room_member_offline_ntf))
  local updatePlayerId = room_member_offline_ntf.player_id
  local updateOffline = room_member_offline_ntf.offline
  if self.matchResult and self.matchResult.playerInfos then
    for key, value in pairs(self.matchResult.playerInfos) do
      if value.playerId == updatePlayerId then
        value.offline = updateOffline
      end
    end
  end
end
function RoomProxy:OnResTeamKick(data)
  self:SetNetCheckTimer(false)
  local team_kick_res = pb.decode(Pb_ncmd_cs_lobby.team_kick_res, data)
  LogInfo("OnResTeamKick callback data:", TableToString(team_kick_res))
  local errorCode = team_kick_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamReady(data)
  self:SetNetCheckTimer(false)
  local team_ready_res = pb.decode(Pb_ncmd_cs_lobby.team_ready_res, data)
  LogInfo("OnResTeamReady callback data:", TableToString(team_ready_res))
  local errorCode = team_ready_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamTransLeader(data)
  self:SetNetCheckTimer(false)
  local team_trans_leader_res = pb.decode(Pb_ncmd_cs_lobby.team_trans_leader_res, data)
  LogInfo("OnResTeamTransLeader callback data:", TableToString(team_trans_leader_res))
  local errorCode = team_trans_leader_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamSwitchAnswer(data)
  self:SetNetCheckTimer(false)
  local team_switch_answer_res = pb.decode(Pb_ncmd_cs_lobby.team_switch_answer_res, data)
  LogInfo("OnResTeamSwitchAnswer callback data:", TableToString(team_switch_answer_res))
  local errorCode = team_switch_answer_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamMode(data)
  self:SetNetCheckTimer(false)
  local team_mode_res = pb.decode(Pb_ncmd_cs_lobby.team_mode_res, data)
  LogInfo("OnResTeamMode callback data:", TableToString(team_mode_res))
  local errorCode = team_mode_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:OnResTeamApply(data)
  self:SetNetCheckTimer(false)
  local team_apply_res = pb.decode(Pb_ncmd_cs_lobby.team_apply_res, data)
  LogInfo("OnResTeamApply callback data:", TableToString(team_apply_res))
  local errorCode = team_apply_res.code
  if 0 ~= errorCode then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function RoomProxy:ReqPlayerGuideBattle()
  local playerGuideBattleReq = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.player_guide_battle_req, playerGuideBattleReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_PLAYER_GUIDE_BATTLE_REQ, req)
end
function RoomProxy:ReqTeamGenRoomCode()
  local teamGenRoomCodeReq = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.team_gen_room_code_req, teamGenRoomCodeReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_GEN_ROOM_CODE_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqReadyConfirm()
  local readyConfirmReq = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.ready_confirm_req, readyConfirmReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_READY_CONFIRM_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqQuitMatch()
  if 0 == self.ticket then
    LogInfo("ReqQuitMatch ticket == 0")
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    self.bIsReqJoinMatch = false
    return
  end
  local matchQuitReq = {}
  matchQuitReq.ticket = self.ticket
  LogInfo("ReqQuitMatch reqInfo:", TableToString(matchQuitReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.match_quit_req, matchQuitReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_MATCH_QUIT_REQ, req)
  self:SetNetCheckTimer(true)
  return true
end
function RoomProxy:ReqTeamApply(teamId, playerId)
  local teamApplyReq = {}
  teamApplyReq.team_id = teamId
  teamApplyReq.player_id = playerId
  LogInfo("ReqTeamApply reqInfo:", TableToString(teamApplyReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_apply_req, teamApplyReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_APPLY_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamInvite(teamId, invitePlayerId)
  local teamInviteReq = {}
  teamInviteReq.team_id = teamId
  if type(invitePlayerId) == "number" then
    teamInviteReq.player_ids = {invitePlayerId}
  else
    teamInviteReq.player_ids = invitePlayerId
  end
  LogInfo("ReqTeamInvite reqInfo:", TableToString(teamInviteReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_invite_req, teamInviteReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamCreate(ModeType, mapId, special)
  local teamCreateReq = {}
  teamCreateReq.mode = ModeType
  teamCreateReq.map_id = mapId
  teamCreateReq.special = special
  teamCreateReq.version = UE4.UPMLuaBridgeBlueprintLibrary.GetClientVersionStr()
  LogInfo("ReqTeamCreate reqInfo:", TableToString(teamCreateReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_create_req, teamCreateReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_CREATE_REQ, req)
  self:SetRecentlySelectedMode(ModeType)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomKick(RoomId, Tar_uid)
  local roomKickReq = {}
  roomKickReq.team_id = RoomId
  roomKickReq.player_id = Tar_uid
  LogInfo("ReqRoomKick reqInfo:", TableToString(roomKickReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_kick_req, roomKickReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomRobot(roomID, role, rank, count, team, botType)
  local roomRobotReq = {}
  roomRobotReq.team_id = roomID
  roomRobotReq.role = role
  roomRobotReq.rank = rank
  roomRobotReq.count = count
  roomRobotReq.team = team
  roomRobotReq.robot_type = botType
  LogInfo("ReqRoomRobot reqInfo:", TableToString(roomRobotReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_robot_req, roomRobotReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqJoinMatch()
  if not self:CanReqJoinMatch(true) then
    return false
  end
  local matchJoinReq = {}
  matchJoinReq.version = UE4.UPMLuaBridgeBlueprintLibrary.GetClientVersionStr()
  LogInfo("ReqJoinMatch reqInfo:", TableToString(matchJoinReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.match_join_req, matchJoinReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_MATCH_JOIN_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomReady(roomId, bReady)
  local roomReadyReq = {}
  roomReadyReq.team_id = roomId
  if true == bReady then
    roomReadyReq.status = 1
  else
    roomReadyReq.status = 0
  end
  LogInfo("ReqRoomReady reqInfo:", TableToString(roomReadyReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_ready_req, roomReadyReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomBegin(roomId)
  local roomBeginReq = {}
  roomBeginReq.team_id = roomId
  LogInfo("ReqRoomBegin reqInfo:", TableToString(roomBeginReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_begin_req, roomBeginReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_BEGIN_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTransLeader(roomId, Tar_uid)
  local roomTransLeaderReq = {}
  roomTransLeaderReq.team_id = roomId
  roomTransLeaderReq.player_id = Tar_uid
  LogInfo("ReqTransLeader reqInfo:", TableToString(roomTransLeaderReq))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_trans_leader_req, roomTransLeaderReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomSwitch(roomId, pos, targetID, pattern)
  local room_switch_req = {}
  room_switch_req.team_id = roomId
  room_switch_req.pos = pos
  room_switch_req.target_id = targetID
  room_switch_req.pattern = pattern
  LogInfo("ReqRoomSwitch reqInfo:", Pb_ncmd_cs_lobby.team_switch_req)
  local req = pb.encode(Pb_ncmd_cs_lobby.team_switch_req, room_switch_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomSwitchAnswer(RoomId, Tar_Uid, Tar_pos, bAnswer)
  local room_switch_answer_req = {}
  room_switch_answer_req.team_id = RoomId
  room_switch_answer_req.tar_player_id = Tar_Uid
  room_switch_answer_req.tar_pos = Tar_pos
  room_switch_answer_req.answer = bAnswer
  LogInfo("ReqRoomSwitchAnswer reqInfo:", TableToString(room_switch_answer_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_switch_answer_req, room_switch_answer_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_SWITCH_ANSWER_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqRoomInvite(RoomId, TargetID, Pos)
  local room_invite_req = {}
  room_invite_req.team_id = RoomId
  room_invite_req.target_id = TargetID
  room_invite_req.pos = Pos
  LogInfo("ReqRoomInvite reqInfo:", TableToString(room_invite_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.room_invite_req, room_invite_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_INVITE_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamExit(team_id)
  local team_exit_req = {}
  team_exit_req.team_id = team_id
  LogInfo("ReqTeamExit reqInfo:", TableToString(team_exit_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_exit_req, team_exit_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamKick(team_id, kick_id)
  local team_kick_req = {}
  team_kick_req.team_id = team_id
  team_kick_req.player_id = kick_id
  LogInfo("ReqTeamKick reqInfo:", TableToString(team_kick_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_kick_req, team_kick_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_KICK_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamReady(team_id, status)
  local team_ready_req = {}
  team_ready_req.team_id = team_id
  team_ready_req.status = status
  LogInfo("ReqTeamReady reqInfo:", TableToString(team_ready_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_ready_req, team_ready_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_READY_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamTransLeader(team_id, tar_uid)
  local team_trans_leader_req = {}
  team_trans_leader_req.team_id = team_id
  team_trans_leader_req.player_id = tar_uid
  LogInfo("ReqTeamTransLeader reqInfo:", TableToString(team_trans_leader_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_trans_leader_req, team_trans_leader_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_TRANS_LEADER_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamMode(TeamId, Mode, MapId)
  local team_mode_req = {}
  team_mode_req.team_id = TeamId
  team_mode_req.mode = Mode
  team_mode_req.map_id = MapId
  LogInfo("ReqTeamMode reqInfo:", TableToString(team_mode_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_mode_req, team_mode_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamInfo(TeamId)
  local team_query_req = {}
  team_query_req.team_id = TeamId
  LogInfo("ReqTeamInfo reqInfo:", TableToString(team_query_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.team_query_req, team_query_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_QUERY_REQ, req)
end
function RoomProxy:ReqTeamEnterPractice()
  local team_enter_practice_req = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.team_enter_practice_req, team_enter_practice_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_PRACTICE_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamLeavePractice()
  local team_leave_practice_req = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.team_leave_practice_req, team_leave_practice_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_LEAVE_PRACTICE_REQ, req, nil, nil, ProtocolFlag.NeedExplicitReconnect)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamRobotSet(difficulty)
  local team_robot_set_req = {}
  team_robot_set_req.difficulty = difficulty
  local req = pb.encode(Pb_ncmd_cs_lobby.team_robot_set_req, team_robot_set_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_ROBOT_SET_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqTeamEnter(roomCode)
  local team_enter_req = {}
  team_enter_req.room_code = roomCode
  local req = pb.encode(Pb_ncmd_cs_lobby.team_enter_req, team_enter_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_ENTER_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqPracticeRemind(playerId)
  local practice_remind_req = {}
  practice_remind_req.tar_player_id = playerId
  local req = pb.encode(Pb_ncmd_cs_lobby.practice_remind_req, practice_remind_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:ReqPracticeRemindReplyReq(bAgree)
  local practice_remind_reply_req = {}
  practice_remind_reply_req.agree = bAgree
  local req = pb.encode(Pb_ncmd_cs_lobby.practice_remind_reply_req, practice_remind_reply_req)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_PRACTICE_REMIND_REPLY_REQ, req)
  self:SetNetCheckTimer(true)
end
function RoomProxy:SetExpectMatchTime(val)
  self.expectMatchTime = val
end
function RoomProxy:CanReqJoinMatch(bShowLog)
  if 0 ~= self.ticket then
    if bShowLog then
      LogInfo("ReqQuitMatch Failed, The Ticked is not the zero.")
    end
    return false
  end
  if self.bIsReqJoinMatch then
    if bShowLog then
      LogInfo("ReqQuitMatch Failed, Requesting join match.")
    end
    return false
  end
  if self.useClientPenaltyTime > 0 then
    self:ShowPenaltyTips(self.cachedPenaltyTime, self.cachedPenaltyPlayerID)
    return false
  end
  return true
end
function RoomProxy:ShowPenaltyTips(penaltyTime, penaltyPlayerID)
  if 0 == penaltyTime then
    return
  end
  local penaltyTips = ""
  if penaltyPlayerID == self:GetPlayerID() then
    local text = "({0})"
    local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
    local arg1 = UE4.FFormatArgumentData()
    arg1.ArgumentName = "0"
    arg1.ArgumentValue = tostring(math.ceil(penaltyTime))
    arg1.ArgumentValueType = 4
    inArgsTarry:Add(arg1)
    penaltyTips = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PunishTime"), inArgsTarry)
  else
    local member = self:GetTeamMemberByPlayerID(penaltyPlayerID)
    if member then
      local text = "({0})"
      local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
      local arg1 = UE4.FFormatArgumentData()
      arg1.ArgumentName = "0"
      arg1.ArgumentValue = tostring(member.nick)
      arg1.ArgumentValueType = 4
      inArgsTarry:Add(arg1)
      local arg2 = UE4.FFormatArgumentData()
      arg2.ArgumentName = "1"
      arg2.ArgumentValue = tostring(math.ceil(penaltyTime))
      arg2.ArgumentValueType = 4
      inArgsTarry:Add(arg2)
      penaltyTips = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PunishTime1"), inArgsTarry)
    end
  end
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, penaltyTips)
end
function RoomProxy:GetTeamInfo()
  return self.teamInfo
end
function RoomProxy:GetMapTypeName(inMapID)
  local mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  for key, value in pairs(mapTableRows) do
    if value and value.Id == inMapID then
      local rowType = value.Type
      if rowType == RoomEnum.MapType.TeamSports then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamMode")
      elseif rowType == RoomEnum.MapType.BlastInvasion then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "BombMode")
      elseif rowType == RoomEnum.MapType.CrystalWar then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CrystaScrambleMode")
      elseif rowType == RoomEnum.MapType.Team5V5V5 then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Team5V5V5")
      elseif rowType == RoomEnum.MapType.TeamRiot3v3v3 then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamRiot3v3v3")
      end
    end
  end
  return ""
end
function RoomProxy:GetMapName(inMapID)
  local mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  for key, value in pairs(mapTableRows) do
    if value.Id == inMapID then
      return value.Name
    end
  end
  return ""
end
function RoomProxy:GetMapType(inMapID)
  local mapTableRows = {}
  mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  for key, value in pairs(mapTableRows) do
    if value.Id == inMapID then
      local rowType = value.Type
      return rowType
    end
  end
  return RoomEnum.MapType.None
end
function RoomProxy:GetCustomRoomMaxPlayerNumberByMapType(mapType)
  if mapType == RoomEnum.MapType.BlastInvasion then
    return 10
  elseif mapType == RoomEnum.MapType.TeamSports then
    return 10
  elseif mapType == RoomEnum.MapType.CrystalWar then
    return 10
  elseif mapType == RoomEnum.MapType.Team5V5V5 then
    return 15
  end
  return 0
end
function RoomProxy:GetMapByMapId(mapId)
  local mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  for key, value in pairs(mapTableRows) do
    if value.Id == mapId then
      return value
    end
  end
end
function RoomProxy:GetDefaultMapId(inModeType)
  local mapTableRows = self:GetMapListFromMapCfg()
  local mapList = self:GetMapList()
  for key, value in pairs(mapTableRows) do
    for k, v in pairs(mapList) do
      if value.Id == v and value.Type == inModeType then
        return v
      end
    end
  end
  return 101
end
function RoomProxy:GetMapListFromMapCfg()
  local mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  local newTable = {}
  for k, v in pairs(mapTableRows) do
    table.insert(newTable, v)
  end
  table.sort(newTable, function(a, b)
    return tonumber(a.order) < tonumber(b.order)
  end)
  return newTable
end
function RoomProxy:StartAutoRefuseSwitch(refuseId)
  local data = {}
  data.id = refuseId
  table.insert(self.refuseSwitchIDs, data)
  if not self.TimerHandle_RefuseSwitch:IsFinished() then
    self.TimerHandle_RefuseSwitch = TimerMgr:AddTimeTask(0, 1, 0, function()
      self:RefuseSwitchTimer()
    end)
  end
end
function RoomProxy:RefuseSwitchTimer()
  for key, value in pairs(self.refuseSwitchIDs) do
    if value then
      if value.time >= 0 then
        value.time = value.time - 1
      else
        self.refuseSwitchIDs[key] = nil
      end
    end
  end
  if 0 == #self.refuseSwitchIDs then
    self.TimerHandle_RefuseSwitch:EndTask()
  end
end
function RoomProxy:StartAutoRefuseInvite(refuseId)
  local data = {}
  data.id = refuseId
  if self.refuseInviteIDs then
    table.insert(self.refuseInviteIDs, data)
    if not self.TimerHandle_RefuseInvite:IsFinished() then
      self.TimerHandle_RefuseInvite = TimerMgr:AddTimeTask(0, 1, 0, function()
        self:RefuseInviteTimer()
      end)
    end
  end
end
function RoomProxy:RemoveAutoRefuseInvite(refuseId)
  local data = {}
  data.id = refuseId
  if self.teamInviteStack then
    for key, value in pairs(self.teamInviteStack) do
      if value and value.uid == refuseId then
        self.teamInviteStack[key] = nil
      end
    end
  end
  if self.refuseInviteIDs and 0 == #self.refuseInviteIDs then
    self.TimerHandle_RefuseInvite:EndTask()
  end
end
function RoomProxy:RefuseInviteTimer()
  if self.refuseInviteIDs then
    for key, value in pairs(self.refuseInviteIDs) do
      if value then
        if value.time >= 0 then
          value.time = value.time - 1
        else
          self.refuseInviteIDs[key] = nil
        end
      end
    end
    if 0 == #self.refuseInviteIDs then
      self.TimerHandle_RefuseInvite:EndTask()
    end
  end
end
function RoomProxy:StartRoomCountdown(inTime)
  self.remainTime = inTime
  self.TimerHandle_Countdown = TimerMgr:AddTimeTask(0, 1, 0, function()
    self:RoomCountdown()
  end)
end
function RoomProxy:RoomCountdown()
  if self.remainTime > 0 then
    GameFacade:SendNotification(NotificationDefines.TeamRoom.RemainCountdown, self.remainTime)
    self.remainTime = self.remainTime - 1
  else
    self.TimerHandle_Countdown:EndTask()
  end
end
function RoomProxy:GetRoomPlayerByPos(pos)
  for key, value in pairs(self:GetRoomPlayer()) do
    if value.pos == pos then
      return value
    end
  end
  return nil
end
function RoomProxy:GetRoomPlayer(playerId)
  for key, value in pairs(self:GetRoomPlayerList()) do
    if value.uid == playerId then
      return value
    end
  end
  return nil
end
function RoomProxy:GetRoomPlayerList()
  return self.roomPlayerList
end
function RoomProxy:SetRoomPlayerList(roomPlayerList)
  self.roomPlayerList = roomPlayerList
end
function RoomProxy:OnMatchResultResCallback(bResult)
  if bResult and self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      value.status = RoomEnum.TeamMemberStatusType.Ready
    end
  end
end
function RoomProxy:OnTeamInviteNtfCallback(inInviteInfo)
  if self.refuseInviteIDs then
    for key, value in pairs(self.refuseInviteIDs) do
      if inInviteInfo.uid == value.id then
        return
      end
    end
  end
  if friendDataProxy then
    if friendDataProxy.currentSocialType == FriendEnum.SocialSecretType.Private then
      return
    elseif friendDataProxy.currentSocialType == FriendEnum.SocialSecretType.Friend and friendDataProxy.allFriendMap[inInviteInfo.uid] then
      return
    end
  end
  local bHave = false
  if #self.teamInviteStack > 0 then
    for i = 1, #self.teamInviteStack do
      local info = self.teamInviteStack[i]
      if info.uid == inInviteInfo.uid then
        bHave = true
        self.teamInviteStack[index] = inInviteInfo
        break
      end
    end
  end
  if not bHave then
    table.insert(self.teamInviteStack, inInviteInfo)
  end
  ViewMgr:OpenPage(LuaGetWorld(), "BeInvitePagePC")
  GameFacade:SendNotification(NotificationDefines.RankRoom.OnTeamInviteNtf, self.teamInviteStack)
end
function RoomProxy:OnTeamApplyNtfCallback(inApplyInfo)
  if self.refuseInviteIDs then
    for key, value in pairs(self.refuseInviteIDs) do
      if inApplyInfo.uid == value.id then
        return
      end
    end
  end
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    if friendDataProxy.currentSocialType == FriendEnum.SocialSecretType.Private then
      return
    elseif friendDataProxy.currentSocialType == FriendEnum.SocialSecretType.Friend and friendDataProxy.allFriendMap[inApplyInfo.uid] then
      return
    end
  end
  local bHave = false
  if self.teamApplyStack and #self.teamApplyStack > 0 then
    for i = 1, #self.teamApplyStack do
      local info = self.teamApplyStack[i]
      if info.uid == inApplyInfo.uid then
        bHave = self.teamApplyStack
        table.remove(self.teamApplyStack, i)
        table.insert(self.teamApplyStack, inApplyInfo)
        break
      end
    end
  end
  if not self.teamApplyStack then
    self.teamApplyStack = {}
  end
  if not bHave then
    table.insert(self.teamApplyStack, inApplyInfo)
  end
  ViewMgr:OpenPage(LuaGetWorld(), "TeamApplyPC")
end
function RoomProxy:OnFriendListResCallback(inFriendList)
  if 0 ~= #inFriendList then
    self.friendList = inFriendList
  end
end
function RoomProxy:GetTeamInfoMember()
  local memberNum = 0
  if self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      memberNum = memberNum + 1
    end
  end
  return memberNum
end
function RoomProxy:OnTeamReplyNtfCallback(inReply)
  if inReply.sure == RoomEnum.TeamMemberStatusType.NotReady then
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RefuseInviteDCText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function RoomProxy:OnTeamApplyReplyNtfCallback(inReply)
  if inReply.sure == RoomEnum.TeamMemberStatusType.NotReady then
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RefuseApplyDCText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function RoomProxy:OnTeamTransLeaderNtfCallback(inLeaderId)
  if self.teamInfo and self.teamInfo.leaderId then
    local oldLeaderId = self.teamInfo.leaderId
    local newLeaderId = inLeaderId
    local oldLeaderName = ""
    local newLeaderName = ""
    if self.teamInfo.members then
      for key, value in pairs(self.teamInfo.members) do
        if value.playerId == oldLeaderId then
          oldLeaderName = value.nick
        elseif value.playerId == newLeaderId then
          value.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim
          newLeaderName = value.nick
          local arg1 = UE4.FFormatArgumentData()
          arg1.ArgumentName = "0"
          arg1.ArgumentValue = newLeaderName
          arg1.ArgumentValueType = 4
          local inArgsTarry2 = UE4.TArray(UE4.FFormatArgumentData)
          inArgsTarry2:Add(arg1)
          local newTeamMasterText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamMasterTransfer")
          newTeamMasterText = UE4.UKismetTextLibrary.Format(newTeamMasterText, inArgsTarry2)
          GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, newTeamMasterText)
        end
      end
      for key, value in pairs(self.teamInfo.members) do
        if self:GetPlayerID() == value.playerId then
          if value.playerId == oldLeaderId then
            local infoString = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TransSourceDCText")
            local arg1 = UE4.FFormatArgumentData()
            arg1.ArgumentName = "PlayerName"
            arg1.ArgumentValue = newLeaderName
            arg1.ArgumentValueType = 4
            local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
            inArgsTarry:Add(arg1)
            local tempText = UE4.UKismetTextLibrary.Format(infoString, inArgsTarry)
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tempText)
            break
          elseif value.playerId == newLeaderId then
            local infoString = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TransTargetDCText")
            local arg1 = UE4.FFormatArgumentData()
            arg1.ArgumentName = "PlayerName"
            arg1.ArgumentValue = oldLeaderName
            arg1.ArgumentValueType = 4
            local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
            inArgsTarry:Add(arg1)
            local tempText = UE4.UKismetTextLibrary.Format(infoString, inArgsTarry)
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tempText)
            break
          end
        end
      end
    end
    self.teamInfo.leaderId = inLeaderId
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnTeamTransLeaderNtf, inLeaderId)
  end
end
function RoomProxy:OnQuitMatchNtfCallback()
  local teamInfo = self:GetTeamInfo()
  if teamInfo then
    for key, value in pairs(teamInfo.members) do
      value.status = RoomEnum.TeamMemberStatusType.Ready
    end
  end
  self:SetLockEditRoomInfo(false)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.OnQuitMatchNtf)
end
function RoomProxy:SetTeamMember(inMember)
  if self:GetPlayerID() and inMember.playerId == self:GetPlayerID() then
    self.playerTeamMemberInfo = inMember
  end
  if self.teamInfo and self.teamInfo.members then
    table.insert(self.teamInfo.members, inMember)
    local memberNum = 0
    for key, value in pairs(self.teamInfo.members) do
      if value then
        memberNum = memberNum + 1
      end
    end
    if memberNum > 1 then
      table.sort(self.teamInfo.members, function(a, b)
        if a and b then
          return a.pos < b.pos
        end
        return false
      end)
    end
  end
end
function RoomProxy:SetMatchTimeOut(newTimeOut)
  if not self.matchResult then
    self.matchResult = {}
  end
  self.matchResult.timeOut = newTimeOut
end
function RoomProxy:RemoveTeamMember(inPlayerID)
  if self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      local member = value
      if member.playerId == inPlayerID then
        if member.playerId == self:GetPlayerID() then
          self.PlayerTeamMemberInfo = nil
        end
        table.remove(self.teamInfo.members, key)
        local memberNum = 0
        for key, value in pairs(self.teamInfo.members) do
          if value then
            memberNum = memberNum + 1
          end
        end
        if memberNum > 1 then
          table.sort(self.teamInfo.members, function(a, b)
            if a and b then
              return a.pos < b.pos
            end
            return false
          end)
        end
        break
      end
    end
  end
  if inPlayerID and self.practiceRemindMap[inPlayerID] then
    self.practiceRemindMap[inPlayerID] = nil
  end
end
function RoomProxy:ShowKickMsg(inPlayerID)
  if self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      local member = value
      if member.playerId == inPlayerID then
        if member.playerId == self:GetPlayerID() then
          local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberKickedOutRoomText")
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
        else
          local arg1 = UE4.FFormatArgumentData()
          arg1.ArgumentName = "PlayerName"
          arg1.ArgumentValue = member.nick
          arg1.ArgumentValueType = 4
          local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
          inArgsTarry:Add(arg1)
          if self:IsTeamLeader() then
            local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MasterKickMemberRoomText")
            local showMsgText = UE4.UKismetTextLibrary.Format(showMsg, inArgsTarry)
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsgText)
          else
            local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberExitRoomText")
            local showMsgText = UE4.UKismetTextLibrary.Format(showMsg, inArgsTarry)
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsgText)
          end
          local arg1 = UE4.FFormatArgumentData()
          arg1.ArgumentName = "0"
          arg1.ArgumentValue = member.nick
          arg1.ArgumentValueType = 4
          local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
          inArgsTarry:Add(arg1)
          local memberKickedText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberKicked")
          memberKickedText = UE4.UKismetTextLibrary.Format(memberKickedText, inArgsTarry)
          GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, memberKickedText)
        end
      end
    end
  end
end
function RoomProxy:ShowExitMsg(inPlayerID)
  if self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      if value.playerId == inPlayerID and not value.bIsRobot then
        local arg1 = UE4.FFormatArgumentData()
        arg1.ArgumentName = "PlayerName"
        arg1.ArgumentValue = value.nick
        arg1.ArgumentValueType = 4
        local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
        inArgsTarry:Add(arg1)
        local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberExitRoomText")
        local showMsgText = UE4.UKismetTextLibrary.Format(showMsg, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsgText)
        local arg2 = UE4.FFormatArgumentData()
        arg2.ArgumentName = "0"
        arg2.ArgumentValue = value.nick
        arg2.ArgumentValueType = 4
        local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
        inArgsTarry:Add(arg2)
        local memberQuitTeamText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MemberQuitTeam")
        memberQuitTeamText = UE4.UKismetTextLibrary.Format(memberQuitTeamText, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, memberQuitTeamText)
      end
    end
  end
end
function RoomProxy:GetTeamMemberByPlayerID(playerId)
  if self.teamInfo then
    for key, value in pairs(self.teamInfo.members) do
      if value.playerId == playerId then
        return value
      end
    end
  end
  return nil
end
function RoomProxy:GetPlayerID()
  return GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetPlayerID()
end
function RoomProxy:GetRoomPageType()
  if not gameModeSelectProxy:GetBackToHomePage() and not self.bIsReqJoinMatch and self.teamInfo and self.teamInfo.mode then
    if self.teamInfo.mode == GameModeSelectNum.GameModeType.Room then
      return RoomEnum.ClientPlayerPageType.Room
    elseif self.teamInfo.mode ~= GameModeSelectNum.GameModeType.None then
      return RoomEnum.ClientPlayerPageType.Team
    end
  end
  return RoomEnum.ClientPlayerPageType.Lobby
end
function RoomProxy:GetGameModeTypeByPlayMode(playMode, bMatchOpen, bRankOpen)
  if playMode then
    if playMode == RoomEnum.MapType.TeamSports then
      return GameModeSelectNum.GameModeType.Team
    elseif playMode == RoomEnum.MapType.BlastInvasion then
      if bMatchOpen then
        return GameModeSelectNum.GameModeType.Boomb
      end
      if bRankOpen then
        return GameModeSelectNum.GameModeType.RankBomb
      end
      return GameModeSelectNum.GameModeType.Boomb
    elseif playMode == RoomEnum.MapType.CrystalWar then
      return GameModeSelectNum.GameModeType.CrystalScramble
    elseif playMode == RoomEnum.MapType.Team5V5V5 then
      return GameModeSelectNum.GameModeType.Team5V5V5
    end
  else
    LogDebug("RoomProxy", "GetGameModeTypeByPlayMode playMode is nil")
  end
  return GameModeSelectNum.GameModeType.None
end
function RoomProxy:GetGameModeType()
  if self.teamInfo and self.teamInfo.mode then
    if self.teamInfo.mode == GameModeSelectNum.GameModeType.Room then
      return GameModeSelectNum.GameModeType.Room
    elseif self.teamInfo.mode ~= GameModeSelectNum.GameModeType.None then
      return GameModeSelectNum.GameModeType.Team
    end
  end
  return GameModeSelectNum.GameModeType.None
end
function RoomProxy:GetGameMode()
  if self.teamInfo and self.teamInfo.mode then
    return self.teamInfo.mode
  end
  return GameModeSelectNum.GameModeType.None
end
function RoomProxy:SetLockEditRoomInfo(bLock)
  self.bLockEditRoomInfo = bLock
end
function RoomProxy:GetLockEditRoomInfo()
  return self.bLockEditRoomInfo
end
function RoomProxy:IsTeamLeader()
  if self.teamInfo and self.teamInfo.leaderId and self:GetPlayerID() then
    return self:GetPlayerID() == self.teamInfo.leaderId
  elseif not self.teamInfo then
    LogInfo("IsTeamLeader:", "teamInfo is nil")
  elseif not self.teamInfo.leaderId then
    LogInfo("IsTeamLeader:", "leaderId is nil")
  elseif not self:GetPlayerID() then
    LogInfo("IsTeamLeader:", "GetPlayerID is nil")
  else
    LogInfo("IsTeamLeader:", "leaderId=" .. tostring(self.teamInfo.leaderId) .. "  playerId=" .. tostring(self:GetPlayerID()))
  end
  return false
end
function RoomProxy:PlayerIsTeamLeader(playerId)
  if self.teamInfo and self.teamInfo.leaderId and playerId then
    return playerId == self.teamInfo.leaderId
  end
  return false
end
function RoomProxy:IsRoomMaster()
  return self:IsTeamLeader()
end
function RoomProxy:GetIsInMatch()
  return self.bIsReqJoinMatch
end
function RoomProxy:GetExpectMatchTime()
  return self.expectMatchTime
end
function RoomProxy:SetInMatchPrepareState(inMatchPrepareState)
  self.bInMatchPrepareState = inMatchPrepareState
end
function RoomProxy:IsInMatchPrepare()
  return self.bInMatchPrepareState
end
function RoomProxy:GetDSUrl()
  local friendProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  LogDebug("@@@", tostring(friendProxy))
  local playerId = friendProxy:GetPlayerID()
  local openUrl = string.format("%s:%s?UID=%s?TOKEN=%s?ROOM=%s", self.dsip, tostring(self.dsport), tostring(playerId), self.token, self.roomId)
  LogDebug("RoomProxy", "OpenDSUR:" .. openUrl)
  return openUrl
end
function RoomProxy:QueryRoomStatusForReconnect()
  local lobbyService = GetLobbyServiceHandle()
  local reqTable = {}
  reqTable.room_id = self.roomId
  LogDebug("RoomProxy", "QueryRoomStatusForReconnect Request...%s", self.roomId)
  local req = pb.encode(Pb_ncmd_cs_lobby.query_room_status_req, reqTable)
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_QUERY_ROOM_STATUS_REQ, req, Pb_ncmd_cs.NCmdId.NID_QUERY_ROOM_STATUS_RES, FuncSlot(function(data)
    local response = pb.decode(Pb_ncmd_cs_lobby.query_room_status_res, data)
    LogDebug("RoomProxy", [[
QueryRoomStatusForReconnect query_room_status_res Response %s
%s]], response, TableToString(response))
    GameFacade:SendNotification(NotificationDefines.ReConnectToDS, response, NotificationDefines.ReConnectToDSType.QueryRoomStatus)
  end), ProtocolFlag.NeedExplicitReconnect)
end
function RoomProxy:CanPlaySequence()
  if self.teamInfo and self.teamInfo.teamId and 0 ~= self.teamInfo.teamId then
    return false
  end
  return true
end
function RoomProxy:GetMatchResult()
  return self.matchResult
end
function RoomProxy:HasValidMatchResult()
  if self:GetMatchResult() and self:GetMatchResult().roomId > 0 then
    return true
  end
  return false
end
function RoomProxy:SendRoomReconnectReq()
  local lobbyService = GetLobbyServiceHandle()
  local reqTable = {}
  reqTable.sure = 1
  LogDebug("RoomProxy", "SendRoomReconnectReq...")
  local req = pb.encode(Pb_ncmd_cs_lobby.room_reconnect_req, reqTable)
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_ROOM_RECONNECT_REQ, req)
end
function RoomProxy:CheckIsInGame()
  local gamestate = LuaGetWorld().GameState
  if gamestate and gamestate.GetModeType and gamestate:GetModeType() ~= UE4.EPMGameModeType.FrontEnd then
    return true
  else
    return false
  end
end
function RoomProxy:SetRecentlySelectedMode(selectedMode)
  if self.recentlySelectedMode and selectedMode then
    self.recentlySelectedMode = selectedMode
  end
end
function RoomProxy:GetRecentlySelectedMode()
  if self.recentlySelectedMode then
    return self.recentlySelectedMode
  end
end
function RoomProxy:SetRoomMapID(mapId)
  if self.teamInfo then
    self.teamInfo.mapID = mapId
  end
end
function RoomProxy:SetEnterPracticeStatus(bEnter)
  self.bEnter = bEnter
end
function RoomProxy:GetEnterPracticeStatus()
  if self.bEnter then
    return self.bEnter
  end
  return false
end
function RoomProxy:GetCurrentAiLevel()
  if self.teamInfo and self.teamInfo.difficulty then
    return self.teamInfo.difficulty
  end
  return nil
end
function RoomProxy:GetAllPlayerReady()
  local bAllPlayerReady = true
  local tempTeamInfo = self:GetTeamInfo()
  if tempTeamInfo and tempTeamInfo.members then
    for key, value in pairs(tempTeamInfo.members) do
      if value.playerId ~= tempTeamInfo.leaderId and value.status ~= RoomEnum.TeamMemberStatusType.Ready then
        bAllPlayerReady = false
        break
      end
    end
  end
  return bAllPlayerReady
end
function RoomProxy:GetRoomCode()
  local tempTeamInfo = self:GetTeamInfo()
  if tempTeamInfo and tempTeamInfo.roomCode and 0 ~= tempTeamInfo.roomCode then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(tostring(tempTeamInfo.roomCode))
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RoomCodePasteSuccess")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  else
    self:ReqTeamGenRoomCode()
  end
  return nil
end
function RoomProxy:GetMapList()
  return self.mapList
end
function RoomProxy:GetIsInTeamCompetition()
  if self.teamInfo and self.teamInfo.special and 1 == self.teamInfo.special then
    return true
  end
  return false
end
function RoomProxy:GetRoomIsNotFirstOpen()
  if self.teamInfo and self.teamInfo.bNotFirstOpen then
    return self.teamInfo.bNotFirstOpen
  end
  return false
end
function RoomProxy:SetRoomIsNotFirstOpen(bNotFirstOpen)
  if self.teamInfo then
    self.teamInfo.bNotFirstOpen = bNotFirstOpen
  end
end
function RoomProxy:ClearPenaltyTimerHandle()
  if self.penaltyTimerHandle then
    self.penaltyTimerHandle:EndTask()
    self.penaltyTimerHandle = nil
  end
end
function RoomProxy:SetKeepIgnoreExchangePositionReq(bValue)
  self.bKeepIgnoreExchangePositionReq = bValue
end
function RoomProxy:GetKeepIgnoreExchangePositionReq()
  return self.bKeepIgnoreExchangePositionReq
end
function RoomProxy:GetCurrentModeIsTeam3v3v3Mode()
  if self.teamInfo and self.teamInfo.mode and self.teamInfo.mode == GameModeSelectNum.GameModeType.Team3V3V3 then
    return true
  end
  return false
end
function RoomProxy:GetPlayerFightPositionNumberInCustomRoom()
  local playerFightPositionNumber = 0
  if self.teamInfo and self.teamInfo.members then
    local mapPlayMode = self:GetMapType(self.teamInfo.mapID)
    if mapPlayMode and mapPlayMode > RoomEnum.MapType.None then
      local maxPlayerNumber = self:GetCustomRoomMaxPlayerNumberByMapType(mapPlayMode)
      for k, value in pairs(self.teamInfo.members) do
        if value and value.pos and maxPlayerNumber >= value.pos then
          playerFightPositionNumber = playerFightPositionNumber + 1
        end
      end
    end
  end
  return playerFightPositionNumber
end
function RoomProxy:GetPlayerNumberInRoom()
  if self.teamInfo and self.teamInfo.members then
    return #self.teamInfo.members
  end
  return 0
end
function RoomProxy:GetPlayerPositionByPlayerId(playerId)
  if self.teamInfo and self.teamInfo.members then
    for key, value in pairs(self.teamInfo.members) do
      if value and value.playerId and playerId == value.playerId then
        return value.pos
      end
    end
  end
  return -1
end
function RoomProxy:GetTeamMemberList()
  if self.teamInfo and self.teamInfo.members then
    local teamMemberList = {}
    for key, value in pairs(self.teamInfo.members) do
      local info = {}
      info.pos = value.pos
      info.playerId = value.playerId
      info.nick = value.nick
      info.icon = value.icon
      info.sex = value.sex
      info.ready = value.ready
      info.level = value.level
      info.rank = value.rank
      info.avatarId = value.avatarId
      info.frameId = value.frameId
      info.borderId = value.borderId
      info.achievementId = value.achievementId
      info.stars = value.stars
      info.status = value.status
      info.bIsRobot = value.bIsRobot
      info.bEnterPractice = value.bEnterPractice
      info.offline = value.offline
      table.insert(teamMemberList, info)
    end
    return teamMemberList
  end
  return nil
end
function RoomProxy:GetRoomMemberList()
  if self.matchResult and self.matchResult.playerInfos then
    local roomMemberList = {}
    for key, value in pairs(self.matchResult.playerInfos) do
      local playerInfo = {}
      playerInfo.teamId = value.teamId
      playerInfo.playerId = value.playerId
      playerInfo.isRobot = value.isRobot
      playerInfo.nick = value.nick
      playerInfo.icon = value.icon
      playerInfo.sex = value.sex
      playerInfo.rank = value.rank
      playerInfo.status = value.status
      playerInfo.uIPos = value.uIPos
      playerInfo.level = value.level
      playerInfo.avatarId = value.avatarId
      playerInfo.frameId = value.frameId
      playerInfo.borderId = value.borderId
      playerInfo.achievementId = value.achievementId
      playerInfo.stars = value.stars
      playerInfo.readyConfirm = value.readyConfirm
      playerInfo.offline = value.offline
      table.insert(roomMemberList, playerInfo)
    end
    return roomMemberList
  end
  return nil
end
function RoomProxy:IsPlayerTeammate(targetPlayerId)
  if self.matchResult and self.matchResult.playerInfos then
    local selfId = self:GetPlayerID()
    local selfTeamId = -1
    local targetPlayerTeamId = -1
    for key, value in pairs(self.matchResult.playerInfos) do
      if value.playerId == selfId then
        selfTeamId = value.teamId
      elseif value.playerId == targetPlayerId then
        targetPlayerTeamId = value.teamId
      end
    end
    if selfTeamId > 0 and targetPlayerTeamId > 0 and selfTeamId == targetPlayerTeamId then
      return true
    end
  end
  return false
end
function RoomProxy:GetTeamMemberCount()
  if self.teamInfo and self.teamInfo.members then
    local MemberCount = 0
    for key, value in pairs(self.teamInfo.members) do
      if not value.bIsRobot then
        MemberCount = MemberCount + 1
      end
    end
    return MemberCount
  end
  return 0
end
function RoomProxy:GetTeamMemberCountInBattlePosition()
  local playerMaxNum = 10
  local roomInfo = self.teamInfo
  if roomInfo and roomInfo.mapID then
    local mapPlayMode = self:GetMapType(roomInfo.mapID)
    if mapPlayMode == RoomEnum.MapType.Team5V5V5 then
      playerMaxNum = 15
    else
      playerMaxNum = 10
    end
  end
  if self.teamInfo and self.teamInfo.members then
    local MemberCount = 0
    for key, value in pairs(self.teamInfo.members) do
      if not value.bIsRobot and value.pos and playerMaxNum >= value.pos then
        MemberCount = MemberCount + 1
      end
    end
    return MemberCount
  end
  return 0
end
function RoomProxy:SetStartGameStatus(status)
  self.bStartGame = status
end
function RoomProxy:GetStartGameStatus()
  return self.bStartGame
end
function RoomProxy:SetIsInRankOrRoomUI(bIn)
  self.bIsInRankOrRoomUI = bIn
end
function RoomProxy:GetIsInRankOrRoomUI()
  return self.bIsInRankOrRoomUI
end
function RoomProxy:PlayerIsAlreadyPracticeRemind(playerId)
  if self.practiceRemindMap[playerId] then
    return true
  end
  return false
end
function RoomProxy:ClearMatchResult()
  self.matchResult = nil
end
function RoomProxy:SetModeDatas(datas)
  self.modeDatas = datas
end
function RoomProxy:GetModeDatas()
  if self.modeDatas then
    return self.modeDatas
  else
    LogInfo("GetModeDatas:", "modeDatas is nil")
    return nil
  end
end
function RoomProxy:SetNetCheckTimer(bOpen)
  if bOpen then
    if self.NetCheckTimer then
      LogInfo("RoomProxy SetNetCheckTimer", "Is in net check timer")
      return
    else
      LogInfo("RoomProxy SetNetCheckTimer", "netCheckTime:" .. tostring(self.netCheckTime))
      self.NetCheckTimer = TimerMgr:AddTimeTask(self.netCheckTime, 0, 1, function()
        LogInfo("RoomProxy SetNetCheckTimer", "net check timer is ending")
        ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RoomPendingPage)
        self.NetCheckTimer:EndTask()
        self.NetCheckTimer = nil
      end)
    end
  else
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RoomPendingPage)
    if self.NetCheckTimer then
      self.NetCheckTimer:EndTask()
      self.NetCheckTimer = nil
    end
  end
end
function RoomProxy:SetRoomNetCheckTime(timeNum)
  self.netCheckTime = timeNum
end
return RoomProxy
