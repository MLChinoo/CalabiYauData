local FriendProxy = class("FriendProxy", PureMVC.Proxy)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local Queue = require("core/containers/Queue")
FriendProxy.FriendErrCode = {FriendNumberIsLimit = 20109, FriendApplyIsLimit = 20110}
function FriendProxy:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_ADD_RES, FuncSlot(self.OnResFriendAdd, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_DEL_RES, FuncSlot(self.OnResFriendDel, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_DEL_NTF, FuncSlot(self.OnNtfFriendDel, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_REPLY_RES, FuncSlot(self.OnResFriendReply, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_MEMBER_NTF, FuncSlot(self.OnNtfFriendMember, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_LIST_NTF, FuncSlot(self.OnNtfFriendList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_LIST_RES, FuncSlot(self.OnResFriendList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_NTF, FuncSlot(self.OnNtfFriendGroup, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_ADD_RES, FuncSlot(self.OnResFriendGroupAdd, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_DEL_RES, FuncSlot(self.OnResFriendGroupDel, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MODIFY_RES, FuncSlot(self.OnResFriendGroupModify, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_SWAP_RES, FuncSlot(self.OnResFriendGroupSwap, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MOVE_RES, FuncSlot(self.OnResFriendGroupMove, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_REMARKS_RES, FuncSlot(self.OnResFriendRemarks, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_SETUP_RES, FuncSlot(self.OnResFriendSetup, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_SETUP_NTF, FuncSlot(self.OnNtfFriendSetup, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_SEARCH_RES, FuncSlot(self.OnResFriendSearch, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResPlayerCreate, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_QUERY_RES, FuncSlot(self.OnResFriendQuery, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FRIEND_SOCIAL_LIST_RES, FuncSlot(self.OnFriendSocialListRes, self))
  self.playerId = 0
  self.nick = ""
  self.onlineStatus = Pb_ncmd_cs.EOnlineStatus.OnlineStatus_NONE
  self.currentSocialType = FriendEnum.SocialSecretType.None
  self.bInitComplete = false
  self.bShowPlatformFriend = false
  self:ClearData()
end
function FriendProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_ADD_RES, FuncSlot(self.OnResFriendAdd, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_DEL_RES, FuncSlot(self.OnResFriendDel, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_DEL_NTF, FuncSlot(self.OnNtfFriendDel, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_REPLY_RES, FuncSlot(self.OnResFriendReply, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_MEMBER_NTF, FuncSlot(self.OnNtfFriendMember, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_LIST_NTF, FuncSlot(self.OnNtfFriendList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_LIST_RES, FuncSlot(self.OnResFriendList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_NTF, FuncSlot(self.OnNtfFriendGroup, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_ADD_RES, FuncSlot(self.OnResFriendGroupAdd, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_DEL_RES, FuncSlot(self.OnResFriendGroupDel, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MODIFY_RES, FuncSlot(self.OnResFriendGroupModify, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_SWAP_RES, FuncSlot(self.OnResFriendGroupSwap, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MOVE_RES, FuncSlot(self.OnResFriendGroupMove, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_REMARKS_RES, FuncSlot(self.OnResFriendRemarks, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_SETUP_RES, FuncSlot(self.OnResFriendSetup, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_SETUP_NTF, FuncSlot(self.OnNtfFriendSetup, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_SEARCH_RES, FuncSlot(self.OnResFriendSearch, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResPlayerCreate, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_QUERY_RES, FuncSlot(self.OnResFriendQuery, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FRIEND_SOCIAL_LIST_RES, FuncSlot(self.OnFriendSocialListRes, self))
end
function FriendProxy:ClearData()
  self.PlatformFriendList = {}
  self.onlineList = {}
  self.offlineList = {}
  self.shieldList = {}
  self.allFriendMap = {}
  self.applyList = {}
  self.blackList = {}
  self.nearList = {}
  self.friendMap = {}
  self.msgQue = Queue.new()
  self.searchPlayerName = ""
  self.groupDatas = {}
  self.addMsg = {}
  self.searchedFriends = {}
  self.addFriendReqMap = {}
end
function FriendProxy:AddChatMsg(stringKey, ...)
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, stringKey)
  if nil == formatText then
    return
  end
  local stringMap = {}
  for key, value in pairs({
    ...
  }) do
    stringMap[key - 1] = value
  end
  local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
end
function FriendProxy:AddHintMsg(inMsgType, targetPlayerNick)
  local msg = {msgType = inMsgType, playerName = targetPlayerNick}
  self.msgQue:PushBack(msg)
  self:OpenFriendMsgPage()
end
function FriendProxy:AddPlayer(player)
  if nil == player or nil == player.player then
    return
  end
  local playerInfo = player.player
  local playerId = playerInfo.player_id
  if nil == playerId then
    return
  end
  local playerInfoTable = self:AssemblePlayer(player)
  if player.friend_type == Pb_ncmd_cs.EFriendType.FriendType_FRIEND then
    if player.group_id == Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_SHIELD then
      self.shieldList[playerId] = playerInfoTable
      GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):AddToChatBlacklist(playerId, true)
    else
      if playerInfo.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE or playerInfo.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LOST then
        self.offlineList[playerId] = playerInfoTable
      else
        self.onlineList[playerId] = playerInfoTable
      end
      self.allFriendMap[playerId] = playerInfoTable
    end
  elseif player.friend_type == Pb_ncmd_cs.EFriendType.FriendType_BLACK then
    self.blackList[playerId] = playerInfoTable
  elseif player.friend_type == Pb_ncmd_cs.EFriendType.FriendType_APPLY then
    self.applyList[playerId] = playerInfoTable
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.FriendReq, table.count(self.applyList))
  elseif player.friend_type == Pb_ncmd_cs.EFriendType.FriendType_NEAR then
    self.nearList[playerId] = playerInfoTable
  end
  self.friendMap[playerId] = playerInfoTable
end
function FriendProxy:DeletePlayer(playerId)
  if nil == playerId then
    return
  end
  self.offlineList[playerId] = nil
  self.onlineList[playerId] = nil
  if self.shieldList[playerId] then
    self.shieldList[playerId] = nil
    GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):AddToChatBlacklist(playerId, false)
  end
  if self.applyList[playerId] then
    self.applyList[playerId] = nil
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.FriendReq, table.count(self.applyList))
  end
  self.blackList[playerId] = nil
  self.nearList[playerId] = nil
  self.allFriendMap[playerId] = nil
  self.friendMap[playerId] = nil
end
function FriendProxy:ModifyPlayer(player)
  if nil == player or nil == player.player then
    return
  end
  local playerInfo = player.player
  local playerId = playerInfo.player_id
  if nil == playerId then
    return
  end
  local bIsFriend_Former = self:IsFriend(playerId)
  self:DeletePlayer(playerId)
  self:AddPlayer(player)
  local bIsFriend_Now = self:IsFriend(playerId)
  if not bIsFriend_Former and bIsFriend_Now then
    self:AddChatMsg("AddNtfText", playerInfo.nick)
    self:AddHintMsg(FriendEnum.FriendMsgType.AddFriend, playerInfo.nick)
  end
end
function FriendProxy:OpenFriendMsgPage()
  local globalState = UE4.UPMGlobalStateMachine.Get(LuaGetWorld()):GetCurrentGlobalStateType()
  if globalState ~= UE4.EPMGlobalStateType.Lobby then
    return
  end
  if GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetIsInLottery() then
    return
  end
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if NewPlayerGuideProxy:IsAllGuideComplete() and LuaGetWorld() then
    TimerMgr:AddTimeTask(0.1, 0, 1, function()
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendMsgNtfPage)
    end)
  end
end
function FriendProxy:OnResPlayerCreate(data)
  local playerCreate = pb.decode(Pb_ncmd_cs_lobby.player_create_res, data)
  if 0 == playerCreate.code then
    self.playerId = playerCreate.player.player_id
  end
end
function FriendProxy:OnResAttrSyncNtf(data)
  local roleAttrInfo = pb.decode(Pb_ncmd_cs_lobby.attribute_sync_ntf, data)
  for key, value in pairs(roleAttrInfo.items) do
    if value.id == GlobalEnumDefine.PlayerAttributeType.emNick then
      if value.value ~= "" then
        self.nick = value.value
      end
      break
    end
  end
end
function FriendProxy:OnReceiveLoginRes(data)
  local login_res = DeCode(Pb_ncmd_cs_lobby.login_res, data)
  LogInfo("OnReceiveLoginRes", TableToString(login_res))
  if 0 == login_res.code then
    self:FriendSocialListReq(0)
  end
  if login_res.player then
    self.playerId = login_res.player.player_id
    if login_res.player.nick ~= "" then
      self.nick = login_res.player.nick
    end
    self.onlineStatus = login_res.player.online_status
    if 0 == login_res.player.team_id and 0 == login_res.player.room_id then
      local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
      if roomDataProxy then
        roomDataProxy:ClearData()
      end
    end
    GameFacade:SendNotification(NotificationDefines.Login.ReceiveLoginRes)
  end
end
function FriendProxy:OnResFriendAdd(data)
  LogDebug("FriendProxy", "Res friend add")
  local friendAdd_res = pb.decode(Pb_ncmd_cs_lobby.friend_add_res, data)
  if friendAdd_res.code == FriendEnum.FriendErrCode.FriendNumberIsLimit then
    self:AddHintMsg(FriendEnum.FriendMsgType.FriendIsLimit)
  elseif friendAdd_res.code == FriendEnum.FriendErrCode.FriendApplyIsLimit then
    self:AddHintMsg(FriendEnum.FriendMsgType.ApplyIsLimit)
  elseif 0 == friendAdd_res.code then
    self:AddHintMsg(FriendEnum.FriendMsgType.FriendRequest, friendAdd_res.target_nick)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendAdd_res.code)
  end
end
function FriendProxy:OnResFriendDel(data)
  LogDebug("FriendProxy", "Res friend delete")
  local friendDel_res = pb.decode(Pb_ncmd_cs_lobby.friend_del_res, data)
  if 0 ~= friendDel_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendDel_res.code)
  end
end
function FriendProxy:OnNtfFriendDel(data)
  LogDebug("FriendProxy", "Ntf friend delete")
  local friendDel_ntf = pb.decode(Pb_ncmd_cs_lobby.friend_del_ntf, data)
  self:DeletePlayer(friendDel_ntf.target_id)
  GameFacade:SendNotification(NotificationDefines.FriendCmd, friendDel_ntf.target_id, NotificationDefines.FriendCmdType.FriendDelNtf)
  if 1 == friendDel_ntf.reason then
    self:AddHintMsg(FriendEnum.FriendMsgType.OtherFriendListFull)
  end
end
function FriendProxy:OnNtfFriendMember(data)
  LogDebug("FriendProxy", "Ntf friend member")
  local friendMember_res = pb.decode(Pb_ncmd_cs_lobby.friend_member_ntf, data)
  if friendMember_res.friend then
    local player = friendMember_res.friend
    self:ModifyPlayer(player)
    if player.friend_type == Pb_ncmd_cs.EFriendType.FriendType_APPLY then
      self:AddHintMsg(FriendEnum.FriendMsgType.RecvFriendApply, player.player.nick)
      self:AddChatMsg("PlayerRequestMakeFriendWithYou", player.player.nick)
    end
    local playerId = player.player.player_id
    if self.friendMap[playerId] then
      GameFacade:SendNotification(NotificationDefines.FriendCmd, self.friendMap[playerId], NotificationDefines.FriendCmdType.FriendChangeNtf)
    end
  end
end
function FriendProxy:OnNtfFriendList(data)
  LogDebug("FriendProxy", "Ntf friend list")
  local friendList_ntf = pb.decode(Pb_ncmd_cs_lobby.friend_list_ntf, data)
  if friendList_ntf.is_reset then
    self:ClearData()
  end
  self.currentSocialType = friendList_ntf.social_secret
  local newMsg = {}
  newMsg.msgType = FriendEnum.FriendMsgType.RecvFriendApply
  if friendList_ntf.friends then
    for key, value in pairs(friendList_ntf.friends) do
      self:AddPlayer(value)
      if value.friend_type == Pb_ncmd_cs.EFriendType.FriendType_APPLY then
        newMsg.nick = value.player.nick
      end
    end
  end
  if newMsg.nick then
    self:AddHintMsg(newMsg.msgType, newMsg.nick)
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, true, NotificationDefines.FriendCmdType.FriendListNtf)
  GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.FriendInitComplete)
end
function FriendProxy:OnResFriendList(data)
  LogDebug("FriendProxy", "Res friend list")
  local friendList_res = pb.decode(Pb_ncmd_cs_lobby.friend_list_res, data)
  if 0 ~= friendList_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendList_res.code)
  else
    if 0 == friendList_res.sync_type then
      self:ClearData()
    end
    self.currentSocialType = friendList_res.social_secret
    if friendList_res.friends then
      for key, value in pairs(friendList_res.friends) do
        self:AddPlayer(value)
      end
    end
    if 1 == friendList_res.sync_type then
      local playerInfoChanged = {}
      for key, value in pairs(friendList_res.friends) do
        table.insert(playerInfoChanged, self:AssemblePlayer(value))
      end
      GameFacade:SendNotification(NotificationDefines.FriendCmd, playerInfoChanged, NotificationDefines.FriendCmdType.FriendInfoUpdate)
    else
      GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.FriendListNtf)
    end
  end
end
function FriendProxy:OnResFriendRemarks(data)
  LogDebug("FriendProxy", "Res friend remark")
  local friendRemarks_res = pb.decode(Pb_ncmd_cs_lobby.friend_remarks_res, data)
  if 0 ~= friendRemarks_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendRemarks_res.code)
  end
end
function FriendProxy:OnResFriendSetup(data)
  LogDebug("FriendProxy", "Res friend setup")
  local friendSetup_res = pb.decode(Pb_ncmd_cs_lobby.friend_setup_res, data)
  if 0 ~= friendSetup_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendSetup_res.code)
    return
  end
  if friendSetup_res.setup_type == FriendEnum.FriendSetupType.OnlineState then
    self.onlineStatus = friendSetup_res.setup_status
  elseif friendSetup_res.setup_type == FriendEnum.FriendSetupType.TeamLimit then
    self.currentSocialType = friendSetup_res.setup_status
  end
end
function FriendProxy:OnNtfFriendSetup(data)
  LogDebug("FriendProxy", "Ntf friend setup")
  local friendSetup_ntf = pb.decode(Pb_ncmd_cs_lobby.friend_setup_ntf, data)
  local playerId = friendSetup_ntf.friend_id
  local setUpType = friendSetup_ntf.setup_type
  local setupStatus = friendSetup_ntf.setup_status
  if self.allFriendMap[playerId] then
    local friendPlayer = self.allFriendMap[playerId]
    if setUpType == FriendEnum.FriendSetupType.OnlineState then
      friendPlayer.onlineStatus = setupStatus
    elseif setUpType == FriendEnum.FriendSetupType.TeamLimit then
      friendPlayer.socialType = setupStatus
    end
    if self.onlineList[playerId] then
      self.onlineList[friendPlayer.playerId] = friendPlayer
    end
    GameFacade:SendNotification(NotificationDefines.FriendInfoChange, friendPlayer)
  end
end
function FriendProxy:OnResFriendReply(data)
  LogDebug("FriendProxy", "Res friend reply")
  local friend_reply_res = pb.decode(Pb_ncmd_cs_lobby.friend_reply_res, data)
  if 0 ~= friend_reply_res.code and friend_reply_res.code == FriendEnum.FriendErrCode.FriendNumberIsLimit then
    self:AddHintMsg(FriendEnum.FriendMsgType.FriendIsLimit)
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, 0 == friend_reply_res.code, NotificationDefines.FriendCmdType.FriendReplyRes)
end
function FriendProxy:OnResFriendSearch(data)
  local friend_search_res = pb.decode(Pb_ncmd_cs_lobby.friend_search_res, data)
  local friends = {}
  if friend_search_res.friends then
    for key, value in pairs(friend_search_res.friends) do
      local friend = self:GetPlayerInfo(value)
      table.insert(friends, friend)
    end
  end
  if 0 == table.count(friends) then
    if self:GetPlayerID() == tonumber(self.searchPlayerName, 10) or type(self.searchPlayerName) == "string" and self:GetNick() == self.searchPlayerName then
      local StringTableStore = StringTablePath.ST_FriendName
      local showMsg = ConfigMgr:FromStringTable(StringTableStore, "AddSelf_FriendListText")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
      return
    end
    if 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
      self:AddHintMsg(FriendEnum.FriendMsgType.NotFound, self.searchPlayerName)
    end
  end
  self.searchedFriends = friends
  GameFacade:SendNotification(NotificationDefines.FriendCmd, friends, NotificationDefines.FriendCmdType.SearchFriendRes)
end
function FriendProxy:OnResFriendQuery(data)
  local friend_query_res = pb.decode(Pb_ncmd_cs_lobby.friend_query_res, data)
  if friend_query_res and 0 == friend_query_res.code and friend_query_res.friend then
    local player = self:GetPlayerInfo(friend_query_res.friend)
    if player.socialSecret then
    end
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friend_query_res.code)
  end
end
function FriendProxy:OnNtfFriendGroup(data)
  local friendGroup_ntf = pb.decode(Pb_ncmd_cs_lobby.friend_group_ntf, data)
  if friendGroup_ntf.groups then
    for key, value in pairs(friendGroup_ntf.groups) do
      if value then
        local friendGroup = value
        if friendGroup then
          local groupData = {}
          groupData.groupID = friendGroup.group_id
          groupData.groupName = friendGroup.group_name
          groupData.index = friendGroup.index
          table.insert(self.groupDatas, groupData)
        end
      end
    end
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
end
function FriendProxy:OnResFriendGroupAdd(data)
  local friendGroupAdd_ntf = pb.decode(Pb_ncmd_cs_lobby.friend_group_add_res, data)
  if 0 == friendGroupAdd_ntf.code then
    GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendGroupAdd_ntf.code)
  end
end
function FriendProxy:OnResFriendGroupDel(data)
  local friendGroupDel_res = pb.decode(Pb_ncmd_cs_lobby.friend_group_del_res, data)
  if 0 == friendGroupDel_res.code then
    GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendGroupDel_res.code)
  end
end
function FriendProxy:OnResFriendGroupModify(data)
  local friendGroupModify_res = pb.decode(Pb_ncmd_cs_lobby.friend_group_modify_res, data)
  if 0 == friendGroupModify_res.code then
    GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendGroupModify_res.code)
  end
end
function FriendProxy:OnResFriendGroupSwap(data)
  local friendGroupSwap_res = pb.decode(Pb_ncmd_cs_lobby.friend_group_swap_res, data)
  if 0 == friendGroupSwap_res.code then
    GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendGroupSwap_res.code)
  end
end
function FriendProxy:OnResFriendGroupMove(data)
  local friendGroupMove_res = pb.decode(Pb_ncmd_cs_lobby.friend_group_move_res, data)
  if 0 == friendGroupMove_res.code then
    GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, friendGroupMove_res.code)
  end
end
function FriendProxy:ReqFriendGroupAdd(groupName)
  local friendGroupAddRequest = {}
  friendGroupAddRequest.group_name = groupName
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_group_add_req, friendGroupAddRequest)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_ADD_REQ, req)
  end
end
function FriendProxy:ReqFriendGroupDel(groupId)
  local friendGroupDelReq = {}
  friendGroupDelReq.group_id = groupId
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_group_del_req, friendGroupDelReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_DEL_REQ, req)
  end
end
function FriendProxy:ReqFriendGroupModify(groupId, groupName)
  local friendGroupModifyReq = {}
  friendGroupModifyReq.group_id = groupId
  friendGroupModifyReq.group_name = groupName
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_group_modify_req, friendGroupModifyReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MODIFY_REQ, req)
  end
end
function FriendProxy:ReqFriendGroupSwap(groupId, index)
  local friendGroupSwapReq = {}
  friendGroupSwapReq.group_id = groupId
  friendGroupSwapReq.index = index
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_group_swap_req, friendGroupSwapReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_SWAP_REQ, req)
  end
end
function FriendProxy:ReqFriendGroupMove(targetID, groupId)
  local data = {target_id = targetID, group_id = groupId}
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_group_move_req, data)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_GROUP_MOVE_REQ, req)
  end
end
function FriendProxy:ReqFriendListUpdate()
  local friendListUpdateReq = {sync_type = 1}
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_list_req, friendListUpdateReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_LIST_REQ, req)
  end
  self:FriendSocialListReq(1)
end
function FriendProxy:ReqFriendSearch(nick, playerID)
  local friendSearchRequest = {}
  friendSearchRequest.nick = nick
  friendSearchRequest.player_id = playerID
  self.searchPlayerName = nick
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_search_req, friendSearchRequest)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_SEARCH_REQ, req)
  end
end
function FriendProxy:ReqFriendReply(inReply, inTargetID)
  local friendReplyRequest = {}
  friendReplyRequest.reply = inReply
  friendReplyRequest.target_id = inTargetID
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_reply_req, friendReplyRequest)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_REPLY_REQ, req)
  end
end
function FriendProxy:ReqFriendAdd(addPlayerNick, inTargetID, inFriendType)
  local friendAddRequest = {}
  friendAddRequest.target_id = inTargetID
  friendAddRequest.friend_type = inFriendType
  friendAddRequest.target_nick = addPlayerNick
  if inFriendType == FriendEnum.FriendType.Apply then
    self:AddChatMsg("FriendApplyText", addPlayerNick)
  end
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_add_req, friendAddRequest)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_ADD_REQ, req)
  end
