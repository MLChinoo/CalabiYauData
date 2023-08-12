local ApartmentConditionProxy = class("ApartmentConditionProxy", PureMVC.Proxy)
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function ApartmentConditionProxy:OnRegister()
  self.super.OnRegister(self)
  self.roles_settings = nil
  self.initShowEmailFlag = true
  self.newEmailFlag = false
  self.newEpicSkinFlag = false
  self.newResultFlag = UE4.ECyBattleResultType.None
  LogInfo("ApartmentConditionProxy", "OnRegister")
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_SALON_ROLES_NTF, FuncSlot(self.OnRcvRolesPropertiesList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_SETTING_ROLE_RES, FuncSlot(self.SaveCustomDataResult, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_BATTLE_GAME_NTF, FuncSlot(self.OnNtfSettleBattle, self))
end
function ApartmentConditionProxy:OnRemove()
  self.super.OnRemove(self)
  self.roles_settings = nil
  LogInfo("ApartmentConditionProxy", "OnRemove")
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  LogInfo("ApartmentConditionProxy", "OnRemoveHandler")
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_ROLES_NTF, FuncSlot(self.OnRcvRolesPropertiesList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_SETTING_ROLE_RES, FuncSlot(self.SaveCustomDataResult, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_BATTLE_GAME_NTF, FuncSlot(self.OnNtfSettleBattle, self))
end
function ApartmentConditionProxy:SaveContractCustomBattle(value, lastRoomId)
  self:SaveSettingByRoleIdInClient(RoleAttrMap.RoleSettingKey.RoleBattleResult, value, RoleAttrMap.BattleRoleID)
  self:SaveSettingByRoleId(RoleAttrMap.RoleSettingKey.RoleLastRoomID, lastRoomId, RoleAttrMap.BattleRoleID)
end
function ApartmentConditionProxy:SaveSettingByRoleIdInClient(key, value, roleId)
  if self.roles_settings == nil then
    return
  end
  local settings = self.roles_settings[roleId] or {}
  local bFind = false
  for i, v in ipairs(settings) do
    if v.key == key then
      v.value = value
      bFind = true
      break
    end
  end
  if false == bFind then
    settings[#settings + 1] = {key = key, value = value}
  end
  self.roles_settings[roleId] = settings
end
function ApartmentConditionProxy:SaveSettingByRoleId(key, value, roleId)
  if self.roles_settings == nil then
    return
  end
  self:SaveSettingByRoleIdInClient(key, value, roleId)
  local settings = table.copy(self.roles_settings[roleId])
  local reqData = {
    role_id = roleId,
    settings = settings,
    is_reset = 1
  }
  LogInfo("ApartmentConditionProxy", "SaveSettingByRoleId")
  table.print(reqData)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SETTING_ROLE_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_setting_role_req, reqData))
end
function ApartmentConditionProxy:SaveCustomDataResult(result)
  local resultInfo = DeCode(Pb_ncmd_cs_lobby.salon_setting_role_res, result)
  if 0 == resultInfo.code then
    LogInfo("ApartmentConditionProxy", "SaveCustomDataResult  success")
  else
    LogInfo("ApartmentConditionProxy", "SaveCustomDataResult faileure" .. tostring(resultInfo.code))
  end
end
function ApartmentConditionProxy:OnRcvRolesPropertiesList(ServerData)
  if self.roles_settings and next(self.roles_settings) ~= nil then
    return
  end
  local RolesProperties = DeCode(Pb_ncmd_cs_lobby.salon_roles_ntf, ServerData) or {}
  LogInfo("ApartmentConditionProxy", "OnRcvRolesPropertiesList")
  self.roles_settings = {}
  if RolesProperties.roles then
    for key, value in pairs(RolesProperties.roles) do
      if value.role_id then
        self.roles_settings[value.role_id] = value.settings or {}
      end
    end
  end
  LogInfo("ApartmentConditionProxy", "OnRcvRolesPropertiesList")
end
function ApartmentConditionProxy:GetRoleSettings()
  return self.roles_settings or {}
end
function ApartmentConditionProxy:GetValueByRoleIDAndKey(roleid, key)
  if self.roles_settings and self.roles_settings[roleid] then
    local role_setting = self.roles_settings[roleid]
    for k, v in pairs(role_setting) do
      if v.key == key then
        return v.value
      end
    end
  else
    LogInfo("ApartmentConditionProxy:GetValueByRoleIDAndKey", "roles_setting is nil" .. " roleid is " .. tostring(roleid))
  end
end
function ApartmentConditionProxy:OnNtfSettleBattle(data)
  local battle_data = pb.decode(Pb_ncmd_cs_lobby.settle_battle_game_ntf, data)
  LogInfo("ApartmentConditionProxy", "OnNtfSettleBattle")
  table.print(battle_data)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  local myID = friendDataProxy:GetPlayerID()
  local res = UE4.ECyBattleResultType.None
  LogInfo("ApartmentConditionProxy", "myID" .. tostring(myID))
  for i, v in ipairs(battle_data.players) do
    if v.player_id == myID then
      if v.win == Pb_ncmd_cs.EWinType.WinType_DRAW then
        res = UE4.ECyBattleResultType.WIN
        break
      end
      if v.win == Pb_ncmd_cs.EWinType.WinType_WIN then
        if v.mvp then
          res = UE4.ECyBattleResultType.MVP
          break
        end
        res = UE4.ECyBattleResultType.WIN
        break
      end
      if v.win == Pb_ncmd_cs.EWinType.WinType_LOSE then
        if v.mvp then
          res = UE4.ECyBattleResultType.SVP
          break
        end
        res = UE4.ECyBattleResultType.LOSE
        break
      end
      LogInfo("ApartmentConditionProxy OnNtfSettleBattle", "win is unknown" .. tostring(v.win))
      break
    end
  end
  LogInfo("ApartmentConditionProxy", "res" .. tostring(res))
  self.newResultFlag = res
end
function ApartmentConditionProxy:GetCombatComfortCondResult()
  local result = self:GetBattleResult()
  return result
end
function ApartmentConditionProxy:GetBattleResult()
  return self.newResultFlag
end
function ApartmentConditionProxy:UpdateEpicCondition(skinServarData)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  for key, value in pairs(skinServarData.change_list) do
    if value.role_skin_id then
      local skin = RoleProxy:GetRoleSkin(value.role_skin_id)
      if skin and skin.Quality == UE4.ECyItemQualityType.Red then
        self.newEpicSkinFlag = true
      end
    end
  end
end
function ApartmentConditionProxy:GetEpicSkinFlag()
  return self.newEpicSkinFlag
end
function ApartmentConditionProxy:SetEpicSkinFlag(SkinFlag)
  self.newEpicSkinFlag = SkinFlag
end
return ApartmentConditionProxy
