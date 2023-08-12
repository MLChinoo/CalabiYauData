local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.RoleProxy,
    Path = "Business/Role/Proxies/RoleProxy"
  },
  {
    Name = ModuleProxyNames.RoleFlyEffectProxy,
    Path = "Business/Role/Proxies/RoleFlyEffectProxy"
  },
  {
    Name = ModuleProxyNames.RoleTeamProxy,
    Path = "Business/Role/Proxies/RoleTeamProxy"
  },
  {
    Name = ModuleProxyNames.RoleSkinUpgradeProxy,
    Path = "Business/Role/Proxies/RoleSkinUpgradeProxy"
  },
  {
    Name = ModuleProxyNames.RoleEmoteProxy,
    Path = "Business/Role/Proxies/RoleEmoteProxy"
  },
  {
    Name = ModuleProxyNames.RolePersonalityCommunicationProxy,
    Path = "Business/Role/Proxies/RolePersonalityCommunicationProxy"
  }
}
M.Commands = {}
return M
