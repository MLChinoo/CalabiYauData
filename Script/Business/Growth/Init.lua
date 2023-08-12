local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.GrowthProxy,
    Path = "Business/Growth/Proxies/GrowthProxy"
  }
}
M.Commands = {}
return M
