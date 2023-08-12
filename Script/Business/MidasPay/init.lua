local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.MidasProxy,
    Path = "Business/MidasPay/Proxies/MidasProxy"
  }
}
M.Commands = {}
return M
