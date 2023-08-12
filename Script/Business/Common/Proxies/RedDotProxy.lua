local RedDotProxy = class("RedDotProxy", PureMVC.Proxy)
local redDotQualitySetting
local redDotMap = {}
function RedDotProxy:OnRegister()
  RedDotProxy.super.OnRegister(self)
  redDotMap = {}
  redDotQualitySetting = nil
  self.bHasNtf = false
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REDDOT_READ_RES, FuncSlot(self.OnResRedDotRead, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REDDOT_ADD_RES, FuncSlot(self.OnResRedDotAdd, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REDDOT_ADD_NTF, FuncSlot(self.OnNtfRedDotAdd, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REDDOT_SYNC_NTF, FuncSlot(self.OnNtfRedDotSync, self))
  end
end
function RedDotProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REDDOT_READ_RES, FuncSlot(self.OnResRedDotRead, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REDDOT_ADD_RES, FuncSlot(self.OnResRedDotAdd, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REDDOT_ADD_NTF, FuncSlot(self.OnNtfRedDotAdd, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REDDOT_SYNC_NTF, FuncSlot(self.OnNtfRedDotSync, self))
  end
  RedDotProxy.super.OnRemove(self)
end
function RedDotProxy:Classify(redDotInfo)
  LogDebug("RedDotProxy", "New red dot info: " .. TableToString(redDotInfo))
  local redDotType = redDotInfo.reddot_type
  if nil == redDotMap[redDotType] then
    redDotMap[redDotType] = {}
  end
  local redDotQualitySetting = self:GetRedDotQualitySetting()
  if redDotQualitySetting then
    local itemId = 0 ~= redDotInfo.event_id and redDotInfo.event_id or redDotInfo.reddot_rid
    local itemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(itemId)
    if nil == itemQuality and tonumber(redDotInfo.custom) then
      itemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(tonumber(redDotInfo.custom))
    end
    if itemQuality and redDotQualitySetting <= itemQuality then
      redDotInfo.needPassUp = true
    else
      redDotInfo.needPassUp = false
    end
  end
  redDotMap[redDotType][redDotInfo.reddot_id] = redDotInfo
end
function RedDotProxy:OnResRedDotRead(data)
  local redDotReadRes = pb.decode(Pb_ncmd_cs_lobby.reddot_read_res, data)
  if 0 == redDotReadRes.code then
    LogDebug("RedDotProxy", "Read red dot succeed! ")
  end
end
function RedDotProxy:OnResRedDotAdd(data)
  local redDotAddRes = pb.decode(Pb_ncmd_cs_lobby.reddot_add_res, data)
  if 0 == redDotAddRes.code then
    LogDebug("RedDotProxy", "Add red dot succeed! ")
  else
    LogDebug("RedDotProxy", "Add red dot failed! ")
  end
end
function RedDotProxy:OnNtfRedDotAdd(data)
  LogDebug("RedDotProxy", "Ntf add red dot...")
  if self.bHasNtf == false then
    return
  end
  local redDotAddNtf = pb.decode(Pb_ncmd_cs_lobby.reddot_add_ntf, data)
  if redDotMap[redDotAddNtf.reddot.reddot_type] ~= nil and nil ~= redDotMap[redDotAddNtf.reddot.reddot_type][redDotAddNtf.reddot.reddot_id] and redDotMap[redDotAddNtf.reddot.reddot_type][redDotAddNtf.reddot.reddot_id].mark then
    return
  end
  self:Classify(redDotAddNtf.reddot)
  GameFacade:SendNotification(NotificationDefines.RedDot.NewRedDotCmd, redDotAddNtf.reddot, redDotAddNtf.reddot.reddot_type)
end
function RedDotProxy:OnNtfRedDotSync(data)
  LogDebug("RedDotProxy", "Ntf snyc red dot...")
  if self.bHasNtf then
    return
  end
  local redDotSyncNtf = pb.decode(Pb_ncmd_cs_lobby.reddot_sync_ntf, data)
  for _, value in pairs(redDotSyncNtf.reddots) do
    self:Classify(value)
  end
  self.bHasNtf = true
  GameFacade:SendNotification(NotificationDefines.RedDot.NtfRedDotSyncCmd)
end
function RedDotProxy:GetRedDots(redDotType)
  return redDotMap[redDotType]
end
function RedDotProxy:ReadRedDot(redDotId)
  LogDebug("RedDotProxy", "Read red dot: " .. redDotId or 0)
  for _, value in pairs(redDotMap) do
    if value[redDotId] then
      value[redDotId].mark = false
      break
    end
  end
  local data = {reddot_id = redDotId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_REDDOT_READ_REQ, pb.encode(Pb_ncmd_cs_lobby.reddot_read_req, data))
end
function RedDotProxy:AddRedDot(redDotType, redDotRId, overTime, custom)
  LogDebug("RedDotProxy", "Add red dot, rId: " .. redDotRId or 0)
  local data = {
    reddot_rid = redDotRId,
    reddot_type = redDotType,
    overtime = overTime or 0,
    custom = custom or ""
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_REDDOT_ADD_REQ, pb.encode(Pb_ncmd_cs_lobby.reddot_add_req, data))
end
function RedDotProxy:GetRedDotPass(redDotId)
  for _, value in pairs(redDotMap) do
    if value[redDotId] then
      return value[redDotId].needPassUp
    end
  end
  return false
end
function RedDotProxy:GetRedDotQualitySetting()
  if nil == redDotQualitySetting then
    redDotQualitySetting = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy):GetCurrentValueByKey("RedDotColor")
  end
  return redDotQualitySetting
end
return RedDotProxy
