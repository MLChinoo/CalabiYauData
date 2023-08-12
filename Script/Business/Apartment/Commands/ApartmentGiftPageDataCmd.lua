local ApartmentGiftPageDataCmd = class("ApartmentGiftPageDataCmd", PureMVC.Command)
function ApartmentGiftPageDataCmd:Execute(notification)
  local WareHouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local BagItemsList = WareHouseProxy:GetGiftItemListData()
  local Body = {
    RoleId = CurrentRoleId,
    GiftList = {}
  }
  local Idx = 0
  for uuid, itemData in pairs(BagItemsList or {}) do
    Idx = Idx + 1
    local GridPanelData = self:BuildGiftShowData(itemData.item_id, itemData)
    GridPanelData.ItemIndex = Idx
    table.insert(Body.GiftList, GridPanelData)
  end
  table.sort(Body.GiftList, function(a, b)
    return a.ItemCfgId < b.ItemCfgId
  end)
  GameFacade:SendNotification(NotificationDefines.SetApartmentGiftPageData, Body)
end
function ApartmentGiftPageDataCmd:BuildGiftShowData(giftId, itemBagInfo)
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local GiftCfg = ItemProxy:GetItemCfg(giftId)
  local GridPanelData = {
    InItemID = itemBagInfo and itemBagInfo.item_uuid,
    ItemCfgId = giftId,
    softTexture = ItemProxy:GetAnyItemImg(giftId),
    count = itemBagInfo and itemBagInfo.count or 0,
    desc = {
      itemName = GiftCfg.Name,
      itemDesc = GiftCfg.Desc,
      saleType = GiftCfg.SaleType
    }
  }
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM)
  for key, value in pairs(redDotList or {}) do
    if GridPanelData.InItemID == value.reddot_rid and value.mark then
      GridPanelData.redDotID = key
    end
  end
  return GridPanelData
end
return ApartmentGiftPageDataCmd
