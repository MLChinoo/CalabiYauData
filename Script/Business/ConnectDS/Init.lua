local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {}
M.Commands = {
  {
    Name = ModuleNotificationNames.ReConnectToDS,
    Path = "Business/ConnectDS/Commands/ConnectToDSCommand"
  }
}
return M
