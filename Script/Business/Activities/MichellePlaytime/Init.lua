local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.MichellePlaytimeProxy,
    Path = "Business/Activities/MichellePlaytime/Proxies/MichellePlaytimeProxy"
  }
}
return M