end
function FriendProxy:ReqFriendDel(inTargetID, friendType)
  local friendDelRequest = {}
  friendDelRequest.target_id = inTargetID
  friendDelRequest.friend_type = friendType
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_del_req, friendDelRequest)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_DEL_REQ, req)
  end
end
function FriendProxy:ReqFriendRemarks(targetID, remark)
  local friendRemarksReq = {}
  friendRemarksReq.target_id = targetID
  friendRemarksReq.remarks = remark
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_remarks_req, friendRemarksReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_REMARKS_REQ, req)
  end
end
function FriendProxy:ReqReadRedDot(reddotId)
  local reddotReadReq = {}
  reddotReadReq.reddot_id = reddotId
  local req = pb.encode(Pb_ncmd_cs_lobby.reddot_read_req, reddotReadReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_REDDOT_READ_REQ, req)
  end
end
function FriendProxy:ReqFriendSetup(inType, inStatus)
  LogDebug("FriendProxy", "Req friend setup, type:%d state:%d", inType, inStatus)
  local friendSetupReq = {}
  friendSetupReq.setup_type = inType
  friendSetupReq.setup_status = inStatus
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_setup_req, friendSetupReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_SETUP_REQ, req)
  end
end
function FriendProxy:ReqFriendQuery(playerId)
  local friendQueryReq = {}
  friendQueryReq.player_id = playerId
  local req = pb.encode(Pb_ncmd_cs_lobby.friend_query_req, friendQueryReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_QUERY_REQ, req)
  end
