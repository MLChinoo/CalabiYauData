local KaMailProxy = class("KaMailProxy", PureMVC.Proxy)
local Valid
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function KaMailProxy:GetCurrentUnReadMailNum()
  return RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaMail)
end
function KaMailProxy:GetMailList()
  return self.MailList
end
function KaMailProxy:GetMailData(MailId)
  return self.MailList[tonumber(MailId)]
end
function KaMailProxy:ReqReadMail(Mail_Ids)
  local data = {}
  data.mail_ids = {}
  local MailId
  for key, InMailId in pairs(Mail_Ids or {}) do
    MailId = InMailId
    Valid = 0 == self:GetMailData(InMailId).mail_state and table.insert(data.mail_ids, InMailId)
  end
  if table.count(data.mail_ids) > 0 then
    self.ReqReadMailIds = data.mail_ids
    SendRequest(Pb_ncmd_cs.NCmdId.NID_MAIL_READ_REQ, pb.encode(Pb_ncmd_cs_lobby.mail_read_req, data))
  else
    Valid = MailId and GameFacade:SendNotification(NotificationDefines.UpdateMailDetail, MailId)
  end
end
function KaMailProxy:ReqDeleteMail(Mail_Ids)
  local data = {mail_ids = Mail_Ids}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MAIL_DELETE_REQ, pb.encode(Pb_ncmd_cs_lobby.mail_delete_req, data))
end
function KaMailProxy:ReqTakeAttachMail(Mail_Ids, IsInDetail)
  local data = {mail_ids = Mail_Ids}
  self.IsInDetail = IsInDetail
  self.AttachIdsList = Mail_Ids
  self.AttachId = Mail_Ids[1]
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MAIL_ATTACH_TAKE_REQ, pb.encode(Pb_ncmd_cs_lobby.mail_attach_take_req, data))
end
function KaMailProxy:OnRegister()
  KaMailProxy.super.OnRegister(self)
  self.MailList = {}
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_SYNC_NTF, FuncSlot(self.OnRcvMailList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_READ_RES, FuncSlot(self.OnRcvReadMail, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_ATTACH_TAKE_RES, FuncSlot(self.OnRcvTakeAttachMail, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_DELETE_RES, FuncSlot(self.OnRcvDeleteMail, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_GLOBAL_NTF, FuncSlot(self.OnRcvGlobalMail, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_RECV_NTF, FuncSlot(self.OnRcvNewMail, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MAIL_LOAD_RES, FuncSlot(self.OnRcvLoadNewMail, self))
end
function KaMailProxy:OnRemove()
  KaMailProxy.super.OnRemove(self)
  self.MailList = {}
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_SYNC_NTF, FuncSlot(self.OnRcvMailList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_READ_RES, FuncSlot(self.OnRcvReadMail, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_ATTACH_TAKE_RES, FuncSlot(self.OnRcvTakeAttachMail, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_DELETE_RES, FuncSlot(self.OnRcvDeleteMail, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_GLOBAL_NTF, FuncSlot(self.OnRcvGlobalMail, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_RECV_NTF, FuncSlot(self.OnRcvNewMail, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MAIL_LOAD_RES, FuncSlot(self.OnRcvLoadNewMail, self))
end
function KaMailProxy:OnRcvMailList(ServerData)
  local ResItem = DeCode(Pb_ncmd_cs_lobby.mail_sync_ntf, ServerData)
  if ResItem.mails == nil then
    return
  end
  for i, v in pairs(ResItem.mails) do
    self.MailList[v.mail_id] = v
  end
  if ResItem.finish then
    local redDotCnt = 0
    for key, value in pairs(self.MailList or {}) do
      if 0 == value.attach_state and value.attach_items and table.count(value.attach_items) > 0 or 0 == value.mail_state then
        redDotCnt = redDotCnt + 1
      end
    end
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.KaMail, redDotCnt)
  end
end
function KaMailProxy:OnRcvReadMail(data)
  local ResItem = DeCode(Pb_ncmd_cs_lobby.mail_read_res, data)
  if 0 ~= ResItem.code then
    LogWarn("MailProxy", "Fail to res ReadMail info!!!")
    return
  end
  local MailId
  if self.ReqReadMailIds then
    for key, value in pairs(self.MailList or {}) do
      if table.containsValue(self.ReqReadMailIds, value.mail_id) then
        value.mail_state = 1
        MailId = value.mail_id
        local isRead = true
        if 0 == value.attach_state and value.attach_items and table.count(value.attach_items) > 0 then
          isRead = false
        end
        Valid = isRead and RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.KaMail, -1)
      end
    end
  end
  Valid = MailId and GameFacade:SendNotification(NotificationDefines.UpdateMailDetail, MailId)
end
function KaMailProxy:OnRcvTakeAttachMail(ServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.mail_attach_take_res, ServerData)
  if data.code and 0 ~= data.code then
    LogWarn("MailProxy", "Fail to res TakeAttachMail info!!!")
    return
  end
  if data.attach_items then
    local RedDotNum = 0
    for key, value in pairs(self.MailList or {}) do
      if table.containsValue(self.AttachIdsList, value.mail_id) then
        RedDotNum = RedDotNum + 1
        value.attach_state = 1
        value.mail_state = 1
      end
    end
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.KaMail, -RedDotNum)
    local rewardItems = {}
    for key, value in pairs(data.attach_items or {}) do
      local item = {}
      item.itemId = value.item_id
      item.itemCnt = value.item_count
      table.insert(rewardItems, item)
    end
  end
  local Body, NotifyType
  if self.IsInDetail and self.AttachId then
    Body = self.AttachId
    NotifyType = NotificationDefines.UpdateMailDetail
  else
    NotifyType = NotificationDefines.UpdateMailList
  end
  GameFacade:SendNotification(NotifyType, Body)
  self.AttachId = nil
end
function KaMailProxy:OnRcvDeleteMail(ServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.mail_delete_res, ServerData)
  if data.mail_ids then
    for i, v in pairs(data.mail_ids) do
      self.MailList[v] = nil
    end
  end
  GameFacade:SendNotification(NotificationDefines.UpdateMailList)
end
function KaMailProxy:OnRcvGlobalMail(ServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.mail_global_ntf, ServerData)
  Valid = data and data.mail_uuid and self:ReqLoadMail(data.mail_uuid)
end
function KaMailProxy:OnRcvNewMail(ServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.mail_recv_ntf, ServerData)
  self.MailList[data.mail.mail_id] = data.mail
  RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.KaMail, 1)
  GameFacade:SendNotification(NotificationDefines.UpdateMailList, true)
  GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):AddHintMsg(FriendEnum.FriendMsgType.NewMail)
end
function KaMailProxy:ReqLoadMail(Mail_UUid)
  local data = {mail_uuid = Mail_UUid}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MAIL_LOAD_REQ, pb.encode(Pb_ncmd_cs_lobby.mail_load_req, data))
end
function KaMailProxy:OnRcvLoadNewMail(ServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.mail_load_res, ServerData)
  Valid = 0 ~= data.code and GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
end
return KaMailProxy
