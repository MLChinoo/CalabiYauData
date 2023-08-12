local KaPhoneProxy = class("KaPhoneProxy", PureMVC.Proxy)
local Valid
function KaPhoneProxy:GetUnLockRoles()
  return self.RolesProperties
end
function KaPhoneProxy:GetRoleProperties(RoleId)
  return self.RolesProperties[RoleId]
end
function KaPhoneProxy:SetRolePropertiesReaded(RoleId)
  self.RolesProperties[RoleId].new_sms = 0
end
function KaPhoneProxy:UpdateRedDotPromise()
  local CurRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  if nil == CurRoleId then
    return
  end
  local RolePro = self:GetRoleProperties(CurRoleId)
  if not RolePro then
    return
  end
  local RoleLvRewards = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavorabilityRewardData(CurRoleId)
  local RewardsNum = 0
  for index, value in pairs(RoleLvRewards or {}) do
    if value.favoLv <= RolePro.intimacy_lv and not table.containsValue(RolePro.upgrade_rewards, value.favoLv) then
      RewardsNum = RewardsNum + 1
    end
  end
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.PromiseTaskRewards, RewardsNum)
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.PromiseBiography, RolePro.biographys and #RolePro.biographys or 0)
  local newPromiseItemNum = 0
  if RolePro.pledges and #RolePro.pledges > 0 then
    for idx, unlockedPledge in ipairs(RolePro.pledges) do
      if unlockedPledge.step < 1 then
        newPromiseItemNum = newPromiseItemNum + 1
      end
    end
  end
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.PromiseItem, newPromiseItemNum)
  local MemoryProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomWindingCorridorProxy)
  local sequenceReddotNum = 0
  if RolePro.sequences then
    for key, value in pairs(RolePro.sequences or {}) do
      if 0 == value.main_status or MemoryProxy:MemoryStoryHasPicture(CurRoleId, value.id) and 0 == value.picture_status then
        sequenceReddotNum = sequenceReddotNum + 1
      end
    end
  end
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.PromiseMemory, sequenceReddotNum)
end
function KaPhoneProxy:OnRcvRolesPropertiesList(ServerData)
  local RolesProperties = DeCode(Pb_ncmd_cs_lobby.salon_roles_ntf, ServerData) or {}
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local WindingCorridorProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomWindingCorridorProxy)
  local InitmacyMaxLv = RoleProxy:GetRoleFavorabilityMaxLv()
  if RolesProperties.roles then
    for key, value in pairs(RolesProperties.roles or {}) do
      if InitmacyMaxLv < value.intimacy_lv then
        value.intimacy_lv = InitmacyMaxLv
      end
      self.RolesProperties[value.role_id] = value
      if not value.upgrade_rewards then
        self.RolesProperties[value.role_id].upgrade_rewards = {}
      end
      WindingCorridorProxy:UpdateUnlockWindingCorridorMap(value.role_id, value.sequences)
    end
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentRoleInfoChangedCmd)
  self:UpdateRedDotPromise()
end
function KaPhoneProxy:OnRcvRolesUpgrade(ServerData)
  local RolesProperties = DeCode(Pb_ncmd_cs_lobby.salon_role_upgrad_ntf, ServerData) or {}
  if next(RolesProperties) then
    local preRoleProp = self.RolesProperties[RolesProperties.role_id] or {}
    for key, value in pairs(RolesProperties or {}) do
      preRoleProp[key] = value
    end
    GameFacade:SendNotification(NotificationDefines.PMApartmentMainCmd, RolesProperties, NotificationDefines.ApartmentRoleUpgrade)
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):SaveRoleNewUnlockActivityArea(RolesProperties)
end
function KaPhoneProxy:OnRegister()
  KaPhoneProxy.super.OnRegister(self)
  self.RolesProperties = {}
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_ROLES_NTF, FuncSlot(self.OnRcvRolesPropertiesList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_ROLE_UPGRAD_NTF, FuncSlot(self.OnRcvRolesUpgrade, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_SHOW_OPER_RES, FuncSlot(self.InteractOperateRes, self))
end
function KaPhoneProxy:OnRemove()
  KaPhoneProxy.super.OnRemove(self)
  self.RolesProperties = {}
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_ROLES_NTF, FuncSlot(self.OnRcvRolesPropertiesList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_ROLE_UPGRAD_NTF, FuncSlot(self.OnRcvRolesUpgrade, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_SHOW_OPER_RES, FuncSlot(self.InteractOperateRes, self))
end
function KaPhoneProxy:InteractOperateReq(optType, param, subParam, addParams)
  local reqData = {}
  reqData.oper_type = optType
  reqData.param = param
  reqData.param_sub = subParam
  reqData.param_adds = addParams
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SHOW_OPER_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_show_oper_req, reqData))
end
function KaPhoneProxy:InteractOperateRes(serverData)
  local interactOptResult = DeCode(Pb_ncmd_cs_lobby.salon_show_oper_res, serverData)
  if 0 ~= interactOptResult.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, interactOptResult.code)
  end
end
return KaPhoneProxy
