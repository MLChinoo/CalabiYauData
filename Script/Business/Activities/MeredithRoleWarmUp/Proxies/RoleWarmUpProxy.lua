local RoleWarmUpProxy = class("RoleWarmUpProxy", PureMVC.Proxy)
RoleWarmUpProxy.ActivityStayTypeEnum = {
  EntryMainPage = 1,
  ClickCallRoleBtn = 2,
  EntryClewPage = 3,
  EntryRewardExchangePage = 4,
  EntryRewardRulesPage = 5,
  QuitMainPage = 6,
  ClickGetRoleBtn = 7,
  QuitClewPage = 8,
  QuitRewardExchangePage = 9,
  QuitRewardRulesPage = 10
}
function RoleWarmUpProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.OnResTakeTaskPrize, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_GET_DATA_RES, FuncSlot(self.OnResRoleWarmUpGetData, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_PHASE_RES, FuncSlot(self.OnResRoleWarmUpPhaseAward, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_ROLE_RES, FuncSlot(self.OnResRoleWarmUpRoleAward, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_EXCHANGE_RES, FuncSlot(self.OnResExchangeReward, self))
  self.activityId = 10012
end
function RoleWarmUpProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.OnResTakeTaskPrize, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_GET_DATA_RES, FuncSlot(self.OnResRoleWarmUpGetData, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_PHASE_RES, FuncSlot(self.OnResRoleWarmUpPhaseAward, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_ROLE_RES, FuncSlot(self.OnResRoleWarmUpRoleAward, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_EXCHANGE_RES, FuncSlot(self.OnResExchangeReward, self))
end
function RoleWarmUpProxy:ReqRoleWarmUpGetData(activity_id)
  local tb = {}
  tb.activity_id = activity_id
  local req = pb.encode(Pb_ncmd_cs_lobby.role_warm_up_get_data_req, tb)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_GET_DATA_REQ, req)
end
function RoleWarmUpProxy:OnResRoleWarmUpGetData(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.role_warm_up_get_data_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  self.redeemRewardTb = {}
  self.PhaseDes = {}
  self.PhaseDesPage = {}
  self.MilestonePhases = {}
  self.PhaseAwardTb = {}
  self.award_phase = {}
  self.exchangeNum = netData.activity_cfg.exchange_num
  self.FreedTime = netData.activity_cfg.start_time
  self.consume_id = netData.activity_cfg.consume_id
  self.role_id = netData.activity_cfg.role_id
  self.award_role = netData.award_role
  self.EnergySum = netData.activity_cfg.unlock_num
  for key, value in pairs(netData.activity_cfg.items) do
    table.insert(self.redeemRewardTb, {
      ItemId = value.item_id,
      ItemCount = value.item_cnt
    })
  end
  for key, value in pairs(netData.award_phase) do
    table.insert(self.award_phase, value)
  end
  for key, value in pairs(netData.phase_cfg) do
    table.insert(self.PhaseDes, value.phase_des)
    table.insert(self.MilestonePhases, value.milestone_phase)
    table.insert(self.PhaseDesPage, value.phase_despage)
    for k, v in pairs(value.items) do
      table.insert(self.PhaseAwardTb, {
        ItemId = v.item_id,
        ItemCount = v.item_cnt
      })
    end
  end
  local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if ActivitiesProxy then
    if self:HasAwardPhaseNotReceive() or self:HasTaskNotReceive() or self:HasConvertible() or self:HasRoleNotReceive() then
      ActivitiesProxy:SetRedNumByActivityID(self.activityId, 1)
    else
      ActivitiesProxy:SetRedNumByActivityID(self.activityId, 0)
    end
  end
  LogDebug("RoleWarmUpProxy", "OnResRoleWarmUpGetData")
  GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.UpdateRoleWarmUpData)
end
function RoleWarmUpProxy:HasAwardPhaseNotReceive()
  local PhaseIndex = self:GetPhaseIndex()
  for index = 1, 5 do
    if index < PhaseIndex and self:GetAwardPhaseIsTakeByID(index) == false then
      LogDebug("RoleWarmUpProxy", "GetAwardPhaseIsTakeByID == true")
      return true
    end
  end
  LogDebug("RoleWarmUpProxy", "GetAwardPhaseIsTakeByID == false")
  return false
end
function RoleWarmUpProxy:HasTaskNotReceive()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local TaskIdList = self:GetTaskIdList()
  if BattlePassProxy then
    local activityTasks = BattlePassProxy:GetActivityTasks()
    for k, v in pairs(TaskIdList) do
      for key, value in pairs(activityTasks) do
        if value and value.taskId == v and value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
          LogDebug("RoleWarmUpProxy", "HasTaskNotReceive == true")
          return true
        end
      end
    end
  end
  LogDebug("RoleWarmUpProxy", "HasTaskNotReceive == false")
  return false
end
function RoleWarmUpProxy:HasConvertible()
  if self:GetIsReceiveRole() and self:GetCurrentEnergy() / self:GetConsumeNumWhileExchange() >= 1 then
    LogDebug("RoleWarmUpProxy", "HasConvertible == true")
    return true
  end
  LogDebug("RoleWarmUpProxy", "HasConvertible == false")
  return false
end
function RoleWarmUpProxy:HasRoleNotReceive()
  local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  if not NoticeSubSys or self:GetIsReceiveRole() then
  else
    local IsEnergyComplete = self:GetIsEnergyComplete()
    local IsCallRole = NoticeSubSys:GetIsTouchByName("CallRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
    if IsEnergyComplete then
      if IsCallRole then
        local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
        local isFreedRole = servertime > self.FreedTime
        if isFreedRole then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end
function RoleWarmUpProxy:ReqRoleWarmUpPhaseAward(activity_id, phase)
  local tb = {}
  tb.activity_id = activity_id
  tb.phase = phase
  local req = pb.encode(Pb_ncmd_cs_lobby.role_warm_up_award_phase_req, tb)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_PHASE_REQ, req)
end
function RoleWarmUpProxy:OnResRoleWarmUpPhaseAward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.role_warm_up_award_phase_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.TakePhaseAwardSuccess, netData.phase)
  self:ReqRoleWarmUpGetData(self.activityId)
end
function RoleWarmUpProxy:ReqRoleWarmUpRoleAward(activity_id)
  local tb = {}
  tb.activity_id = activity_id
  local req = pb.encode(Pb_ncmd_cs_lobby.role_warm_up_award_role_req, tb)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_AWARD_ROLE_REQ, req)
end
function RoleWarmUpProxy:OnResRoleWarmUpRoleAward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.role_warm_up_award_role_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.TakeRoleSuccess)
end
function RoleWarmUpProxy:ReqExchangeReward(activity_id, cnt)
  local tb = {}
  tb.activity_id = activity_id
  tb.cnt = cnt
  local req = pb.encode(Pb_ncmd_cs_lobby.role_warm_up_exchange_req, tb)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ROLE_WARM_UP_EXCHANGE_REQ, req)
