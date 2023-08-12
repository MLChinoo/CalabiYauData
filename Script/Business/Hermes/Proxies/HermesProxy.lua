local HermesProxy = class("HermesProxy", PureMVC.Proxy)
function HermesProxy:GetStoreGoodsPriceData(StoreId)
  local GoodsProxy = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy)
  local storeGoodsData = StoreId and self:GetAnyStoreGoodsDataByStoreId(StoreId)
  local GoodsCfg = storeGoodsData and GoodsProxy:GetGoodsCfg(storeGoodsData.goods_id)
  if nil == storeGoodsData or nil == GoodsCfg then
    local ErrorText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ConfigErrorTip")
    _ = ErrorText and LogError("HermesProxy:GetCurStoreGoodsPrice", ErrorText .. "请找策划解决 id为" .. StoreId)
    return nil
  end
  if 1 == storeGoodsData.store_type and (storeGoodsData.store_param == GlobalEnumDefine.EStoreType.GiftAway or storeGoodsData.store_param == GlobalEnumDefine.EStoreType.SingleProductCantBuy) then
    local ErrorText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ConfigErrorTip")
    _ = ErrorText and LogError("HermesProxy:GetCurStoreGoodsPrice", ErrorText .. "请找策划解决 id为" .. StoreId)
    return nil
  end
  local LeftTimeTable = storeGoodsData.shop_down_time and FunctionUtil:FormatTime(os.difftime(storeGoodsData.shop_down_time, os.time()))
  local priceListData = self:GetStorePrice(storeGoodsData, storeGoodsData.suit_main or nil)
  if LeftTimeTable then
    priceListData.TimeLeft = LeftTimeTable.Day > 0 and LeftTimeTable.PMGameUtil_Format_DaysHours or LeftTimeTable.PMGameUtil_Format_HoursMinutes
  end
  return priceListData
end
local MaxLoopSearchNum = 1
function HermesProxy:GetStoreGoodsOwned(StoreId, LoopNum)
  if LoopNum then
    LoopNum = LoopNum + 1
  else
    LoopNum = 1
  end
  local StoreData = StoreId and self:GetAnyStoreGoodsDataByStoreId(StoreId)
  if self:GetIsLimited(StoreId) then
    return true
  end
  if StoreData then
    if self:GetStoreGoodsIsPackage(StoreId) then
      if LoopNum > MaxLoopSearchNum then
        LogError("HermesProxy:GetStoreGoodsOwned", "Loop Search StorePackage!!!! Csv Misconfiguration!!!! StoreId : " .. StoreId)
        return false
      end
      local bIsOwnedPart = false
      local NeedReturnInSuitMain = false
      for _, v in pairs(StoreData.suit_main or {}) do
        if self:GetStoreGoodsOwned(v, LoopNum) then
          bIsOwnedPart = true
        else
          NeedReturnInSuitMain = true
        end
      end
      if NeedReturnInSuitMain then
        return false, bIsOwnedPart
      end
      if StoreData.suit_main and table.count(StoreData.suit_main) > 0 then
        return true
      else
        return false
      end
    else
      local GoodsProxy = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy)
      if not GoodsProxy:GetAnyGoodsOwned(StoreId) then
        return GoodsProxy:GetAnyGoodsOwned(StoreData.goods_id)
      else
        return true
      end
    end
  else
    return false
  end
end
function HermesProxy:GetStoreGiftOwned(StoreId)
  local StoreData = StoreId and self:GetAnyStoreGoodsDataByStoreId(StoreId)
  if StoreData and self:GetStoreGoodsIsPackage(StoreId) then
    for _, v in pairs(StoreData.suit_free or {}) do
      if not self:GetStoreGoodsOwned(v) then
        return false
      end
    end
  end
  return true
end
function HermesProxy:GetStoreGoodsIsPackage(StoreId)
  local StoreData = StoreId and self:GetAnyStoreGoodsDataByStoreId(StoreId)
  if 1 == StoreData.store_type and (StoreData.store_param == GlobalEnumDefine.EStoreType.DiscountPackage or StoreData.store_param == GlobalEnumDefine.EStoreType.NoDiscountPackage) then
    return true
  else
    return false
  end
end
function HermesProxy:GetStoreGoodsHasGiftAway(StoreId)
  local StoreData = StoreId and self:GetAnyStoreGoodsDataByStoreId(StoreId)
  if 1 == StoreData.store_type and (StoreData.store_param == GlobalEnumDefine.EStoreType.DiscountPackage or StoreData.store_param == GlobalEnumDefine.EStoreType.NoDiscountPackage) and StoreData.suit_free and table.count(StoreData.suit_free) > 0 then
    return true
  else
    return false
  end
