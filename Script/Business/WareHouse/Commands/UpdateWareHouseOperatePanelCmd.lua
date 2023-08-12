local UpdateWareHouseOperateCmd = class("UpdateWareHouseOperateCmd", PureMVC.Command)
function UpdateWareHouseOperateCmd:Execute(notification)
  local Body = notification:GetBody()
  local body = {
    IsUseOperate = Body.IsUseButton,
    OperateData = self:GetOperatePanelData(Body.ItemUUId)
  }
  GameFacade:SendNotification(NotificationDefines.NtfWareHouseOperatePanel, body)
end
function UpdateWareHouseOperateCmd:GetOperatePanelData(ItemUUId)
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ItemData = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):GetItemData(ItemUUId)
  if ItemData then
    local ItemConfig = ItemsProxy:GetItemTableConfig(ItemData.item_id)
    local ItemCurrencyConfig = ItemsProxy:GetCurrencyConfig(ItemConfig.SaleType)
    local ItemQuality = ItemsProxy:GetItemQualityConfig(ItemConfig.Quality)
    local ItemIdIntervalType = ItemsProxy:GetItemIdIntervalType(ItemData.item_id)
    if ItemConfig and ItemQuality and ItemIdIntervalType then
      local Data = {
        UUID = ItemUUId,
        InItemID = ItemData.item_id,
        softTexture = ItemConfig.IconItem,
        count = ItemData.count,
        itemName = ItemConfig.Name,
        saleParam = ItemConfig.SaleParam,
        ImgQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQuality.Color)),
        CurrencyIconItem = ItemCurrencyConfig and ItemCurrencyConfig.IconTipItem,
        saleType = ItemConfig.SaleType,
        bIsModNameCard = ItemIdIntervalType == UE4.EItemIdIntervalType.BagItem_ModName
      }
      return Data
    end
  end
  return nil
end
return UpdateWareHouseOperateCmd
