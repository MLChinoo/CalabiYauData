local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.BattleDataProxy,
    Path = "Business/BattleData/Proxies/BattleDataProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.BattleData.UpdatePanelReqCmd,
    Path = "Business/BattleData/Commands/UpdateBattleDataCmd"
  }
}
return M
