local EquipRoomRedDotProxy = class("EquipRoomRedDotProxy", PureMVC.Proxy)
function EquipRoomRedDotProxy:OnRegister()
  EquipRoomRedDotProxy.super.OnRegister(self)
  self.localSkinRedDotMap = {}
  self.localVoiceRedDotMap = {}
  self.localAllVoiceRedDotMap = {}
  self.localCommuicationVoiceRedDotMap = {}
  self.localCommuicationActionRedDotMap = {}
  self.localPrimaryWeaponSkinRedDotMap = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_READ_RES, FuncSlot(self.OnResReadVoiceRedDot, self))
  end
end
function EquipRoomRedDotProxy:OnRemove()
  LogDebug("EquipRoomRedDotProxy", "OnRemove")
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_READ_RES, FuncSlot(self.OnResReadVoiceRedDot, self))
  end
  EquipRoomRedDotProxy.super.OnRemove(self)
end
function EquipRoomRedDotProxy:InitRedDot()
  self:InitRoleSkinRedDot()
  self:InitCommunicationActionRedDot()
  self:InitWeaponSkinRedDot()
  self:InitDecalRedDot()
  self:InitRoleVoiceRedDot()
  self:InitEmoteRedDot()
end
function EquipRoomRedDotProxy:InitDecalRedDot()
  LogDebug("EquipRoomRedDotProxy:InitDecalRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_DECAL)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddDecalRedDot(value)
      end
    end
  end
end
function EquipRoomRedDotProxy:AddDecalRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local decalProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
    local row = decalProxy:GetDecalTableDataByItemID(redDotInfo.event_id)
    if self:IsHide(row) then
      LogError("EquipRoomRedDotProxy:AddDecalRedDot", "DecalID: " .. tonumber(redDotInfo.event_id) .. ",AvailableState is 0,联系策划")
      return
    end
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.Decal, 1)
  end
end
function EquipRoomRedDotProxy:InitEmoteRedDot()
  LogDebug("EquipRoomRedDotProxy:InitEmoteRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_EMOTION)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddEmoteRedDot(value)
      end
    end
  end
end
function EquipRoomRedDotProxy:AddEmoteRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local emoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    local row = emoteProxy:GetRoleEmoteTableRow(redDotInfo.event_id)
    if self:IsHide(row) then
      LogError("EquipRoomRedDotProxy:AddEmoteRedDot", "RoleEmoteID: " .. tonumber(redDotInfo.event_id) .. ",AvailableState is 0,联系策划")
      return
    end
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote, 1)
  end
end
function EquipRoomRedDotProxy:InitRoleSkinRedDot()
  LogDebug("EquipRoomRedDotProxy:InitRoleSkinRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ROLE_SKIN)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddRoleSkinRedDot(value)
      end
    end
  end
end
function EquipRoomRedDotProxy:AddRoleSkinRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local roleSkinRow = roleProxy:GetRoleSkin(redDotInfo.event_id)
    if self:IsHide(roleSkinRow) then
      LogError("EquipRoomRedDotProxy:AddRoleSkinRedDot", "RoleSkinID: " .. tonumber(redDotInfo.event_id) .. ",AvailableState is 0,联系策划")
      return
    end
    local bAdd = self:AddLocalRedDot(redDotInfo, self.localSkinRedDotMap)
    if bAdd then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleSkin, 1)
    end
  end
end
function EquipRoomRedDotProxy:InitRoleVoiceRedDot()
  LogDebug("EquipRoomRedDotProxy:InitRoleVoiceRedDot", "Init red dot...")
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local voiceRows = roleProxy:GetAllVoiceRow()
  for key, value in pairs(voiceRows) do
    if value and (value.VoiceType == UE4.ETableVoiceType.InGameCommunication or value.VoiceType == UE4.ETableVoiceType.Trigger) and roleProxy:IsUnlockRole(value.RoleId) == true and true == roleProxy:IsUnlockRoleVoice(value.RoleVoiceId) and roleProxy:IsReadVoiceRedDot(value.RoleId, value.RoleVoiceId) == false then
      self:AddRoleVoiceRedDot(value)
    end
  end
  LogDebug("EquipRoomRedDotProxy:InitRoleVoiceRedDot", "localVoiceRedDotMap cout is " .. table.count(self.localVoiceRedDotMap))
