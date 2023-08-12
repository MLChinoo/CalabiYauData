local ReqBuyGoodsCmd = class("ReqBuyGoodsCmd", PureMVC.Command)
local Valid
function ReqBuyGoodsCmd:Execute(notification)
  local Type = notification:GetType()
  local Body = notification:GetBody()
  local CurrencyId = Body.CurrencyId
  local CurrencyNum = tonumber(Body.CurrencyNum)
  local StoreId = Body.StoreId
  local GoodsNum = Body.GoodsNum
  Valid = Body.PageName and GameFacade:RetrieveProxy(ProxyNames.HermesProxy):SetCurPage(Body.PageName)
  if nil == GoodsNum then
    GoodsNum = 1
  end
  if not CurrencyId then
    local TempData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyStoreGoodsDataByStoreId(StoreId)
    CurrencyId = tonumber(TempData.now_price[1].currency_id)
    CurrencyNum = tonumber(TempData.now_price[1].currency_amount)
  end
  CurrencyNum = GoodsNum * CurrencyNum
  local TableRows = ConfigMgr:GetErrorCodeTableRows()
  local MsgText
  if CurrencyId == UE4.EFunctionCoinType.Hermes then
    MsgText = TableRows[tostring(20517)].ErrorDesc
  elseif CurrencyId == UE4.EFunctionCoinType.Crystal then
    MsgText = TableRows[tostring(8202)].ErrorDesc
  elseif CurrencyId == UE4.EFunctionCoinType.WeaponParticles then
    MsgText = TableRows[tostring(20519)].ErrorDesc
  elseif CurrencyId == UE4.EFunctionCoinType.RoleChip then
    MsgText = TableRows[tostring(20520)].ErrorDesc
  end
  local CurCurrencyNum = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetCurCurrencyNum(CurrencyId)
  if CurrencyNum > CurCurrencyNum then
    local Body = {
      IsSuccessed = false,
      CurrencyId = CurrencyId,
      PageName = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetCurPage(),
      Message = MsgText
    }
    GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed, Body)
    if 3 ~= CurrencyId then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, MsgText)
    end
    return nil
  end
  local GoodsData = {
    shop_index = StoreId,
    pay_currency_id = CurrencyId,
    count = GoodsNum
  }
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):ReqBuyGoods(GoodsData)
end
return ReqBuyGoodsCmd
