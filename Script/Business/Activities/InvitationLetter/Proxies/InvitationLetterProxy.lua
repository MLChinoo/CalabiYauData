local InvitationLetterProxy = class("InvitationLetterProxy", PureMVC.Proxy)
InvitationLetterProxy.ActivityEventTypeEnum = {EntryMainPage = 1, QuitActivity = 2}
function InvitationLetterProxy:OnRegister()
  InvitationLetterProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_DATA_GET_RES, FuncSlot(self.OnResGetInvitationLetterData, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_REWARD_RES, FuncSlot(self.OnResGetInvitationCode, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_DATA_NTF, FuncSlot(self.OnNtfInvitationCardData, self))
end
function InvitationLetterProxy:OnRemove()
  InvitationLetterProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_DATA_GET_RES, FuncSlot(self.OnResGetInvitationLetterData, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_REWARD_RES, FuncSlot(self.OnResGetInvitationCode, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_DATA_NTF, FuncSlot(self.OnNtfInvitationCardData, self))
  end
end
function InvitationLetterProxy:ReqGetInvitationLetterData()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_DATA_GET_REQ, pb.encode(Pb_ncmd_cs_lobby.invite_card_data_get_req, {activity_id = 10009}))
end
function InvitationLetterProxy:OnResGetInvitationLetterData(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.invite_card_data_get_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  if netData.invite_card_cfg_list and netData.invite_card_data_list then
    local sendData = {}
    sendData.dataList = netData.invite_card_data_list
    sendData.cfgList = netData.invite_card_cfg_list
    sendData.bIsArray = true
    GameFacade:SendNotification(NotificationDefines.Activities.InvitationLetter.UpdateInvitationLetterData, sendData)
  end
end
function InvitationLetterProxy:ReqGetInvitationCode(activityId, subActivityId)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_INVITE_CARD_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.invite_card_reward_req, {activity_id = activityId, sub_activity_id = subActivityId}))
end
function InvitationLetterProxy:OnResGetInvitationCode(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.invite_card_reward_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  if netData.card_data then
    local sendData = {}
    sendData.dataList = netData.card_data
    sendData.bIsArray = false
    GameFacade:SendNotification(NotificationDefines.Activities.InvitationLetter.UpdateInvitationLetterData, sendData)
  end
end
function InvitationLetterProxy:OnNtfInvitationCardData(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.invite_card_data_ntf, data)
  if netData.invite_card_data_list then
    for key, value in pairs(netData.invite_card_data_list) do
      if 1 == value.status then
        self:SetRedRotNum(1)
      end
    end
  end
end
function InvitationLetterProxy:HandleCommonData()
  local commonData = UE4.FActivityInvitationletterData()
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):GetInvitationLetterCommonData(commonData)
  return commonData
end
function InvitationLetterProxy:SendTLOG(data)
  LogDebug("InvitationLetterProxy", "SendTLOG Data is :")
  table.print(data)
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):SendTLogData(data, false)
end
function InvitationLetterProxy:SetActivityEventInfoOfTLOG(eventType)
  local commonData = self:HandleCommonData()
  if commonData then
    commonData.Activityeventtime = commonData.Dteventtime
    commonData.Activityevent = eventType
  end
  local str = UE4.UPMCliTLogApi.Make_ActivityInvitationletter_Data(commonData)
  self:SendTLOG(str)
end
function InvitationLetterProxy:SetRedRotNum(Num)
  self.RedRotNum = Num
  if self.RedRotNum < 0 then
    self.RedRotNum = 0
  end
  if self.RedRotNum > 0 then
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(10009, 1)
  else
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(10009, 0)
  end
end
function InvitationLetterProxy:GetRedRotNum()
  if self.RedRotNum then
    return self.RedRotNum
  end
  return nil
end
return InvitationLetterProxy
