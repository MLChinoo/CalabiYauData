local OpenPurchaseGoodsPageCmd = class("OpenPurchaseGoodsPageCmd", PureMVC.Command)
local Valid
function OpenPurchaseGoodsPageCmd:Execute(notification)
  local Type = notification:GetType()
  local Body = notification:GetBody()
  Valid = Body.StoreId and GameFacade:SendNotification(NotificationDefines.HermesPurchaseGoodsNtf, self:GetGoodsData(Body))
end
function OpenPurchaseGoodsPageCmd:GetGoodsData(Data)
  local StoreId = Data.StoreId
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local GoodsProxy = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy)
  if nil == StoreId then
    local ErrorText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ConfigErrorTip")
    local valid = ErrorText and LogWarn("OpenPurchaseGoodsPageCmd", ErrorText)
    return nil
  end
  local StoreGoodsData = HermesProxy:GetAnyStoreGoodsDataByStoreId(StoreId)
  if nil == StoreGoodsData then
    local ErrorText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ConfigErrorTip")
    local valid = ErrorText and LogWarn("OpenPurchaseGoodsPageCmd", ErrorText)
    return nil
  end
  local GoodsId = StoreGoodsData.goods_id
  local GoodsData = GoodsProxy:GetGoodsCfg(GoodsId)
  if nil == GoodsData then
    local ErrorText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ConfigErrorTip")
    local valid = ErrorText and LogWarn("OpenPurchaseGoodsPageCmd", ErrorText)
    return nil
  end
  local StorePrice = HermesProxy:GetStoreGoodsPriceData(StoreId)
  if not StorePrice then
    return nil
  end
  local PackageData = {
    StoreId = StoreId,
    GoodsId = GoodsId,
    bHiddenIcon = Data.bHiddenIcon,
    ItemsData = {},
    SellDesc = GoodsData.SellDesc,
    StoreRolePaintTexture = GoodsData.PopupPortrait
  }
  local ItemId, ItemNum, ItemCfg, ItemQuality
  for i = 1, GoodsData.Items:Length() do
    ItemId = GoodsData.Items:Get(i).ItemId
    ItemNum = GoodsData.Items:Get(i).ItemAmount
    ItemCfg = ItemProxy:GetAnyItemInfoById(ItemId)
    ItemQuality = ItemProxy:GetItemQualityConfig(ItemCfg.quality)
    local TempData = {
      IsLimited = ItemProxy:GetAnyItemOwned(ItemId),
      StoreType = HermesProxy:GetAnyStoreGoodsDataByStoreId(ItemId).store_param,
      ItemId = ItemId,
      Name = ItemCfg.name,
      Image = ItemCfg.image,
      ItemNum = ItemNum,
      QualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQuality.Color))
    }
    PackageData.ItemsData[i] = TempData
  end
  return PackageData
end
function OpenPurchaseGoodsPageCmd:GetNeedsCurrency(PriceType, PriceNum)
  local CurCurrencyNum = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetCurCurrencyNum(PriceType)
  if CurCurrencyNum and PriceNum > CurCurrencyNum then
    return PriceNum - CurCurrencyNum
  end
  return nil
end
return OpenPurchaseGoodsPageCmd
