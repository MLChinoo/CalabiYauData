local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.KaPhoneProxy,
    Path = "Business/KaPhone/Proxies/KaPhoneProxy"
  },
  {
    Name = ProxyNames.KaChatProxy,
    Path = "Business/KaPhone/Proxies/KaChatProxy"
  },
  {
    Name = ProxyNames.KaMailProxy,
    Path = "Business/KaPhone/Proxies/KaMailProxy"
  },
  {
    Name = ProxyNames.KaNavigationProxy,
    Path = "Business/KaPhone/Proxies/KaNavigationProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.UpdateKaChatList,
    Path = "Business/KaPhone/Commands/UpdatePhoneChatCmd"
  },
  {
    Name = NotificationDefines.UpdateKaChatDetail,
    Path = "Business/KaPhone/Commands/UpdatePhoneChatDetailCmd"
  },
  {
    Name = NotificationDefines.UpdateMailList,
    Path = "Business/KaPhone/Commands/UpdateMailListCmd"
  },
  {
    Name = NotificationDefines.UpdateMailDetail,
    Path = "Business/KaPhone/Commands/UpdateMailDetailCmd"
  },
  {
    Name = NotificationDefines.UpdateKaNavigation,
    Path = "Business/KaPhone/Commands/UpdateNavigationCmd"
  }
}
return M
