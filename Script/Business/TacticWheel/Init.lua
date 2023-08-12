local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.TacticWheelProxy,
    Path = "Business/TacticWheel/Proxies/TacticWheelProxy"
  }
}
M.Commands = {}
return M