end
function HermesProxy:GetStorePrice(StoreData, StorePackage)
  local GoodsProxy = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy)
  local OwnedGoodsPrice = {}
  if StorePackage and table.count(StorePackage) > 0 then
    for _, InStoreId in pairs(StorePackage or {}) do
      local InStoreData = self:GetAnyStoreGoodsDataByStoreId(InStoreId)
      if InStoreData then
        local InGoodsCfg = GoodsProxy:GetGoodsCfg(InStoreData.goods_id)
        if self:GetStoreGoodsOwned(InStoreId) and InGoodsCfg then
          for index = 1, InGoodsCfg.Price:Length() do
            OwnedGoodsPrice[index] = (OwnedGoodsPrice[index] or 0) + tonumber(InGoodsCfg.Price:Get(index).CurrencyAmount or 0)
          end
        end
      end
    end
  end
  local GoodsCfg = GoodsProxy:GetGoodsCfg(StoreData.goods_id)
  local priceListData = {
    bHasDiscount = {},
    DiscountNum = {},
    priceList = {},
    PriceOrigin = {},
    PriceTypeNum = 0
  }
  for i, v in pairs(StoreData.now_price) do
    if i <= GoodsCfg.Price:Length() then
      local OriPrice = GoodsCfg.Price:Get(i)
      if OriPrice then
        local OwnedPrice = OwnedGoodsPrice[i] or 0
        priceListData.bHasDiscount[i] = v.currency_amount ~= OriPrice.CurrencyAmount
        priceListData.priceList[i] = {
          currencyID = v.currency_id,
          currencyNum = v.currency_amount - OwnedPrice
        }
        if priceListData.bHasDiscount[i] then
          local NowPriceNum = tonumber(v.currency_amount)
          local OriPriceNum = tonumber(OriPrice.CurrencyAmount)
          priceListData.PriceOrigin[i] = OriPriceNum - OwnedPrice
          priceListData.DiscountNum[i] = "-" .. tostring(math.floor((OriPriceNum - NowPriceNum) / OriPriceNum * 100 + 0.5)) .. "%"
        end
        priceListData.PriceTypeNum = i
      end
    end
  end
  return priceListData
end
function HermesProxy:GetAnyParameterCfg(ParameterId)
  local arrRows = ConfigMgr:GetParameterTableRows()
  if arrRows then
    return arrRows:ToLuaTable()[tostring(ParameterId)]
  end
end
function HermesProxy:GetNeedsCurrency(PriceType, PriceNum)
  local CurCurrencyNum = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetCurCurrencyNum(PriceType)
  if CurCurrencyNum and PriceNum > CurCurrencyNum then
    return PriceNum - CurCurrencyNum
  end
  return nil
end
function HermesProxy:GetLimitNumCurrency(PriceType, PriceNum)
  local LimitNum = 1
  local CurCurrencyNum = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetCurCurrencyNum(PriceType)
  if PriceNum < CurCurrencyNum then
    local tmp1, tmp2 = math.modf(CurCurrencyNum / PriceNum)
    return tmp1
  end
  return LimitNum
end
function HermesProxy:GetHotListData()
  return self.HotListData
end
function HermesProxy:GetPayTableCfg()
  local arrRows = ConfigMgr:GetPayTableRows()
  if arrRows then
    return arrRows:ToLuaTable()
  end
  return {}
end
function HermesProxy:GetAnyStoreGoodsDataByStoreId(StoreId)
  if self.ShopStoreIdListData and self.ShopStoreIdListData[tostring(StoreId)] then
    return self.ShopStoreIdListData[tostring(StoreId)]
  end
  return nil
end
function HermesProxy:ReqBuyGoods(GoodsData)
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  if dataCenter and (dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ or dataCenter:GetLoginType() == UE4.ELoginType.ELT_Wechat) and midasSys then
    local open_key = midasSys:GetLuaOpenKey()
    local pf = midasSys:GetLuapf()
    local pf_key = midasSys:GetLuapfKey()
    if "" == open_key or "" == pf or "" == pf_key then
      midasSys:LoginStateExpiredExitGame()
      return
    end
    GoodsData.open_key = open_key
    GoodsData.pf = pf
    GoodsData.pf_key = pf_key
  end
  self.ReqBuyGoodsData = GoodsData
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SHOP_BUY_COMMODITY_REQ, pb.encode(Pb_ncmd_cs_lobby.shop_buy_commodity_req, GoodsData))
end
function HermesProxy:ReqShopData()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SHOP_CFG_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.shop_cfg_data_req, {}))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SHOP_LIMIT_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.shop_limit_data_req, {}))
end
function HermesProxy:ReqGiftAway()
  for k, _ in pairs(self.HotListData) do
    if self:GetStoreGoodsIsPackage(k) and self:GetStoreGoodsOwned(k) and self:GetStoreGoodsHasGiftAway(k) and not self:GetStoreGiftOwned(k) then
      SendRequest(Pb_ncmd_cs.NCmdId.NID_SHOP_RECV_GIFT_REQ, pb.encode(Pb_ncmd_cs_lobby.shop_recv_gift_req, {shop_index = k}))
    end
  end
