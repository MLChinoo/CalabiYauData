local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.Activities
M.Proxys = {
  {
    Name = ModuleProxyNames.InvitationLetterProxy,
    Path = "Business/Activities/InvitationLetter/Proxies/InvitationLetterProxy"
  }
}
return M
