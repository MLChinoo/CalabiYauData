local RoleWarmUpRewardItem = class("RoleWarmUpRewardItem", PureMVC.ViewComponentPanel)
function RoleWarmUpRewardItem:Construct()
  RoleWarmUpRewardItem.super.Construct(self)
end
function RoleWarmUpRewardItem:Destruct()
  RoleWarmUpRewardItem.super.Destruct(self)
end
function RoleWarmUpRewardItem:UpdataRewardItem(RewardItemData)
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if ItemsProxy then
    local ItemInfo = ItemsProxy:GetAnyItemInfoById(RewardItemData.ItemId)
    local itemQualityCfg = ItemsProxy:GetItemQualityConfig(ItemInfo.quality)
    if self.Image_Quality then
      self.Image_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.Color)))
    end
    if self.Image_Item then
      self:SetImageByTexture2D(self.Image_Item, ItemInfo.image)
    end
    if self.NumText then
      self.NumText:SetText(tostring(RewardItemData.ItemCount))
    end
  end
end
return RoleWarmUpRewardItem
