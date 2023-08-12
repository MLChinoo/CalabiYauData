local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.AccountBindProxy,
    Path = "Business/AccountBind/Proxies/AccountBindProxy"
  }
}
M.Commands = {}
return M
