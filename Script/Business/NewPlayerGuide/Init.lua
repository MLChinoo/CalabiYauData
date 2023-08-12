local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.NewPlayerGuideProxy,
    Path = "Business/NewPlayerGuide/Proxies/NewPlayerGuideProxy"
  },
  {
    Name = ModuleProxyNames.NewPlayerGuideTriggerProxy,
    Path = "Business/NewPlayerGuide/Proxies/NewPlayerGuideTriggerProxy"
  },
  {
    Name = ModuleProxyNames.NewPlayerTeamFightGuideTriggerProxy,
    Path = "Business/NewPlayerGuide/Proxies/NewPlayerTeamFightGuideTriggerProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.ShowPlayerGuideCmd,
    Path = "Business/NewPlayerGuide/Commands/ShowPlayerGuideCmd"
  }
}
return M
