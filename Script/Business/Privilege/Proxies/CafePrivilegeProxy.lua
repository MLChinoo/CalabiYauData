local CafePrivilegeProxy = class("CafePrivilegeProxy", PureMVC.Proxy)
function CafePrivilegeProxy:OnRegister()
  self.cafePrivilegeType = 0
  self.internetBarTypeTableRows = {}
  self.cafePrivilegeCfg = {}
  local rows = ConfigMgr:GetCafePrivilegeTypeTableRow()
  if rows then
    local luaTable = rows:ToLuaTable()
    for key, value in pairs(luaTable) do
      if value then
        self.internetBarTypeTableRows[value.Type] = value
      end
    end
  end
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CAFE_PRIVILEGE_CFG_NTF, FuncSlot(self.OnNtfCafePrivilegeCfg, self))
  end
end
function CafePrivilegeProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CAFE_PRIVILEGE_CFG_NTF, FuncSlot(self.OnNtfCafePrivilegeCfg, self))
  end
end
function CafePrivilegeProxy:GetCafePrivilegeTypeRow(type)
  return self.internetBarTypeTableRows[type]
end
function CafePrivilegeProxy:GetInternetBarInfo(type)
  local row = self:GetCafePrivilegeTypeRow(type)
  if row then
    return row.Desc
  end
end
function CafePrivilegeProxy:IsCafeItem(itemID)
  return self.cafePrivilegeCfg[itemID] ~= nil
end
function CafePrivilegeProxy:UpdateCafePrivilegeData(itemData)
  if not itemData.bUnlock then
    local isPrivilege = self:IsCafeItem(itemData.InItemID)
    if isPrivilege then
      local privilegeData = {}
      privilegeData.PrivilegeType = UE4.ECyPrivilegeType.QQCafe
      itemData.privilegeData = privilegeData
    end
  end
end
function CafePrivilegeProxy:GetPrivilegeEquipBtnName()
  local row = self:GetCafePrivilegeTypeRow(self:GetCafePrivilegeType())
  if row then
    return row.PrivilegedName .. "-" .. ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
  end
  return ""
end
function CafePrivilegeProxy:GetPrivilegeExpAddDesc()
  local row = self:GetCafePrivilegeTypeRow(self:GetCafePrivilegeType())
  if row then
    return row.ExpAddDesc
  end
  return ""
end
function CafePrivilegeProxy:GetCurrentInternetBarInfo()
  local info = self:GetInternetBarInfo(self:GetCafePrivilegeType())
  return info
end
function CafePrivilegeProxy:GetCafePrivilegeType()
  return self.cafePrivilegeType
end
function CafePrivilegeProxy:SetCafePrivilegeType(inCafePrivilegeType)
  self.cafePrivilegeType = inCafePrivilegeType
end
function CafePrivilegeProxy:OnNtfCafePrivilegeCfg(data)
  local ServerData = DeCode(Pb_ncmd_cs_lobby.cafe_privilege_cfg_ntf, data)
  if nil == ServerData then
    LogError("OnNtfCafePrivilegeCfg", "ServerData is nil")
    return
  end
  self:SetCafePrivilegeType(ServerData.cafe_privilege)
  self:UpdateCafePrivilegeCfg(ServerData.items)
  GameFacade:SendNotification(NotificationDefines.OnNtfCafePrivilegeCfg)
end
function CafePrivilegeProxy:UpdateCafePrivilegeCfg(items)
  for key, value in pairs(items) do
    self.cafePrivilegeCfg[value] = value
  end
end
return CafePrivilegeProxy
