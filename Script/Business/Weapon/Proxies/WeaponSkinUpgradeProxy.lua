local WeaponSkinUpgradeProxy = class("WeaponSkinUpgradeProxy", PureMVC.Proxy)
function WeaponSkinUpgradeProxy:OnRegister()
  WeaponSkinUpgradeProxy.super.OnRegister(self)
  self:InitTableCfg()
  self.ownedWeaponFxSeverDataMap = {}
end
function WeaponSkinUpgradeProxy:InitTableCfg()
  self.fxWeaponTableRows = {}
  local arrRows = ConfigMgr:GetFxWeaponTableRows()
  if arrRows then
    for key, value in pairs(arrRows:ToLuaTable()) do
      if value then
        self.fxWeaponTableRows[value.Id] = value
      end
    end
  end
end
function WeaponSkinUpgradeProxy:OnRemove()
  WeaponSkinUpgradeProxy.super.OnRemove(self)
end
function WeaponSkinUpgradeProxy:GetFxWeaponRow(id)
  return self.fxWeaponTableRows[id]
end
function WeaponSkinUpgradeProxy:GetBaseItemData(baseWeaponRow)
  if nil == baseWeaponRow then
    return
  end
  local data = {}
  data.InItemID = baseWeaponRow.Id
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  data.bEquip = equipRoomPrepareProxy:IsEquipWeaponByWeaponID(baseWeaponRow.Id) and 0 == weaponProxy:GetCurrentEquipAdvanedSkinID(baseWeaponRow.Id)
  data.bUnlock = weaponProxy:GetWeaponUnlockState(baseWeaponRow.Id)
  return data
end
function WeaponSkinUpgradeProxy:GetAdvanceFxItemData(baseWeaponRow)
  if nil == baseWeaponRow then
    return
  end
  local data = {}
  data.InItemID = baseWeaponRow.FxfireId
  data.bEquip = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):IsEquipWeaponAdvancedFx(baseWeaponRow.Id, baseWeaponRow.FxfireId)
  data.bUnlock = self:IsUnlockWeaponFx(baseWeaponRow.FxfireId)
  return data
end
function WeaponSkinUpgradeProxy:GetFinalFxItemData(baseWeaponRow)
  if nil == baseWeaponRow then
    return
  end
  local data = {}
  data.InItemID = baseWeaponRow.FxkillId
  data.bEquip = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):IsEquipWeaponFinalFx(baseWeaponRow.Id, baseWeaponRow.FxkillId)
  data.bUnlock = self:IsUnlockWeaponFx(baseWeaponRow.FxkillId)
  return data
end
function WeaponSkinUpgradeProxy:GetAdvadceSkinIDList(baseWeaponRow)
  local skinIDArray = {}
  if nil == baseWeaponRow then
    return skinIDArray
  end
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local num = baseWeaponRow.UpdateSkinId:Length()
  for index = 1, num do
    local id = baseWeaponRow.UpdateSkinId:Get(index)
    local row = weaponProxy:GetWeapon(id)
    if row and row.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
      table.insert(skinIDArray, id)
    else
      LogError("WeaponSkinUpgradeProxy:GetAdvadceSkinIDList", "weeapon is cofing Error, weapon id is : " .. tostring(id) .. "ECyCharacterSkinUpgradeType is :" .. tostring(row.LevelupType))
    end
  end
  return skinIDArray
end
function WeaponSkinUpgradeProxy:GetAdvadceSkinDataListByRow(baseWeaponRow)
  local skinArray = {}
  if nil == baseWeaponRow then
    LogError("GetAdvadceSkinDataListByRow:GetAdvadceSkinDataListByRow", "baseWeaponRow is nil")
    return skinArray
  end
  if baseWeaponRow.LevelupType ~= UE4.ECyCharacterSkinUpgradeType.Basics then
    LogError("WeaponSkinUpgradeProxy:GetAdvadceSkinList", "roleSkin is not up, ECyCharacterSkinUpgradeType is : " .. tostring(baseWeaponRow.LevelupType))
    return skinArray
  end
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local num = baseWeaponRow.UpdateSkinId:Length()
  for index = 1, num do
    local id = baseWeaponRow.UpdateSkinId:Get(index)
    local row = weaponProxy:GetWeapon(id)
    if row and row.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
      local itemData = {}
      itemData.InItemID = row.Id
      itemData.bEquip = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):IsEquipWeaponByWeaponID(baseWeaponRow.Id) and weaponProxy:IsEquipWeaponAdvancedSkin(baseWeaponRow.Id, row.Id)
      itemData.bUnlock = weaponProxy:IsUnlockAdvancedSkin(baseWeaponRow.Id, row.Id)
      itemData.softTexture = row.IconItem
      table.insert(skinArray, itemData)
    else
      LogError("GetAdvadceSkinDataListByRow:GetAdvadceSkinDataListByRow", "weapon is cofing Error, skin id is : " .. tostring(id))
    end
  end
  return skinArray
end
function WeaponSkinUpgradeProxy:UpdateOwnedWeaponFx(fxList)
  if fxList then
    for key, value in pairs(fxList) do
      self.ownedWeaponFxSeverDataMap[value.item_id] = value
    end
  end
end
function WeaponSkinUpgradeProxy:IsUnlockWeaponFx(fxID)
  return self.ownedWeaponFxSeverDataMap[fxID] ~= nil
end
return WeaponSkinUpgradeProxy