end
function FriendProxy:GetPlayerID()
  return self.playerId
end
function FriendProxy:GetNick()
  return self.nick
end
function FriendProxy:GetOnlineStatus()
  return self.onlineStatus
end
function FriendProxy:GetSocialType()
  return self.currentSocialType
end
function FriendProxy:GetFriendGroupData()
  return self.groupDatas
end
function FriendProxy:GetAllFriends()
  return self.allFriendMap
end
function FriendProxy:GetPlatformFriends()
  return self.PlatformFriendList
end
function FriendProxy:GetShieldlist()
  return self.shieldList
end
function FriendProxy:GetBlacklist()
  return self.blackList
end
function FriendProxy:GetNearPlayers()
  return self.nearList
end
function FriendProxy:GetApplyPlayers()
  return self.applyList
end
function FriendProxy:ShieldPlayer(playerId)
  self:ReqFriendGroupMove(playerId, Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_SHIELD)
end
function FriendProxy:UnshieldPlayer(playerId)
  self:ReqFriendGroupMove(playerId, Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_NONE)
end
function FriendProxy:ClearNewFriendMsg()
  self.msgQue:Clear()
end
function FriendProxy:IsFriend(friendID)
  if self.allFriendMap[friendID] or self.shieldList[friendID] then
    return true
  end
  return false
