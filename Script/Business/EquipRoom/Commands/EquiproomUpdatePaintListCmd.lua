local EquiproomUpdatePaintListCmd = class("EquiproomUpdatePaintListCmd", PureMVC.Command)
function EquiproomUpdatePaintListCmd:Execute(notification)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local decalTableDatas = equipRoomPaintProxy:GetDecalTableDatas()
  local currentRoleID = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy):GetSelectRoleID()
  local paintItemData = {}
  for k, v in pairs(decalTableDatas) do
    if v then
      local itemData = {}
      itemData.InItemID = v.Id
      itemData.bUnlock = equipRoomPaintProxy:IsOwnDecalByDecalID(v.Id)
      if itemData.bUnlock then
        itemData.bEquip = equipRoomPrepareProxy:IsEquipDecalByID(v.Id, currentRoleID)
      end
      itemData.softTexture = v.IconItem
      itemData.bCanDrag = true
      itemData.SortID = v.SortID
      itemData.quality = v.Quality
      if self:IsShow(v, itemData.bUnlock) then
        table.insert(paintItemData, itemData)
      end
    end
  end
  table.sort(paintItemData, function(a, b)
    if a.bUnlock == b.bUnlock then
      return a.SortID > b.SortID
    elseif a.bUnlock then
      return true
    else
      return false
    end
  end)
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_DECAL)
  if redDotList then
    for key, value in pairs(redDotList) do
      for k, v in pairs(paintItemData) do
        if v.InItemID == value.reddot_rid and value.mark then
          v.redDotID = key
        end
      end
    end
  end
  local body = {}
  body.paintItemData = paintItemData
  body.defaultSelectIndex = notification.body
  LogDebug("EquiproomUpdatePaintListCmd", "EquiproomUpdatePaintListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintData, body)
end
function EquiproomUpdatePaintListCmd:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return EquiproomUpdatePaintListCmd
