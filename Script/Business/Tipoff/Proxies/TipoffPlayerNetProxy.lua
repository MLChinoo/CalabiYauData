local TipoffPlayerNetProxy = class("TipoffPlayerNetProxy", PureMVC.Proxy)
function TipoffPlayerNetProxy:OnRegister()
  TipoffPlayerNetProxy.super.OnRegister(self)
  LogDebug("TipoffPlayerNetProxy", "OnRegister")
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REPORT_FEEDBACK_RES, FuncSlot(self.OnNetReportfRes, self))
  end
end
function TipoffPlayerNetProxy:OnRemove()
  LogDebug("TipoffPlayerNetProxy", "OnRemove")
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REPORT_FEEDBACK_RES, FuncSlot(self.OnNetReportfRes, self))
  end
  TipoffPlayerNetProxy.super.OnRemove(self)
end
function TipoffPlayerNetProxy:OnNetTipoffReq()
  LogDebug("TipoffPlayerNetProxy", "OnNetTipoffReq Start.")
  local TipoffReqParam
  local TipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProxy then
    local CurTipoffData = TipoffPlayerDataProxy:GetCurTipoffData()
    if not CurTipoffData then
      return
    end
    TipoffReqParam = {
      target_id = CurTipoffData.TargetUID,
      report_category = CurTipoffData.CurCategoryType,
      report_reason = CurTipoffData.CurReasonTypes,
      report_scene = CurTipoffData.CurSceneType,
      report_desc = CurTipoffData.CurDesc,
      report_content = CurTipoffData.CurContent
    }
    if nil ~= TipoffReqParam and CurTipoffData.RoomID > 0 then
      TipoffReqParam.report_battle_id = tostring(CurTipoffData.RoomID)
      TipoffReqParam.report_battle_time = CurTipoffData.BattleTime
    end
  end
  if not TipoffReqParam then
    return
  end
  LogDebug("TipoffPlayerNetProxy", "============================= Net Req")
  LogDebug("TipoffPlayerNetProxy", TableToString(TipoffReqParam))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_REPORT_FEEDBACK_REQ, pb.encode(Pb_ncmd_cs_lobby.report_feedback_req, TipoffReqParam))
  ShowCommonTip(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_Success"))
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.CloseTipOffPlayerPage)
end
function TipoffPlayerNetProxy:OnNetReportfRes(Data)
  LogDebug("TipoffPlayerNetProxy", "======================= OnNetReportfRes")
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.ResTipoffPlayerInfo)
end
return TipoffPlayerNetProxy
