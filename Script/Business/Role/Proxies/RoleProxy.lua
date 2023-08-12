local RoleProxy = class("RoleProxy", PureMVC.Proxy)
local roleCfg = {}
local roleSkinCfg = {}
local roleActionCfg = {}
local roleVoiceCfg = {}
local roleProfileCfg = {}
local roleProfessionCfg = {}
local roleSkillCfg = {}
local roleFavorabilityCfg = {}
local roleFavorabilityEventCfg = {}
local roleBiographCfg = {}
local roleSkinMap = {}
local roleVoiceMap = {}
local roleCommuncationVoiceMap = {}
local roleRestroomVoiceMap = {}
local roleCommuncationActionMap = {}
local roleSkinServerDataMap = {}
local roleOwnVoiceMap = {}
local roleOwnActionMap = {}
local ownRoleMap = {}
function RoleProxy:InitTableCfg()
  roleCfg = {}
  roleSkinCfg = {}
  roleActionCfg = {}
  roleVoiceCfg = {}
  roleProfileCfg = {}
  roleProfessionCfg = {}
  roleSkillCfg = {}
  roleFavorabilityCfg = {}
  roleFavorabilityEventCfg = {}
  roleBiographCfg = {}
  roleSkinMap = {}
  roleVoiceMap = {}
  roleCommuncationVoiceMap = {}
  roleRestroomVoiceMap = {}
  roleCommuncationActionMap = {}
  roleSkinServerDataMap = {}
  roleOwnVoiceMap = {}
  roleOwnActionMap = {}
  ownRoleMap = {}
  self.voiceRedDotReadMap = {}
  self.roleSpecialObtainedCfgMap = {}
  self:InitRoleTableCfg()
  self:InitRoleSkinTableCfg()
  self:InitRoleActionTableCfg()
  self:InitRoleVoiceTableCfg()
  self:InitRoleProfileTableCfg()
  self:InitRoleProfessionTableCfg()
  self:InitRoleSkillTableCfg()
  self:InitRoleFavorabilityTableCfg()
  self:InitRoleFavorabilityEventTableCfg()
  self:InitRoleBiographCfg()
end
function RoleProxy:InitRoleTableCfg()
  local arrRows = ConfigMgr:GetRoleTableRows()
  if arrRows then
    roleCfg = arrRows:ToLuaTable()
  end
end
function RoleProxy:InitRoleSkinTableCfg()
  local arrRows = ConfigMgr:GetRoleSkinTableRows()
  if arrRows then
    roleSkinCfg = arrRows:ToLuaTable()
  end
end
function RoleProxy:InitRoleActionTableCfg()
  local arrRows = ConfigMgr:GetRoleActionTableRows()
  if arrRows then
    roleActionCfg = arrRows:ToLuaTable()
    for key, value in pairs(roleActionCfg) do
      if value and value.ActionPlayType == UE4.ETableActionType.InGameCommunication then
        local actionList = roleCommuncationActionMap[value.RoleId]
        if nil == actionList then
          actionList = {}
          actionList[value.RoleActionId] = value.RoleActionId
          roleCommuncationActionMap[value.RoleId] = actionList
        else
          actionList[value.RoleActionId] = value.RoleActionId
        end
      end
    end
  end
end
function RoleProxy:InitRoleVoiceTableCfg()
  local arrRows = ConfigMgr:GetRoleVoiceTableRows()
  if arrRows then
    roleVoiceCfg = arrRows:ToLuaTable()
    for key, value in pairs(roleVoiceCfg) do
      if value then
        if value.VoiceType == UE4.ETableVoiceType.Trigger then
          local voiceList = roleVoiceMap[value.RoleId]
          if nil == voiceList then
            voiceList = {}
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
            roleVoiceMap[value.RoleId] = voiceList
          else
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
          end
        elseif value.VoiceType == UE4.ETableVoiceType.InGameCommunication then
          local voiceList = roleCommuncationVoiceMap[value.RoleId]
          if nil == voiceList then
            voiceList = {}
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
            roleCommuncationVoiceMap[value.RoleId] = voiceList
          else
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
          end
        elseif value.VoiceType == UE4.ETableVoiceType.InRestroom then
          local voiceList = roleRestroomVoiceMap[value.RoleId]
          if nil == voiceList then
            voiceList = {}
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
            roleRestroomVoiceMap[value.RoleId] = voiceList
          else
            voiceList[value.RoleVoiceId] = value.RoleVoiceId
          end
        end
      end
    end
  end
