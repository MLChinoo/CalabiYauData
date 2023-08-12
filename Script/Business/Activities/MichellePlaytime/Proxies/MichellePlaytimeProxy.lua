local MichellePlaytimeProxy = class("MichellePlaytimeProxy", PureMVC.Proxy)
MichellePlaytimeProxy.ActivityStayTypeEnum = {
  EntryMainPage = 1,
  EntryTaskPage = 2,
  EntryRewardPreviewPage = 3,
  EntryRewardExchangePage = 4,
  EntryRewardRulesPage = 5
}
function MichellePlaytimeProxy:OnRegister()
  MichellePlaytimeProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  self:SetIsFirstPlayVoice(false)
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MP_GET_DATA_RES, FuncSlot(self.OnResGetMichellePlaytimeData, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MP_UNLOCK_REWARD_RES, FuncSlot(self.OnResUnlockReward, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_MP_EXCHANGE_REWARD_RES, FuncSlot(self.OnResExchangeReward, self))
  self.activityId = 10010
end
function MichellePlaytimeProxy:OnRemove()
  MichellePlaytimeProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MP_GET_DATA_RES, FuncSlot(self.OnResGetMichellePlaytimeData, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MP_UNLOCK_REWARD_RES, FuncSlot(self.OnResUnlockReward, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_MP_EXCHANGE_REWARD_RES, FuncSlot(self.OnResExchangeReward, self))
  end
end
function MichellePlaytimeProxy:ReqGetMichellePlaytimeData()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MP_GET_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.mp_get_data_req, {
    activity_id = self.activityId
  }))
end
function MichellePlaytimeProxy:OnResGetMichellePlaytimeData(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.mp_get_data_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  if netData.mp_cfg then
    self:SetActivityConfigData(netData.mp_cfg)
  end
  if netData.unlock_cfg then
    self:SetActivityUnLockConfigData(netData.unlock_cfg)
  end
  if netData.unlock_grids then
    self:SetActivityUnLockDatas(netData.unlock_grids)
  end
  if netData.gain_items then
    self:SetActivityGainRewardData(netData.gain_items)
  end
  GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.UpdateMichellePlaytimeData)
end
function MichellePlaytimeProxy:ReqUnlockReward(activityId, gridId)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MP_UNLOCK_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.mp_unlock_reward_req, {activity_id = activityId, grid = gridId}))
end
function MichellePlaytimeProxy:OnResUnlockReward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.mp_unlock_reward_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  if netData.grid then
    table.insert(self.activityUnLockDatas, netData.grid)
    GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.UpdateUnlockReward, netData.grid)
  end
  if netData.gain_items then
    self:SetActivityGainRewardData(netData.gain_items)
  end
  GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum)
end
function MichellePlaytimeProxy:ReqExchangeReward(activityId, times)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_MP_EXCHANGE_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.mp_exchange_reward_req, {activity_id = activityId, cnt = times}))
end
function MichellePlaytimeProxy:OnResExchangeReward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.mp_exchange_reward_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  if netData.gain_items then
    self:SetActivityGainRewardData(netData.gain_items)
  end
  GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum)
end
function MichellePlaytimeProxy:GetConsumeId()
  return self.consumeId
end
function MichellePlaytimeProxy:GetConsumeNumWhileExchange()
  return self.exchangeNum
end
function MichellePlaytimeProxy:GetRedeemRewardId()
  return self.redeemRewardId
end
function MichellePlaytimeProxy:GetRedeemRewardNum()
  return self.redeemRewardNum
end
function MichellePlaytimeProxy:SetActivityConfigData(data)
  self.activityConfigData = data
  self.consumeId = data.consume_id
  self.unLockNum = data.unlock_num
  self.exchangeNum = data.exchange_num
  if data.items then
    for key, value in pairs(data.items) do
      self.redeemRewardId = value.item_id
      self.redeemRewardNum = value.item_cnt
      break
    end
  end
end
function MichellePlaytimeProxy:GetActivityConfigData()
  return self.activityConfigData
end
function MichellePlaytimeProxy:SetActivityUnLockConfigData(data)
  self.activityUnLockConfigData = data
end
function MichellePlaytimeProxy:GetActivityUnLockConfigData()
  return self.activityUnLockConfigData
end
function MichellePlaytimeProxy:GetActivityUnLockConfigDataNum()
  if self.activityUnLockConfigData then
    return #self.activityUnLockConfigData
  end
  return 0
end
function MichellePlaytimeProxy:SetActivityUnLockDatas(data)
  self.activityUnLockDatas = data
