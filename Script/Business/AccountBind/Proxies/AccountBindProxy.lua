local AccountBindProxy = class("AccountBindProxy", PureMVC.Proxy)
function AccountBindProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SEND_PHONE_MSG_RES, FuncSlot(self.OnResSendPhoneMsg, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CHECK_PHONE_CODE_RES, FuncSlot(self.OnResCheckPhoneCode, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_QUERY_ACCOUNT_INFO_RES, FuncSlot(self.OnResQueryAccountInfo, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_PHONE_RES, FuncSlot(self.OnResBindAccountPhone, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_FANBOOK_RES, FuncSlot(self.OnResBindAccountFanbook, self))
end
function AccountBindProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SEND_PHONE_MSG_RES, FuncSlot(self.OnResSendPhoneMsg, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CHECK_PHONE_CODE_RES, FuncSlot(self.OnResCheckPhoneCode, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_QUERY_ACCOUNT_INFO_RES, FuncSlot(self.OnResQueryAccountInfo, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_PHONE_RES, FuncSlot(self.OnResBindAccountPhone, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_FANBOOK_RES, FuncSlot(self.OnResBindAccountFanbook, self))
end
function AccountBindProxy:ReqSendPhoneMsg(phone, sms_type)
  LogDebug("AccountBindProxy", "ReqSendPhoneMsg sms_type = " .. tostring(sms_type) .. ";phone = " .. phone)
  local SendPhoneMsg = {}
  SendPhoneMsg.phone = phone
  SendPhoneMsg.sms_type = sms_type
  local req = pb.encode(Pb_ncmd_cs_lobby.send_phone_msg_req, SendPhoneMsg)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_SEND_PHONE_MSG_REQ, req)
  end
end
function AccountBindProxy:OnResSendPhoneMsg(data)
  LogDebug("AccountBindProxy", "OnResSendPhoneMsg")
  local PhoneMsg = pb.decode(Pb_ncmd_cs_lobby.send_phone_msg_res, data)
  if 0 ~= PhoneMsg.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, PhoneMsg.code)
    return
  end
end
function AccountBindProxy:ReqCheckPhoneCode(phone, code, check_type)
  LogDebug("AccountBindProxy", "ReqCheckPhoneCode check_type = " .. tostring(check_type) .. ";code  = " .. code .. ";phone = " .. phone)
  local CheckPhone = {}
  CheckPhone.phone = phone
  CheckPhone.check_type = check_type
  CheckPhone.code = code
  local req = pb.encode(Pb_ncmd_cs_lobby.check_phone_code_req, CheckPhone)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_CHECK_PHONE_CODE_REQ, req)
  end
end
function AccountBindProxy:OnResCheckPhoneCode(data)
  LogDebug("AccountBindProxy", "OnResCheckPhoneCode")
  local CheckPhone = pb.decode(Pb_ncmd_cs_lobby.check_phone_code_res, data)
  if 0 ~= CheckPhone.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, CheckPhone.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.AccountBind.PhoneCheckSuccess)
end
function AccountBindProxy:ReqQueryAccountInfo()
  local QueryAccountInfo = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.query_account_info_req, QueryAccountInfo)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_QUERY_ACCOUNT_INFO_REQ, req)
  end
end
function AccountBindProxy:OnResQueryAccountInfo(data)
  LogDebug("AccountBindProxy", "OnResQueryAccountInfo")
  local accountInfo = pb.decode(Pb_ncmd_cs_lobby.query_account_info_res, data)
  if 0 ~= accountInfo.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, accountInfo.code)
    return
  end
  self.PhoneNumber = accountInfo.phone
  self.FBid = accountInfo.fanbook
  self.PhoneBindCount = accountInfo.phone_count
  self.FBBindCount = accountInfo.fanbook_count
  GameFacade:SendNotification(NotificationDefines.AccountBind.UpdataAccountInfo)
end
function AccountBindProxy:ReqBindAccountPhone(oper_type, phone_code, phone)
  LogDebug("AccountBindProxy", "ReqBindAccountPhone oper_type = " .. tostring(oper_type) .. ";phone_code  = " .. phone_code .. ";phone = " .. phone)
  local BindAccountPhone = {}
  BindAccountPhone.phone = phone
  BindAccountPhone.phone_code = phone_code
  BindAccountPhone.oper_type = oper_type
  local req = pb.encode(Pb_ncmd_cs_lobby.bind_account_phone_req, BindAccountPhone)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_PHONE_REQ, req)
  end