end
function FriendProxy:IsSocialFriend(playerId)
  if self.PlatformFriendList[playerId] then
    return true
  end
  return false
end
function FriendProxy:IsShieldList(playerId)
  if self.shieldList[playerId] then
    return true
  end
  return false
end
function FriendProxy:IsBlacklist(playerId)
  if self.blackList[playerId] then
    return true
  end
  return false
end
function FriendProxy:GetFriendInfoFromPlayerID(friendID)
  if self.allFriendMap then
    return self.allFriendMap[friendID]
  end
  return nil
end
function FriendProxy:AssemblePlayer(inPlayer)
  local player = self:GetPlayerInfo(inPlayer.player)
  player.groupId = inPlayer.group_id
  player.friendType = inPlayer.friend_type
  player.intimacy = inPlayer.intimacy
  player.remarks = inPlayer.remarks
  player.socialType = inPlayer.social_secret
  player.friendTime = inPlayer.friend_time
  return player
end
function FriendProxy:GetPlayerInfo(inPlayer)
  local playerInfo = {}
  playerInfo.friendType = FriendEnum.FriendType.None
  playerInfo.bInvite = true
  playerInfo.bReqJoin = true
  playerInfo.playerId = inPlayer.player_id
  playerInfo.nick = inPlayer.nick
  playerInfo.icon = inPlayer.icon
  playerInfo.sex = inPlayer.sex
  playerInfo.level = inPlayer.level
  playerInfo.rank = inPlayer.rank
  playerInfo.status = inPlayer.status
  playerInfo.teamId = inPlayer.team_id
  playerInfo.roomId = inPlayer.room_id
  playerInfo.lastTime = inPlayer.logout_time
  playerInfo.time = inPlayer.time
  playerInfo.onlineStatus = inPlayer.online_status
  playerInfo.stars = inPlayer.stars
  playerInfo.totalGames = inPlayer.total_games
  playerInfo.roomStatus = inPlayer.room_status
  playerInfo.medal_cnt = inPlayer.medal_cnt
  playerInfo.epic_cnt = inPlayer.epic_cnt
  playerInfo.honour_cnt = inPlayer.honour_cnt
  playerInfo.lastQQLoginTime = inPlayer.privilege_login_time
  playerInfo.vcBorderId = inPlayer.vc_border_id
  local battleInfo = {}
  battleInfo.winCount = inPlayer.win_games
  battleInfo.mvpCount = inPlayer.mvp_count
  battleInfo.total = inPlayer.total_games
  playerInfo.battleInfo = battleInfo
  if inPlayer.settings and table.count(inPlayer.settings) then
    playerInfo.bShowPlayerInfo = inPlayer.settings
  end
  playerInfo.freqRoles = {}
  for key, value in pairs(inPlayer.freq_roles) do
    table.insert(playerInfo.freqRoles, value)
  end
  if playerInfo.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
    playerInfo.sortLevel = FriendEnum.FriendSortLevel.Online
  end
  if playerInfo.teamId and 0 ~= playerInfo.teamId or playerInfo.roomId and 0 ~= playerInfo.roomId then
    playerInfo.sortLevel = FriendEnum.FriendSortLevel.InRoom
    if playerInfo.roomStatus and playerInfo.roomStatus == FriendEnum.RoomStatus.Running then
      playerInfo.sortLevel = FriendEnum.FriendSortLevel.InGame
    end
  end
  if playerInfo.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LEAVE then
    playerInfo.sortLevel = FriendEnum.FriendSortLevel.Leave
  end
  return playerInfo
