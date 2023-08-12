local EquiproomUpdatePaintEquipSlotCmd = class("EquiproomUpdatePaintEquipSlotCmd", PureMVC.Command)
function EquiproomUpdatePaintEquipSlotCmd:Execute(notification)
  local notificationBody = {}
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local currentRoleID = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy):GetSelectRoleID()
  local equipData = equipRoomPrepareProxy:GetEquipDecalDatas(currentRoleID)
  if equipData then
    for key, value in pairs(equipData) do
      local decalID = value.decal_id
      if decalID then
        local singleDecalData = {}
        local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(decalID)
        if decalRowData then
          singleDecalData.sortTexture = decalRowData.IconItem
        end
        singleDecalData.itemID = decalID
        notificationBody[value.decal_pos] = singleDecalData
      end
    end
  else
    LogDebug("EquiproomUpdatePaintEquipSlotCmd", "equipData is nil, roleID is " .. tostring(currentRoleID))
  end
  LogDebug("EquiproomUpdatePaintEquipSlotCmd", "EquipRoomShowPaintCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePaintEquipSlot, notificationBody)
end
return EquiproomUpdatePaintEquipSlotCmd
