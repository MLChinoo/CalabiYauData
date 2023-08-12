local ApartmentRoomTouchProxy = class("ApartmentRoomTouchProxy", PureMVC.Proxy)
function ApartmentRoomTouchProxy:OnRegister()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_INTERACTION_RES, FuncSlot(self.OnResInteraction, self))
  end
end
function ApartmentRoomTouchProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_INTERACTION_RES, FuncSlot(self.OnResInteraction, self))
  end
end
function ApartmentRoomTouchProxy:GetRoleUnlockCfg(roleID, favorableLevel)
  local data = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleUnlockParts(roleID, favorableLevel)
  LogDebug("ApartmentRoomTouchProxy:GetRoleUnlockCfg", "current roleID is " .. roleID .. " , current favorableLevel is " .. favorableLevel)
  LogDebug("ApartmentRoomTouchProxy:GetRoleUnlockCfg", "Unlock part list")
  table.print(data)
  return data
end
function ApartmentRoomTouchProxy:TouchRole()
  local roleID = UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):GetApartmentCurRoleId()
  self:ReqInteraction(roleID)
end
function ApartmentRoomTouchProxy:ReqInteraction(roleID)
  local data = {role_id = roleID}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_INTERACTION_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_interaction_req, data))
end
function ApartmentRoomTouchProxy:OnResInteraction(data)
  local interactionData = pb.decode(Pb_ncmd_cs_lobby.salon_interaction_res, data)
  if nil == interactionData then
    LogError("ApartmentRoomTouchProxy:OnResInteraction", "equipData decode Faild")
    return
  end
  if 0 ~= interactionData.code then
    LogWarn("ApartmentRoomTouchProxy:OnResInteraction", "ErrorCode is " .. tostring(interactionData.code))
    return
  end
  LogDebug("ApartmentRoomTouchProxy:OnResInteraction", "OnResInteraction call back")
end
return ApartmentRoomTouchProxy
