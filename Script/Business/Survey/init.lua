local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.QuestionnaireProxy,
    Path = "Business/Survey/Proxies/QuestionnaireProxy"
  }
}
M.Commands = {}
return M
