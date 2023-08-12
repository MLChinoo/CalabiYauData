local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.ChatDataProxy,
    Path = "Business/Chat/Proxies/ChatDataProxy"
  },
  {
    Name = ModuleProxyNames.WorldChatProxy,
    Path = "Business/Chat/Proxies/WorldChatProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.Chat.GetGroupChatListCmd,
    Path = "Business/Chat/Commands/GetGroupChatListCmd"
  },
  {
    Name = ModuleNotificationNames.Chat.GetChatEmotionListCmd,
    Path = "Business/Chat/Commands/GetChatEmotionListCmd"
  },
  {
    Name = ModuleNotificationNames.Chat.AddFavorEmotionCmd,
    Path = "Business/Chat/Commands/AddFavorEmotionCmd"
  }
}
return M
