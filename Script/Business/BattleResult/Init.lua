local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.BattleResultProxy,
    Path = "Business/BattleResult/Proxies/BattleResultProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.BattleResult.BattleResultReviceData,
    Path = "Business/BattleResult/Commands/BattleResultCommand"
  },
  {
    Name = ModuleNotificationNames.BattleResult.ResultAccountDataReq,
    Path = "Business/BattleResult/Commands/ResultAccountDataCmd"
  },
  {
    Name = ModuleNotificationNames.BattleResult.ResultRoleDataReq,
    Path = "Business/BattleResult/Commands/ResultRoleDataCmd"
  }
}
return M
