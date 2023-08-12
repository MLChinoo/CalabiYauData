local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.BusinessCardDataProxy,
    Path = "Business/PlayerProfile/Proxies/BusinessCard/BusinessCardDataProxy"
  },
  {
    Name = ModuleProxyNames.PlayerDataProxy,
    Path = "Business/PlayerProfile/Proxies/PlayerDataProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.PlayerProfile.BusinessCard.GetCardTypeDataCmd,
    Path = "Business/PlayerProfile/Commands/BusinessCard/GetCardTypeDataCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.BusinessCard.GetCardDataCmd,
    Path = "Business/PlayerProfile/Commands/BusinessCard/GetCardDataCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.BusinessCard.ChangeBCStyleCmd,
    Path = "Business/PlayerProfile/Commands/BusinessCard/ChangeBCStyleCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.BusinessCard.UpdateCenterCardCmd,
    Path = "Business/PlayerProfile/Commands/BusinessCard/UpdateCenterCardCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.GetPlayerDataCmd,
    Path = "Business/PlayerProfile/Commands/GetPlayerDataCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.ShowDataCmd,
    Path = "Business/PlayerProfile/Commands/ShowDataCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.PlayerData.GetCareerDataCmd,
    Path = "Business/PlayerProfile/Commands/PlayerData/GetCareerDataCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerProfile.PlayerData.GetRoleMatchDataCmd,
    Path = "Business/PlayerProfile/Commands/PlayerData/GetRoleMatchDataCmd"
  }
}
return M
