local WorldChatProxy = class("WorldChatProxy", PureMVC.Proxy)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function WorldChatProxy:GetWorldChat()
  return self.worldChatInfo
end
function WorldChatProxy:SetWorldMsgSetting(newSetting)
  LogDebug("WorldChatProxy", "Set world msg receive:%d", newSetting)
  self.msgReceiveSetting = newSetting
  if self.msgReceiveSetting == ChatEnum.EWorldMsgSetting.ignore then
    self:ClearReservedMsg()
  end
end
function WorldChatProxy:GetWorldMsgSetting()
  return self.msgReceiveSetting
end
function WorldChatProxy:GetWorldChannelId()
  return self.worldChatInfo and self.worldChatInfo.group_id or nil
end
function WorldChatProxy:ClearReservedMsg()
  if self.showMsgTask then
    self.showMsgTask:EndTask()
    self.showMsgTask = nil
  end
  self.reservedMsgs = {}
end
function WorldChatProxy:OnRegister()
  LogDebug("WorldChatProxy", "Register world Chat Data Proxy")
  WorldChatProxy.super.OnRegister(self)
  self.worldChatInfo = nil
  self.msgReceiveSetting = ChatEnum.EWorldMsgSetting.display
  self.reservedMsgs = {}
  self.updateFreq = 0
  self.updateFreqMaxTime = 5
  self.showMsgTask = nil
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_CHANNEL_NTF, FuncSlot(self.OnNtfWorldChatChannel, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MODIFY_CHANNEL_RES, FuncSlot(self.OnResModifyChannel, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_ALL_CHANNEL_RES, FuncSlot(self.OnResAllChannel, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_SEND_RES, FuncSlot(self.OnResSendWorldMsg, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_RECV_NTF, FuncSlot(self.OnNtfWorldChatRecv, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MSGS_RES, FuncSlot(self.OnResWorldChatMsgs, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_CLEAR_NTF, FuncSlot(self.OnNtfWorldChatClear, self))
  end
end
function WorldChatProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_CHANNEL_NTF, FuncSlot(self.OnNtfWorldChatChannel, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MODIFY_CHANNEL_RES, FuncSlot(self.OnResModifyChannel, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_ALL_CHANNEL_RES, FuncSlot(self.OnResAllChannel, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_SEND_RES, FuncSlot(self.OnResSendWorldMsg, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_RECV_NTF, FuncSlot(self.OnNtfWorldChatRecv, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MSGS_RES, FuncSlot(self.OnResWorldChatMsgs, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_CLEAR_NTF, FuncSlot(self.OnNtfWorldChatClear, self))
  end
  if self.showMsgTask then
    self.showMsgTask:EndTask()
    self.showMsgTask = nil
  end
  WorldChatProxy.super.OnRemove(self)
end
function WorldChatProxy:CreateNewChatGroup(chatGroupInfo)
  self.worldChatInfo = chatGroupInfo
  GameFacade:SendNotification(NotificationDefines.Chat.CreateChatGroup, chatGroupInfo)
end
function WorldChatProxy:OnNtfWorldChatChannel(data)
  local worldChannelNtf = pb.decode(Pb_ncmd_cs_lobby.world_chat_channel_ntf, data)
  LogDebug("WorldChatProxy", "Ntf initial world channel: %d", worldChannelNtf.channel)
  self:UpdateNewWorldChannel(worldChannelNtf.channel)
end
function WorldChatProxy:QueryAllWorldChannel()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_ALL_CHANNEL_REQ, pb.encode(Pb_ncmd_cs_lobby.world_chat_all_channel_req, {}))
end
function WorldChatProxy:OnResAllChannel(data)
  LogDebug("WorldChatProxy", "Res all world channel...")
  local allChannels = pb.decode(Pb_ncmd_cs_lobby.world_chat_all_channel_res, data)
  LogDebug("WorldChatProxy", TableToString(allChannels))
  GameFacade:SendNotification(NotificationDefines.Chat.OnResAllWorldChannel, allChannels)
end
function WorldChatProxy:ReqModifyWorldChannel(channelIndex)
  LogDebug("WorldChatProxy", "Require change world channel: %d", channelIndex)
  local data = {new_channel = channelIndex}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MODIFY_CHANNEL_REQ, pb.encode(Pb_ncmd_cs_lobby.world_chat_modify_channel_req, data))
end
function WorldChatProxy:OnResModifyChannel(data)
  LogDebug("WorldChatProxy", "Res modify world channel...")
  local modifyChannelRes = pb.decode(Pb_ncmd_cs_lobby.world_chat_modify_channel_res, data)
  if 0 ~= modifyChannelRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, modifyChannelRes.code)
    return
  end
  self:UpdateNewWorldChannel(modifyChannelRes.new_channel)
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "WorldChannelChangeSucceed")
  local stringMap = {
    [0] = modifyChannelRes.new_channel
  }
  local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
end
function WorldChatProxy:SendWorldChatMsg(content)
  LogDebug("WorldChatProxy", "Require send world msg: %s", content)
  local data = {
    item = {msg = content}
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_SEND_REQ, pb.encode(Pb_ncmd_cs_lobby.world_chat_send_req, data))
end
function WorldChatProxy:OnResSendWorldMsg(data)
  local worldMsgSendRes = pb.decode(Pb_ncmd_cs_lobby.world_chat_send_res, data)
  GameFacade:SendNotification(NotificationDefines.Chat.SendMsgReback, worldMsgSendRes, NotificationDefines.Chat.MsgType.Group)
end
function WorldChatProxy:ReqUpdateWorldMsg(frequence)
  if self.msgReceiveSetting == ChatEnum.EWorldMsgSetting.ignore then
    return
  end
  self.updateFreq = frequence
  LogDebug("WorldChatProxy", "Req update world chat msg...")
  local data = {}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_WORLD_CHAT_MSGS_REQ, pb.encode(Pb_ncmd_cs_lobby.world_chat_msgs_req, data))
end
function WorldChatProxy:OnResWorldChatMsgs(data)
  LogDebug("WorldChatProxy", "Res world chat msgs...")
  local worldChatMsgsRes = pb.decode(Pb_ncmd_cs_lobby.world_chat_msgs_res, data)
  if 0 == worldChatMsgsRes.code then
    local selfId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
    for key, value in pairs(worldChatMsgsRes.item) do
      if value.player_id ~= selfId then
        table.insert(self.reservedMsgs, value)
      end
    end
    if self.showMsgTask == nil then
      self:ShowReservedMsg()
    end
  end
end
function WorldChatProxy:ShowReservedMsg()
  if #self.reservedMsgs > 0 then
    local msgItem = table.remove(self.reservedMsgs, 1)
    self:NewWorldMsgItem(msgItem)
    if self.showMsgTask then
      self.showMsgTask:EndTask()
    end
    self.showMsgTask = nil
    if #self.reservedMsgs > 0 then
      local updateInterval = self.updateFreq / table.count(self.reservedMsgs)
      if updateInterval > self.updateFreqMaxTime then
        updateInterval = self.updateFreqMaxTime
      end
      self.showMsgTask = TimerMgr:AddTimeTask(updateInterval, 0, 1, function()
        self:ShowReservedMsg()
      end)
    end
  end
end
function WorldChatProxy:OnNtfWorldChatRecv(data)
  LogDebug("WorldChatProxy", "Ntf receive world chat msg...")
  if self.msgReceiveSetting == ChatEnum.EWorldMsgSetting.ignore then
    return
  end
  local worldChatRecvNtf = pb.decode(Pb_ncmd_cs_lobby.world_chat_recv_ntf, data)
  local msgItem = worldChatRecvNtf.item
  self:NewWorldMsgItem(msgItem)
end
function WorldChatProxy:NewWorldMsgItem(msgItem)
  local chatProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
  if msgItem.player_id and chatProxy and chatProxy:IsInChatBlacklist(msgItem.player_id) then
    return
  end
  if self.worldChatInfo == nil then
    return
  end
  msgItem.group_id = self.worldChatInfo.group_id
  GameFacade:SendNotification(NotificationDefines.Chat.RecvMsg, msgItem, NotificationDefines.Chat.MsgType.Group)
end
function WorldChatProxy:UpdateNewWorldChannel(channelId)
  local chatGroupInfo = {
    group_id = channelId,
    group_type = Pb_ncmd_cs.EChatType.ChatType_WORLD
  }
  self:CreateNewChatGroup(chatGroupInfo)
end
function WorldChatProxy:OnNtfWorldChatClear(data)
  LogDebug("WorldChatProxy", "Ntf clear world chat msg...")
  local worldChatClearNtf = pb.decode(Pb_ncmd_cs_lobby.world_chat_clear_ntf, data)
  if worldChatClearNtf.player_id then
    LogDebug("WorldChatProxy", "Clear target player:%d msg", worldChatClearNtf.player_id)
    local chatProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if chatProxy then
      chatProxy:AddToChatBlacklist(worldChatClearNtf.player_id, true)
    end
    GameFacade:SendNotification(NotificationDefines.Chat.ClearBlacklistMsg, worldChatClearNtf.player_id)
  end
end
return WorldChatProxy