end
function RoleProxy:InitRoleProfileTableCfg()
  local arrRows = ConfigMgr:GetRoleProfileTableRows()
  if arrRows then
    roleProfileCfg = arrRows:ToLuaTable()
  end
end
function RoleProxy:InitRoleFavorabilityTableCfg()
  local arrRows = ConfigMgr:GetRoleFavorabilityTableRows()
  if arrRows then
    local infoList = arrRows:ToLuaTable()
    for _, v in pairs(infoList) do
      roleFavorabilityCfg[v.FLv] = v
    end
  end
end
function RoleProxy:GetRoleFavorabilityMaxLv()
  return #roleFavorabilityCfg
end
function RoleProxy:InitRoleFavorabilityEventTableCfg()
  local arrRows = ConfigMgr:GetRoleFavorabilityEventTableRows()
  if arrRows then
    local infoList = arrRows:ToLuaTable()
    for _, v in pairs(infoList) do
      roleFavorabilityEventCfg[v.Id] = v
    end
  end
end
function RoleProxy:InitRoleBiographCfg()
  local arrRows = ConfigMgr:GetRoleBiographyTableRow()
  if arrRows then
    local bioRows = arrRows:ToLuaTable()
    for _, v in pairs(bioRows) do
      if not roleBiographCfg[v.RoleId] then
        roleBiographCfg[v.RoleId] = {}
      end
      roleBiographCfg[v.RoleId][v.Id] = v
    end
  end
end
function RoleProxy:InitRoleProfessionTableCfg()
  local arrRows = ConfigMgr:GetRoleProfessionTableRows()
  if arrRows then
    roleProfessionCfg = arrRows:ToLuaTable()
  end
end
function RoleProxy:InitRoleSkillTableCfg()
  local arrRows = ConfigMgr:GetRoleSkillTableRows()
  if arrRows then
    roleSkillCfg = arrRows:ToLuaTable()
  end
end
function RoleProxy:ctor(proxyName, data)
  RoleProxy.super.ctor(self, proxyName, data)
