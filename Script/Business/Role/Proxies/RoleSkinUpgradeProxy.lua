local RoleSkinUpgradeProxy = class("RoleSkinUpgradeProxy", PureMVC.Proxy)
function RoleSkinUpgradeProxy:OnRegister()
  RoleSkinUpgradeProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_SELECT_FLUTTER_RES, FuncSlot(self.OnRoleSelectFlutterRes, self))
  end
end
function RoleSkinUpgradeProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_SELECT_FLUTTER_RES, FuncSlot(self.OnRoleSelectFlutterRes, self))
  end
end
function RoleSkinUpgradeProxy:GetAdvadceSkinIDList(skinID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleSkinRow = rolePorxy:GetRoleSkin(skinID)
  if nil == roleSkinRow then
    LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkinRow is nil , skin ID: " .. tostring(skinID))
    return
  end
  if roleSkinRow.UpdateType ~= UE4.ECyCharacterSkinUpgradeType.Basics then
    LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkin is not up, ECyCharacterSkinUpgradeType is : " .. tostring(roleSkinRow.UpdateType))
    return
  end
  local skinIDArray = {}
  local num = roleSkinRow.UpdateSkinId:Length()
  for index = 1, num do
    local id = roleSkinRow.UpdateSkinId:Get(index)
    local row = rolePorxy:GetRoleSkin(id)
    if row then
      if row.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
        table.insert(skinIDArray, id)
      else
        LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkin is cofing Error, skin id is : " .. tostring(id) .. "ECyCharacterSkinUpgradeType is :" .. tostring(row.UpdateType))
      end
    end
  end
  return skinIDArray
end
function RoleSkinUpgradeProxy:GetAdvadceSkinListByRow(roleSkinRow)
  local skinArray = {}
  if nil == roleSkinRow then
    LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkinRow is nil")
    return skinArray
  end
  if roleSkinRow.UpdateType ~= UE4.ECyCharacterSkinUpgradeType.Basics then
    LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkin is not up, ECyCharacterSkinUpgradeType is : " .. tostring(roleSkinRow.UpdateType))
    return skinArray
  end
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local num = roleSkinRow.UpdateSkinId:Length()
  for index = 1, num do
    local id = roleSkinRow.UpdateSkinId:Get(index)
    local row = rolePorxy:GetRoleSkin(id)
    if row then
      if row.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
        local itemData = {}
        itemData.InItemID = row.RoleSkinId
        itemData.bEquip = rolePorxy:IsEquipRoleSkin(row.RoleId, row.RoleSkinId) and rolePorxy:IsEquipRoleSkin(roleSkinRow.RoleId, roleSkinRow.RoleSkinId)
        itemData.bUnlock = rolePorxy:IsUnlockRoleSkin(row.RoleSkinId)
        itemData.softTexture = row.IconItem
        table.insert(skinArray, itemData)
      else
        LogError("RoleSkinUpgradeProxy:GetAdvadceSkinList", "roleSkin is cofing Error, skin id is : " .. tostring(id) .. "ECyCharacterSkinUpgradeType is :" .. tostring(row.UpdateType))
      end
    end
  end
  return skinArray
end
function RoleSkinUpgradeProxy:GetSkinItemData(skinRow)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local data = {}
  data.InItemID = skinRow.RoleSkinId
  if skinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics then
    if self:IsEquipAdvancedSkin(skinRow.RoleSkinId) == false then
      data.bEquip = rolePorxy:IsEquipRoleSkin(skinRow.RoleId, skinRow.RoleSkinId)
    else
      data.bEquip = false
    end
  else
    data.bEquip = rolePorxy:IsEquipRoleSkin(skinRow.RoleId, skinRow.RoleSkinId)
  end
  data.bUnlock = rolePorxy:IsUnlockRoleSkin(skinRow.RoleSkinId)
  data.softTexture = skinRow.IconItem
  return data
end
function RoleSkinUpgradeProxy:GetFlyEffectItemData(skinRow)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local data = {}
  data.InItemID = skinRow.FxflyingId
  data.bEquip = self:IsEquipFlyEffect(skinRow.RoleSkinId, skinRow.FxflyingId)
  data.bUnlock = roleFlyEffectProxy:IsUnlockFlyEffect(skinRow.FxflyingId)
  return data
end
function RoleSkinUpgradeProxy:GetUpSkinItemData(skinRow)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local data = {}
  data.InItemID = skinRow.RoleSkinId
  data.bEquip = self:IsEquipAdvancedSkin(skinRow.RoleSkinId) and rolePorxy:IsEquipRoleSkin(skinRow.RoleId, skinRow.RoleSkinId)
  data.bUnlock = self:IsUnlockAdvancedSkin(skinRow.RoleSkinId)
  return data
end
function RoleSkinUpgradeProxy:ReqRoleSelectFlutterSkin(skinID, flutterID)
  local data = {skin_id = skinID, flutter_id = flutterID}
  LogDebug("RoleSkinUpgradeProxy:ReqRoleSelectFlutterSkin", "data is :" .. TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_SELECT_FLUTTER_REQ, pb.encode(Pb_ncmd_cs_lobby.role_select_flutter_req, data))
end
function RoleSkinUpgradeProxy:OnRoleSelectFlutterRes(data)
  local servarData = DeCode(Pb_ncmd_cs_lobby.role_select_flutter_res, data)
  if nil == servarData then
    return
  end
  if 0 ~= servarData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, servarData.code)
    return
  end
  LogDebug("RoleSkinUpgradeProxy:OnRoleSelectFlutterRes", "data is :" .. TableToString(servarData))
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  rolePorxy:UpdateSeverAdvancedSkinFlyEffect(servarData.skin_id, servarData.flutter_id)
  GameFacade:SendNotification(NotificationDefines.OnResRoleSkinSelect, servarData)
end
function RoleSkinUpgradeProxy:IsEquipFlyEffect(roleSKinID, flutterID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local servarData = rolePorxy:GetSeverSkinInfo(roleSKinID)
  if servarData then
    return servarData.flutter_id == flutterID
  end
  return false
end
function RoleSkinUpgradeProxy:IsEquipAdvancedSkin(baseSkinID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local servarData = rolePorxy:GetSeverSkinInfo(baseSkinID)
  if servarData then
    return 0 ~= servarData.advanced_skin_id
  end
  return false
end
function RoleSkinUpgradeProxy:IsUnlockAdvancedSkin(baseSkinID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local servarData = rolePorxy:GetSeverSkinInfo(baseSkinID)
  if servarData then
    return 0 ~= table.count(servarData.advanced_skins)
  end
  return false
end
return RoleSkinUpgradeProxy
