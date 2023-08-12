local M = class("Init", PureMVC.ModuleInit)
local ModuleNotificationNames = NotificationDefines.InGameTipoffPlayer
M.Proxys = {
  {
    Name = ProxyNames.InGameTipoffPlayerDataProxy,
    Path = "Business/Tipoff/InGame/Proxies/InGameTipoffPlayerDataProxy"
  }
}
M.Commands = {}
return M
