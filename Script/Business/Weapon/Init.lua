local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.WeaponProxy,
    Path = "Business/Weapon/Proxies/WeaponProxy"
  },
  {
    Name = ModuleProxyNames.WeaponSkinUpgradeProxy,
    Path = "Business/Weapon/Proxies/WeaponSkinUpgradeProxy"
  }
}
M.Commands = {}
return M
