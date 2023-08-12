local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Guide
M.Proxys = {
  {
    Name = ModuleProxyNames.GuideProxy,
    Path = "Business/Guide/Proxies/GuideProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.DeathTipsCmd,
    Path = "Business/Guide/Commands/GuideDeathTipsCmd"
  },
  {
    Name = ModuleNotificationNames.MediaGuideCmd,
    Path = "Business/Guide/Commands/GuideMediaGuideCmd"
  }
}
return M
