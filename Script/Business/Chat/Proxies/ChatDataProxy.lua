local ChatDataProxy = class("ChatDataProxy", PureMVC.Proxy)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function ChatDataProxy:SetShowChatMsg(bShow)
  LogDebug("ChatDataProxy", "Show chat msg:%s", tostring(bShow))
  self.bShowChaMsg = bShow
end
function ChatDataProxy:GetShowChatMsg()
  return self.bShowChaMsg
end
function ChatDataProxy:GetGroupChatList()
  return self.groupChatList
end
function ChatDataProxy:AddToChatBlacklist(playerId, isAdd)
  self.chatBlacklist[playerId] = isAdd
end
function ChatDataProxy:IsInChatBlacklist(playerId)
  return self.chatBlacklist[playerId]
end
function ChatDataProxy:AddToBlacklist(playerId)
  self:AddToChatBlacklist(playerId, true)
end
function ChatDataProxy:IsInCustomRoom()
  return self.isCustomRoom
end
function ChatDataProxy:GetChatEmotionList()
  return self.chatEmotion
end
function ChatDataProxy:GetChatEmotionCfg(emotionId)
  return self.chatEmotion[tostring(emotionId)]
end
function ChatDataProxy:AddFavorEmotion(emoteCfg)
  if emoteCfg then
    for key, value in pairs(self.favorEmotions) do
      if value.id == emoteCfg.id then
        table.remove(self.favorEmotions, key)
      end
    end
    table.insert(self.favorEmotions, 1, emoteCfg)
    if table.count(self.favorEmotions) > 5 then
      table.remove(self.favorEmotions)
    end
    GameFacade:SendNotification(NotificationDefines.Chat.AddFavorEmotion)
  end
end
function ChatDataProxy:GetFavorEmotion()
  return self.favorEmotions
end
function ChatDataProxy:GetPrivateMsg()
  for _, value in pairsByKeys(self.offlineMsgs, function(a, b)
    return self.offlineMsgs[a].time < self.offlineMsgs[b].time
  end) do
    self:ReserveMsg(value.src_player_id, value.src_nick, value.icon, value.time, value.msg)
  end
  self.offlineMsgs = {}
  self.hasInitChatPanel = true
  return self.privateMsgList
end
function ChatDataProxy:GetGroupMsg()
  return self.groupMsgList
