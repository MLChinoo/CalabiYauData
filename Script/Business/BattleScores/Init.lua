local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.BattleScoresProxy,
    Path = "Business/BattleScores/Proxies/BattleScoresProxy"
  }
}
M.Commands = {}
return M
