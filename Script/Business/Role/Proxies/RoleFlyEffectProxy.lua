local RoleFlyEffectProxy = class("RoleFlyEffectProxy", PureMVC.Proxy)
local roleFlyingRowTableCfg = {}
local ownFlyEffectMap = {}
local currentEquipFlyEffect = {}
function RoleFlyEffectProxy:ctor(proxyName, data)
  RoleFlyEffectProxy.super.ctor(self, proxyName, data)
end
function RoleFlyEffectProxy:OnRegister()
  RoleFlyEffectProxy.super.OnRegister(self)
  roleFlyingRowTableCfg = {}
  ownFlyEffectMap = {}
  currentEquipFlyEffect = {}
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_EQUIP_FLUTTERING_RES, FuncSlot(self.OnResEquipFlyEffect, self))
  end
end
function RoleFlyEffectProxy:InitTableCfg()
  local arrRows = ConfigMgr:GetRoleFxFlyingTableRows()
  if arrRows then
    roleFlyingRowTableCfg = arrRows:ToLuaTable()
  end
end
function RoleFlyEffectProxy:UpdateOwnFlyEffect(data)
  for key, value in pairs(data or {}) do
    if value then
      ownFlyEffectMap[value.item_id] = value
    end
  end
end
function RoleFlyEffectProxy:UpdateCurrentEquipFlyEffect(flyEffectUUID)
  if 0 ~= flyEffectUUID then
    currentEquipFlyEffect.flyEffectUUID = flyEffectUUID
  end
end
function RoleFlyEffectProxy:ReqEquipFlyEffect(flyEffectID)
  local data = {}
  data.fluttering_uuid = self:GetFlyEffectUUID(flyEffectID)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_EQUIP_FLUTTERING_REQ, pb.encode(Pb_ncmd_cs_lobby.equip_fluttering_req, data))
end
function RoleFlyEffectProxy:OnResEquipFlyEffect(data)
  local flyEffectData = DeCode(Pb_ncmd_cs_lobby.equip_fluttering_res, data)
  local flyEffectID = self:GetFlyEffectID(flyEffectData.fluttering_uuid)
  self:UpdateCurrentEquipFlyEffect(flyEffectData.fluttering_uuid)
  GameFacade:SendNotification(NotificationDefines.OnResEquipFlyEffect, flyEffectID)
end
function RoleFlyEffectProxy:GetAllFlyEffectRowTableCfg()
  return roleFlyingRowTableCfg
end
function RoleFlyEffectProxy:GetFlyEffectRowTableCfg(flyEffectID)
  return roleFlyingRowTableCfg[tostring(flyEffectID)]
end
function RoleFlyEffectProxy:IsUnlockFlyEffect(flyEffectID)
  return ownFlyEffectMap[tonumber(flyEffectID)] ~= nil
end
function RoleFlyEffectProxy:IsEquipFlyEffect(flyEffectID)
  if nil == currentEquipFlyEffect or nil == currentEquipFlyEffect.flyEffectUUID then
    return false
  end
  local flyEffectUUID = self:GetFlyEffectUUID(flyEffectID)
  return currentEquipFlyEffect.flyEffectUUID == flyEffectUUID
end
function RoleFlyEffectProxy:GetFlyEffectID(flyEffectUUID)
  for key, value in pairs(ownFlyEffectMap) do
    if flyEffectUUID == value.item_uuid then
      return value.item_id
    end
  end
  return nil
end
function RoleFlyEffectProxy:GetFlyEffectUUID(flyEffectID)
  local data = ownFlyEffectMap[flyEffectID]
  if data then
    return data.item_uuid
  end
  return nil
end
function RoleFlyEffectProxy:InitRedDot()
  LogDebug("RoleFlyEffectProxy:InitRedDot", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_FLUTTERING)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddRedDot(value)
      end
    end
  end
end
function RoleFlyEffectProxy:AddRedDot(redDotInfo)
  if redDotInfo then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomFlyEffect, 1)
  end
end
return RoleFlyEffectProxy
