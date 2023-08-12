local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.RoleWarmUpProxy,
    Path = "Business/Activities/MeredithRoleWarmUp/Proxies/RoleWarmUpProxy"
  }
}
M.Commands = {}
return M
