local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.GameModeSelectProxy,
    Path = "Business/Lobby/Proxies/GameModeSelectProxy"
  },
  {
    Name = ModuleProxyNames.MatchRoomProxy,
    Path = "Business/Lobby/Proxies/MatchProxy"
  },
  {
    Name = ModuleProxyNames.RoomProxy,
    Path = "Business/Lobby/Proxies/RoomProxy"
  }
}
M.Commands = {}
return M
