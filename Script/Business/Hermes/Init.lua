local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.HermesProxy,
    Path = "Business/Hermes/Proxies/HermesProxy"
  },
  {
    Name = ProxyNames.HermesTLogProxy,
    Path = "Business/Hermes/Proxies/HermesTLogProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.HermesHotListUpdate,
    Path = "Business/Hermes/Commands/HotList/UpdateHotListCmd"
  },
  {
    Name = NotificationDefines.HermesPurchaseGoodsUpdate,
    Path = "Business/Hermes/Commands/HotList/OpenPurchaseGoodsPageCmd"
  },
  {
    Name = NotificationDefines.Hermes.PurchaseGoods.ReqBuyGoods,
    Path = "Business/Hermes/Commands/HotList/ReqBuyGoodsCmd"
  },
  {
    Name = NotificationDefines.HermesGoodsDetailUpdate,
    Path = "Business/Hermes/Commands/HotList/OpenStoreGoodsDetailCmd"
  },
  {
    Name = NotificationDefines.Hermes.TopUp.MainPage.Update,
    Path = "Business/Hermes/Commands/TopUp/UpdateMainPageCmd"
  }
}
return M