end
function RoleProxy:OnRegister()
  RoleProxy.super.OnRegister(self)
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SYNC_NTF, FuncSlot(self.OnNtfRoleSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_SYNC_NTF, FuncSlot(self.OnNtfRoleSkinSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_CHANGE_NTF, FuncSlot(self.OnNtfRoleSkinChange, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_SYNC_NTF, FuncSlot(self.OnNtfRoleVoiceSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_UPDATE_NTF, FuncSlot(self.OnNtfRoleVoiceUpdate, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_ACTION_SYNC_NTF, FuncSlot(self.OnNtfRoleActionSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_ACTION_UPDATE_NTF, FuncSlot(self.OnNtfRoleActionUpdate, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_CHANGE_NTF, FuncSlot(self.OnNtfRoleChange, self))
  end
end
function RoleProxy:OnRemove()
  RoleProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SYNC_NTF, FuncSlot(self.OnNtfRoleSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_SYNC_NTF, FuncSlot(self.OnNtfRoleSkinSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SKIN_CHANGE_NTF, FuncSlot(self.OnNtfRoleSkinChange, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_SYNC_NTF, FuncSlot(self.OnNtfRoleVoiceSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_UPDATE_NTF, FuncSlot(self.OnNtfRoleVoiceUpdate, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_ACTION_SYNC_NTF, FuncSlot(self.OnNtfRoleActionSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_ACTION_UPDATE_NTF, FuncSlot(self.OnNtfRoleActionUpdate, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_CHANGE_NTF, FuncSlot(self.OnNtfRoleChange, self))
  end
end
function RoleProxy:OnNtfRoleSync(data)
  local roleServarData = DeCode(Pb_ncmd_cs_lobby.role_sync_ntf, data)
  if nil == roleServarData then
    LogError("RoleProxy:OnNtfRoleSync", "roleServarData decode Faild")
    return
  end
  if nil == roleServarData.role_list then
    LogError("RoleProxy:OnNtfRoleSync", "roleServarData role_list is nil ")
    return
  end
  for key, value in pairs(roleServarData.role_list) do
    if value and value.owned == true then
      ownRoleMap[value.role_id] = value.role_id
    end
    self:HandleReadVoiceRedDot(value.role_id, value.reddots)
  end
  if roleServarData.role_cfg_list then
    for key, value in pairs(roleServarData.role_cfg_list) do
      if value then
        self.roleSpecialObtainedCfgMap[value.role_id] = value
      end
    end
  end
end
function RoleProxy:OnNtfRoleChange(data)
  LogDebug("RoleProxy:OnNtfRoleChange", "RoleProxy:OnNtfRoleChange")
  local roleServarData = DeCode(Pb_ncmd_cs_lobby.role_change_ntf, data)
  if nil == roleServarData then
    LogError("RoleProxy:OnNtfRoleChange", "roleServarData decode Faild")
    return
  end
  if nil == roleServarData.change_list then
    LogError("RoleProxy:OnNtfRoleSync", "roleServarData change_list is nil ")
    return
  end
  local rolePersonalityProxy = GameFacade:RetrieveProxy(ProxyNames.RolePersonalityCommunicationProxy)
  for key, value in pairs(roleServarData.change_list) do
    if value and value.owned == true then
      ownRoleMap[value.role_id] = value.role_id
    end
    self:HandleReadVoiceRedDot(value.role_id, value.reddots)
  end
end
function RoleProxy:OnNtfRoleSkinSync(data)
  local skinServarData = pb.decode(Pb_ncmd_cs_lobby.role_skin_sync_ntf, data)
  if nil == skinServarData then
    LogError("RoleProxy:OnNtfRoleSkinSync", "skinServarData decode Faild")
    return
  end
  if nil == skinServarData.role_skin_list then
    LogError("RoleProxy:OnNtfRoleSkinSync", "skinServarData role_list is nil ")
    return
  end
  for key, value in pairs(skinServarData.role_skin_list) do
    roleSkinServerDataMap[value.role_skin_id] = value
  end
end
function RoleProxy:OnNtfRoleSkinChange(data)
  local skinServarData = pb.decode(Pb_ncmd_cs_lobby.role_skin_change_ntf, data)
  if nil == skinServarData then
    LogError("RoleProxy:OnNtfRoleSkinSync", "skinServarData decode Faild")
    return
  end
  if nil == skinServarData.change_list then
    LogError("RoleProxy:OnNtfRoleSkinSync", "skinServarData role_list is nil ")
    return
  end
  for key, value in pairs(skinServarData.change_list) do
    roleSkinServerDataMap[value.role_skin_id] = value
  end
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  ConditionProxy:UpdateEpicCondition(skinServarData)
  GameFacade:SendNotification(NotificationDefines.HermesHotListRefreshPriceState)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
end
function RoleProxy:ReqRoleSkinSelect(roleID, roleSkinID, advancedSkinID)
  GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):ReqRoleSkinSelect(roleID, roleSkinID, advancedSkinID)
end
function RoleProxy:OnNtfRoleVoiceSync(data)
  local voiceData = pb.decode(Pb_ncmd_cs_lobby.role_voice_sync_ntf, data)
  if nil == voiceData then
    LogError("RoleProxy:OnNtfRoleVoiceSync", "voiceData decode Faild")
    return
  end
  self:UpdateOwnVoice(voiceData.voice_ids)
end
function RoleProxy:OnNtfRoleVoiceUpdate(data)
  local voiceData = DeCode(Pb_ncmd_cs_lobby.role_voice_update_ntf, data)
  if nil == voiceData then
    LogError("RoleProxy:OnNtfRoleVoiceUpdate", "voiceData decode Faild")
    return
  end
  self:UpdateOwnVoice(voiceData.add_voice_ids)
  self:AddVoiceReadRedDot(voiceData.add_voice_ids)
end
function RoleProxy:UpdateOwnVoice(data)
  if data then
    for key, value in pairs(data) do
      roleOwnVoiceMap[value] = value
    end
  end
end
function RoleProxy:OnNtfRoleActionSync(data)
  local actionData = pb.decode(Pb_ncmd_cs_lobby.role_action_sync_ntf, data)
  if nil == actionData then
    LogError("RoleProxy:OnNtfRoleActionSync", "actionData decode Faild")
    return
  end
  self:UpdateOwnAction(actionData.action_ids)
end
function RoleProxy:OnNtfRoleActionUpdate(data)
  local actionData = pb.decode(Pb_ncmd_cs_lobby.role_action_update_ntf, data)
  if nil == actionData then
    LogError("RoleProxy:OnNtfRoleActionUpdate", "actionData decode Faild")
    return
  end
  self:UpdateOwnAction(actionData.add_action_ids)
end
function RoleProxy:UpdateOwnAction(data)
  if data then
    for key, value in pairs(data) do
      roleOwnActionMap[value] = value
    end
  end
end
function RoleProxy:ReqUpdateRoleEquipCommunications(roleID, listIndex, communicationType, itemID)
  GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):ReqRoleSetCommunications(roleID, listIndex, communicationType, itemID)
end
function RoleProxy:GetRole(roleId)
  return roleCfg[tostring(roleId)]
end
function RoleProxy:GetRoleIds()
  local RoleIds = {}
  for key, value in pairs(roleCfg) do
    table.insert(RoleIds, key)
  end
  return RoleIds
end
function RoleProxy:GetAllRoleCfgs()
  return roleCfg
end
function RoleProxy:GetRoleSkin(roleSkinId)
  return roleSkinCfg[tostring(roleSkinId)]
end
function RoleProxy:GetRoleDefaultSkin(roleId)
  local role = self:GetRole(roleId)
  if role then
    return self:GetRoleSkin(role.RoleSkin)
  end
  return nil
end
function RoleProxy:GetRoleAction(roleActionId)
  return roleActionCfg[tostring(roleActionId)]
end
function RoleProxy:GetRoleVoice(roleVoiceId)
  return roleVoiceCfg[tostring(roleVoiceId)]
end
function RoleProxy:GetAllVoiceRow()
  return roleVoiceCfg
end
function RoleProxy:GetRoleProfile(roleId)
  return roleProfileCfg[tostring(roleId)]
end
function RoleProxy:GetAllRoleProfile()
  return roleProfileCfg
end
function RoleProxy:GetRoleFavoribility(roleIntimacyLv)
  return roleFavorabilityCfg[roleIntimacyLv]
end
function RoleProxy:GetRoleBiographCfg(roleId, biographId)
  if roleBiographCfg[roleId] then
    if biographId then
      return roleBiographCfg[roleId][biographId]
    else
      return roleBiographCfg[roleId]
    end
  end
end
function RoleProxy:GetRoleFavorabilityRewardData(roleId)
  local data = {}
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v.RoleId == roleId then
      data[v.FavoLevel] = {
        itemId = v.FavoPrize:Get(1).ItemId,
        itemAmount = v.FavoPrize:Get(1).ItemAmount,
        itemArray = v.FavoPrize,
        itemArrayImg = v.EmoticonsPicture,
        favoLv = v.FavoLevel,
        biographyUnlock = v.BiographyUnlock
      }
    end
  end
  return data
end
function RoleProxy:GetRoleFavorLevByBiographyId(RoleId, BiographyId)
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v.RoleId == RoleId then
      for i = 1, v.BiographyUnlock:Length() do
        local UnlockBio = v.BiographyUnlock:Get(i)
        if UnlockBio ~ 0 and UnlockBio == BiographyId then
          return v.FavoLevel
        end
      end
    end
  end
  return nil
end
function RoleProxy:GetRoleUnlockParts(roleId, favorableLevel)
  local data = {}
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v and v.RoleId == roleId and favorableLevel >= v.FavoLevel and v.PartUnlock and v.PartUnlock:Length() > 0 then
      for index = 1, v.PartUnlock:Length() do
        local partType = v.PartUnlock:Get(index)
        if 0 ~= partType then
          table.insert(data, partType)
        end
      end
    end
  end
  return data
end
function RoleProxy:GetRoleUnlockArea(roleId, favorableLevel)
  local data = {}
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v and v.RoleId == roleId and favorableLevel >= v.FavoLevel and v.AreaUnlock and v.AreaUnlock:Length() > 0 then
      for index = 1, v.AreaUnlock:Length() do
        local areaType = v.AreaUnlock:Get(index)
        if 0 ~= areaType then
          table.insert(data, areaType)
        end
      end
    end
  end
  return data
end
function RoleProxy:GetRoleFavorabilityEventSectionCfg(roleID, maxLevel, minLevel)
  local data = {}
  if nil == roleID or 0 == roleID then
    LogDebug(" RoleProxy:GetRoleUnlockSection", "role id is ni")
    return data
  end
  if nil == minLevel then
    LogDebug(" RoleProxy:GetRoleUnlockSection", "minLevel is ni")
    minLevel = 0
  end
  if nil == maxLevel then
    LogDebug(" RoleProxy:GetRoleUnlockSection", "maxLevel is ni")
    return data
  end
  if maxLevel <= minLevel then
    LogDebug(" RoleProxy:GetRoleUnlockSection", "maxLevel is <= minLevel")
    return data
  end
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v and v.RoleId == roleID and minLevel < v.FavoLevel and maxLevel >= v.FavoLevel then
      table.insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.FavoLevel > b.FavoLevel
  end)
  return data
end
function RoleProxy:GetRoleProfession(professionId)
  return roleProfessionCfg[tostring(professionId)]
end
function RoleProxy:GetRoleSkill(skillId)
  return roleSkillCfg[tostring(skillId)]
end
function RoleProxy:GetRoleCurrentWearSkinID(roleID)
  return GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):GetRoleCurrentWearSkinID(roleID)
end
function RoleProxy:GetRoleCurrentWearAdvancedSkinID(roleID)
  local skinID = self:GetRoleCurrentWearSkinID(roleID)
  local upSkinSverdata = roleSkinServerDataMap[skinID]
  if upSkinSverdata and (0 ~= upSkinSverdata.advanced_skin_id or not skinID) then
    skinID = upSkinSverdata.advanced_skin_id
  end
  return skinID
end
function RoleProxy:IsOwnRole(roleID)
  local cafePrivilegeOwn = GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):IsCafeItem(roleID)
  local unlcokOwn = self:IsUnlockRole(roleID)
  return unlcokOwn or cafePrivilegeOwn
end
function RoleProxy:IsUnlockRole(roleID)
  return ownRoleMap[tonumber(roleID)] ~= nil
end
function RoleProxy:IsRoleSkinUsed(inSkinId)
  local roleId = self:GetRoleSkin(inSkinId).RoleId
  if roleId then
    return self:IsEquipRoleSkin(roleId, inSkinId)
  else
    LogError("RoleProxy:IsRoleSkinUsed", "No role use skin: " .. tostring(inSkinId))
    return false
  end
end
function RoleProxy:IsEquipRoleSkin(roleID, inSkinID)
  local skinRow = self:GetRoleSkin(inSkinID)
  if nil == skinRow then
    LogError("RoleProxy:IsEquipRoleSkin", "skinRow is nil,ID:  " .. tostring(inSkinID))
    return false
  end
  if not self:IsOwnRole(roleID) then
    return false
  end
  local skinID = self:GetRoleCurrentWearSkinID(roleID)
  if skinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
    local serverData = roleSkinServerDataMap[skinRow.BasicSkinId]
    if serverData then
      return serverData.advanced_skin_id == inSkinID
    end
  else
    return skinID == inSkinID
  end
  return false
end
function RoleProxy:IsUpgradeRoleSkin(inSkinID)
  local skinRow = self:GetRoleSkin(inSkinID)
  if nil == skinRow then
    LogError("RoleProxy:IsEquipRoleSkin", "skinRow is nil,ID:  " .. tostring(inSkinID))
    return false
  end
  if skinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics then
    return true
  end
  return false
end
function RoleProxy:GetRoleSkinIDList(roleID)
  local roleSkinList = roleSkinMap[roleID]
  if nil == roleSkinList then
    roleSkinList = {}
    for key, value in pairs(roleSkinCfg) do
      if value.RoleId == roleID then
        table.insert(roleSkinList, value.RoleSkinId)
      end
    end
    roleSkinMap[roleID] = roleSkinList
  end
  return roleSkinList
end
function RoleProxy:IsUnlockRoleSkin(inSkinID)
  local skinRow = self:GetRoleSkin(inSkinID)
  if nil == skinRow then
    LogError("RoleProxy:IsUnlockRoleSkin", "skinRow is nil,ID:  " .. tostring(inSkinID))
    return false
  end
  if skinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
    local serverData = roleSkinServerDataMap[tonumber(skinRow.BasicSkinId)]
    if serverData and serverData.advanced_skins then
      for key, value in pairs(serverData.advanced_skins) do
        if inSkinID == value then
          return true
        end
      end
    end
  else
    local serverData = roleSkinServerDataMap[inSkinID]
    if serverData then
      return true
    end
  end
  return false
end
function RoleProxy:GetRoleVoiceIDList(roleID)
  return roleVoiceMap[roleID]
end
function RoleProxy:GetRoleRestroomVoiceIDList(roleID)
  return roleRestroomVoiceMap[roleID]
end
function RoleProxy:IsUnlockRoleVoice(voiceID)
  local voiceRow = self:GetRoleVoice(voiceID)
  if voiceRow and voiceRow.DefaultGet then
    return true
  end
  if roleOwnVoiceMap[tonumber(voiceID)] then
    return true
  end
  return false
end
function RoleProxy:GetRoleVoiceRandomActionID(voiceID)
  local roleVoiceRow = self:GetRoleVoice(voiceID)
  if roleVoiceRow then
    local num = roleVoiceRow.VoiceAction:Length()
    if num > 0 then
      local index = math.random(num)
      if index then
        return roleVoiceRow.VoiceAction:Get(index)
      end
    end
  end
  return nil
end
function RoleProxy:GetRoleCommunicationVoiceIDList(roleID)
  return roleCommuncationVoiceMap[roleID]
end
function RoleProxy:GetRoleCommunicationActionIDList(roleID)
  return roleCommuncationActionMap[roleID]
end
function RoleProxy:IsUnlockRoleAction(actionID)
  if roleOwnActionMap[tonumber(actionID)] then
    return true
  end
  return false
end
function RoleProxy:GetRoleEquipCommunication(roleID)
  return GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):GetRoleEquipCommunication(roleID)
end
function RoleProxy:IsEquipRoleCommunicationItem(roleID, itemID)
  return GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):IsEquipRoleCommunicationItem(roleID, itemID)
end
function RoleProxy:GetRoleCfgByWeaponId(weaponId)
  local WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local WeaponCfg = WeaponProxy:GetWeapon(weaponId)
  local AllRoleCfgs = self:GetAllRoleCfgs()
  for RoleId, RoleCfg in pairs(AllRoleCfgs) do
    if RoleCfg.DefaultWeapon1 == WeaponCfg.SubType then
      return self:GetRoleProfile(RoleCfg.RoleId)
    end
  end
end
function RoleProxy:AddVoiceReadRedDot(addVoiceIDList)
  LogDebug("RoleProxy:AddVoiceReadRedDot", "AddVoiceReadRedDot")
  local equipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
  for key, value in pairs(addVoiceIDList) do
    equipRoomProxy:AddRoleVoiceRedDot(self:GetRoleVoice(value))
  end
end
function RoleProxy:IsReadVoiceRedDot(roleID, voiceID)
  local voiceRow = self:GetRoleVoice(voiceID)
  if voiceRow then
    local voiceIDList = self.voiceRedDotReadMap[roleID]
    if voiceIDList then
      for key, value in pairs(voiceIDList) do
        if value == voiceRow.RoleVoiceId then
          return true
        end
      end
    end
  end
  return false
end
function RoleProxy:HandleReadVoiceRedDot(roleID, severData)
  if severData then
    LogDebug("RoleProxy:HandleReadVoiceRedDot", "severData convert indexArr ")
    local redDotIndexArr = {}
    for i = 1, #severData do
      for j = 0, 31 do
        if 0 ~= severData[i] & 1 << j then
          table.insert(redDotIndexArr, 32 * (i - 1) + j + 1)
        end
      end
    end
    LogDebug("RoleProxy:HandleReadVoiceRedDot", "indexArr convert voiceIDList")
    local redDotVoiceIDList = {}
    if roleVoiceCfg then
      for key, index in pairs(redDotIndexArr) do
        for key, value in pairs(roleVoiceCfg) do
          if value and value.RoleVoiceIndex == index and value.RoleId == roleID then
            table.insert(redDotVoiceIDList, value.RoleVoiceId)
          end
        end
      end
    end
    self.voiceRedDotReadMap[roleID] = redDotVoiceIDList
    LogDebug("RoleProxy:HandleReadVoiceRedDot", "save voiceIDList")
  end
end
function RoleProxy:GetSequenceIdByRoleIdAndFavorLevel(roleId, favorLevel)
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v.RoleId == roleId and v.FavoLevel == favorLevel then
      return v.SequenceId
    end
  end
  return 0
end
function RoleProxy:GetRolePromiseItemInfo(roleId, favorLv)
  local unlockedPromiseItems = {}
  for _, v in pairs(roleFavorabilityEventCfg) do
    if v.RoleId == roleId and v.UnlockPledgeItem > 0 then
      local info = {}
      info.id = v.UnlockPledgeItem
      info.storySequence = v.PledgeSeqId
      info.storyAvg = v.PledgeAvgId
      info.unlockedLv = v.FavoLevel
      info.unlocked = favorLv >= v.FavoLevel and true or false
      table.insert(unlockedPromiseItems, info)
    end
  end
  table.sort(unlockedPromiseItems, function(a, b)
    return a.unlockedLv < b.unlockedLv
  end)
  return unlockedPromiseItems
end
function RoleProxy:IsSkinUpgrade(skinID)
  local row = self:GetRoleSkin(skinID)
  if row then
    return row.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics
  end
  return false
end
function RoleProxy:GetSeverSkinInfo(baseSkinID)
  return roleSkinServerDataMap[baseSkinID]
end
function RoleProxy:UpdateSeverAdvancedSkin(baseSkinID, advancedSkinID)
  local severData = roleSkinServerDataMap[baseSkinID]
  if nil == severData then
    return
  end
  if nil == advancedSkinID then
    LogError("RoleProxy:UpdateSeverAdvancedSkin", "advancedSkinID is nil")
    return
  end
  severData.advanced_skin_id = advancedSkinID
end
function RoleProxy:UpdateSeverAdvancedSkinFlyEffect(baseSkinID, flyEffectID)
  local severData = roleSkinServerDataMap[baseSkinID]
  if nil == severData then
    LogError("RoleProxy:UpdateSeverAdvancedSkin", "severData is nil , baseSkinID is : " .. tostring(baseSkinID))
    return
  end
  if nil == flyEffectID then
    LogError("RoleProxy:UpdateSeverAdvancedSkin", "flyEffectID is nil")
    return
  end
  severData.flutter_id = flyEffectID
end
function RoleProxy:GetRoleSpecialObtainedCfg(roleID)
  return self.roleSpecialObtainedCfgMap[roleID]
end
return RoleProxy
