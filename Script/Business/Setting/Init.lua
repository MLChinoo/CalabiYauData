local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
M.Proxys = {
  {
    Name = ModuleProxyNames.SettingInputUtilProxy,
    Path = "Business/Setting/Proxies/SettingInputUtilProxy"
  },
  {
    Name = ModuleProxyNames.SettingProxy,
    Path = "Business/Setting/Proxies/SettingProxy"
  },
  {
    Name = ModuleProxyNames.SettingSaveGameProxy,
    Path = "Business/Setting/Proxies/SettingSaveGameProxy"
  },
  {
    Name = ModuleProxyNames.SettingVisualProxy,
    Path = "Business/Setting/Proxies/SettingVisualProxy"
  },
  {
    Name = ModuleProxyNames.SettingKeyMapManagerProxy,
    Path = "Business/Setting/Proxies/SettingKeyMapManagerProxy"
  },
  {
    Name = ModuleProxyNames.SettingConfigProxy,
    Path = "Business/Setting/Proxies/SettingConfigProxy"
  },
  {
    Name = ModuleProxyNames.SettingNetProxy,
    Path = "Business/Setting/Proxies/SettingNetProxy"
  },
  {
    Name = ModuleProxyNames.SettingSaveDataProxy,
    Path = "Business/Setting/Proxies/SettingSaveDataProxy"
  },
  {
    Name = ModuleProxyNames.SettingCombatProxy,
    Path = "Business/Setting/Proxies/SettingCombatProxy"
  },
  {
    Name = ModuleProxyNames.SettingCacheProxy,
    Path = "Business/Setting/Proxies/SettingCacheProxy"
  },
  {
    Name = ModuleProxyNames.SettingOperationProxy,
    Path = "Business/Setting/Proxies/SettingOperationProxy"
  },
  {
    Name = ModuleProxyNames.SettingSensitivityProxy,
    Path = "Business/Setting/Proxies/SettingSensitivityProxy"
  },
  {
    Name = ModuleProxyNames.SettingVoiceProxy,
    Path = "Business/Setting/Proxies/SettingVoiceProxy"
  },
  {
    Name = ModuleProxyNames.SettingManagerProxy,
    Path = "Business/Setting/Proxies/SettingManagerProxy"
  }
}
M.Commands = {}
return M
