local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.CardDataProxy,
    Path = "Business/Room/Proxies/CardDataProxy"
  },
  {
    Name = ModuleProxyNames.CareerDataProxy,
    Path = "Business/Room/Proxies/CareerDataProxy"
  }
}
M.Commands = {}
return M
