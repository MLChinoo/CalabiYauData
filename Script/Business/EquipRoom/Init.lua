local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.EquipRoomProxy,
    Path = "Business/EquipRoom/Proxies/EquipRoomProxy"
  },
  {
    Name = ModuleProxyNames.EquipRoomPrepareProxy,
    Path = "Business/EquipRoom/Proxies/EquipRoomPrepareProxy"
  },
  {
    Name = ModuleProxyNames.EquipRoomRedDotProxy,
    Path = "Business/EquipRoom/Proxies/EquipRoomRedDotProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleSkinListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleSkinListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleInfoPanelCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleInfoPanelCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateItemDescCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateItemDescCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleVoiceListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleVoiceListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdatePaintDataCmd,
    Path = "Business/EquipRoom/Commands/EquiproomUpdatePaintListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomShowPaintCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomShowPaintCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdatePaintEquipSlotCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdatePaintEquipSlotCmd"
  },
  {
    Name = ModuleNotificationNames.ReqEquipDecalCmd,
    Path = "Business/EquipRoom/Commands/ReqEquipDecalCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleProfessionInfoCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleProfessionInfoCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateSkillInfoCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateSkillInfoCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateWeaponEquipSoltCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateWeaponEquipSoltCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateWeaponListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateWeaponListCmd"
  },
  {
    Name = ModuleNotificationNames.ReqEquipWeaponCmd,
    Path = "Business/EquipRoom/Commands/ReqEquipWeaponCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleCommunicationVoiceListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleCommunicationVoiceListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleCommunicationActionListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleCommunicationActionListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateEquipCommunicationListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateEquipCommunicationListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateWeaponSkinListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateWeaponSkinListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleFlyEffectListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleFlyEffectListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdateRoleEmoteListCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdateRoleEmoteListCmd"
  },
  {
    Name = ModuleNotificationNames.EquipRoomUpdatePersonalityRouletteCmd,
    Path = "Business/EquipRoom/Commands/EquipRoomUpdatePersonalityRouletteCmd"
  }
}
return M
