local ItemBoughtPanel = class("ItemBoughtPanel", PureMVC.ViewComponentPanel)
function ItemBoughtPanel:Init(itemId)
  if nil == itemId then
    return
  end
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if self.Image_Item then
    self:SetImageByTexture2D(self.Image_Item, itemProxy:GetAnyItemImg(itemId))
  end
  if self.Image_Quality then
    local color = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(itemProxy:GetAnyItemQuality(itemId)).Color
    self.Image_Quality:SetColorandOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(color)))
  end
end
function ItemBoughtPanel:SetItemAmount(amount)
  if self.Text_Num then
    self.Text_Num:SetText(amount)
  end
end
return ItemBoughtPanel
