local FunctionOpenProxy = class("FunctionOpenProxy", PureMVC.Proxy)
local FunctionOpenEnum = require("Business/Common/Proxies/FunctionOpenEnum")
local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
function FunctionOpenProxy:OnRegister()
  FunctionOpenProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FUNCTION_OPEN_LIST_NTF, FuncSlot(self.OnOpenListNtf, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_FUNCTION_OPEN_LIST_RES, FuncSlot(self.OnOpenListRes, self))
  end
  self.FunctionOpenData = {}
end
function FunctionOpenProxy:OnRemove()
  FunctionOpenProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FUNCTION_OPEN_LIST_NTF, FuncSlot(self.OnOpenListNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_FUNCTION_OPEN_LIST_RES, FuncSlot(self.OnOpenListRes, self))
  end
  self.FunctionOpenData = {}
end
function FunctionOpenProxy:ReqOpenList(funcid)
  local data = {func_id = funcid}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_FUNCTION_OPEN_LIST_REQ, pb.encode(Pb_ncmd_cs_lobby.function_open_list_req, data))
end
function FunctionOpenProxy:OnOpenListRes(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.function_open_list_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
    return
  end
end
function FunctionOpenProxy:OnOpenListNtf(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.function_open_list_ntf, ServerData)
  print("OnOpenListNtf >>>>")
  table.print(Data)
  local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
  self.FunctionOpenData = {}
  for k, v in pairs(Data.func_list) do
    if v.func_id then
      self.FunctionOpenData[v.func_id] = v
      if v.func_id == FunctionOpenEnum.FlapFace then
        FlapFaceProxy:SetConfig(v, FlapFaceEnum.FlapFace)
      elseif v.func_id == FunctionOpenEnum.MonthlyCard then
        FlapFaceProxy:SetConfig(v, FlapFaceEnum.MonthlyCard)
      end
    end
  end
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  midasSys:SetEnablePay(self:GetFunctionOpenByType(FunctionOpenEnum.MidasPay))
end
function FunctionOpenProxy:GetFunctionOpenByType(type)
  for k, v in pairs(self.FunctionOpenData) do
    if k == type and 0 == v.open_type then
      return false
    elseif k == type and 1 == v.open_type then
      local currentTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
      if currentTime > v.end_time or currentTime < v.start_time then
        return false
      else
        return true
      end
    elseif k == type and 2 == v.open_type then
      return true
    end
  end
  return false
end
return FunctionOpenProxy
