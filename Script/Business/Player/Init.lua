local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.PlayerProxy,
    Path = "Business/Player/Proxies/PlayerProxy"
  }
}
M.Commands = {}
return M
