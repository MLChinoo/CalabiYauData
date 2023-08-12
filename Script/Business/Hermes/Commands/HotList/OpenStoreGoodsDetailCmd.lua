local OpenStoreGoodsDetailCmd = class("OpenStoreGoodsDetailCmd", PureMVC.Command)
function OpenStoreGoodsDetailCmd:Execute(notification)
  local StoreId = notification:GetBody()
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local StoreGoodsCfg = HermesProxy:GetAnyStoreGoodsDataByStoreId(StoreId)
  local GoodsData = GameFacade:RetrieveProxy(ProxyNames.GoodsProxy):GetGoodsCfg(StoreGoodsCfg.goods_id)
  local GoodsDetailData = {
    IsLimited = HermesProxy:GetIsLimited(StoreId) and HermesProxy:GetStoreGoodsOwned(StoreGoodsCfg.goods_id),
    StoreId = StoreId,
    GoodsId = StoreGoodsCfg.goods_id,
    StoreType = StoreGoodsCfg.store_param,
    Name = GoodsData.Name,
    ItemsData = {}
  }
  local InWeaponId, InRoleSkinId
  for i = 1, GoodsData.Items:Length() do
    local ItemCfg = ItemProxy:GetAnyItemInfoById(GoodsData.Items:Get(i).ItemId)
    GoodsDetailData.ItemsData[i] = {
      ItemId = GoodsData.Items:Get(i).ItemId,
      itemDesc = ItemCfg.desc,
      Name = ItemCfg.name,
      Image = ItemCfg.image,
      ItemNum = GoodsData.Items:Get(i).ItemAmount,
      ImgQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemProxy:GetItemQualityConfig(ItemCfg.quality).Color)),
      QualityColor = ItemProxy:GetItemQualityConfig(ItemCfg.quality).Color,
      QualityName = ItemProxy:GetItemQualityConfig(ItemCfg.quality).Desc
    }
    local ItemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(GoodsData.Items:Get(i).ItemId)
    if ItemType == UE4.EItemIdIntervalType.RoleSkin then
      if not InRoleSkinId then
        InRoleSkinId = GoodsData.Items:Get(i).ItemId
      end
    elseif ItemType == UE4.EItemIdIntervalType.Weapon and not InWeaponId then
      InWeaponId = GoodsData.Items:Get(i).ItemId
    end
  end
  if InWeaponId and InRoleSkinId then
    GoodsDetailData.bIsPackageDisplay = true
    GoodsDetailData.DefaultWeaponId = InWeaponId
    GoodsDetailData.DefaultRoleSkinId = InRoleSkinId
  end
  GameFacade:SendNotification(NotificationDefines.HermesGoodsDetailNtf, GoodsDetailData)
end
return OpenStoreGoodsDetailCmd
