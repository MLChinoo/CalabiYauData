local MatchProxy = class("MatchProxy", PureMVC.Proxy)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local penaltyDataServer = {}
function MatchProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
end
return MatchProxy
