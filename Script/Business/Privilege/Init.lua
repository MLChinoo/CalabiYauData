local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.CafePrivilegeProxy,
    Path = "Business/Privilege/Proxies/CafePrivilegeProxy"
  }
}
M.Commands = {}
return M
