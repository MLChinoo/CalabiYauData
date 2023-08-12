local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.SpaceMusicProxy,
    Path = "Business/Activities/SpaceMusic/Proxies/SpaceMusicProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.SpaceMusic.SpaceMusicOperatorCmd,
    Path = "Business/Activities/SPaceMusic/Commands/SpaceMusicOperatorCmd"
  }
}
return M
