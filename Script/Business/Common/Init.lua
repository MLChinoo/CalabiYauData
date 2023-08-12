local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.GlobalDelegateProxy,
    Path = "Business/Common/Proxies/GlobalDelegateProxy"
  },
  {
    Name = ModuleProxyNames.BasicFunctionProxy,
    Path = "Business/Common/Proxies/BasicFunctionProxy"
  },
  {
    Name = ModuleProxyNames.MapProxy,
    Path = "Business/Common/Proxies/MapProxy"
  },
  {
    Name = ModuleProxyNames.PopUpPromptProxy,
    Path = "Business/Common/Proxies/PopUpPromptProxy"
  },
  {
    Name = ModuleProxyNames.WebUrlProxy,
    Path = "Business/Common/Proxies/WebUrlProxy"
  },
  {
    Name = ModuleProxyNames.RedDotProxy,
    Path = "Business/Common/Proxies/RedDotProxy"
  },
  {
    Name = ModuleProxyNames.CreditProxy,
    Path = "Business/Common/Proxies/CreditProxy"
  },
  {
    Name = ModuleProxyNames.DownloadProxy,
    Path = "Business/Common/Proxies/DownloadProxy"
  },
  {
    Name = ModuleProxyNames.ReplayProxy,
    Path = "Business/Common/Proxies/ReplayProxy"
  },
  {
    Name = ModuleProxyNames.FunctionOpenProxy,
    Path = "Business/Common/Proxies/FunctionOpenProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.GameDelegateSubsystemCmd,
    Path = "Business/Common/Commands/GameDelegateSubsystemCmd"
  },
  {
    Name = ModuleNotificationNames.JumpToPageCmd,
    Path = "Business/Common/Commands/JumpToPage/JumpToPageCmd"
  },
  {
    Name = ModuleNotificationNames.GameServerConnect,
    Path = "Business/Common/Commands/OnServerSessionOpenCmd"
  },
  {
    Name = ModuleNotificationNames.GameServerReconnect,
    Path = "Business/Common/Commands/OnServerSessionReopenCmd"
  },
  {
    Name = ModuleNotificationNames.GameServerDisconnect,
    Path = "Business/Common/Commands/OnServerSessionCloseCmd"
  },
  {
    Name = ModuleNotificationNames.GetItemOperateStateCmd,
    Path = "Business/Common/Commands/GetItemOperateStateDataCmd"
  },
  {
    Name = ModuleNotificationNames.ShowCommonTipCmd,
    Path = "Business/Common/Commands/ShowCommonTipCmd"
  },
  {
    Name = ModuleNotificationNames.ShowCreditScoreTipCmd,
    Path = "Business/Common/Commands/ShowCreditScoreTipCmd"
  },
  {
    Name = ModuleNotificationNames.PlayerAttrChanged,
    Path = "Business/Common/Commands/LevelUpCmd"
  },
  {
    Name = ModuleNotificationNames.RedDot.NtfRedDotSyncCmd,
    Path = "Business/Common/Commands/NtfRedDotSyncCmd"
  },
  {
    Name = ModuleNotificationNames.RedDot.NewRedDotCmd,
    Path = "Business/Common/Commands/NewRedDotCmd"
  },
  {
    Name = ModuleNotificationNames.Common.OpenItemDisplayPageCmd,
    Path = "Business/Common/Commands/OpenItemDisplayPageCmd"
  }
}
return M
