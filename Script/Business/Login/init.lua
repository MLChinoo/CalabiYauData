local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.LoginData,
    Path = "Business/Login/Proxies/LoginDataProxy"
  }
}
M.Commands = {}
return M
