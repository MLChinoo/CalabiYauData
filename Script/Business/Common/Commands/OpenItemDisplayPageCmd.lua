local OpenItemDisplayPageCmd = class("OpenItemDisplayPageCmd", PureMVC.Command)
function OpenItemDisplayPageCmd:Execute(notification)
  local itemsArry = notification:GetBody()
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ItemsData = {}
  for k, value in pairs(itemsArry) do
    local itemCfg = ItemProxy:GetAnyItemInfoById(value.itemId)
    local itemInfo = {
      itemId = value.itemId,
      itemDesc = itemCfg.desc,
      name = itemCfg.name,
      image = itemCfg.image,
      itemNum = value.itemCnt,
      imgQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemProxy:GetItemQualityConfig(itemCfg.quality).Color)),
      qualityColor = ItemProxy:GetItemQualityConfig(itemCfg.quality).Color,
      qualityName = ItemProxy:GetItemQualityConfig(itemCfg.quality).Desc
    }
    table.insert(ItemsData, itemInfo)
  end
  GameFacade:SendNotification(NotificationDefines.Common.SendItemDisplayDataNtf, ItemsData)
end
return OpenItemDisplayPageCmd
