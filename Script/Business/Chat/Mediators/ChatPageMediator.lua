local ChatPageMediator = class("ChatPageMediator", PureMVC.Mediator)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local PMVoiceManager
function ChatPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.CreateChatGroup,
    NotificationDefines.Chat.ModifyChatGroupInfo,
    NotificationDefines.Chat.MemberEnter,
    NotificationDefines.Chat.MemberExit,
    NotificationDefines.SetChatState,
    NotificationDefines.Chat.GetGroupChatList,
    NotificationDefines.Chat.SendMsgReback,
    NotificationDefines.Chat.RecvMsg,
    NotificationDefines.Chat.CreatePrivateChat,
    NotificationDefines.GameModeSelect.GameModeChanged,
    NotificationDefines.FriendCmd,
    NotificationDefines.GameServerReconnect,
    NotificationDefines.FriendInfoChange,
    NotificationDefines.Chat.AddSystemMsg
  }
end
function ChatPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.SetChatState then
    if notification:GetType() == NotificationDefines.ChatState.Hide then
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.deactive)
      self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if notification:GetType() == NotificationDefines.ChatState.Show then
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.deactive)
      self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if notification:GetType() == NotificationDefines.ChatState.Collapsed then
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.deactive)
    end
    if notification:GetType() == NotificationDefines.ChatState.HoldOn then
      self:GetViewComponent():SetChatInvalidation(true)
    end
    if notification:GetType() == NotificationDefines.ChatState.CancelHoldOn then
      self:GetViewComponent():SetChatInvalidation(false)
    end
  end
  if notification:GetName() == NotificationDefines.Chat.CreatePrivateChat then
    local targetPlayerInfo = notification:GetBody()
    if targetPlayerInfo.playerId and targetPlayerInfo.playerName then
      self:GetViewComponent():AddChat(ChatEnum.EChatChannel.private, targetPlayerInfo.playerName, targetPlayerInfo.playerId)
      self:GetViewComponent():SetChatState(ChatEnum.EChatState.active)
      self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.channelMap[targetPlayerInfo.playerId] = targetPlayerInfo.playerName
    end
  end
  if notification:GetName() == NotificationDefines.Chat.GetGroupChatList then
    local groupChatList = notification:GetBody()
    for key, value in pairs(groupChatList) do
      if self.channelMap[value.group_id] == nil then
        self:CreateGroupChat(value)
      end
    end
    self:GetViewComponent():InitFriendList()
  end
  if notification:GetName() == NotificationDefines.Chat.ModifyChatGroupInfo then
    local groupChatInfo = notification:GetBody()
    for key, value in pairs(self.channelMap) do
      if self:GetTabName(groupChatInfo.group_type) == value then
        self.channelMap[key] = nil
        self.channelMap[groupChatInfo.group_id] = value
        break
      end
    end
  end
  if notification:GetName() == NotificationDefines.Chat.CreateChatGroup then
    self:CreateGroupChat(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Chat.MemberEnter then
    local groupId = notification:GetBody().group_id
    local member = notification:GetBody().member
    if self.channelMap[groupId] then
      if self.channelMap[groupId] == ChatEnum.ChannelName.room then
        if member.player_id == self.playerId then
          self.teamIndex = member.team_id
          for index, value in pairs(self.groupMember) do
            if value.team_id == self.teamIndex then
              self:GetViewComponent():AddMember(ChatEnum.ChannelName.team, value)
            else
              self:GetViewComponent():DeleteMember(ChatEnum.ChannelName.team, value.player_id)
            end
          end
          local groupProp = {}
          groupProp.isCustomRoom = true
          groupProp.teamId = self.teamIndex
          groupProp.roomId = groupId
          if groupProp.teamId then
            GameFacade:SendNotification(NotificationDefines.Chat.ChatGroupProp, groupProp)
          end
        elseif self.groupMember[member.player_id] then
          self.groupMember[member.player_id] = member
          if member.team_id == self.teamIndex then
            self:GetViewComponent():AddMember(ChatEnum.ChannelName.team, member)
          else
            self:GetViewComponent():DeleteMember(ChatEnum.ChannelName.team, member.player_id)
          end
        else
          self.groupMember[member.player_id] = member
          self:GetViewComponent():AddMember(self.channelMap[groupId], member)
          if member.team_id == self.teamIndex then
            self:GetViewComponent():AddMember(ChatEnum.ChannelName.team, member)
          end
        end
      else
        self:GetViewComponent():AddMember(self.channelMap[groupId], member)
      end
    end
    local groupChatList = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetGroupChatList()
    if groupChatList[ChatEnum.EChatChannel.room] and member.player_id == self.playerId then
      local roomInfo = groupChatList[ChatEnum.EChatChannel.room]
      local groupID = roomInfo.group_id
      self.teamIndex = member.team_id
      local teamIdStr = tostring(groupID) .. tostring(self.teamIndex)
      PMVoiceManager:JoinTeamVoiceChannel(teamIdStr)
      if self.teamIndex ~= 254 then
        PMVoiceManager:JoinRoomVoiceChannel(tostring(groupID))
      else
        PMVoiceManager:QuitRoomVoiceChannel()
      end
    end
  end
  if notification:GetName() == NotificationDefines.Chat.MemberExit then
    local targetChannelName = self.channelMap[notification:GetBody().group_id]
    if notification:GetBody().player_id and notification:GetBody().player_id ~= self.playerId then
      self.groupMember[notification:GetBody().player_id] = nil
      self:GetViewComponent():DeleteMember(targetChannelName, notification:GetBody().player_id)
    else
      self:GetViewComponent():DeleteChat(targetChannelName)
      if targetChannelName == ChatEnum.ChannelName.room then
        self:GetViewComponent():DeleteChat(ChatEnum.ChannelName.team)
      end
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
          chatIcon_Border = self.playerIconBorder,
          isOwnMsg = true,
          isPrivateChat = true
        }
        self:GetViewComponent():NotifyRecvMsg(self.channelMap[sendMsgRes.tar_player_id], msgToShow)
      end
    elseif sendMsgRes.code == 20306 then
      self:ChatIsForbidden()
      self:GetViewComponent():SendMsg(false)
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, sendMsgRes.code)
      self:GetViewComponent():SendMsg(false)
    end
  end
  if notification:GetName() == NotificationDefines.Chat.RecvMsg then
    local msgInfo = notification:GetBody()
    local msgToShow = {}
    local channelName
    if notification:GetType() == NotificationDefines.Chat.MsgType.Group then
      msgToShow = {
        chatId = msgInfo.group_id,
        chatNick = msgInfo.nick,
        chatMsg = msgInfo.msg,
        chatIcon = msgInfo.icon,
        chatIcon_Border = msgInfo.vc_border_id,
        isOwnMsg = msgInfo.player_id == self.playerId,
        playerId = msgInfo.player_id
      }
      if msgInfo.team_id and 0 ~= msgInfo.team_id then
        channelName = ChatEnum.ChannelName.team
      else
        channelName = self.channelMap[msgInfo.group_id]
      end
    else
      msgToShow = {
        chatId = msgInfo.src_player_id,
        chatNick = msgInfo.src_nick,
        chatMsg = msgInfo.msg,
        chatIcon = msgInfo.icon,
        chatIcon_Border = msgInfo.vc_border_id,
        isOwnMsg = msgInfo.src_player_id == self.playerId,
        isPrivateChat = true
      }
      channelName = msgInfo.src_nick
      if nil == self.channelMap[msgInfo.src_player_id] then
        self.channelMap[msgInfo.src_player_id] = channelName
      end
    end
    self:GetViewComponent():NotifyRecvMsg(channelName, msgToShow)
  end
  if notification:GetName() == NotificationDefines.Chat.AddSystemMsg then
    self:GetViewComponent():AddSystemMsg(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.FriendCmd then
    if notification:GetType() == NotificationDefines.FriendCmdType.FriendInitComplete then
      self:GetViewComponent():InitFriendList()
    end
    if notification:GetType() == NotificationDefines.FriendCmdType.FriendDelNtf then
      self:GetViewComponent():DeleteFriend(notification:GetBody())
    end
  end
  if notification:GetName() == NotificationDefines.FriendInfoChange then
    self:GetViewComponent():UpdateFriendInfo(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.GameModeSelect.GameModeChanged then
    self:GetViewComponent():ClearTeamMsgs()
  end
  if notification:GetName() == NotificationDefines.GameServerReconnect then
    self:GetViewComponent():SendMsg(false)
  end
end
function ChatPageMediator:OnRegister()
  ChatPageMediator.super.OnRegister(self)
  self.channelMap = {}
  self.teamIndex = 0
  self.playerName = ""
  self.playerId = 0
  self.groupMember = {}
  self:GetViewComponent().actionOnShowReserveMsg:Add(self.ShowReservedMsgs, self)
  self:GetViewComponent().actionOnSendMsg:Add(self.OnSendMsg, self)
  self:GetViewComponent().actionOnDeleteChat:Add(self.OnDeleteChat, self)
  PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
end
function ChatPageMediator:OnRemove()
  self:GetViewComponent().actionOnShowReserveMsg:Remove(self.ShowReservedMsgs, self)
  self:GetViewComponent().actionOnSendMsg:Remove(self.OnSendMsg, self)
  self:GetViewComponent().actionOnDeleteChat:Remove(self.OnDeleteChat, self)
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  ChatPageMediator.super.OnRemove(self)
end
function ChatPageMediator:OnJoinVoiceRoom(roomID)
  if PMVoiceManager:GetTeamVoiceChannel() == roomID then
    local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if chatDataProxy then
      chatDataProxy:SendMicStateReq()
    end
  end
end
function ChatPageMediator:OnSendMsg(msgInfo)
  local targetChannel = msgInfo.channelType
  if targetChannel == ChatEnum.EChatChannel.private then
    GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SendChatReq(msgInfo.chatId, msgInfo.msgSend, os.time(), msgInfo.chatName)
  elseif targetChannel == ChatEnum.EChatChannel.team then
    if self.teamIndex > 0 then
      targetChannel = ChatEnum.EChatChannel.room
    end
    GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SendGroupChatReq(targetChannel, msgInfo.msgSend, os.time(), self.teamIndex)
  elseif targetChannel == ChatEnum.EChatChannel.room then
    GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SendGroupChatReq(targetChannel, msgInfo.msgSend, os.time(), 0)
  else
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SendGroupChatReq(targetChannel, msgInfo.msgSend, os.time())
    else
      GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):SendWorldChatMsg(msgInfo.msgSend)
    end
  end
end
function ChatPageMediator:OnDeleteChat(tabName)
  for key, value in pairs(self.channelMap) do
    if value == tabName then
      self.channelMap[key] = nil
    end
  end
end
function ChatPageMediator:GetTabName(groupType)
  local tabString = ""
  if groupType == ChatEnum.EChatChannel.world then
    tabString = ChatEnum.ChannelName.world
  elseif groupType == ChatEnum.EChatChannel.team then
    tabString = ChatEnum.ChannelName.team
  elseif groupType == ChatEnum.EChatChannel.room then
    tabString = ChatEnum.ChannelName.room
  end
  return tabString
end
function ChatPageMediator:CreateGroupChat(chatGroupInfo)
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.fight then
    return
  end
  if self.playerName == "" then
    self.playerName = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emNick)
    self.playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
    self.playerIcon = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
    if self.playerIcon == nil then
      self.playerIcon = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
    end
    self.playerIconBorder = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId))
  end
  self.teamIndex = 0
  self.groupMember = {}
  local tabName = self:GetTabName(chatGroupInfo.group_type)
  self.channelMap[chatGroupInfo.group_id] = tabName
  self:GetViewComponent():AddChat(chatGroupInfo.group_type, tabName, chatGroupInfo.group_id, chatGroupInfo.members, self.playerId)
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.room then
    local redTeam, blueTeam = {}, {}
    for key, value in pairs(chatGroupInfo.members) do
      if value.player_id == self.playerId then
        self.teamIndex = value.team_id
      else
        self.groupMember[value.player_id] = value
        if 1 == value.team_id then
          table.insert(redTeam, value)
        else
          table.insert(blueTeam, value)
        end
      end
    end
    local playerTeam = redTeam
    if 1 ~= self.teamIndex then
      playerTeam = blueTeam
    end
    self:GetViewComponent():AddChat(ChatEnum.EChatChannel.team, self:GetTabName(ChatEnum.EChatChannel.team), chatGroupInfo.group_id, playerTeam, self.playerId)
  end
  local groupProp = {}
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.team then
    groupProp.isCustomRoom = false
    groupProp.teamId = chatGroupInfo.group_id
    groupProp.roomId = 0
    PMVoiceManager:SetGameModeType(RoomEnum.GameModeType.Matching)
    local roomIdStr = tostring(chatGroupInfo.group_id)
    if self.teamIndex ~= 254 then
      PMVoiceManager:JoinRoomVoiceChannel(roomIdStr)
    end
    local teamIdStr = tostring(chatGroupInfo.group_id) .. "1"
    PMVoiceManager:JoinTeamVoiceChannel(teamIdStr)
  end
  if chatGroupInfo.group_type == ChatEnum.EChatChannel.room then
    groupProp.isCustomRoom = true
    groupProp.teamId = self.teamIndex
    groupProp.roomId = chatGroupInfo.group_id
    PMVoiceManager:SetGameModeType(RoomEnum.GameModeType.Custom)
    local roomIdStr = tostring(chatGroupInfo.group_id)
    if self.teamIndex ~= 254 then
      PMVoiceManager:JoinRoomVoiceChannel(roomIdStr)
    end
    local teamIdStr = tostring(chatGroupInfo.group_id) .. tostring(self.teamIndex)
    PMVoiceManager:JoinTeamVoiceChannel(teamIdStr)
  end
  if groupProp.teamId then
    GameFacade:SendNotification(NotificationDefines.Chat.ChatGroupProp, groupProp)
  end
end
function ChatPageMediator:ShowReservedMsgs()
  local msgs = {}
  local reservedGroupMsgs = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetGroupMsg()
  for _, value in pairs(reservedGroupMsgs) do
    local msgToShow = {
      chatId = value.groupId,
      chatNick = value.nick,
      chatMsg = value.msg,
      chatIcon = value.icon,
      chatIcon_Border = value.vc_border_id,
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
        chatIcon_Border = value.vc_border_id,
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
function ChatPageMediator:ChatIsForbidden()
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
return ChatPageMediator