end
function RoleWarmUpProxy:OnResExchangeReward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.role_warm_up_exchange_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.UpdateEnergyNum)
  self:ReqRoleWarmUpGetData(self.activityId)
end
function RoleWarmUpProxy:ReqGetTaskReward(taskId)
  local tb = {}
  tb.task_id = taskId
  local req = pb.encode(Pb_ncmd_cs_lobby.take_task_prize_req, tb)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_REQ, req)
end
function RoleWarmUpProxy:OnResTakeTaskPrize(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.take_task_prize_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.RoleWarmUp.TakeTaskAwardSuccess, netData.task_id)
  self:ReqRoleWarmUpGetData(self.activityId)
end
function RoleWarmUpProxy:GetAwardPhaseIsTakeByID(PhaseID)
  for key, value in pairs(self.award_phase) do
    if value == PhaseID then
      return true
    end
  end
  return false
end
function RoleWarmUpProxy:GetActivityId()
  return self.activityId
end
function RoleWarmUpProxy:GetConsumeNumWhileExchange()
  return self.exchangeNum
end
function RoleWarmUpProxy:GetRedeemRewardTB()
  return self.redeemRewardTb
end
function RoleWarmUpProxy:GetEnergySum()
  return self.EnergySum
end
function RoleWarmUpProxy:GetCurrentEnergy()
  local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  self.CurrentEnergy = warehouseProxy:GetItemCnt(self.consume_id)
  return self.CurrentEnergy