end
function ChatDataProxy:OnRegister()
  LogDebug("ChatDataProxy", "Register Chat Data Proxy")
  ChatDataProxy.super.OnRegister(self)
  self.bShowChaMsg = true
  self.groupChatList = {}
  self.offlineMsgs = {}
  self.privateMsgList = {}
  self.groupMsgList = {}
  self.hasInitChatPanel = false
  self.chatBlacklist = {}
  self.bMicIsEnable = false
  self.joinTeamCDList = {}
  self.chatEmotion = {}
  self.favorEmotions = {}
  self:InitChatEmotionCfg()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_SEND_RES, FuncSlot(self.OnResChatSend, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_RECV_NTF, FuncSlot(self.OnNtfChatRecv, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_INFO_ALL_NTF, FuncSlot(self.OnNtfChatGroupAllInfo, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_INFO_NTF, FuncSlot(self.OnNtfChatGroupInfo, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_MEMBER_NTF, FuncSlot(self.OnNtfChatGroupMember, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_QUIT_NTF, FuncSlot(self.OnNtfChatGroupQuit, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_SEND_RES, FuncSlot(self.OnResChatGroupSend, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_RECV_NTF, FuncSlot(self.OnNtfChatGroupRecv, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_DESTORY_NTF, FuncSlot(self.OnNtfChatGroupDestroy, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_NTF, FuncSlot(self.OnNtfTeamMode, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_NTF, FuncSlot(self.OnNtfTeamExit, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_QUERY_RES, FuncSlot(self.OnResTeamQuery, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_MEMBER_MIC_RES, FuncSlot(self.OnResMicState, self))
  end
  self.OnNavigatePlayerInfoHandle = DelegateMgr:AddDelegate(GetGlobalDelegateManager().OnNavigatePlayerInfo, self, "AddFriend")
  self.OnNavigateJoinTeamHandle = DelegateMgr:AddDelegate(GetGlobalDelegateManager().OnNavigateJoinTeam, self, "JoinTeam")
  self.OnShieldPlayerHandle = DelegateMgr:AddDelegate(GetGlobalDelegateManager().OnPlayreForbidStateChangeDelegate, self, "AddToChatBlacklist")
end
function ChatDataProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_SEND_RES, FuncSlot(self.OnResChatSend, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_RECV_NTF, FuncSlot(self.OnNtfChatRecv, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_INFO_ALL_NTF, FuncSlot(self.OnNtfChatGroupAllInfo, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_INFO_NTF, FuncSlot(self.OnNtfChatGroupInfo, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_MEMBER_NTF, FuncSlot(self.OnNtfChatGroupMember, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_QUIT_NTF, FuncSlot(self.OnNtfChatGroupQuit, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_SEND_RES, FuncSlot(self.OnResChatGroupSend, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_RECV_NTF, FuncSlot(self.OnNtfChatGroupRecv, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_DESTORY_NTF, FuncSlot(self.OnNtfChatGroupDestroy, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_NTF, FuncSlot(self.OnNtfTeamMode, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_NTF, FuncSlot(self.OnNtfTeamExit, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_QUERY_RES, FuncSlot(self.OnResTeamQuery, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_MEMBER_MIC_RES, FuncSlot(self.OnResMicState, self))
  end
  DelegateMgr:RemoveDelegate(GetGlobalDelegateManager().OnNavigatePlayerInfo, self.OnNavigatePlayerInfoHandle)
  DelegateMgr:RemoveDelegate(GetGlobalDelegateManager().OnNavigateJoinTeam, self.OnNavigateJoinTeamHandle)
  DelegateMgr:RemoveDelegate(GetGlobalDelegateManager().OnPlayreForbidStateChangeDelegate, self.OnShieldPlayerHandle)
  ChatDataProxy.super.OnRemove(self)
end
function ChatDataProxy:SendChatReq(targetPlayerId, chatMsg, contextId, chatName)
  self.currentChatName = chatName
  local data = {
    tar_player_id = targetPlayerId,
    msg = chatMsg,
    context_id = contextId
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_CHAT_SEND_REQ, pb.encode(Pb_ncmd_cs_lobby.chat_send_req, data))
end
function ChatDataProxy:SendMicStateReq()
  local PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if PMVoiceManager and (PMVoiceManager:IsInRoomVoiceChannel() or PMVoiceManager:IsInTeamVoiceChannel()) then
    local groupID
    if self.groupChatList[ChatEnum.EChatChannel.fight] then
      groupID = self.groupChatList[ChatEnum.EChatChannel.fight].group_id
    elseif self.groupChatList[ChatEnum.EChatChannel.room] then
      groupID = self.groupChatList[ChatEnum.EChatChannel.room].group_id
    elseif self.groupChatList[ChatEnum.EChatChannel.team] then
      groupID = self.groupChatList[ChatEnum.EChatChannel.team].group_id
    else
      return
    end
    self.bMicIsEnable = UE4.UPMVoiceManager.Get(LuaGetWorld()):GetMicIsEnable()
    local data = {
      group_id = groupID,
      mic_flag = self.bMicIsEnable
    }
    LogDebug("ChatDataProxy", "SendMicStateReq:  groupID = %s mic_flag = %s ", groupID, self.bMicIsEnable)
    SendRequest(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_MEMBER_MIC_REQ, pb.encode(Pb_ncmd_cs_lobby.chat_group_member_mic_req, data))
  end
end
function ChatDataProxy:OnResMicState(data)
  local res = pb.decode(Pb_ncmd_cs_lobby.chat_group_member_mic_res, data)
  LogDebug("ChatDataProxy", "OnResMicState:" .. TableToString(res))
end
function ChatDataProxy:SendGroupChatReq(groupType, chatMsg, contextId, teamId)
  if self.groupChatList[groupType] then
    local groupId = self.groupChatList[groupType].group_id
    local teamIdShow = teamId or 0
    LogDebug("ChatDataProxy", "Send group msg, group id: " .. groupId .. ", team id: " .. teamIdShow)
    local data = {
      group_id = groupId,
      msg = chatMsg,
      context_id = contextId,
      team_id = teamId
    }
    SendRequest(Pb_ncmd_cs.NCmdId.NID_CHAT_GROUP_SEND_REQ, pb.encode(Pb_ncmd_cs_lobby.chat_group_send_req, data))
  else
    LogDebug("ChatDataProxy", "Group type: %d doesn't exist", groupType)
  end
end
function ChatDataProxy:OnResChatSend(data)
  local chatSendRes = pb.decode(Pb_ncmd_cs_lobby.chat_send_res, data)
  if 0 == chatSendRes.code then
    self:ReserveMsg(nil, self.currentChatName, nil, os.time(), chatSendRes.msg, chatSendRes.tar_player_id)
  end
  GameFacade:SendNotification(NotificationDefines.Chat.SendMsgReback, chatSendRes, NotificationDefines.Chat.MsgType.Private)
end
function ChatDataProxy:OnNtfChatRecv(data)
  local chatRecvNtf = pb.decode(Pb_ncmd_cs_lobby.chat_recv_ntf, data)
  if chatRecvNtf.src_player_id and self.chatBlacklist[chatRecvNtf.src_player_id] then
    return
  end
  if chatRecvNtf.time == nil or 0 == chatRecvNtf.time or self.hasInitChatPanel then
    local msgTime = (chatRecvNtf.time == nil or 0 == chatRecvNtf.time) and os.time() or chatRecvNtf.time
    self:ReserveMsg(chatRecvNtf.src_player_id, chatRecvNtf.src_nick, nil, msgTime, chatRecvNtf.msg)
    GameFacade:SendNotification(NotificationDefines.Chat.RecvMsg, chatRecvNtf, NotificationDefines.Chat.MsgType.Private)
  else
    table.insert(self.offlineMsgs, chatRecvNtf)
  end
end
function ChatDataProxy:OnNtfChatGroupAllInfo(data)
  local chatGroupInfoAllNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_info_all_ntf, data)
  LogDebug("ChatDataProxy", "OnNtfChatGroupAllInfo:" .. TableToString(chatGroupInfoAllNtf))
  local groupTypeList = {}
  for _, value in pairs(chatGroupInfoAllNtf.items) do
    groupTypeList[value.group_type] = true
    if self.groupChatList[value.group_type] then
      self.groupChatList[value.group_type] = value
      GameFacade:SendNotification(NotificationDefines.Chat.ModifyChatGroupInfo, value)
    else
      self:CreateNewChatGroup(value)
    end
  end
  for key, value in pairs(self.groupChatList) do
    if not groupTypeList[key] then
      self:DeleteGroup(value.group_id)
      GameFacade:SendNotification(NotificationDefines.Chat.MemberExit, value)
    end
  end
end
function ChatDataProxy:OnNtfChatGroupInfo(data)
  local chatGroupInfoNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_info_ntf, data)
  LogDebug("ChatDataProxy", "OnNtfChatGroupInfo:" .. TableToString(chatGroupInfoNtf))
  self:CreateNewChatGroup(chatGroupInfoNtf)
end
function ChatDataProxy:CreateNewChatGroup(chatGroupInfo)
  local oldChatGroupInfo
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.team and self.groupChatList[ChatEnum.EChatChannel.room] then
    LogDebug("ChatDataProxy", "Change to team...")
    oldChatGroupInfo = self.groupChatList[ChatEnum.EChatChannel.room]
  end
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.room and self.groupChatList[ChatEnum.EChatChannel.team] then
    LogDebug("ChatDataProxy", "Change to custom room...")
    oldChatGroupInfo = self.groupChatList[ChatEnum.EChatChannel.team]
  end
  if oldChatGroupInfo then
    self:DeleteGroup(oldChatGroupInfo.group_id)
    GameFacade:SendNotification(NotificationDefines.Chat.MemberExit, oldChatGroupInfo)
  end
  self.groupChatList[chatGroupInfo.group_type] = chatGroupInfo
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.room or chatGroupInfo.group_type == ChatEnum.EChatChannel.team or chatGroupInfo.group_type == ChatEnum.EChatChannel.fight then
    for key, value in pairs(chatGroupInfo.members) do
      UE4.UPMVoiceManager.Get(LuaGetWorld()):SetMicIsEnableStateMap(value.player_id, value.mic_flag)
      GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChanged, value.player_id)
    end
  end
  GameFacade:SendNotification(NotificationDefines.Chat.CreateChatGroup, chatGroupInfo)
end
function ChatDataProxy:OnNtfChatGroupMember(data)
  local chatGroupMemberNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_member_ntf, data)
  LogDebug("ChatDataProxy", "OnNtfChatGroupMember:" .. TableToString(chatGroupMemberNtf))
  if chatGroupMemberNtf.member == nil then
    return
  end
  UE4.UPMVoiceManager.Get(LuaGetWorld()):SetMicIsEnableStateMap(chatGroupMemberNtf.member.player_id, chatGroupMemberNtf.member.mic_flag)
  local selfId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  if selfId == chatGroupMemberNtf.member.player_id and self.mic_flag ~= chatGroupMemberNtf.member.mic_flag then
    self.mic_flag = chatGroupMemberNtf.member.mic_flag
    GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChangedList, chatGroupMemberNtf.member.player_id)
  else
    GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChanged, chatGroupMemberNtf.member.player_id)
  end
  for key, value in pairs(self.groupChatList) do
    if value.group_id == chatGroupMemberNtf.group_id then
      local playerInGroup = false
      for _, v in pairs(value.members) do
        if v.player_id == chatGroupMemberNtf.member.player_id then
          v.team_id = chatGroupMemberNtf.member.team_id
          v.mic_flag = chatGroupMemberNtf.member.mic_flag
          playerInGroup = true
          break
        end
      end
      if false == playerInGroup then
        table.insert(value.members, chatGroupMemberNtf.member)
      end
      break
    end
  end
  if self.groupChatList[ChatEnum.EChatChannel.fight] and self.groupChatList[ChatEnum.EChatChannel.fight].group_id == chatGroupMemberNtf.group_id then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Chat.MemberEnter, chatGroupMemberNtf)
end
function ChatDataProxy:OnNtfChatGroupQuit(data)
  local chatGroupQuitNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_quit_ntf, data)
  LogDebug("ChatDataProxy", "OnNtfChatGroupQuit:" .. TableToString(chatGroupQuitNtf))
  local selfId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  if selfId == chatGroupQuitNtf.player_id then
    self:DeleteGroup(chatGroupQuitNtf.group_id)
  else
    for _, value in pairs(self.groupChatList) do
      if value.group_id == chatGroupQuitNtf.group_id then
        for key, v in pairs(value.members) do
          if v.player_id == chatGroupQuitNtf.player_id then
            table.remove(value.members, key)
            break
          end
        end
      end
    end
  end
  if self.groupChatList[ChatEnum.EChatChannel.fight] and self.groupChatList[ChatEnum.EChatChannel.fight].group_id == chatGroupQuitNtf.group_id then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Chat.MemberExit, chatGroupQuitNtf)
end
function ChatDataProxy:OnResChatGroupSend(data)
  local chatGroupSendRes = pb.decode(Pb_ncmd_cs_lobby.chat_group_send_res, data)
  GameFacade:SendNotification(NotificationDefines.Chat.SendMsgReback, chatGroupSendRes, NotificationDefines.Chat.MsgType.Group)
end
function ChatDataProxy:OnNtfChatGroupRecv(data)
  local chatGroupRecvNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_recv_ntf, data)
  if chatGroupRecvNtf.player_id and self.chatBlacklist[chatGroupRecvNtf.player_id] then
    return
  end
  self:ReserveMsg(chatGroupRecvNtf.player_id, chatGroupRecvNtf.nick, chatGroupRecvNtf.icon, nil, chatGroupRecvNtf.msg, nil, chatGroupRecvNtf.group_id, chatGroupRecvNtf.team_id)
  GameFacade:SendNotification(NotificationDefines.Chat.RecvMsg, chatGroupRecvNtf, NotificationDefines.Chat.MsgType.Group)
end
function ChatDataProxy:OnNtfChatGroupDestroy(data)
  local chatGroupDestroyNtf = pb.decode(Pb_ncmd_cs_lobby.chat_group_destory_ntf, data)
  LogDebug("ChatDataProxy", "OnNtfChatGroupDestroy:" .. TableToString(chatGroupDestroyNtf))
  self:DeleteGroup(chatGroupDestroyNtf.group_id)
  if self.groupChatList[ChatEnum.EChatChannel.fight] then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Chat.MemberExit, chatGroupDestroyNtf)
end
function ChatDataProxy:DeleteGroup(groupId)
  for key, value in pairs(self.groupChatList) do
    if value.group_id == groupId then
      if key == ChatEnum.EChatChannel.room or key == ChatEnum.EChatChannel.team then
        self.groupMsgList = {}
      end
      self.groupChatList[key] = nil
      break
    end
  end
  if tostring(groupId) == tostring(UE4.UPMVoiceManager.Get(LuaGetWorld()):GetTeamVoiceChannel()) then
    self:SendMicStateReq()
  elseif tostring(groupId) == tostring(UE4.UPMVoiceManager.Get(LuaGetWorld()):GetRoomVoiceChannel()) then
  end
end
function ChatDataProxy:ReserveMsg(playerId, nick, icon, time, msg, targetPlayerId, groupId, teamId)
  do return end
  if groupId then
    local groupType
    for key, value in pairs(self.groupChatList) do
      if value.group_id == groupId then
        groupType = value.group_type
        break
      end
    end
    if nil == groupType or groupType == ChatEnum.EChatChannel.world then
      return
    end
    if groupType == ChatEnum.EChatChannel.fight then
      if 0 == teamId then
        if self.groupChatList[ChatEnum.EChatChannel.room] then
          groupType = ChatEnum.EChatChannel.room
        else
          return
        end
      else
        groupType = ChatEnum.EChatChannel.team
      end
    end
    local newMsg = {
      playerId = playerId,
      nick = nick,
      icon = icon,
      groupType = groupType,
      groupId = groupId,
      teamId = teamId,
      msg = msg,
      time = time or os.time()
    }
    table.insert(self.groupMsgList, newMsg)
    local msgCount = table.count(self.groupMsgList)
    if msgCount > 200 then
      table.remove(self.groupMsgList, 1)
    end
  else
    local newMsg = {
      playerId = playerId,
      nick = nick,
      icon = icon,
      targetPlayerId = targetPlayerId,
      msg = msg,
      time = time or os.time()
    }
    table.insert(self.privateMsgList, newMsg)
  end
end
function ChatDataProxy:OnNtfTeamMode(data)
  self:SendMicStateReq()
  local teamModeNtf = pb.decode(Pb_ncmd_cs_lobby.team_mode_ntf, data)
  if teamModeNtf.mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM and self.groupChatList[ChatEnum.EChatChannel.room] then
    LogDebug("ChatDataProxy", "Change map...")
    return
  end
  LogDebug("ChatDataProxy", "Change team mode...")
  self:ClearGroupMsg()
end
function ChatDataProxy:OnNtfTeamExit(data)
  LogDebug("ChatDataProxy", "Exit team...")
  self:ClearGroupMsg()
end
function ChatDataProxy:ClearGroupMsg()
  self.groupMsgList = {}
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.GameModeChanged)
end
function ChatDataProxy:AddFriend(targetPlayerId, targetPlayerNick)
  LogDebug("ChatDataProxy", "Add player: %d...", targetPlayerId)
  local playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  if playerId == targetPlayerId then
    return
  elseif GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsFriend(targetPlayerId) then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20312)
  else
    local playerInfo = {playerId = targetPlayerId, nick = targetPlayerNick}
    GameFacade:SendNotification(NotificationDefines.AddFriendCmd, playerInfo)
  end
end
function ChatDataProxy:JoinTeam(teamId, playerId)
  LogDebug("ChatDataProxy", "Require join team: %d...", teamId)
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomProxy:GetTeamInfo()
  if teamInfo and teamInfo.teamId and teamInfo.teamId == teamId then
    return
  end
  if playerId > 0 then
    if self.joinTeamCDList[teamId] then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20313)
    else
      GameFacade:RetrieveProxy(ProxyNames.RoomProxy):ReqTeamApply(teamId, playerId)
      self:AddToJoinTeamCDList(teamId)
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "Chat_JoinTeamApply")
      GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
    end
  end
end
function ChatDataProxy:QueryTeamExist(teamId)
  local data = {team_id = teamId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_QUERY_REQ, pb.encode(Pb_ncmd_cs_lobby.team_query_req, data))
end
function ChatDataProxy:OnResTeamQuery(data)
  local teamQueryRes = pb.decode(Pb_ncmd_cs_lobby.team_query_res, data)
  if 0 == teamQueryRes.code then
    if teamQueryRes.in_battle then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1055)
    else
      local playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
      local teamId = teamQueryRes.team_id
      if playerId > 0 then
        if self.joinTeamCDList[teamId] then
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20313)
        else
          GameFacade:RetrieveProxy(ProxyNames.RoomProxy):ReqTeamApply(teamId, playerId)
          self:AddToJoinTeamCDList(teamId)
          local text = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "Chat_JoinTeamApply")
          GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
        end
      end
    end
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamQueryRes.code)
  end
end
function ChatDataProxy:AddToJoinTeamCDList(teamId)
  if not self.coolDownTime then
    self.coolDownTime = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("8203")
  end
  if not self.coolDownTime or self.coolDownTime <= 0 then
    return
  end
  self.joinTeamCDList[teamId] = true
  TimerMgr:AddTimeTask(self.coolDownTime, 0, 1, function()
    self:MoveOutJoinTeamCD(teamId)
  end)
end
function ChatDataProxy:MoveOutJoinTeamCD(teamId)
  if self.joinTeamCDList[teamId] then
    self.joinTeamCDList[teamId] = nil
  end
end
function ChatDataProxy:InitChatEmotionCfg()
  self.chatEmotion = ConfigMgr:GetChatEmotionTableRows():ToLuaTable()
end
return ChatDataProxy
