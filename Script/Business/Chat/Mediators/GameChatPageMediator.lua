local GameChatPageMediator = class("GameChatPageMediator", PureMVC.Mediator)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local PMVoiceManager
function GameChatPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.SendMsgReback,
    NotificationDefines.Chat.RecvMsg,
    NotificationDefines.Chat.AddSystemMsg,
    NotificationDefines.Chat.CreateChatGroup,
    NotificationDefines.Chat.MemberExit,
    NotificationDefines.SetChatState,
    NotificationDefines.GameServerReconnect,
    NotificationDefines.Chat.SetChatPanelLoc
  }
end
function GameChatPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.SetChatState then
    if notification:GetType() == NotificationDefines.ChatState.Hide then
      self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if notification:GetType() == NotificationDefines.ChatState.Show then
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.deactive)
      self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if notification:GetType() == NotificationDefines.ChatState.Collapsed then
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.deactive)
    end
    if notification:GetType() == NotificationDefines.ChatState.Switch then
      self:GetViewComponent():SwitchChatState()
    end
  end
  if notification:GetName() == NotificationDefines.Chat.SendMsgReback then
    local sendMsgRes = notification:GetBody()
    if 0 == sendMsgRes.code then
      self:GetViewComponent():SendMsgSucceed()
      if notification:GetType() == NotificationDefines.Chat.MsgType.Private and self.channelMap[sendMsgRes.tar_player_id] then
        local msgToShow = {
          chatId = self.playerId,
          chatNick = self.playerName,
          chatMsg = sendMsgRes.msg,
          chatIcon = self.playerIcon,
          isOwnMsg = true,
          isPrivateChat = true
        }
        self:GetViewComponent():NotifyRecvMsg(self.channelMap[sendMsgRes.tar_player_id], msgToShow)
      end
    elseif sendMsgRes.code == 20306 then
      self:ChatIsForbidden()
      self:GetViewComponent():SetIsSendMsg(false)
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, sendMsgRes.code)
      self:GetViewComponent():SetIsSendMsg(false)
    end
  end
  if notification:GetName() == NotificationDefines.Chat.RecvMsg then
    local msgInfo = notification:GetBody()
    local msgToShow = {}
    local channelName = ""
    if notification:GetType() == NotificationDefines.Chat.MsgType.Group then
      if msgInfo.group_id ~= self.fightGroupId then
        return
      end
      local roleName, bIsTeammate = self:GetPlayerRoleAndTeam(msgInfo.player_id)
      msgToShow = {
        chatId = msgInfo.group_id,
        chatNick = msgInfo.nick .. roleName,
        chatMsg = msgInfo.msg,
        chatIcon = msgInfo.icon,
        isOwnMsg = msgInfo.player_id == self.playerId,
        isTeammate = bIsTeammate
      }
      if 0 ~= msgInfo.team_id or not self.bInRoom then
        channelName = ChatEnum.ChannelName.team
      else
        channelName = ChatEnum.ChannelName.room
      end
    else
      msgToShow = {
        chatId = msgInfo.src_player_id,
        chatNick = msgInfo.src_nick,
        chatMsg = msgInfo.msg,
        chatIcon = msgInfo.icon,
        isOwnMsg = msgInfo.src_player_id == self.playerId,
        isPrivateChat = true
      }
      channelName = msgInfo.src_nick
      if self.channelMap[msgInfo.src_player_id] == nil then
        self.channelMap[msgInfo.src_player_id] = channelName
      end
    end
    self:GetViewComponent():NotifyRecvMsg(channelName, msgToShow)
  end
  if notification:GetName() == NotificationDefines.Chat.CreateChatGroup then
    self:UpdateChannels()
  end
  if notification:GetName() == NotificationDefines.Chat.MemberExit and (notification:GetBody().player_id == nil or notification:GetBody().player_id == self.playerId) then
    self:GetViewComponent():DeleteSystemChat()
  end
  if notification:GetName() == NotificationDefines.Chat.AddSystemMsg then
    self:GetViewComponent():AddSystemMsg(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.GameServerReconnect then
    self:GetViewComponent():SetIsSendMsg(false)
  end
  if notification:GetName() == NotificationDefines.Chat.SetChatPanelLoc then
    self:GetViewComponent():SetChatPanelLoc(notification:GetBody())
  end
end
function GameChatPageMediator:GetPlayerRoleAndTeam(targetPlayerId)
  local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
  if GameState then
    local roleName = ""
    local selfTeam = -1
    local targetTeam = -1
    for i = 1, GameState.PlayerArray:Length() do
      local playerState = GameState.PlayerArray:Get(i)
      local playerId = playerState.UID
      if playerId and playerId == targetPlayerId then
        local roleId = playerState:GetSelectRoleID()
        if roleId and roleId > 0 then
          roleName = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleProfile(roleId).NameCn
          roleName = " [" .. roleName .. "] "
        end
        targetTeam = playerState.AttributeTeamID
      end
      if playerId and playerId == self.playerId then
        selfTeam = playerState.AttributeTeamID
      end
    end
    if -1 ~= selfTeam then
      return roleName, selfTeam == targetTeam
    end
  else
    LogWarn("GameChatPageMediator", "Get GameState fail")
  end
  return "", false
end
function GameChatPageMediator:OnRegister()
  GameChatPageMediator.super.OnRegister(self)
  self.channelMap = {}
  self.teamIndex = 1
  self.fightGroupId = 0
  self.bInRoom = false
  self.playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  self.playerName = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerNick()
  self:GetViewComponent().actionOnPageInitFinished:Add(self.InitChannels, self)
  self:GetViewComponent().actionOnSendMsg:Add(self.OnSendMsg, self)
  PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
end
function GameChatPageMediator:OnRemove()
  self:GetViewComponent().actionOnPageInitFinished:Remove(self.InitChannels, self)
  self:GetViewComponent().actionOnSendMsg:Remove(self.OnSendMsg, self)
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  GameChatPageMediator.super.OnRemove(self)
end
function GameChatPageMediator:OnJoinVoiceRoom(roomID)
  local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
  if chatDataProxy then
    chatDataProxy:SendMicStateReq()
  end
end
function GameChatPageMediator:OnSendMsg(msgInfo)
  local targetChannel = msgInfo.channelType
  if targetChannel == ChatEnum.EChatChannel.private then
    GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SendChatReq(msgInfo.chatId, msgInfo.msgSend, os.time(), msgInfo.chatName)
  elseif targetChannel == ChatEnum.EChatChannel.team then
    local chatProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if self.bInRoom then
      targetChannel = ChatEnum.EChatChannel.room
    end
    if chatProxy:GetGroupChatList()[ChatEnum.EChatChannel.fight] then
      targetChannel = ChatEnum.EChatChannel.fight
    end
    chatProxy:SendGroupChatReq(targetChannel, msgInfo.msgSend, os.time(), self.teamIndex)
  else
    local chatProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if chatProxy:GetGroupChatList()[ChatEnum.EChatChannel.fight] then
      targetChannel = ChatEnum.EChatChannel.fight
    end
    chatProxy:SendGroupChatReq(targetChannel, msgInfo.msgSend, os.time())
  end
end
function GameChatPageMediator:InitChannels()
  self:UpdateChannels()
  self:ShowReservedMsgs()
end
function GameChatPageMediator:UpdateChannels()
  local groupChatList = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetGroupChatList()
  if table.count(groupChatList) <= 0 then
    LogWarn("GameChatPageMediator", "No available group chat")
    return
  end
  local chatRoomInfo = groupChatList[ChatEnum.EChatChannel.fight]
  if nil == chatRoomInfo then
    chatRoomInfo = groupChatList[ChatEnum.EChatChannel.team]
    if nil ~= chatRoomInfo then
      self.bInRoom = false
    else
      chatRoomInfo = groupChatList[ChatEnum.EChatChannel.room]
      self.bInRoom = true
    end
  else
    self.bInRoom = true
  end
  if nil == chatRoomInfo then
    return
  end
  for key, value in pairs(chatRoomInfo.members) do
    if value.player_id == self.playerId then
      self.teamIndex = value.team_id
      break
    end
  end
  self.fightGroupId = chatRoomInfo.group_id
  self:GetViewComponent():AddChat(ChatEnum.EChatChannel.team, ChatEnum.ChannelName.team, chatRoomInfo.group_id)
  if self.bInRoom then
    self:GetViewComponent():AddChat(ChatEnum.EChatChannel.room, ChatEnum.ChannelName.room, chatRoomInfo.group_id)
  end
  local groupProp = {}
  groupProp.isCustomRoom = true
  groupProp.teamId = self.teamIndex
  groupProp.roomId = chatRoomInfo.group_id
  if groupProp.teamId then
    GameFacade:SendNotification(NotificationDefines.Chat.ChatGroupProp, groupProp)
  end
  if groupChatList[ChatEnum.EChatChannel.fight] == nil then
    LogDebug("GameChatPageMediator", "groupChatList[ChatEnum.EChatChannel.fight] == nil ")
    PMVoiceManager:QuitAllVoiceRoom()
  else
    local roomIdStr, teamIdStr
    if groupChatList[ChatEnum.EChatChannel.room] then
      LogDebug("GameChatPageMediator", " is in room type")
      PMVoiceManager:SetGameModeType(RoomEnum.GameModeType.Custom)
      local roomInfo = groupChatList[ChatEnum.EChatChannel.room]
      if UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) == GlobalEnumDefine.EPlatformType.Mobile then
        roomIdStr = tostring(roomInfo.group_id) .. "0" .. tostring(self.teamIndex)
      else
        roomIdStr = tostring(roomInfo.group_id)
      end
      teamIdStr = tostring(roomInfo.group_id) .. tostring(self.teamIndex)
    elseif groupChatList[ChatEnum.EChatChannel.team] then
      LogDebug("GameChatPageMediator", " is in team type")
      PMVoiceManager:SetGameModeType(RoomEnum.GameModeType.Matching)
      local roomInfo = groupChatList[ChatEnum.EChatChannel.team]
      local fightInfo = groupChatList[ChatEnum.EChatChannel.fight]
      roomIdStr = tostring(roomInfo.group_id)
      teamIdStr = tostring(fightInfo.group_id) .. tostring(self.teamIndex)
    else
      LogDebug("GameChatPageMediator", "Not Team and Not Room type")
      return
    end
    LogDebug("GameChatPageMediator", "groupChatList[ChatEnum.EChatChannel.fight].group_id = " .. groupChatList[ChatEnum.EChatChannel.fight].group_id)
    LogDebug("GameChatPageMediator", "roomIdStr = " .. roomIdStr)
    LogDebug("GameChatPageMediator", "teamIdStr = " .. teamIdStr)
    LogDebug("GameChatPageMediator", "self.teamIndex = " .. tostring(self.teamIndex))
    if self.teamIndex ~= 254 then
      PMVoiceManager:JoinRoomVoiceChannel(roomIdStr)
    end
    PMVoiceManager:JoinTeamVoiceChannel(teamIdStr)
    local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if chatDataProxy then
      chatDataProxy:SendMicStateReq()
    end
  end
