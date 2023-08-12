local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.FlapFaceProxy,
    Path = "Business/Activities/FlapFace/Proxies/FlapFaceProxy"
  }
}
return M
