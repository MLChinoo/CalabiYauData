local UpdateWareHouseGridCmd = class("UpdateWareHouseGridCmd", PureMVC.Command)
function UpdateWareHouseGridCmd:Execute(notification)
  GameFacade:SendNotification(NotificationDefines.NtfWareHouseGridPanel, self:GetGridPanelDatas())
end
function UpdateWareHouseGridCmd:GetGridPanelDatas()
  local ItemList = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):GetItemListData()
  local Data = {}
  local GridPanelData = {}
  local ItemConfig
  local index = 1
  for key, value in pairsByKeys(ItemList or {}, function(a, b)
    if ItemList[a].item_id < ItemList[b].item_id then
      return true
    end
    return false
  end) do
    ItemConfig = nil
    GridPanelData = {}
    ItemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemTableConfig(value.item_id)
    if ItemConfig and ItemConfig.ItemType > 0 then
      GridPanelData = {
        ItemIndex = index,
        InItemID = value.item_uuid,
        ItemID = value.item_id,
        bEquipment = false,
        bUnlock = true,
        softTexture = ItemConfig.IconItem,
        count = value.count,
        quality = ItemConfig.Quality
      }
      Data[index] = GridPanelData
      index = index + 1
    end
  end
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM)
  local ItemCfg
  for key, value in pairs(redDotList or {}) do
    for k, v in pairs(Data) do
      ItemCfg = nil
      ItemCfg = v.ItemID and GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemCfg(v.ItemID)
      if ItemCfg and (1 == ItemCfg.ItemType or 2 == ItemCfg.ItemType) and v.InItemID == value.reddot_rid and value.mark then
        v.redDotID = key
      end
    end
  end
  return Data
end
return UpdateWareHouseGridCmd