end
function RoleWarmUpProxy:GetMilestonePhases()
  return self.MilestonePhases
end
function RoleWarmUpProxy:GetPhaseDes()
  return self.PhaseDes
end
function RoleWarmUpProxy:GetPhaseDesPage()
  local _PhaseDesPage = {}
  for key, value in pairs(self.PhaseDesPage) do
    table.insert(_PhaseDesPage, value)
  end
  return _PhaseDesPage
end
function RoleWarmUpProxy:GetPhaseAwardTb()
  return self.PhaseAwardTb
end
function RoleWarmUpProxy:GetPhaseIndex()
  if self:GetIsReceiveRole() then
    return 6
  end
  for key, value in pairs(self.MilestonePhases) do
    LogDebug("RoleWarmUpProxy", "MilestonePhase = " .. value)
    if value > self:GetCurrentEnergy() then
      return key
    end
  end
  return 6
end
function RoleWarmUpProxy:GetIsEnergyComplete()
  return self:GetCurrentEnergy() >= self.EnergySum
end
function RoleWarmUpProxy:GetIsReceiveRole()
  return self.award_role
end
function RoleWarmUpProxy:GetCurrentPhaseDescIndex()
  local index = 0
  local PhaseIndex = self:GetPhaseIndex()
  for i = 1, PhaseIndex do
    local PhaseDesc = self:GetPhaseDescByID(i)
    if PhaseDesc and "" ~= PhaseDesc then
      index = index + 1
    end
  end
  return index
end
function RoleWarmUpProxy:GetPhaseDescByID(Phaseid)
  local PhaseDesc = self.PhaseDes[Phaseid]
  return PhaseDesc
end
function RoleWarmUpProxy:GetCountDownTimeText(countDownTime)
  local CountDownTimeText
  local timeTable = FunctionUtil:FormatTime(countDownTime)
  if countDownTime >= 86400 then
    local DaysHoursText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(DaysHoursText, {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    })
  elseif countDownTime >= 3600 then
    local HoursMinutesText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(HoursMinutesText, {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute
    })
  elseif countDownTime >= 60 then
    local MinutesSecondsText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_MinutesSeconds")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(MinutesSecondsText, {
      Minutes = timeTable.Minute,
      Seconds = timeTable.Second
    })
  else
    local SecondsText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Seconds")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(SecondsText, {
      Seconds = timeTable.Second
    })
  end
  return CountDownTimeText
end
function RoleWarmUpProxy:GetTaskIdList()
  local taskIdList = {}
  local arrRows = ConfigMgr:GetActivityTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData.ActivityId and rowData.ActivityId == self.activityId and rowData.Id then
        table.insert(taskIdList, rowData.Id)
      end
    end
  end
  table.sort(taskIdList, function(a, b)
    return a < b
  end)
  if taskIdList and #taskIdList > 0 then
    return taskIdList
  end
  LogInfo("GetTaskIdList:", "taskIdList is nil")
  return nil
end
function RoleWarmUpProxy:SendTLOG(Activitystaytype, Herotouchactnum)
  local commonData = UE4.FActivityMrdsPreheatingData()
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):GetMrdsPreheatingData(commonData)
  if commonData then
    commonData.Activitystaytype = Activitystaytype
    commonData.Herotouchactnum = Herotouchactnum
  end
  local str = UE4.UPMCliTLogApi.Make_ActivityMrdsPreheating_Data(commonData)
  LogDebug("RoleWarmUpProxy", "SendTLOG = " .. str)
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):SendTLogData(str, false)
end
return RoleWarmUpProxy
