local RechargeBateProxy = class("RechargeBateProxy", PureMVC.Proxy)
function RechargeBateProxy:ctor(proxyName, data)
  RechargeBateProxy.super.ctor(self, proxyName, data)
end
function RechargeBateProxy:OnRegister()
  RechargeBateProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_DATA_RES, FuncSlot(self.OnResRechargeData, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_TAKE_RES, FuncSlot(self.OnResRechargeTake, self))
end
function RechargeBateProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_DATA_RES, FuncSlot(self.OnResRechargeData, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_TAKE_RES, FuncSlot(self.OnResRechargeTake, self))
end
function RechargeBateProxy:OnResRechargeData(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.beta_recharge_rebate_data_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, resultInfo.code)
  else
    self.ChargeNum = Data.recharge_amount
    self.RebateNum = Data.rebate_amount
    if Data.has_take then
      GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(10011, 0)
    end
    GameFacade:SendNotification(NotificationDefines.ActivitiesRechargeBateUpdateDataCmd, Data)
  end
end
function RechargeBateProxy:OnResRechargeTake(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.beta_recharge_rebate_take_res, ServerData)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.PendingPage)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
  else
    GameFacade:SendNotification(NotificationDefines.ActivitiesReBateTakeSuccess)
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(10011, 0)
  end
end
function RechargeBateProxy:ReqReChargeData()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.beta_recharge_rebate_data_req, {}))
end
function RechargeBateProxy:ReqReChargeTake()
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PendingPage, nil, {Time = 5})
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BETA_RECHARGE_REBATE_TAKE_REQ, pb.encode(Pb_ncmd_cs_lobby.beta_recharge_rebate_take_req, {}))
end
function RechargeBateProxy:GetNum()
  return self.ChargeNum, self.RebateNum
end
return RechargeBateProxy