end
function MichellePlaytimeProxy:GetActivityUnLockDatas()
  return self.activityUnLockDatas
end
function MichellePlaytimeProxy:GetCurrentRewardPhase()
  if self.activityUnLockDatas then
    return #self.activityUnLockDatas + 1
  end
  return 0
end
function MichellePlaytimeProxy:GetMaxRewardPhase()
  if self.activityUnLockConfigData then
    return #self.activityUnLockConfigData
  end
  return 0
end
function MichellePlaytimeProxy:SetActivityGainRewardData(data)
  self.activityGainRewardData = data
end
function MichellePlaytimeProxy:GetActivityGainRewardData()
  return self.activityGainRewardData
end
function MichellePlaytimeProxy:GetGamePointCnt()
  local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  if self.consumeId and 0 ~= self.consumeId then
    return warehouseProxy:GetItemCnt(self.consumeId)
  end
  return 0
end
function MichellePlaytimeProxy:SetIsFirstPlayVoice(bFirst)
  self.bFirstPlayVoice = bFirst
end
function MichellePlaytimeProxy:GetIsFirstPlayVoice()
  return self.bFirstPlayVoice
end
function MichellePlaytimeProxy:HandleCommonData()
  local commonData = UE4.FActivityMxrgameplayData()
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):GetMxrgameplayData(commonData)
  return commonData
end
function MichellePlaytimeProxy:SendTLOG(data)
  LogDebug("MichellePlaytimeProxy", "Data is :")
  table.print(data)
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):SendTLogData(data, false)
end
function MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, staytime)
  local commonData = self:HandleCommonData()
  if commonData then
    commonData.Activitystaytype = staytype
    commonData.Activitystaytime = staytime
  end
  local str = UE4.UPMCliTLogApi.Make_ActivityMxrgameplay_Data(commonData)
  self:SendTLOG(str)
end
function MichellePlaytimeProxy:GetRemainingTimeStrFromTimeStamp(timeStamp)
  local str = ""
  if timeStamp <= 0 then
    return str
  end
  local day = math.floor(timeStamp / 86400)
  local hour = math.floor(timeStamp % 86400 / 3600)
  local minute = math.floor(timeStamp % 86400 % 3600 / 60)
  local seconds = math.floor(timeStamp % 86400 % 3600 % 60)
  local hourStr = tostring(day * 24 + hour)
  local minuteStr = tostring(minute)
  local secondsStr = tostring(seconds)
  str = hourStr .. tostring(":") .. minuteStr .. tostring(":") .. secondsStr
  return str
end
function MichellePlaytimeProxy:SetShowRedDot(bShow)
  if bShow then
    self.bShowRedRot = true
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, 1)
  else
    self.bShowRedRot = false
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, 0)
  end
end
function MichellePlaytimeProxy:HasTaskRewardPendingReceive()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local activityTasks = BattlePassProxy:GetActivityTasks()
  if activityTasks then
    local taskItemList = self:GetMPTaskIdList()
    for key1, value1 in pairs(taskItemList) do
      for key, value in pairs(activityTasks) do
        if value.taskId == value1 and value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
          return true
        end
      end
    end
  else
    LogInfo("HasTaskRewardPendingReceive:", "activityTasks is nil")
  end
  return false
end
function MichellePlaytimeProxy:CheckRedDotShow()
  local taskIdList = self:GetMPTaskIdList()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local activityTasks = BattlePassProxy:GetActivityTasks()
  if activityTasks then
    for k, taskIdItem in pairs(taskIdList) do
      for key, value in pairs(activityTasks) do
        if value and value.taskId == taskIdItem then
          if value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
            self:SetShowRedDot(true)
            return
          end
          break
        end
      end
    end
  else
    LogInfo("CheckRedDotShow:", "activityTasks is nil")
  end
end
function MichellePlaytimeProxy:GetActivityId()
  if self.activityId then
    return self.activityId
  end
  LogInfo("MichellePlaytimeProxy GetActivityId:", "activityId is nil")
  return nil
end
function MichellePlaytimeProxy:GetMPTaskIdList()
  local taskIdList = {}
  local arrRows = ConfigMgr:GetActivityTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData.ActivityId and rowData.ActivityId == self.activityId and rowData.Id then
        table.insert(taskIdList, rowData.Id)
      end
    end
  end
  if taskIdList and #taskIdList > 0 then
    return taskIdList
  end
  LogInfo("GetMPTaskIdList:", "taskIdList is nil")
  return nil
end
return MichellePlaytimeProxy
