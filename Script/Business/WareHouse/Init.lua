local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.WareHouseProxy,
    Path = "Business/WareHouse/Proxies/WareHouseProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.UpdateWareHouseGridPanel,
    Path = "Business/WareHouse/Commands/UpdateWareHouseGridPanelCmd"
  },
  {
    Name = NotificationDefines.UpdateWareHouseOperatePanel,
    Path = "Business/WareHouse/Commands/UpdateWareHouseOperatePanelCmd"
  },
  {
    Name = NotificationDefines.UpdateWareHouseDescPanel,
    Path = "Business/WareHouse/Commands/UpdateWareHouseDescPanelCmd"
  }
}
return M
