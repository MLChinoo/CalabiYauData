local EquipRoomUpdateWeaponSkinListCmd = class("EquipRoomUpdateWeaponSkinListCmd", PureMVC.Command)
local WeaponProxy = {}
local EquipRoomPrepareProxy = {}
local ItemProxy = {}
function EquipRoomUpdateWeaponSkinListCmd:Execute(notification)
  if nil == notification then
    LogError("EquipRoomUpdateWeaponSkinListCmd", "body is nil")
    return
  end
  WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  EquipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local body = notification:GetBody()
  local weaponSubType = body.weaponSubType
  local roleID = body.roleID
  local bHasRole = roleProxy:IsUnlockRole(roleID)
  local weaponSkinList = WeaponProxy:GetWeaponSkinListBySubType(weaponSubType)
  if nil == weaponSkinList then
    LogError("EquipRoomUpdateWeaponSkinListCmd", "weaponSkinList is nil")
    return
  end
  local weaponSkinListData = {}
  for key, value in pairs(weaponSkinList) do
    if value then
      local weaponRow = WeaponProxy:GetWeapon(value)
      if weaponRow and weaponRow.LevelupType ~= UE4.ECyCharacterSkinUpgradeType.Advance then
        local itemData = {}
        itemData.InItemID = value
        itemData.bUnlock = WeaponProxy:GetWeaponUnlockState(value)
        itemData.bEquip = false
        itemData.bEquip = EquipRoomPrepareProxy:IsEquipWeapon(roleID, value)
        self:UpdateCafePrivilegeData(itemData)
        itemData.itemName = weaponRow.Name
        itemData.quality = weaponRow.SortId
        local qulityRow = ItemProxy:GetItemQualityConfig(weaponRow.Quality)
        if qulityRow then
          itemData.qulityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qulityRow.Color))
          itemData.qulityName = qulityRow.Desc
        end
        if self:IsShow(weaponRow, itemData.bUnlock) then
          table.insert(weaponSkinListData, itemData)
        end
      end
    end
  end
  table.sort(weaponSkinListData, function(a, b)
    if a.bEquip == b.bEquip then
      if a.bUnlock == b.bUnlock then
        return a.quality > b.quality
      elseif a.bUnlock then
        return true
      else
        return false
      end
    else
      if a.bEquip == true then
        return true
      end
      return false
    end
  end)
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM)
  if redDotList then
    for key, value in pairs(redDotList) do
      for k, v in pairs(weaponSkinListData) do
        if value.mark and v.InItemID == value.event_id then
          v.redDotID = key
        end
      end
    end
  end
  LogDebug("EquipRoomUpdateWeaponSkinListCmd", "EquipRoomUpdateWeaponSkinListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponSkinList, weaponSkinListData)
end
function EquipRoomUpdateWeaponSkinListCmd:UpdateCafePrivilegeData(itemData)
  GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):UpdateCafePrivilegeData(itemData)
end
function EquipRoomUpdateWeaponSkinListCmd:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return EquipRoomUpdateWeaponSkinListCmd
