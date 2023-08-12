local EquipRoomUpdateWeaponEquipSoltCmd = class("EquipRoomUpdateWeaponEquipSoltCmd", PureMVC.Command)
function EquipRoomUpdateWeaponEquipSoltCmd:Execute(notification)
  local roleID = notification.body
  if nil == roleID then
    LogError("EquipRoomUpdateWeaponEquipSoltCmd", "roleID is nil")
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local equipWeaponMap = {}
  local bHasRole = roleProxy:IsOwnRole(roleID)
  if bHasRole then
    equipWeaponMap = equipRoomPrepareProxy:GetEquipWeaponMapByRoleID(roleID)
  else
    equipWeaponMap = equipRoomPrepareProxy:GetDefaultEquipWeaponMapByRoleID(roleID)
  end
  if nil == equipWeaponMap then
    LogError("EquipRoomUpdateWeaponEquipSoltCmd", "EquipWeaponMap is nil,roleID:%s", roleID)
    return
  end
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponSoltData = {}
  for index, value in pairs(equipWeaponMap) do
    local singleSoltData = {}
    local weaponID = value.weapon_id
    if nil == weaponID then
      return
    end
    local weaponTableData = weaponProxy:GetWeapon(weaponID)
    if nil == weaponTableData then
      LogError("EquipRoomUpdateWeaponEquipSoltCmd", "WeaponConfig is nil,weaponID:%s", weaponID)
      return
    end
    if weaponTableData then
      singleSoltData.itemID = weaponTableData.Id
      local sub = weaponProxy:GetWeapon(weaponTableData.SubType)
      if sub then
        singleSoltData.itemName = sub.Name
        singleSoltData.itemDesc = sub.Tips
      end
      singleSoltData.sortTexture = weaponTableData.IconWhite
      singleSoltData.bShowSwitcherIcon = true
      if index == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
        singleSoltData.bShowSwitcherIcon = false
        singleSoltData.itemIndex = 1
      elseif index == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
        singleSoltData.itemIndex = 2
      elseif index == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
        singleSoltData.itemIndex = 3
      elseif index == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
        singleSoltData.itemIndex = 4
      end
    end
    weaponSoltData[index] = singleSoltData
  end
  LogDebug("EquipRoomUpdateWeaponEquipSoltCmd", "EquipRoomUpdateWeaponEquipSoltCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponEquipSolt, weaponSoltData)
end
return EquipRoomUpdateWeaponEquipSoltCmd
