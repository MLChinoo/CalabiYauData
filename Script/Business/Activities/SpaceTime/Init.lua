local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.SpaceTimeProxy,
    Path = "Business/Activities/SpaceTime/Proxies/SpaceTimeProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.SpaceTime.SpaceTimeOperatorCmd,
    Path = "Business/Activities/SPaceTime/Commands/SpaceTimeOperatorCmd"
  }
}
return M
