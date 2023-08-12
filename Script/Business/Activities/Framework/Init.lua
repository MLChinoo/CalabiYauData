local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.ActivitiesProxy,
    Path = "Business/Activities/Framework/Proxies/ActivitiesProxy"
  },
  {
    Name = ModuleProxyNames.BuffProxy,
    Path = "Business/Activities/Framework/Proxies/BuffProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.ReqActivitiesCmd,
    Path = "Business/Activities/Framework/Commands/ActivitiesCmd"
  },
  {
    Name = ModuleNotificationNames.ActivityOperateCmd,
    Path = "Business/Activities/Framework/Commands/ActivityOperatorCmd"
  },
  {
    Name = ModuleNotificationNames.ActivitiesRedDotCmd,
    Path = "Business/Activities/Framework/Commands/ActivitiesRedDotCmd"
  }
}
return M
