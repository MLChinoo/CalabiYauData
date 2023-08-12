local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.ItemsProxy,
    Path = "Business/Items/Proxies/ItemsProxy"
  },
  {
    Name = ModuleProxyNames.GoodsProxy,
    Path = "Business/Items/Proxies/GoodsProxy"
  },
  {
    Name = ModuleProxyNames.DecalProxy,
    Path = "Business/Items/Proxies/DecalProxy"
  }
}
M.Commands = {}
return M
