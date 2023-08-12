local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.LotteryProxy,
    Path = "Business/Lottery/Proxies/LotteryProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.Lottery.InitLotteryCmd,
    Path = "Business/Lottery/Commands/InitLotteryCmd"
  },
  {
    Name = ModuleNotificationNames.Lottery.BuyTicketCmd,
    Path = "Business/Lottery/Commands/BuyTicketCmd"
  },
  {
    Name = ModuleNotificationNames.Lottery.ShowLotteryResultCmd,
    Path = "Business/Lottery/Commands/ShowLotteryResultCmd"
  },
  {
    Name = ModuleNotificationNames.Lottery.TryLotteryCmd,
    Path = "Business/Lottery/Commands/TryLotteryCmd"
  },
  {
    Name = ModuleNotificationNames.Lottery.StartLotteryProcessCmd,
    Path = "Business/Lottery/Commands/StartLotteryProcessCmd"
  }
}
return M
