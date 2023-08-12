local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.SummerThemeSongProxy,
    Path = "Business/Activities/SummerThemeSong/Proxies/SummerThemeSongProxy"
  }
}
return M
