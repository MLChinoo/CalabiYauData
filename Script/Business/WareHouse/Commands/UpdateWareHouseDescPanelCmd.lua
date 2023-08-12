local UpdateWareHouseDescCmd = class("UpdateWareHouseDescCmd", PureMVC.Command)
function UpdateWareHouseDescCmd:Execute(notification)
  GameFacade:SendNotification(NotificationDefines.NtfWareHouseDescPanel, self:GetDescPanelData(notification:GetBody()))
end
function UpdateWareHouseDescCmd:GetDescPanelData(ItemUUId)
  local ItemData = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):GetItemData(ItemUUId)
  if not ItemData then
    return {}
  end
  local ItemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemTableConfig(ItemData.item_id)
  local ItemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(ItemConfig.Quality)
  local Data = {
    itemId = ItemData.item_id,
    itemName = ItemConfig.Name,
    itemDesc = ItemConfig.Desc,
    qualityName = ItemQuality.Desc,
    qualityColor = ItemQuality.Color,
    saleType = ItemConfig.SaleType
  }
  return Data
end
return UpdateWareHouseDescCmd
