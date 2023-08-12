local EquipRoomPrepareProxy = class("EquipRoomPrepareProxy", PureMVC.Proxy)
function EquipRoomPrepareProxy:OnRegister()
  self.super:OnRegister()
  self.RolePrepareServerDataMap = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_PREPARE_SYNC_NTF, FuncSlot(self.OnNtfRolePrepareSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_EQUIP_DECAL_RES, FuncSlot(self.OnResEquipDecal, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_RES, FuncSlot(self.OnResEquipWeapon, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_PREPARE_NTF, FuncSlot(self.OnNtfRolePrepare, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_SELECT_RES, FuncSlot(self.OnResRoleSkinSelect, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_COMMUNICATIONS_RES, FuncSlot(self.OnResRoleSetCommunications, self))
  end
end
function EquipRoomPrepareProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_PREPARE_SYNC_NTF, FuncSlot(self.OnNtfRolePrepareSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_EQUIP_DECAL_RES, FuncSlot(self.OnResEquipDecal, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_RES, FuncSlot(self.OnResEquipWeapon, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_PREPARE_NTF, FuncSlot(self.OnNtfRolePrepare, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_SELECT_RES, FuncSlot(self.OnResRoleSkinSelect, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_COMMUNICATIONS_RES, FuncSlot(self.OnResRoleSetCommunications, self))
  end
end
function EquipRoomPrepareProxy:OnNtfRolePrepareSync(prepareData)
  local prepareDataServerList = DeCode(Pb_ncmd_cs_lobby.role_prepare_sync_ntf, prepareData)
  if nil == prepareDataServerList then
    LogError("EquipRoomPrepareProxy", "OnNtfRoleWeaponSync Parse Faild")
    return
  end
  LogDebug("EquipRoomPrepareProxy:OnNtfRolePrepareSync,", TableToString(prepareDataServerList))
  if prepareDataServerList.roles then
    for index, value in pairs(prepareDataServerList.roles) do
      if value then
        self.RolePrepareServerDataMap[value.role_id] = value
      end
    end
  end
end
function EquipRoomPrepareProxy:OnNtfRolePrepare(prepareData)
  LogDebug("EquipRoomPrepareProxy:OnNtfRolePrepare", "EquipRoomPrepareProxy:OnNtfRolePrepare")
  local prepareDataServerList = DeCode(Pb_ncmd_cs_lobby.role_prepare_ntf, prepareData)
  if nil == prepareDataServerList then
    LogError("EquipRoomPrepareProxy", "OnNtfRolePrepare Parse Faild")
    return
  end
  for index, value in pairs(prepareDataServerList.roles) do
    if value then
      self.RolePrepareServerDataMap[value.role_id] = value
    end
  end
end
function EquipRoomPrepareProxy:ReqEquipDecal(inPaintid, useState, roleID)
  local data = {
    decal_id = inPaintid,
    decal_pos = useState,
    role_id = roleID
  }
  LogDebug("EquipRoomPrepareProxy:ReqEquipDecal,", TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_EQUIP_DECAL_REQ, pb.encode(Pb_ncmd_cs_lobby.equip_decal_req, data))
end
function EquipRoomPrepareProxy:OnResEquipDecal(data)
  local equipDecalData = pb.decode(Pb_ncmd_cs_lobby.equip_decal_res, data)
  if nil == equipDecalData then
    LogError("EquipRoomPrepareProxy", "OnResEquipDecal decode Faild")
    return
  end
  if 0 ~= equipDecalData.code then
    LogError("EquipRoomPrepareProxy", "ErrorCode is %s", equipDecalData.code)
    return
  end
  LogDebug("EquipRoomPrepareProxy:OnResEquipDecal,", TableToString(equipDecalData))
  if 0 == equipDecalData.role_id then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "AllCharacterEquip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    self:AllRoleEquip(equipDecalData.decal_id, equipDecalData.decal_pos)
  else
    self:UpdateRoleDecalServerData(equipDecalData.role_id, equipDecalData.decal_id, equipDecalData.decal_pos)
  end
  GameFacade:SendNotification(NotificationDefines.OnResEquipDecal)
end
function EquipRoomPrepareProxy:AllRoleEquip(decalID, decalPos)
  if self.RolePrepareServerDataMap then
    for inRoleID, value in pairs(self.RolePrepareServerDataMap) do
      if value and value.decals then
        for key, decal in pairs(value.decals) do
          if decal and decal.decal_pos == decalPos then
            decal.decal_id = decalID
          end
        end
      end
    end
  end
end
function EquipRoomPrepareProxy:UpdateRoleDecalServerData(roleID, decalID, decalPos)
  local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
  if rolePrepareServerData and rolePrepareServerData.decals then
    for key, decal in pairs(rolePrepareServerData.decals) do
      if decal and decal.decal_pos == decalPos then
        decal.decal_id = decalID
        break
      end
    end
  end
end
function EquipRoomPrepareProxy:ReqEquipWeaponByWeaponID(weaponID, roleID)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponRow = weaponProxy:GetWeapon(weaponID)
  if nil == weaponRow then
    LogError("EquipRoomPrepareProxy:ReqEquipWeaponByWeaponID", "weaponRow is nil，weaponID is " .. tostring(weaponID))
    return
  end
  if weaponRow.Slot == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
    roleID = weaponProxy:GetRoleIDByWeaponId(weaponID)
  end
  if nil == roleID or 0 == roleID then
    LogError("EquipRoomPrepareProxy:ReqEquipWeaponByWeaponID", "roleID is nil，weaponID is " .. tostring(weaponID))
    return
  end
  self:ReqEquipWeapon(roleID, weaponID, weaponRow.Slot)
end
function EquipRoomPrepareProxy:ReqEquipWeapon(roleID, weaponID, weaponSoltType, advancedSkinID)
  local data = {
    role_id = roleID,
    weapon_id = weaponID,
    slot_pos = weaponSoltType,
    advanced_id = nil == advancedSkinID and 0 or advancedSkinID
  }
  LogDebug("EquipRoomPrepareProxy:ReqEquipWeapon", "equip_weapon_req data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_EQUIP_WEAPON_REQ, pb.encode(Pb_ncmd_cs_lobby.equip_weapon_req, data))
end
function EquipRoomPrepareProxy:OnResEquipWeapon(data)
  local equipData = DeCode(Pb_ncmd_cs_lobby.equip_weapon_res, data)
  if nil == equipData then
    LogError("EquipRoomPrepareProxy:OnResEquipWeapon", "equipData decode Faild")
    return
  end
  if 0 ~= equipData.code then
    LogError("EquipRoomPrepareProxy:OnResEquipWeapon", "ErrorCode is " .. tostring(equipData.code))
    return
  end
  LogDebug("EquipRoomPrepareProxy:OnResEquipWeapon", "equip_weapon_res data is :" .. TableToString(equipData))
  local equipWeaponData = {}
  equipWeaponData.itemID = equipData.weapon_id
  equipWeaponData.weaponSoltType = equipData.slot_pos
  equipWeaponData.roleID = equipData.role_id
  self:UpdateRoleEquipWeaponServerData(equipData.role_id, equipData.weapons)
  GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):UpdateWeaponAdvancedSkin(equipData.weapon_id, equipData.advanced_id)
  GameFacade:SendNotification(NotificationDefines.OnResEquipWeapon, equipWeaponData)
end
function EquipRoomPrepareProxy:UpdateRoleEquipWeaponServerData(roleID, weapons)
  local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
  if weapons then
    rolePrepareServerData.weapons = weapons
  end
end
function EquipRoomPrepareProxy:ReqRoleSkinSelect(roleID, roleSkinID, advancedSkinID)
  local data = {
    role_id = roleID,
    role_skin_id = roleSkinID,
    advanced_skin_id = nil == advancedSkinID and 0 or advancedSkinID
  }
  LogDebug("EquipRoomPrepareProxy:ReqRoleSkinSelect", "role_skin_select_req data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_SELECT_REQ, pb.encode(Pb_ncmd_cs_lobby.role_skin_select_req, data))
end
function EquipRoomPrepareProxy:OnResRoleSkinSelect(data)
  local skinData = pb.decode(Pb_ncmd_cs_lobby.role_skin_select_res, data)
  if nil == skinData then
    LogError("EquipRoomPrepareProxy:OnResRoleSkinSelect", "skinData decode Faild")
    return
  end
  if 0 ~= skinData.code then
    LogError("EquipRoomPrepareProxy:OnResRoleSkinSelect", "ErrorCode is %s", skinData.code)
    return
  end
  LogDebug("EquipRoomPrepareProxy:OnResRoleSkinSelect", "role_skin_select_res data is :" .. TableToString(skinData))
  self:UpdateWearingRoleSkin(skinData.role_id, skinData.role_skin_id)
  GameFacade:RetrieveProxy(ProxyNames.RoleProxy):UpdateSeverAdvancedSkin(skinData.role_skin_id, skinData.advanced_skin_id)
  GameFacade:SendNotification(NotificationDefines.OnResRoleSkinSelect, skinData)
end
function EquipRoomPrepareProxy:UpdateWearingRoleSkin(roleID, roleSkinID)
  if roleID and roleSkinID then
    local prepareData = self:GetRolePrepareServerData(roleID)
    if prepareData then
      prepareData.skin_id = roleSkinID
    else
      LogError("EquipRoomPrepareProxy:UpdateWearingRoleSkin", "prepareData is nil,roID: %s", roleID)
    end
  end
end
function EquipRoomPrepareProxy:GetRolePrepareServerData(roleID)
  if self.RolePrepareServerDataMap == nil then
    LogError("EquipRoomPrepareProxy:GetRolePrepareServerData", "RolePrepareServerDataMap is nil,roID: %s", roleID)
    return nil
  end
  local prepareData = self.RolePrepareServerDataMap[roleID]
  if prepareData then
    return prepareData
  else
    LogWarn("EquipRoomPrepareProxy:GetRolePrepareServerData", "prepareData is nil,roID: %s", roleID)
  end
end
function EquipRoomPrepareProxy:ReqRoleSetCommunications(roleID, listIndex, communicationType, itemID)
  local data = {
    role_id = roleID,
    index = listIndex,
    communication_type = 2,
    id = itemID
  }
  LogDebug("EquipRoomPrepareProxy:ReqRoleSetCommunications", "role_set_communications_req data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_SET_COMMUNICATIONS_REQ, pb.encode(Pb_ncmd_cs_lobby.role_set_communications_req, data))
end
function EquipRoomPrepareProxy:OnResRoleSetCommunications(data)
  local communicationsData = DeCode(Pb_ncmd_cs_lobby.role_set_communications_res, data)
  if nil == communicationsData then
    LogError("EquipRoomPrepareProxy:OnResUpdateRoleEquipCommunications", "communicationsData decode Faild")
    return
  end
  if nil == communicationsData then
    LogError("EquipRoomPrepareProxy:OnResUpdateRoleEquipCommunications", "skinData decode Faild")
    return
  end
  if 0 ~= communicationsData.code then
    LogError("EquipRoomPrepareProxy:OnResUpdateRoleEquipCommunications", "ErrorCode is %s", communicationsData.code)
    return
  end
  LogDebug("EquipRoomPrepareProxy:OnResUpdateRoleEquipCommunications", "role_set_communications_res data is :" .. TableToString(communicationsData))
  self:UpdateRoleEquipCommunication(communicationsData.role_id, communicationsData.communications)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateEquipCommunicationListCmd, communicationsData.role_id)
end
function EquipRoomPrepareProxy:UpdateRoleEquipCommunication(roleID, communications)
  if roleID and communications then
    local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
    if rolePrepareServerData then
      rolePrepareServerData.communications = communications
    end
  end
end
function EquipRoomPrepareProxy:UpdateRoleEquipPersonalities(roleID, personalities)
  if roleID and personalities then
    local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
    if rolePrepareServerData then
      rolePrepareServerData.personalities = personalities
    end
  end
end
function EquipRoomPrepareProxy:GetEquipDecalDatas(roleID)
  local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
  if rolePrepareServerData then
    return rolePrepareServerData.decals
  end
  return nil
end
function EquipRoomPrepareProxy:IsEquipDecalByID(itemID, roleID)
  local equip = false
  if nil == itemID or 0 == itemID then
    return equip
  end
  if nil == roleID or 0 == roleID then
    return equip
  end
  local decals = self:GetEquipDecalDatas(roleID)
  if nil == decals then
    return equip
  end
  for key, decal in pairs(decals) do
    if decal and decal.decal_id == itemID then
      equip = true
      break
    end
  end
  return equip
end
function EquipRoomPrepareProxy:GetEquipWeaponMapByRoleID(roleID)
  local rolePrepareServerData = self:GetRolePrepareServerData(roleID)
  if rolePrepareServerData then
    return rolePrepareServerData.weapons
  end
  LogWarn("EquipRoomPrepareProxy:GetEquipWeaponMapByRoleID", "EquipWeaponServerData is nil roleID:%s", roleID)
  return nil
end
function EquipRoomPrepareProxy:GetDefaultEquipWeaponMapByRoleID(roleID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleRowTable = roleProxy:GetRole(roleID)
  local data = {}
  if roleRowTable then
    data[UE4.EWeaponSlotTypes.WeaponSlot_Primary] = self:AssembleWeaponEquipSoltData(roleRowTable.DefaultWeapon1, UE4.EWeaponSlotTypes.WeaponSlot_Primary)
    data[UE4.EWeaponSlotTypes.WeaponSlot_Secondary] = self:AssembleWeaponEquipSoltData(roleRowTable.DefaultWeapon2, UE4.EWeaponSlotTypes.WeaponSlot_Secondary)
    data[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1] = self:AssembleWeaponEquipSoltData(roleRowTable.DefaultWeapon4, UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1)
    data[UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2] = self:AssembleWeaponEquipSoltData(roleRowTable.DefaultWeapon5, UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2)
  end
  return data
end
function EquipRoomPrepareProxy:AssembleWeaponEquipSoltData(weaponID, sortType)
  local data = {}
  data.slot_pos = sortType
  data.weapon_id = weaponID
  return data
end
function EquipRoomPrepareProxy:IsWeaponUsed(weaponId)
  local roleId = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetRoleIDByWeaponId(weaponId)
  if roleId then
    if GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsUnlockRole(roleId) then
      return self:IsEquipWeapon(roleId, weaponId)
    else
      return false
    end
  else
    LogError("EquipRoomPrepareProxy:IsWeaponUsed", "No role use weapon skin: " .. tostring(weaponId))
    return false
  end
end
function EquipRoomPrepareProxy:IsEquipWeapon(roleID, weaponID)
  local isEquip = false
  local weaponSlotServerDataMap = self:GetEquipWeaponMapByRoleID(roleID)
  if nil == weaponSlotServerDataMap then
    LogWarn("EquipRoomPrepareProxy", "weaponSlotServerDataMap is nil roleID:%s", roleID)
    return isEquip
  end
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponRow = weaponProxy:GetWeapon(weaponID)
  if nil == weaponRow then
    LogError("EquipRoomPrepareProxy", "weaponRow is nil, weaponID: ..", tostring(weaponID))
    return isEquip
  end
  if weaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
    return weaponProxy:IsEquipWeaponAdvancedSkin(weaponRow.BasicSkinId, weaponID)
  else
    for index, value in pairs(weaponSlotServerDataMap) do
      if value.weapon_id == weaponID then
        return true
      end
    end
  end
  return isEquip
end
function EquipRoomPrepareProxy:IsEquipWeaponByWeaponID(weaponId)
  local roleId = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetRoleIDByWeaponId(weaponId)
  if roleId then
    return self:IsEquipWeapon(roleId, weaponId)
  else
    LogError("EquipRoomPrepareProxy:IsEquipWeaponByWeaponID", "No role use weapon skin: " .. tostring(weaponId))
    return false
  end
end
function EquipRoomPrepareProxy:GetCurrentEquipWeaponSlotType(roleID, weaponID)
  local weaponSlotServerDataMap = self:GetEquipWeaponMapByRoleID(roleID)
  if nil == weaponSlotServerDataMap then
    LogError("EquipRoomPrepareProxy", "weaponSlotServerDataMap is nil roleID:%s", roleID)
    return nil
  end
  for index, value in pairs(weaponSlotServerDataMap) do
    if value.weapon_id == weaponID then
      return index
    end
  end
  return nil
end
function EquipRoomPrepareProxy:GetEquipWeaponIDByWeaponSlotType(roleID, weaponSlotType)
  local rolePrepareServerData = self:GetEquipWeaponMapByRoleID(roleID)
  if rolePrepareServerData then
    local weaponSlotServerData = rolePrepareServerData[weaponSlotType]
    if weaponSlotServerData then
      return weaponSlotServerData.weapon_id
    end
  end
  LogError("EquipRoomPrepareProxy:GetEquipWeaponIDByWeaponSlotType", "GetEquipWeaponMapByRoleID is nil roleID:%s", roleID)
  return nil
end
function EquipRoomPrepareProxy:GetRoleCurrentWearSkinID(roleID)
  local skinID
  local prepareData = self:GetRolePrepareServerData(roleID)
  if prepareData then
    skinID = prepareData.skin_id
  end
  if nil == skinID then
    local roleRowData = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRole(roleID)
    if roleRowData then
      skinID = roleRowData.RoleSkin
    else
      LogError("EquipRoomPrepareProxy:GetRoleCurrentWearSkinID", "roleRowData is nil,roleID: %s", roleID)
    end
  end
  return skinID
end
function EquipRoomPrepareProxy:GetRoleEquipCommunication(roleID)
  local prepareData = self:GetRolePrepareServerData(roleID)
  if prepareData then
    return prepareData.communications
  end
  return nil
end
function EquipRoomPrepareProxy:IsEquipRoleCommunicationItem(roleID, itemID)
  local communicationsList = self:GetRoleEquipCommunication(roleID)
  if communicationsList then
    for key, value in pairs(communicationsList) do
      if value and value.id == itemID then
        return true
      end
    end
  end
  return false
end
function EquipRoomPrepareProxy:GetRoleEquipPersonalities(roleID)
  local prepareData = self:GetRolePrepareServerData(roleID)
  if prepareData then
    return prepareData.personalities
  end
  return nil
end
function EquipRoomPrepareProxy:GetRolePrepareServerDataMap()
  return self.RolePrepareServerDataMap
end
return EquipRoomPrepareProxy
