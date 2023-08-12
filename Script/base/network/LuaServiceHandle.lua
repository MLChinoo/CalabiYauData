local LuaServiceHandle = Class()
local LogDebug = _G.LogDebug
local TAG_RESPONSE = 0
local TAG_NTY = 1
local TAG_REQUEST_RESPONSE = 2
function LuaServiceHandle:Initialize()
  LogDebug("LuaPb", "LuaServiceHandle:Initialize")
  self.cmdMap = {}
  SetLobbyServiceHandle(self)
end
function LuaServiceHandle:OnLuaReceiveSessionCmd(cmdid)
  if g_received_pb then
    LogDebug("LuaPb", "receive pb data len %d, cmdid = %d", #g_received_pb, cmdid)
    if self.cmdMap[cmdid] then
      local arr = self.cmdMap[cmdid]
      for i = #arr, 1, -1 do
        local v = arr[i]
        local funcSlot = v[2]
        if v[1] == TAG_REQUEST_RESPONSE then
          table.remove(arr, i)
        end
        if funcSlot then
          funcSlot(g_received_pb)
        else
          LogError("LuaPb", "receive pb cmd id %d, but FunSlot is nil", cmdid)
        end
      end
    else
      LogError("LuaPb", "no func is liscening on %d ", cmdid)
    end
  end
end
function LuaServiceHandle:OnLuaSessionOpen(errorCode)
  LogDebug("LuaServer", "OnLuaSessionOpen " .. tostring(errorCode))
  GameFacade:SendNotification(NotificationDefines.GameServerConnect, errorCode)
end
function LuaServiceHandle:OnLuaSessionReOpen(errorCode)
  LogDebug("LuaServer", "OnLuaSessionReOpen " .. tostring(errorCode))
  GameFacade:SendNotification(NotificationDefines.GameServerReopen)
end
function LuaServiceHandle:OnLuaReconnectSuccess()
  LogDebug("LuaServer", "OnLuaReconnectSuccess")
  GameFacade:SendNotification(NotificationDefines.GameServerReconnect)
end
function LuaServiceHandle:OnLuaReconnectFailed()
  LogDebug("LuaServer", "OnLuaReconnectFailed")
end
function LuaServiceHandle:OnLuaSessionClose(errorCode)
  LogDebug("LuaServer", "OnLuaSessionClose " .. tostring(errorCode))
  GameFacade:SendNotification(NotificationDefines.GameServerDisconnect, errorCode)
end
function LuaServiceHandle:Send(cmdid, data)
  _G.g_send_pb = data
  self:SendLua(cmdid)
end
function LuaServiceHandle:SubscribeCmd(cmdid)
  self:RegistLuaCmd(cmdid)
end
function LuaServiceHandle:UnsubscribeCmd(cmdid)
  self:UnregistLuaCmd(cmdid)
end
function LuaServiceHandle:AddToCmdMap(cmdid, funcSlot, tag)
  if not self.cmdMap[cmdid] then
    self.cmdMap[cmdid] = {}
    self:SubscribeCmd(cmdid)
  end
  local cmdFuncSlots = self.cmdMap[cmdid]
  for _, v in ipairs(cmdFuncSlots) do
    if v[2] == funcSlot then
      LogError("LuaPb", "func slot have added to cmd map")
      return
    end
  end
  LogInfo("LuaPb", "Add lua cmd regiest %d", cmdid)
  table.insert(cmdFuncSlots, {tag, funcSlot})
end
function LuaServiceHandle:RemoveFromCmdMap(cmdid, funcSlot)
  if not self.cmdMap[cmdid] then
    LogError("LuaPb", "func slot for [%d] have not added to cmd map", cmdid)
    return
  end
  local cmdFuncSlots = self.cmdMap[cmdid]
  local count = #cmdFuncSlots
  for pos = count, 1, -1 do
    if cmdFuncSlots[pos][2] == funcSlot then
      table.remove(cmdFuncSlots, pos)
    end
  end
  if 0 == #cmdFuncSlots then
    self.cmdMap[cmdid] = nil
    self:UnsubscribeCmd(cmdid)
  end
end
function LuaServiceHandle:RegistNty(cmdid, funcSlot)
  self:AddToCmdMap(cmdid, funcSlot, TAG_NTY)
end
function LuaServiceHandle:RegistResponse(cmdid, funcSlot)
  self:AddToCmdMap(cmdid, funcSlot, TAG_RESPONSE)
end
function LuaServiceHandle:UnregistNty(cmdid, funcSlot)
  self:RemoveFromCmdMap(cmdid, funcSlot)
end
_G.ProtocolFlag = {}
_G.ProtocolFlag.Default = UE4.EProtocolFlag.Default
_G.ProtocolFlag.CheckConnection = UE4.CheckConnection
_G.ProtocolFlag.NeedExplicitReconnect = UE4.EProtocolFlag.NeedExplicitReconnect
function LuaServiceHandle:SendRequest(cmdid, requestData, responseCmdid, responseFuncslot, flag)
  if not GameUtil:IsBuildShipingOrTest() then
    LogDebug("LuaServiceHandle", "sendPb [cmd_id %d]{%s}", cmdid, TableToString(requestData))
  end
  if responseCmdid and responseFuncslot then
    self:AddToCmdMap(responseCmdid, responseFuncslot, TAG_REQUEST_RESPONSE)
  end
  flag = flag or _G.ProtocolFlag.Default
  _G.g_send_pb = requestData
  self:SendLua(cmdid, flag)
end
return LuaServiceHandle
