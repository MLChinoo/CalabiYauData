local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.SystemNoticeProxy,
    Path = "Business/SystemNotice/Proxies/SystemNoticeProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.SystemNotice.AddNotice,
    Path = "Business/SystemNotice/Commands/SystemNoticeCmd"
  },
  {
    Name = ModuleNotificationNames.SystemNotice.DeleteNotice,
    Path = "Business/SystemNotice/Commands/SystemNoticeCmd"
  }
}
return M