end
function GameChatPageMediator:ShowReservedMsgs()
  local msgs = {}
  local reservedGroupMsgs = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetGroupMsg()
  for _, value in pairs(reservedGroupMsgs) do
    local msgToShow = {
      chatId = value.playerId or value.targetPlayerId,
      chatNick = value.nick,
      chatMsg = value.msg,
      chatIcon = value.icon,
      msgTime = value.time,
      isOwnMsg = value.playerId == self.playerId
    }
    if value.groupType == ChatEnum.EChatChannel.room and 0 == value.teamId then
      msgs[value.time] = {
        msgTypeName = ChatEnum.ChannelName.room,
        msgInfo = msgToShow
      }
    else
      msgs[value.time] = {
        msgTypeName = ChatEnum.ChannelName.team,
        msgInfo = msgToShow
      }
    end
  end
  local blacklist = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetBlacklist()
  local reservedPrivateMsgs = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetPrivateMsg()
  for _, value in pairs(reservedPrivateMsgs) do
    if value.playerId and blacklist[value.playerId] ~= nil then
      LogDebug("ChatPage", "Player %u is in blacklist", value.playerId)
    else
      local msgToShow = {
        chatId = value.playerId or value.targetPlayerId,
        chatNick = value.nick,
        chatMsg = value.msg,
        chatIcon = value.icon,
        msgTime = value.time,
        isOwnMsg = value.playerId == nil,
        isPrivateChat = true
      }
      if nil == self.channelMap[msgToShow.chatId] then
        self.channelMap[msgToShow.chatId] = msgToShow.chatNick
      end
      msgs[value.time] = {
        msgTypeName = value.nick,
        msgInfo = msgToShow
      }
    end
  end
  for _, value in pairsByKeys(msgs, function(a, b)
    return a < b
  end) do
    self:GetViewComponent():NotifyRecvMsg(value.msgTypeName, value.msgInfo)
  end
end
function GameChatPageMediator:ChatIsForbidden()
  local forbidReason = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emBanChatReason)
  local forbidTimeExpire = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emBanChatTime)
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ForbidChatHint")
  local stringMap = {
    [0] = forbidReason,
    [1] = os.date("%Y-%m-%d %H:%M:%S", forbidTimeExpire)
  }
  local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
end
return GameChatPageMediator
