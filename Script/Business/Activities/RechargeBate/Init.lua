local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.RechargeBateProxy,
    Path = "Business/Activities/RechargeBate/Proxies/RechargeBateProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.ActivitiesRechargeBateUpdateDataCmd,
    Path = "Business/Activities/RechargeBate/Commands/ActivitiesRechargeBateUpdateDataCmd"
  }
}
return M
