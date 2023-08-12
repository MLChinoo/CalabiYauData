local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines.BattlePass
M.Proxys = {
  {
    Name = ModuleProxyNames.BattlePassProxy,
    Path = "Business/BattlePass/Proxies/BattlePassProxy"
  },
  {
    Name = ModuleProxyNames.CinematicCloisterProxy,
    Path = "Business/BattlePass/Proxies/CinematicCloisterProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.TaskUpdateCmd,
    Path = "Business/BattlePass/Commands/BattlePassTaskUpdateCmd"
  },
  {
    Name = ModuleNotificationNames.ProgressCmd,
    Path = "Business/BattlePass/Commands/BattlePassProgressCmd"
  },
  {
    Name = ModuleNotificationNames.TaskChangeCmd,
    Path = "Business/BattlePass/Commands/BattlePassTaskChangeCmd"
  },
  {
    Name = ModuleNotificationNames.CinematicCloisterCmd,
    Path = "Business/BattlePass/Commands/CinematicCloisterCmd"
  },
  {
    Name = ModuleNotificationNames.ClueRewardCmd,
    Path = "Business/BattlePass/Commands/BattlePassClueRewardCmd"
  },
  {
    Name = NotificationDefines.PlayerAttrChanged,
    Path = "Business/BattlePass/Commands/BattlePassAttrChangeCmd"
  }
}
return M