end
function EquipRoomRedDotProxy:AddRoleVoiceRedDot(voiceRow)
  if voiceRow then
    if self:IsHide(voiceRow) then
      return
    end
    local redInfo = {
      reddot_id = voiceRow.RoleVoiceId,
      reddot_rid = voiceRow.RoleVoiceId
    }
    if voiceRow.VoiceType == UE4.ETableVoiceType.Trigger then
      local setting = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDotQualitySetting()
      if setting and setting <= voiceRow.Quality and self.localVoiceRedDotMap and self.localVoiceRedDotMap[voiceRow.RoleVoiceId] == nil then
        self:AddLocalRedDot(redInfo, self.localVoiceRedDotMap)
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleVoice, 1)
      end
      self:AddLocalRedDot(redInfo, self.localAllVoiceRedDotMap)
    elseif voiceRow.VoiceType == UE4.ETableVoiceType.InGameCommunication and self.localCommuicationVoiceRedDotMap and nil == self.localCommuicationVoiceRedDotMap[voiceRow.RoleVoiceId] then
      self:AddLocalRedDot(redInfo, self.localCommuicationVoiceRedDotMap)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuicationVoice, 1)
    end
  end
end
function EquipRoomRedDotProxy:InitCommunicationActionRedDot()
  LogDebug("EquipRoomRedDotProxy:InitCommunicationActionRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ACTION)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddRoleActionRedDot(value)
      end
    end
  end
end
function EquipRoomRedDotProxy:AddRoleActionRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local row = roleProxy:GetRoleAction(redDotInfo.event_id)
    if self:IsHide(row) then
      LogError("EquipRoomRedDotProxy:AddRoleActionRedDot", "RoleActionID: " .. tonumber(redDotInfo.event_id) .. ",AvailableState is 0,联系策划")
      return
    end
    local bAdd = self:AddLocalRedDot(redDotInfo, self.localCommuicationActionRedDotMap)
    if bAdd then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuicationAction, 1)
    end
  end
end
function EquipRoomRedDotProxy:InitWeaponSkinRedDot()
  LogDebug("EquipRoomRedDotProxy:InitWeaponSkinRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark and value.needPassUp then
        self:AddWeaponSkinRedDot(value)
      end
    end
  end
end
function EquipRoomRedDotProxy:AddWeaponSkinRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(redDotInfo.event_id)
    if itemType == UE4.EItemIdIntervalType.Weapon then
      local row = WeaponProxy:GetWeapon(redDotInfo.event_id)
      if self:IsHide(row) then
        LogError("EquipRoomRedDotProxy:AddWeaponSkinRedDot", "WeaponID: " .. tonumber(redDotInfo.event_id) .. ",AvailableState is 0,联系策划")
        return
      end
      local slotType = WeaponProxy:GetWeaponSlotTypeByWeaponId(redDotInfo.event_id)
      if slotType == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
        self:AddLocalRedDot(redDotInfo, self.localPrimaryWeaponSkinRedDotMap)
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin, 1)
      else
      end
    end
  end
end
function EquipRoomRedDotProxy:GetLocalVoiceRedDotMap()
  return self.localVoiceRedDotMap
end
function EquipRoomRedDotProxy:GetAllLocalVoiceRedDotMap()
  return self.localAllVoiceRedDotMap
end
function EquipRoomRedDotProxy:GetLocalCommunicationRedDotMap()
  return self.localCommuicationVoiceRedDotMap
end
function EquipRoomRedDotProxy:GetLocalPrimaryWeaponSkinRedDotMap()
  return self.localPrimaryWeaponSkinRedDotMap
end
function EquipRoomRedDotProxy:AddLocalRedDot(redDotInfo, localRedDotMap)
  local bAdd = false
  if redDotInfo then
    if nil == localRedDotMap then
      localRedDotMap = {}
    end
    if nil == localRedDotMap[redDotInfo.reddot_id] then
      localRedDotMap[redDotInfo.reddot_id] = redDotInfo
      bAdd = true
    end
  end
  return bAdd
end
function EquipRoomRedDotProxy:RemoveLocalRedDot(redDotID, itemType)
  if itemType == UE4.EItemIdIntervalType.RoleSkin then
    if self.localSkinRedDotMap then
      self.localSkinRedDotMap[redDotID] = nil
    end
  elseif itemType == UE4.EItemIdIntervalType.RoleVoice then
    self:ReqReadVoiceRedDot(redDotID)
    if self.localVoiceRedDotMap then
      self.localVoiceRedDotMap[redDotID] = nil
    end
    if self.localCommuicationVoiceRedDotMap then
      self.localCommuicationVoiceRedDotMap[redDotID] = nil
    end
    if self.localAllVoiceRedDotMap then
      self.localAllVoiceRedDotMap[redDotID] = nil
    end
  elseif itemType == UE4.EItemIdIntervalType.RoleAction then
    if self.localCommuicationActionRedDotMap then
      self.localCommuicationActionRedDotMap[redDotID] = nil
    end
  elseif itemType == UE4.EItemIdIntervalType.Weapon and self.localPrimaryWeaponSkinRedDotMap then
    self.localPrimaryWeaponSkinRedDotMap[redDotID] = nil
  end
