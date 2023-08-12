local WeaponProxy = class("WeaponProxy", PureMVC.Proxy)
local weaponCfg = {}
local weaponSkinMap = {}
local ownWeaponServerDataMap = {}
function WeaponProxy:InitTableCfg()
  weaponCfg = {}
  weaponSkinMap = {}
  ownWeaponServerDataMap = {}
  self:InitWeaponTableCfg()
end
function WeaponProxy:InitWeaponTableCfg()
  local arrRows = ConfigMgr:GetWeaponTableRows()
  if arrRows then
    weaponCfg = arrRows:ToLuaTable()
    for key, value in pairs(weaponCfg) do
      if value and 0 ~= value.SubType then
        self:UpdateWeaponSkinTableCfg(value)
      end
    end
  end
end
function WeaponProxy:UpdateWeaponSkinTableCfg(value)
  local weaponList = weaponSkinMap[value.SubType]
  if nil == weaponList then
    weaponList = {}
    weaponList[value.Id] = value.Id
    weaponSkinMap[value.SubType] = weaponList
  else
    weaponList[value.Id] = value.Id
  end
end
function WeaponProxy:ctor(proxyName, data)
  WeaponProxy.super.ctor(self, proxyName, data)
end
function WeaponProxy:OnRegister()
  WeaponProxy.super.OnRegister(self)
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_FX_RES, FuncSlot(self.OnResEquipWeaponFx, self))
  end
end
function WeaponProxy:OnRemove()
  WeaponProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_FX_RES, FuncSlot(self.OnResEquipWeaponFx, self))
  end
end
function WeaponProxy:GetWeapon(weaponId)
  return weaponCfg[tostring(weaponId)]
end
function WeaponProxy:GetWeaponUUID(weaponId)
  local weaponData = ownWeaponServerDataMap[weaponId]
  if weaponData and weaponData.weapon_base then
    return weaponData.weapon_base.item_uuid
  end
  LogDebug("WeaponProxy", "weaponData is nil weaponID:%s", weaponId)
  return nil
end
function WeaponProxy:GetWeaponID(weaponUUId)
  for index, value in pairs(ownWeaponServerDataMap) do
    if value and value.item_uuid == weaponUUId then
      return index
    end
  end
  LogWarn("WeaponProxy", "weaponData is nil weaponUUId:%s", weaponUUId)
  return nil
end
function WeaponProxy:GetWeaponSlotTypeByWeaponId(weaponID)
  local weaponRowData = self:GetWeapon(weaponID)
  if weaponRowData then
    return weaponRowData.Slot
  else
    LogWarn("WeaponProxy", "weaponRowData is null ID :%s", weaponID)
  end
end
function WeaponProxy:GetWeaponListByWeaponSlotType(roleID, inWeaponSlotType)
  local weaponMap = {}
  for key, value in pairs(weaponCfg) do
    if value.AvailableState == UE4.ECyAvailableType.Show then
      local weaponSlotType = self:GetWeaponSlotTypeByWeaponId(value.Id)
      if weaponSlotType and weaponSlotType == inWeaponSlotType and 1 == value.Default then
        weaponMap[value.Id] = value
      end
    end
  end
  return weaponMap
end
function WeaponProxy:GetWeaponUnlockState(weaponID)
  local weaponRow = self:GetWeapon(weaponID)
  if nil == weaponRow then
    LogError("EquipRoomPrepareProxy", "weaponRow is nil, weaponID: ..", tostring(weaponID))
    return false
  end
  if weaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
    return self:IsUnlockAdvancedSkin(weaponRow.BasicSkinId, weaponID)
  else
    return nil ~= ownWeaponServerDataMap[tonumber(weaponID)]
  end
end
function WeaponProxy:GetWeaponSkinListBySubType(weaponSubType)
  return weaponSkinMap[weaponSubType]
end
function WeaponProxy:GetDefaultWeaponSkinBySubType(weaponSubType)
  for key, value in pairs(weaponSkinMap[weaponSubType]) do
    if key == weaponSubType then
      local defaultWeapon = self:GetWeapon(value)
      if defaultWeapon then
        return defaultWeapon
      end
    end
  end
  return nil
end
function WeaponProxy:GetRoleIDByWeaponId(weaponId)
  if nil == weaponId or 0 == weaponId then
    LogError("WeaponProxy:GetRoleIDByWeaponId", " WeaponID is nil")
    return 0
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local WeaponCfg = self:GetWeapon(weaponId)
  local AllRoleCfgs = roleProxy:GetAllRoleCfgs()
  for RoleId, RoleCfg in pairs(AllRoleCfgs) do
    if RoleCfg.DefaultWeapon1 == WeaponCfg.SubType then
      return RoleCfg.RoleId
    end
  end
  LogError("WeaponProxy:GetRoleIDByWeaponId", "roleid is nil, WeaponID is " .. tostring(weaponId))
  return 0
