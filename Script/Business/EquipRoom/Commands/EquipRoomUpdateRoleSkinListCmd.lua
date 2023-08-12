local this = class("EquipRoomUpdateRoleSkinListCmd", PureMVC.Command)
function this:Execute(notification)
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  if nil == roleID then
    LogDebug("EquipRoomUpdateRoleSkinListCmd.Execute", "roleID is nil")
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local roleSkinIDList = roleProxy:GetRoleSkinIDList(roleID)
  if nil == roleSkinIDList then
    LogDebug("EquipRoomUpdateRoleSkinListCmd.Execute", "roleSkinIDList is nil,roleID:%s", roleID)
    return
  end
  local data = {}
  local skinDataMap = {}
  local index = 1
  for key, value in pairs(roleSkinIDList) do
    local skinRow = roleProxy:GetRoleSkin(value)
    if skinRow and skinRow.UpdateType ~= UE4.ECyCharacterSkinUpgradeType.Advance then
      local skinData = {}
      skinData.ItemIndex = index
      skinData.itemName = skinRow.NameCn
      skinData.InItemID = value
      skinData.bUnlock = roleProxy:IsUnlockRoleSkin(value)
      self:UpdateCafePrivilegeData(skinData)
      skinData.bEquip = false
      skinData.bEquip = roleProxy:IsEquipRoleSkin(roleID, value)
      skinData.quality = skinRow.SortId
      local qulityRow = itemProxy:GetItemQualityConfig(skinRow.Quality)
      if qulityRow then
        skinData.qulityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qulityRow.Color))
        skinData.qulityName = qulityRow.Desc
      end
      if notification:GetBody() and skinData.bEquip then
        data.equipID = value
      end
      if self:IsShow(skinRow, skinData.bUnlock) then
        skinDataMap[index] = skinData
        index = index + 1
      end
    end
  end
  table.sort(skinDataMap, function(a, b)
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
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ROLE_SKIN)
  if redDotList then
    for key, value in pairs(redDotList) do
      for k, v in pairs(skinDataMap) do
        if v.InItemID == value.reddot_rid and value.mark then
          v.redDotID = key
        end
      end
    end
  end
  data.skinDataMap = skinDataMap
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleSkinList, data)
end
function this:UpdateCafePrivilegeData(itemData)
  GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):UpdateCafePrivilegeData(itemData)
end
function this:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return this
