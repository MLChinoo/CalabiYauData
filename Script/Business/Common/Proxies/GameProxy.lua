local GameProxy = class("GameProxy", PureMVC.Proxy)
function GameProxy:OnRegister()
  GameProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGOUT_RES, FuncSlot(self.OnRcvLogOutMsg, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_KICK_LOBBY_NTF, FuncSlot(self.OnRcvKickOutMsg, self))
  end
end
function GameProxy:OnRcvLogOutMsg(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.logout_res, ServerData)
  if 0 == Data.code then
    GameFacade:SendNotification(NotificationDefines.ClearAllProxy)
  end
end
function GameProxy:OnRemove()
  GameProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGOUT_RES, FuncSlot(self.OnRcvLogOutMsg, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGOUT_RES, FuncSlot(self.OnRcvKickOutMsg, self))
  end
end
function GameProxy:OnRcvKickOutMsg(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.kick_lobby_ntf, ServerData)
  GameFacade:SendNotification(NotificationDefines.ClearAllProxy)
end
return GameProxy
