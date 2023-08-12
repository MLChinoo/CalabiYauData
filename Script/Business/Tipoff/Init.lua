local M = class("Init", PureMVC.ModuleInit)
local ModuleNotificationNames = NotificationDefines.TipoffPlayer
M.Proxys = {
  {
    Name = ProxyNames.TipoffPlayerDataProxy,
    Path = "Business/Tipoff/Proxies/TipoffPlayerDataProxy"
  },
  {
    Name = ProxyNames.TipoffPlayerNetProxy,
    Path = "Business/Tipoff/Proxies/TipoffPlayerNetProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.ReqTipoffPlayerInfoCmd,
    Path = "Business/Tipoff/Commands/ReqTipoffPlayerInfoCmd"
  },
  {
    Name = ModuleNotificationNames.TipoffBehaviorChooseCmd,
    Path = "Business/Tipoff/Commands/TipoffBehaviorChooseCmd"
  },
  {
    Name = ModuleNotificationNames.OpenTipOffPlayerCmd,
    Path = "Business/Tipoff/Commands/OpenTipOffPlayerCmd"
  },
  {
    Name = ModuleNotificationNames.TipoffPlayerDataInitCmd,
    Path = "Business/Tipoff/Commands/TipoffPlayerDataInitCmd"
  },
  {
    Name = ModuleNotificationNames.TipoffContentUpdateCmd,
    Path = "Business/Tipoff/Commands/TipoffContentUpdateCmd"
  },
  {
    Name = ModuleNotificationNames.TipoffPlayerComfirmCmd,
    Path = "Business/Tipoff/Commands/TipoffPlayerComfirmCmd"
  },
  {
    Name = ModuleNotificationNames.UpdateInGameTipoffDataCmd,
    Path = "Business/Tipoff/Commands/UpdateInGameTipoffDataCmd"
  },
  {
    Name = ModuleNotificationNames.TipoffCategoryChooseCmd,
    Path = "Business/Tipoff/Commands/TipoffCategoryTypeChooseCmd"
  }
}
return M