end
function FriendProxy:SetFriendInviteState(playerId, bInvite)
  if self.onlineList and self.onlineList[playerId] then
    self.onlineList[playerId].bInvite = bInvite
  end
end
function FriendProxy:GetFriendInviteState(playerId)
  if self.onlineList and self.onlineList[playerId] and self.onlineList[playerId].bInvite then
    return self.onlineList[playerId].bInvite
  else
    return nil
  end
end
function FriendProxy:SetReqJoinFriendRoomState(playerId, bReqJoin)
  if self.onlineList and self.onlineList[playerId] then
    self.onlineList[playerId].bReqJoin = bReqJoin
  end
end
function FriendProxy:GetReqJoinFriendRoomState(playerId)
  if self.onlineList and self.onlineList[playerId] and self.onlineList[playerId].bInvite then
    return self.onlineList[playerId].bReqJoin
  else
    return nil
  end
end
function FriendProxy:GetFriendCurrentRoomId(playerId)
  if self.onlineList and self.onlineList[playerId] then
    local friendInfo = self.onlineList[playerId]
    if friendInfo.teamId and 0 ~= friendInfo.teamId then
      return friendInfo.teamId
    end
  end
  return nil
end
function FriendProxy:FirendIsInSelfRoom(playerId)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomDataProxy and self.onlineList and self.onlineList[playerId] then
    local friendInfo = self.onlineList[playerId]
    local teamInfo = roomDataProxy:GetTeamInfo()
    if teamInfo and teamInfo.teamId and friendInfo.teamId and 0 ~= friendInfo.teamId and teamInfo.teamId == friendInfo.teamId then
      return true
    end
  end
  return false
