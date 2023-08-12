local RolePersonalityCommunicationProxy = class("RolePersonalityCommunicationProxy", PureMVC.Proxy)
function RolePersonalityCommunicationProxy:OnRegister()
  RolePersonalityCommunicationProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_PERSONALITY_RES, FuncSlot(self.OnResSetPersonality, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SWAP_PERSONALITY_RES, FuncSlot(self.OnResSwapPersonality, self))
  end
end
function RolePersonalityCommunicationProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_PERSONALITY_RES, FuncSlot(self.OnResSetPersonality, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SWAP_PERSONALITY_RES, FuncSlot(self.OnResSwapPersonality, self))
  end
end
function RolePersonalityCommunicationProxy:GetAllRoleEmoteTableRows()
  return self.roleEmoteTableRows
end
function RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData(roleID, index, itemID)
  if nil == index then
    LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "index is nil,itemID : " .. tostring(itemID))
    return
  end
  if nil == itemID then
    LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "itemID is nil,index : " .. tostring(index))
    return
  end
  if nil == roleID then
    LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "roleID is nil")
    return
  end
  if 0 ~= roleID then
    local personalitys = self:GetRoleRouletteSeverData(roleID)
    if personalitys then
      local personalityInfo = personalitys[index]
      if personalityInfo then
        personalityInfo.id = itemID
      else
        LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "personalityInfo is nil,index : " .. tostring(index))
      end
    else
      LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "personalitys is nil,roleID : " .. tostring(roleID))
    end
  else
    local rolePerpareDataMap = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):GetRolePrepareServerDataMap()
    if rolePerpareDataMap then
      for key, value in pairs(rolePerpareDataMap) do
        if value and value.personalities then
          local personalityInfo = value.personalities[index]
          if personalityInfo then
            personalityInfo.id = itemID
          else
            LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipSeverData", "personalityInfo is nil,index : " .. tostring(index))
          end
        else
          LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipSeverData", "value is nil,roleID : " .. tostring(key))
        end
      end
    end
  end
end
function RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData(roleID, index1, index2)
  if nil == index1 then
    LogError("RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData", "index1 is nil,roleID : " .. tostring(roleID))
    return
  end
  if nil == index2 then
    LogError("RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData", "index2 is nil,roleID : " .. tostring(roleID))
    return
  end
  if nil == roleID then
    LogError("RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData", "roleID is nil")
    return
  end
  local personalitys = self:GetRoleRouletteSeverData(roleID)
  if personalitys then
    local personalityInfo1 = personalitys[index1]
    if nil == personalityInfo1 then
      LogError("RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData", "personalityInfo1 is nil,index : " .. tostring(index1))
      return
    end
    local personalityInfo2 = personalitys[index2]
    if nil == personalityInfo2 then
      LogError("RolePersonalityCommunicationProxy:SwapRoleEquipPersonalitySeverData", "personalityInfo2 is nil,index : " .. tostring(index2))
      return
    end
    local temp = personalityInfo1.id
    personalityInfo1.id = personalityInfo2.id
    personalityInfo2.id = temp
  else
    LogError("RolePersonalityCommunicationProxy:UpdateRoleEquipPersonalitySeverData", "personalitys is nil,roleID : " .. tostring(roleID))
  end
end
function RolePersonalityCommunicationProxy:ReqSetsPersonality(roleID, index, itemID)
  local data = {
    role_id = roleID,
    index = index,
    id = itemID
  }
  LogDebug("RolePersonalityCommunicationProxy:ReqSetsPersonality", "data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_PERSONALITY_REQ, pb.encode(Pb_ncmd_cs_lobby.role_set_personality_req, data))
end
function RolePersonalityCommunicationProxy:OnResSetPersonality(data)
  local servarData = DeCode(Pb_ncmd_cs_lobby.role_set_personality_res, data)
  if nil == servarData then
    LogError("RoleProxy:OnResUpdateRoleEquipCommunications", "communicationsData decode Faild")
    return
  end
  if 0 ~= servarData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, servarData.code)
    return
  end
  LogDebug("RolePersonalityCommunicationProxy:OnResSetPersonality", "data is :" .. TableToString(servarData))
  if 0 == servarData.role_id then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "AllCharacterEquip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  end
  self:UpdateRoleEquipPersonalitySeverData(servarData.role_id, servarData.index, servarData.id)
  GameFacade:SendNotification(NotificationDefines.OnResEquipPersonality, servarData)
end
function RolePersonalityCommunicationProxy:ReqSwapPersonality(roleID, index1, index2)
  local data = {
    role_id = roleID,
    slot1 = index1,
    slot2 = index2
  }
  LogDebug("RolePersonalityCommunicationProxy:ReqSwapPersonality", "data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_SWAP_PERSONALITY_REQ, pb.encode(Pb_ncmd_cs_lobby.role_swap_personality_req, data))
end
function RolePersonalityCommunicationProxy:OnResSwapPersonality(data)
  local servarData = DeCode(Pb_ncmd_cs_lobby.role_swap_personality_res, data)
  if nil == servarData then
    LogError("RoleProxy:OnResSwapPersonality", "communicationsData decode Faild")
    return
  end
  if 0 ~= servarData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, servarData.code)
    return
  end
  LogDebug("RolePersonalityCommunicationProxy:OnResSwapPersonality", "data is :" .. TableToString(servarData))
  self:SwapRoleEquipPersonalitySeverData(servarData.role_id, servarData.slot1, servarData.slot2)
  GameFacade:SendNotification(NotificationDefines.OnResEquipPersonality, servarData)
end
function RolePersonalityCommunicationProxy:IsEquipPersonality(roleID, itemID)
  if nil == roleID then
    LogError("RolePersonalityCommunicationProxy:IsEquipPersonality", "roleID is nil")
    return false
  end
  if nil == itemID then
    LogError("RolePersonalityCommunicationProxy:IsEquipPersonality", "itemID is nil")
    return false
  end
  local roleEquipData = self:GetRoleRouletteSeverData(roleID)
  if roleEquipData then
    for key, value in pairs(roleEquipData) do
      if value.id == itemID then
        return true
      end
    end
  end
  return false
end
function RolePersonalityCommunicationProxy:GetRoleRouletteSeverData(roleID)
  return GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):GetRoleEquipPersonalities(roleID)
end
function RolePersonalityCommunicationProxy:GetRoleRouletteItemIDByIndex(roleID, index)
  local personalityInfoMap = self:GetRoleRouletteSeverData(roleID)
  if personalityInfoMap then
    return personalityInfoMap[index].id
  end
  return 0
end
return RolePersonalityCommunicationProxy
