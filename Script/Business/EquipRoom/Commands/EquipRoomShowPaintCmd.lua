local EquipRoomShowPaintCmd = class("EquipRoomShowPaintCmd", PureMVC.Command)
function EquipRoomShowPaintCmd:Execute(notification)
  if notification.body then
    local notificationBody = {}
    local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
    local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(notification.body)
    notificationBody.sortTexture = decalRowData.IconBig
    notificationBody.itemName = decalRowData.Name
    notificationBody.itemDesc = decalRowData.Desc
    notificationBody.itemID = notification.body
    notificationBody.qualityID = decalRowData.Quality
    LogDebug("EquipRoomShowPaintCmd", "EquipRoomShowPaintCmd Execute")
    GameFacade:SendNotification(NotificationDefines.EquipRoomShowPaint, notificationBody)
  else
    LogDebug("EquipRoomShowPaintCmd", "notification.body is nil")
  end
end
return EquipRoomShowPaintCmd