end
function WeaponProxy:IsUnlockAdvancedSkin(baseWeaponID, AdvanedSkinID)
  local servarData = ownWeaponServerDataMap[baseWeaponID]
  if servarData and nil ~= AdvanedSkinID and 0 ~= AdvanedSkinID and servarData and servarData.advanced_skins then
    for key, value in pairs(servarData.advanced_skins) do
      if AdvanedSkinID == value then
        return true
      end
    end
  end
  return false
end
function WeaponProxy:IsEquipWeaponAdvancedSkin(baseWeaponID, AdvanedSkinID)
  local servarData = ownWeaponServerDataMap[baseWeaponID]
  if servarData and nil ~= AdvanedSkinID and 0 ~= AdvanedSkinID then
    return servarData.advanced_skin_id == AdvanedSkinID
  end
  return false
end
function WeaponProxy:GetCurrentEquipAdvanedSkinID(baseWeaponID)
  local servarData = ownWeaponServerDataMap[baseWeaponID]
  if servarData then
    return servarData.advanced_skin_id
  end
  return 0
end
function WeaponProxy:GetEquipAdvanedSkinID(baseWeaponID)
  local advanedSkinID = self:GetCurrentEquipAdvanedSkinID(baseWeaponID)
  if 0 == advanedSkinID then
    return baseWeaponID
  end
  return advanedSkinID
end
function WeaponProxy:IsEquipWeaponFx(fxID, baseWeaponID)
  local fxRow = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy):GetFxWeaponRow(fxID)
  if fxRow then
    if fxRow.FxType == UE4.EWeaponUpgradeFxType.Advanced then
      return self:IsEquipWeaponAdvancedFx(baseWeaponID, fxID)
    elseif fxRow.FxType == UE4.EWeaponUpgradeFxType.Final then
      return self:IsEquipWeaponFinalFx(baseWeaponID, fxID)
    else
      LogError("WeaponProxy:IsEquipWeaponFx", "策划配置错误，武器特效类型，未指定，武器特效id： " .. tostring(fxID))
    end
  end
  return false
end
function WeaponProxy:IsEquipWeaponAdvancedFx(baseWeaponID, fxID)
  local servarData = ownWeaponServerDataMap[baseWeaponID]
  if servarData and nil ~= fxID and 0 ~= fxID then
    return servarData.advanced_fx_id == fxID
  end
  return false
end
function WeaponProxy:IsEquipWeaponFinalFx(baseWeaponID, fxID)
  local servarData = ownWeaponServerDataMap[baseWeaponID]
  if servarData and nil ~= fxID and 0 ~= fxID then
    return servarData.terminate_fx_id == fxID
  end
  return false
end
function WeaponProxy:UpdateOwnWeapon(weaponData)
  local weaponBase = weaponData.weapon_base
  if weaponBase then
    ownWeaponServerDataMap[weaponBase.item_id] = weaponData
  end
end
function WeaponProxy:UpdateWeaponAdvancedSkin(weaponID, waeaponAdvancedID)
  local weaponServerData = ownWeaponServerDataMap[weaponID]
  if weaponServerData then
    weaponServerData.advanced_skin_id = waeaponAdvancedID
  else
    LogWarn("WeaponProxy:UpdateWeaponFx", "weaponServerData is nil ,weaponid :" .. tostring(weaponID))
  end
end
function WeaponProxy:ReqEquipWeponFx(weaponID, fxType, fxID)
  local data = {
    weapon_id = weaponID,
    fx_type = fxType,
    fx_id = fxID
  }
  LogDebug("WeaponProxy:ReqEquipWeponFx", "data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_FX_REQ, pb.encode(Pb_ncmd_cs_lobby.equip_weapon_fx_req, data))
end
function WeaponProxy:OnResEquipWeaponFx(data)
  local servarData = DeCode(Pb_ncmd_cs_lobby.equip_weapon_fx_res, data)
  if nil == servarData then
    return
  end
  if 0 ~= servarData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, servarData.code)
    return
  end
  LogDebug("WeaponProxy:OnResEquipWeaponFx", "data is :" .. TableToString(servarData))
  self:UpdateWeaponFx(servarData.weapon_id, servarData.fx_type, servarData.fx_id)
  GameFacade:SendNotification(NotificationDefines.OnResEquipWeaponFxNtf, servarData)
end
function WeaponProxy:UpdateWeaponFx(weaponID, fxType, fxID)
  local weaponServerData = ownWeaponServerDataMap[weaponID]
  if weaponServerData then
    if fxType == UE4.EWeaponUpgradeFxType.Advanced then
      weaponServerData.advanced_fx_id = fxID
    elseif fxType == UE4.EWeaponUpgradeFxType.Final then
      weaponServerData.terminate_fx_id = fxID
    else
      LogError("WeaponProxy:UpdateWeaponFx", "fxType is none ,weaponid :" .. tostring(weaponID))
    end
  else
    LogError("WeaponProxy:UpdateWeaponFx", "weaponServerData is nil ,weaponid :" .. tostring(weaponID))
  end
end
return WeaponProxy