end
function EquipRoomRedDotProxy:GetRedDotInfluenceRoleIDList()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localSkinRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localVoiceRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationVoiceRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationActionRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localPrimaryWeaponSkinRedDotMap, roleIDList, true)
  LogDebug("EquipRoomRedDotProxy:GetRedDotInfluenceRoleIDList", "EquipRoomRedDotProxy:GetRedDotInfluenceRoleIDList")
  table.count(roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRedDotInfluenceRoleByDefault()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localSkinRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localVoiceRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationVoiceRedDotMap, roleIDList)
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationActionRedDotMap, roleIDList)
  LogDebug("EquipRoomRedDotProxy:GetRedDotInfluenceRoleByDefault", "EquipRoomRedDotProxy:GetRedDotInfluenceRoleByDefault")
  return roleIDList
end
function EquipRoomRedDotProxy:GetRedDotInfluenceRoleByWeaponSkin()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localPrimaryWeaponSkinRedDotMap, roleIDList, true)
  LogDebug("EquipRoomRedDotProxy:GetRedDotInfluenceRoleByWeaponSkin", "EquipRoomRedDotProxy:GetRedDotInfluenceRoleByWeaponSkin")
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListBySkinRedDot()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localSkinRedDotMap, roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListByVoiceRedDot()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localVoiceRedDotMap, roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListByCommunicationRedDot()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationVoiceRedDotMap, roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListByCommunicationVoiceRedDot()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationVoiceRedDotMap, roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListByCommunicationActionRedDot()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localCommuicationActionRedDotMap, roleIDList)
  return roleIDList
end
function EquipRoomRedDotProxy:GetRoleIDListByPrimaryWeaponSkin()
  local roleIDList = {}
  self:HandleGetRotDotInfluenceRoleIDList(self.localPrimaryWeaponSkinRedDotMap, roleIDList, true)
  return roleIDList
end
function EquipRoomRedDotProxy:HandleGetRotDotInfluenceRoleIDList(localRedDotMap, roleIDList, isWeapon)
  if localRedDotMap and table.count(localRedDotMap) > 0 then
    for key, value in pairs(localRedDotMap) do
      if value then
        if isWeapon then
          local roleID = self:HandleGetRoleIDByPrimaryWeaponID(value.event_id)
          roleIDList[roleID] = roleID
        else
          local idString = tostring(value.reddot_rid)
          local subStr = string.sub(idString, 3, 5)
          local roleID = tonumber(subStr)
          roleIDList[roleID] = roleID
        end
      end
    end
  end
end
function EquipRoomRedDotProxy:HandleGetRoleIDByPrimaryWeaponID(weaponID)
  local WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local WeaponCfg = WeaponProxy:GetWeapon(weaponID)
  local AllRoleCfgs = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetAllRoleCfgs()
  for RoleId, RoleCfg in pairs(AllRoleCfgs) do
    if RoleCfg.AiAvailable == true and RoleCfg.DefaultWeapon1 == WeaponCfg.SubType then
      return RoleCfg.RoleId
    end
  end
  return 0
end
function EquipRoomRedDotProxy:ReqReadVoiceRedDot(voiceID)
  local data = {voice_id = voiceID}
  LogDebug("EquipRoomRedDotProxy:ReqReadVoiceRedDot", "voiceID is " .. voiceID)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_VOICE_READ_REQ, pb.encode(Pb_ncmd_cs_lobby.role_voice_read_req, data))
end
function EquipRoomRedDotProxy:OnResReadVoiceRedDot(data)
  local roleServarData = pb.decode(Pb_ncmd_cs_lobby.role_voice_read_res, data)
  if nil == roleServarData then
    LogError("EquipRoomRedDotProxy:OnResReadVoiceRedDot", "roleServarData decode Faild")
    return
  end
  if 0 ~= roleServarData.code then
    LogError("EquipRoomRedDotProxy:OnResReadVoiceRedDot", "code is " .. tostring(roleServarData.code))
    return
  end
  LogDebug("EquipRoomRedDotProxy:OnResReadVoiceRedDot", "ResRead")
end
function EquipRoomRedDotProxy:IsHide(row)
  local bHide = true
  if row then
    bHide = row.AvailableState == UE4.ECyAvailableType.Hide
  end
  return bHide
end
return EquipRoomRedDotProxy
