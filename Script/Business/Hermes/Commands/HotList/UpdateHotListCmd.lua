local UpdateHotLisCmd = class("UpdateHotLisCmd", PureMVC.Command)
function UpdateHotLisCmd:Execute(notification)
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local ListData = HermesProxy:GetHotListData()
  if nil == ListData then
    return {}
  end
  local AllData = {}
  for index, value in pairs(ListData or {}) do
    local PageIndex = value.goods_layout[1]
    if not PageIndex then
    else
      if nil == AllData[PageIndex] then
        AllData[PageIndex] = {}
      end
      if value.up_time > os.time() or value.down_time < os.time() then
      elseif value.show_up_time and value.shop_down_time and (value.show_up_time > os.time() or value.shop_down_time < os.time()) then
      else
        local GoodsCfg = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy):GetGoodsCfg(value.goods_id)
        if nil == GoodsCfg then
          LogInfo("HermesHotList", "Goods table Id Is Null!! Goods_Id:" .. value.goods_id)
        else
          local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
          local ItemQuality = ItemProxy:GetItemQualityConfig(math.clamp(GoodsCfg.Quality, 1, 5))
          local InData = {
            StoreId = value.id,
            GoodsId = value.goods_id,
            ProductImgTexture = GoodsCfg.Icon,
            ItemName = GoodsCfg.Name,
            QualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQuality.Color)),
            Currency_Img = ItemProxy:GetCurrencyConfig(value.now_price[1].currency_id).IconTipItem
          }
          if value.goods_layout[2] and value.goods_layout[3] and value.goods_layout[4] and value.goods_layout[5] then
            InData.Row = value.goods_layout[2]
            InData.Column = value.goods_layout[3]
            InData.SizeWidth = value.goods_layout[4]
            InData.SizeHeight = value.goods_layout[5]
            goto lbl_152
            goto lbl_154
            ::lbl_152::
            AllData[PageIndex][index] = InData
          end
        end
      end
    end
    ::lbl_154::
  end
  GameFacade:SendNotification(NotificationDefines.HermesHotListNtf, AllData)
end
return UpdateHotLisCmd