end
function HermesProxy:GetIsLimited(GoodsId)
  local GoodsCfg = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy):GetGoodsCfg(GoodsId)
  for _, v in pairs(self.ShopLimitationListData) do
    if GoodsCfg and v.goods_id == GoodsId and GoodsCfg.Limits <= v.bought_cnt then
      return true
    end
  end
  return false
end
function HermesProxy:SetCurPage(PageName)
  self.PageName = PageName
end
function HermesProxy:GetCurPage()
  return self.PageName
end
function HermesProxy:ResetCurPage()
  self.PageName = nil
end
function HermesProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_LIMIT_DATA_RES, FuncSlot(self.OnRcvShopLimitData, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_LIMIT_BUY_NTF, FuncSlot(self.OnRcvShopLimitDataNtf, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_CFG_DATA_RES, FuncSlot(self.OnRcvGoodsData, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_BUY_COMMODITY_RES, FuncSlot(self.OnRcvBuyCommpdity, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_RECV_GIFT_RES, FuncSlot(self.OnReceiveGiftRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_MONTH_CARD_NTF, FuncSlot(self.OnReceiveMonthCardNtf, self))
  self.ShopStoreIdListData = {}
  self.ShopLimitationListData = {}
  self.HotListData = {}
end
function HermesProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_LIMIT_DATA_RES, FuncSlot(self.OnRcvShopLimitData, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_LIMIT_BUY_NTF, FuncSlot(self.OnRcvShopLimitDataNtf, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_CFG_DATA_RES, FuncSlot(self.OnRcvGoodsData, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_BUY_COMMODITY_RES, FuncSlot(self.OnRcvBuyCommpdity, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_RECV_GIFT_RES, FuncSlot(self.OnReceiveGiftRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_MONTH_CARD_NTF, FuncSlot(self.OnReceiveMonthCardNtf, self))
end
function HermesProxy:OnRcvGoodsData(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_cfg_data_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
  end
  for _, value in pairs(Data.data or {}) do
    self.ShopStoreIdListData[tostring(value.id)] = value
    if 1 == value.store_type then
      self.HotListData[value.id] = value
    end
  end
  if 1 == Data.is_end then
    self:ReqGiftAway()
  end
end
function HermesProxy:OnRcvShopLimitData(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_limit_data_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
  end
  for _, v in pairs(Data.limitation_list or {}) do
    self.ShopLimitationListData[v.goods_id] = v
  end
  GameFacade:SendNotification(NotificationDefines.HermesHotListRefreshPriceState)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
end
function HermesProxy:OnRcvShopLimitDataNtf(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_limit_buy_ntf, ServerData)
  for _, v in pairs(Data.limit_info or {}) do
    self.ShopLimitationListData[v.goods_id] = v
  end
  GameFacade:SendNotification(NotificationDefines.HermesHotListRefreshPriceState)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
end
function HermesProxy:OnRcvBuyCommpdity(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_buy_commodity_res, ServerData)
  if 0 == Data.code and self.ReqBuyGoodsData and self.ReqBuyGoodsData.shop_index and self.ReqBuyGoodsData.count then
    local CurGoodsData = self:GetAnyStoreGoodsDataByStoreId(self.ReqBuyGoodsData.shop_index)
    if CurGoodsData then
      GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed, {
        PageName = self.PageName,
        IsSuccessed = true,
        goodsID = CurGoodsData.goods_id
      })
    end
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
    GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed, {
      PageName = self.PageName,
      IsSuccessed = false
    })
  end
  GameFacade:SendNotification(NotificationDefines.HermesHotListRefreshPriceState)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
end
function HermesProxy:OnReceiveLoginRes(Data)
  self:ReqShopData()
end
function HermesProxy:OnReceiveGiftRes(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_recv_gift_res, ServerData)
  if 0 == Data.code then
  else
  end
end
function HermesProxy:OnReceiveMonthCardNtf(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.shop_month_card_ntf, ServerData)
  self.CardData = nil
  if Data.cards and Data.cards[1] then
    self.CardData = Data.cards[1]
  end
end
function HermesProxy:GetMonthCardData()
  return self.CardData
end
return HermesProxy
