local UpdateHermesTopUpMainPageCmd = class("UpdateHermesTopUpMainPageCmd", PureMVC.Command)
function UpdateHermesTopUpMainPageCmd:Execute(notification)
  local PayDataCfg = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetPayTableCfg()
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local CrystalId = 3
  local CurrencyDataCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetCurrencyConfig(CrystalId)
  local PayReturnData = {}
  local ItemData = {}
  for index, value in pairs(PayDataCfg or {}) do
    if 0 == value.IsCardSpecial then
      ItemData = {
        CommodityId = value.CommodityId,
        IconPay = value.IconPay,
        Num = value.Name,
        Name = CurrencyDataCfg.Name,
        GivingDescText = value.Desc,
        GivingCurrencyImg = ItemsProxy:GetCurrencyConfig(value.GivingCurrencyId).IconTipItem,
        GivingAmount = value.GivingAmount,
        PriceNum = value.Amount / 100,
        bIsShowParticle = value.GivingCurrencyShow
      }
      local PriceAfterPoint = math.fmod(value.Amount, 100)
      local PriceText = value.Currency .. math.modf(value.Amount / 100) .. "."
      if PriceAfterPoint <= 9 then
        PriceText = PriceText .. "0"
      end
      ItemData.PriceText = PriceText .. PriceAfterPoint
      PayReturnData[tonumber(index)] = ItemData
    else
      ItemData = {
        CommodityId = index,
        IsCardSpecial = value.IsCardSpecial
      }
      PayReturnData[tonumber(index)] = ItemData
    end
  end
  GameFacade:SendNotification(NotificationDefines.HermesTopUpMainPageNtf, PayReturnData)
end
return UpdateHermesTopUpMainPageCmd