end
function AccountBindProxy:OnResBindAccountPhone(data)
  LogDebug("AccountBindProxy", "OnResBindAccountPhone")
  local BindAccount = pb.decode(Pb_ncmd_cs_lobby.bind_account_phone_res, data)
  if 0 ~= BindAccount.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, BindAccount.code)
    return
  end
  if 0 == BindAccount.oper_type then
    self.PhoneNumber = BindAccount.phone
    self.PhoneBindCount = self.PhoneBindCount + 1
    GameFacade:SendNotification(NotificationDefines.AccountBind.PhoneBindSuccess)
    local tipsMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PhoneBindSuccessTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
  elseif 1 == BindAccount.oper_type then
    self.PhoneNumber = ""
    local tipsMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PhoneUnBindSuccessTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
  else
    LogError("AccountBindProxy", "OnResBindAccountPhone BindAccount.oper_type == " .. tostring(BindAccount.oper_type))
  end
end
function AccountBindProxy:ReqBindAccountFanbook(oper_type, fanbook_code, redirect_uri)
  print("AccountBindProxy", "ReqBindAccountFanbook oper_type = " .. tostring(oper_type) .. ";fanbook_code  = " .. fanbook_code)
  local BindAccountFanbook = {}
  BindAccountFanbook.oper_type = oper_type
  BindAccountFanbook.fanbook_code = fanbook_code
  BindAccountFanbook.redirect_uri = redirect_uri
  local req = pb.encode(Pb_ncmd_cs_lobby.bind_account_fanbook_req, BindAccountFanbook)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_BIND_ACCOUNT_FANBOOK_REQ, req)
  end
end
function AccountBindProxy:OnResBindAccountFanbook(data)
  LogDebug("AccountBindProxy", "OnResBindAccountFanbook")
  local BindAccount = pb.decode(Pb_ncmd_cs_lobby.bind_account_fanbook_res, data)
  if 0 ~= BindAccount.code then
    GameFacade:SendNotification(NotificationDefines.AccountBind.FanbookBindFail)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, BindAccount.code)
    return
  end
  if 0 == BindAccount.oper_type then
    self.FBBindCount = self.FBBindCount + 1
    GameFacade:SendNotification(NotificationDefines.AccountBind.FanbookBindSuccess)
    local tipsMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "FanbookBindSuccessTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
  elseif 1 == BindAccount.oper_type then
    local tipsMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "FanbookUnBindSuccessTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
  else
    LogError("AccountBindProxy", "OnResBindAccountFanbook BindAccount.oper_type == " .. tostring(BindAccount.oper_type))
  end
end
function AccountBindProxy:GetPhoneNumber()
  if self.PhoneNumber and self.PhoneNumber ~= "" then
    local PhoneNumberStar = string.sub(self.PhoneNumber, 1, 3)
    local PhoneNumberEnd = string.sub(self.PhoneNumber, -4)
    return self.PhoneNumber, PhoneNumberStar, PhoneNumberEnd
  end
  return nil
end
function AccountBindProxy:GetFBid()
  return self.FBid
end
function AccountBindProxy:SetPhoneCode(phone_code)
  self.PhoneCode = phone_code
end
function AccountBindProxy:GetPhoneCode()
  return self.PhoneCode
end
function AccountBindProxy:GetPhoneIsBind()
  if self.PhoneNumber == nil or self.PhoneNumber == "" then
    return false
  end
  return true
end
function AccountBindProxy:GetFBIsBind()
  if self.FBid == nil or self.FBid == "" then
    return false
  end
  return true
end
function AccountBindProxy:GetPhoneBindReward()
  local PhoneBindRewardIndex = 8109
  local PhoneBindRewardText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(PhoneBindRewardIndex).ParaValue
  PhoneBindRewardText = string.gsub(PhoneBindRewardText, ":", "=")
  PhoneBindRewardText = string.gsub(PhoneBindRewardText, "\"", "")
  local tb = load("return " .. PhoneBindRewardText)()
  return tb.item_id, tb.item_count
end
function AccountBindProxy:GetFBBindReward()
  local PhoneBindRewardIndex = 8110
  local PhoneBindRewardText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(PhoneBindRewardIndex).ParaValue
  if PhoneBindRewardText then
    PhoneBindRewardText = string.gsub(PhoneBindRewardText, ":", "=")
    PhoneBindRewardText = string.gsub(PhoneBindRewardText, "\"", "")
    local tb = load("return " .. PhoneBindRewardText)()
    return tb.item_id, tb.item_count
  end
  return nil
end
function AccountBindProxy:GetPhoneBingHasReward()
  if self.PhoneBindCount then
    return 0 == self.PhoneBindCount
  end
  return false
end
function AccountBindProxy:GetFBBingHasReward()
  if self.FBBindCount then
    return 0 == self.FBBindCount
  end
  return false
end
function AccountBindProxy:CheckIsMobile(str)
  if nil == str then
    return false
  end
  local result = string.match(str, "[1][3-9]%d%d%d%d%d%d%d%d%d")
  return result == str
end
function AccountBindProxy:CheckIsVerificationCode(str)
  if nil == str then
    return false
  end
  local result = string.match(str, "%d%d%d%d%d%d")
  return result == str
end
return AccountBindProxy