end
function FriendProxy:SelfIsInFriendRoom(roomId)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomDataProxy:GetTeamInfo()
  local roomInfo = roomDataProxy:GetRoomInfo()
  if teamInfo and teamInfo.teamId == roomId then
    return true
  elseif roomInfo and roomInfo.roomId == roomId then
    return true
  end
  return false
end
function FriendProxy:AddNewFriendReq(playerId)
  self.addFriendReqMap[playerId] = 1
end
function FriendProxy:RemoveOldFriendReq(playerId)
  if self.addFriendReqMap[playerId] then
    self.addFriendReqMap[playerId] = nil
  end
end
function FriendProxy:HasFriendReq(playerId)
  if self.addFriendReqMap[playerId] then
    return true
  end
  return false
end
function FriendProxy:IsStringFullSpacer(str)
  local strLength = #str
  local spaceLen = 0
  for i = 1, strLength do
    local character = string.sub(str, i, i)
    if " " == character then
      spaceLen = spaceLen + 1
    end
  end
  if strLength == spaceLen then
    return true
  end
  return false
end
function FriendProxy:FriendSocialListReq(type)
  if self.bShowPlatformFriend == false then
    return
  end
  LogDebug("FriendProxy", "FriendSocialListReq")
  local data = {}
  data.sync_type = type
  SendRequest(Pb_ncmd_cs.NCmdId.NID_FRIEND_SOCIAL_LIST_REQ, pb.encode(Pb_ncmd_cs_lobby.friend_social_list_req, data))
