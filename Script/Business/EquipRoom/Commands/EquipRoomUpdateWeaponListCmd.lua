local EquipRoomUpdateWeaponListCmd = class("EquipRoomUpdateWeaponListCmd", PureMVC.Command)
local weaponProxy = {}
local equipRoomPrepareProxy = {}
function EquipRoomUpdateWeaponListCmd:Execute(notification)
  if nil == notification then
    LogError("EquipRoomUpdateWeaponListCmd", "body is nil")
    return
  end
  weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local body = notification:GetBody()
  local weaponSoltType = body.weaponSlotType
  local roleID = body.roleID
  if weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
    weaponSoltType = UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1
  end
  local weaponList = weaponProxy:GetWeaponListByWeaponSlotType(roleID, weaponSoltType)
  if nil == weaponList then
    LogError("EquipRoomUpdateWeaponListCmd", "weaponList is nil")
    return
  end
  local weaponListData = {}
  local index = 1
  for key, value in pairs(weaponList) do
    local singleSoltData = {}
    singleSoltData.itemID = value.Id
    singleSoltData.itemName = value.Name
    singleSoltData.itemDesc = value.Tips
    singleSoltData.sortTexture = value.IconWhite
    singleSoltData.SortId = value.SortId
    singleSoltData.slotType = weaponSoltType
    self:GetUnlockInfo(value.Id, value, singleSoltData)
    self:GetEquipState(value.Id, roleID, singleSoltData)
    singleSoltData.weaponListSoltType = body.weaponSlotType
    weaponListData[index] = singleSoltData
    index = index + 1
  end
  table.sort(weaponListData, function(a, b)
    if a.bUnlock == b.bUnlock then
      return a.SortId > b.SortId
    elseif a.bUnlock then
      return true
    else
      return false
    end
  end)
  LogDebug("EquipRoomUpdateWeaponListCmd", "EquipRoomUpdateWeaponListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponList, weaponListData)
end
function EquipRoomUpdateWeaponListCmd:GetEquipState(weaponID, roleID, singleSoltData)
  if singleSoltData.bUnlock == false then
    singleSoltData.bEquip = false
    return
  end
  local bEquip = equipRoomPrepareProxy:IsEquipWeapon(roleID, weaponID)
  if bEquip then
    singleSoltData.equipType = 0
    local weaponSoltType = equipRoomPrepareProxy:GetCurrentEquipWeaponSlotType(roleID, weaponID)
    if weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
      singleSoltData.equipType = 1
    elseif weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      singleSoltData.equipType = 2
    end
    singleSoltData.currentEquipSoltType = weaponSoltType
  end
  singleSoltData.bEquip = bEquip
end
function EquipRoomUpdateWeaponListCmd:GetUnlockInfo(weaponID, weaponRowData, singleSoltData)
  local bUnlock = weaponProxy:GetWeaponUnlockState(weaponID)
  if false == bUnlock and weaponRowData.GainType:Length() > 0 and weaponRowData.GainParam1:Length() > 0 then
    if weaponRowData.GainType:Get(1) == GlobalEnumDefine.EItemUnlockConditionType.AccountLevel then
      local formatTex = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "WeaponUnlockCondition")
      local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
      local arg1 = UE4.FFormatArgumentData()
      arg1.ArgumentName = "0"
      arg1.ArgumentValue = weaponRowData.GainParam1:Get(1)
      arg1.ArgumentValueType = 4
      inArgsTarry:Add(arg1)
      singleSoltData.unlockInfo = UE4.UKismetTextLibrary.Format(formatTex, inArgsTarry)
    else
      singleSoltData.unlockInfo = "解锁类型配置错误,当前类型为" .. weaponRowData.GainType:Get(1)
    end
  end
  singleSoltData.bUnlock = bUnlock
end
return EquipRoomUpdateWeaponListCmd