end
function FriendProxy:OnFriendSocialListRes(data)
  LogDebug("FriendProxy", "OnFriendSocialListRes")
  local FriendSocialList = pb.decode(Pb_ncmd_cs_lobby.friend_social_list_res, data)
  LogDebug("FriendProxy", FriendSocialList.code)
  if 0 == FriendSocialList.sync_type then
    self.PlatformFriendList = {}
  end
  if FriendSocialList.social_friends then
    LogDebug("FriendProxy", "social_friends.count = " .. table.count(FriendSocialList.social_friends))
    for key, value in pairs(FriendSocialList.social_friends) do
      if value then
        local friend = self:GetPlayerInfo(value.player)
        friend.nick = value.user_name
        friend.picture_url = value.picture_url
        friend.friendType = FriendEnum.FriendType.Social
        friend.gender = value.gender
        friend.openid = value.openid
        self.PlatformFriendList[friend.playerId] = friend
        self.allFriendMap[friend.playerId] = friend
      end
    end
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.SocialFriendListUpdata)
  GameFacade:SendNotification(NotificationDefines.FriendCmd, self.PlatformFriendList, NotificationDefines.FriendCmdType.FriendListNtf)
end
function FriendProxy:OnResLogin(data)
  local login_res = pb.decode(Pb_ncmd_cs_lobby.login_res, data)
  if 0 == login_res.code then
    self:FriendSocialListReq(0)
  end
end
return FriendProxy
