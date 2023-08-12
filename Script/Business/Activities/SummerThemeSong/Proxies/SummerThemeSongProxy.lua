local SummerThemeSongProxy = class("SummerThemeSongProxy", PureMVC.Proxy)
SummerThemeSongProxy.ActivityEventTypeEnum = {
  EntryMainPage = 1,
  QuitActivity = 2,
  EntryTaskPage = 3,
  QuitTaskPage = 4,
  EntryMilestoneAwardPage = 5,
  QuitMilestoneAwardPage = 6,
  EntryDeliveryOpportunityPage = 7,
  QuitDeliveryOpportunityPage = 8,
  EntryActivityRulesPage = 9,
  QuitActivityRulesPage = 10
}
SummerThemeSongProxy.ActivityShareTypeEnum = {
  MilestoneAward_1 = 1,
  MilestoneAward_2 = 2,
  MilestoneAward_3 = 3,
  MilestoneAward_4 = 4,
  MilestoneAward_5 = 5
}
SummerThemeSongProxy.ActivityTouchTypeEnum = {
  ClickTaskBtn = 1,
  ClickDeliveryBtn = 2,
  ClickRulesBtn = 3,
  ClickFlipItemBtn = 4,
  ClickMilestoneAwardBtn = 5
}
function SummerThemeSongProxy:OnRegister()
  SummerThemeSongProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SC_DATA_GET_RES, FuncSlot(self.OnResScDataGet, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SC_AWARD_PHASE_RES, FuncSlot(self.OnResScAwardPhase, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SC_OPEN_CARD_RES, FuncSlot(self.OnResScOpenCard, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SC_DELIVER_RES, FuncSlot(self.OnResScDeliver, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.OnResTakeTaskPrize, self))
  self.curPhaseCueCnt = 0
  self.IsInActiveMainPagePhaseFinishedParticle = false
  self.curFlipRound = 0
  self.activityId = 10006
end
function SummerThemeSongProxy:OnRemove()
  SummerThemeSongProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SC_DATA_GET_RES, FuncSlot(self.OnResScDataGet, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SC_AWARD_PHASE_RES, FuncSlot(self.OnResScAwardPhase, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SC_OPEN_CARD_RES, FuncSlot(self.OnResScOpenCard, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SC_DELIVER_RES, FuncSlot(self.OnResScDeliver, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.OnResTakeTaskPrize, self))
  end
end
function SummerThemeSongProxy:ReqGetTaskReward(taskId)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_REQ, pb.encode(Pb_ncmd_cs_lobby.take_task_prize_req, {task_id = taskId}))
end
function SummerThemeSongProxy:ReqScGetData()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SC_DATA_GET_REQ, pb.encode(Pb_ncmd_cs_lobby.sc_data_get_req, {
    activity_id = self.activityId
  }))
end
function SummerThemeSongProxy:ReqScAwardPhase(searchPhase)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SC_AWARD_PHASE_REQ, pb.encode(Pb_ncmd_cs_lobby.sc_award_phase_req, {
    activity_id = self.activityId,
    phase = searchPhase
  }))
end
function SummerThemeSongProxy:ReqScOpenCard(openCardGrid)
  local flipTimes = self:GetFlipChanceItemCnt()
  local flipCostCnt = self:GetScFlipCostNum()
  if not self:GetAllPhaseFinished() then
    if flipTimes and flipCostCnt and flipTimes >= flipCostCnt then
      SendRequest(Pb_ncmd_cs.NCmdId.NID_SC_OPEN_CARD_REQ, pb.encode(Pb_ncmd_cs_lobby.sc_open_card_req, {
        activity_id = self.activityId,
        grid = openCardGrid
      }))
    else
      local TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "STS_FlipTimesNotEnough")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
    end
  end
end
function SummerThemeSongProxy:ReqScDeliverReq(deliverTimes)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SC_DELIVER_REQ, pb.encode(Pb_ncmd_cs_lobby.sc_deliver_req, {
    activity_id = self.activityId,
    cnt = deliverTimes
  }))
end
function SummerThemeSongProxy:OnResTakeTaskPrize(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.take_task_prize_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask, netData.task_id)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes)
end
function SummerThemeSongProxy:OnResScDataGet(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sc_data_get_res, data)
  self.bScAllPhaseFinished = false
  self.curPhaseCueCnt = 0
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  elseif netData.cur_phase and netData.cfg.summer_concert.max_phase and netData.cur_phase > netData.cfg.summer_concert.max_phase then
    netData.cur_phase = netData.cfg.summer_concert.max_phase
    self.bScAllPhaseFinished = true
  end
  self.curFlipRound = netData.cur_phase
  for key, value in pairs(netData.phase_prize) do
    if netData.cur_phase == value.phase and value.cue then
      self.curPhaseCueCnt = self.curPhaseCueCnt + 1
    end
  end
  self:SetScConfigData(netData.cfg)
  self:SetScData(netData)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateData, netData)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes)
end
function SummerThemeSongProxy:OnResScAwardPhase(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sc_award_phase_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase, netData)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.SummerThemeSongMilestoneRewardsPage)
  self:ReqScGetData()
end
function SummerThemeSongProxy:OnResScOpenCard(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sc_open_card_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateOpenCard, netData)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.PlayerFlipAnimation, netData)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes)
  if netData.cue then
    self.curPhaseCueCnt = self.curPhaseCueCnt + 1
    if 2 == self.curPhaseCueCnt then
      self.IsInActiveMainPagePhaseFinishedParticle = true
      GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.SetFlipClick, false)
      TimerMgr:AddTimeTask(2.5, 0, 1, function()
        self:ReqScGetData()
        GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.ActiveMainPagePhaseFinishedParticle)
        self.IsInActiveMainPagePhaseFinishedParticle = false
      end)
      if 5 == self.curFlipRound then
        TimerMgr:AddTimeTask(3.0, 0, 1, function()
          GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.FlipRoundAllFinished)
        end)
      end
      if self.scData and self.scData.cur_phase then
        self.scData.cur_phase = self.scData.cur_phase + 1
      end
    end
  end
end
function SummerThemeSongProxy:GetIsInActiveMainPagePhaseFinishedParticle()
  if self.IsInActiveMainPagePhaseFinishedParticle then
    return self.IsInActiveMainPagePhaseFinishedParticle
  end
  return false
end
function SummerThemeSongProxy:OnResScDeliver(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sc_deliver_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes)
end
function SummerThemeSongProxy:SetScConfigData(data)
  self.scConfigData = data
end
function SummerThemeSongProxy:GetScConfigData()
  return self.scConfigData
end
function SummerThemeSongProxy:GetItemIDFromScConfigData(rewardPhase)
  if self.scConfigData then
    for key, value in pairs(self.scConfigData.phase_reward) do
      if value and value.phase == rewardPhase and value.items and #value.items > 0 then
        return value.items
      end
    end
  end
  return nil
end
function SummerThemeSongProxy:GetPhaseDesFromScConfigData(rewardPhase)
  if self.scConfigData then
    for key, value in pairs(self.scConfigData.phase_reward) do
      if value and value.phase == rewardPhase and value.phase_des then
        return value.phase_des
      end
    end
  end
  return nil
end
function SummerThemeSongProxy:GetFlipChanceItemCnt()
  local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  if self.scConfigData and self.scConfigData.summer_concert and self.scConfigData.summer_concert.item_id then
    return warehouseProxy:GetItemCnt(self.scConfigData.summer_concert.item_id)
  end
  return 0
end
function SummerThemeSongProxy:SetScData(data)
  self.scData = data
end
function SummerThemeSongProxy:GetScData()
  return self.scData
end
function SummerThemeSongProxy:IsFinishedAllFlipRound()
  return self.bScAllPhaseFinished
end
function SummerThemeSongProxy:IsReceivedAllFlipReward()
  noteBody = self.scData
  if noteBody then
    local phaseReward = noteBody.phase_reward
    local maxPhase = noteBody.cfg.summer_concert.max_phase
    if phaseReward and maxPhase and #phaseReward == maxPhase then
      return true
    end
  end
  return false
end
function SummerThemeSongProxy:GetScDeliverRewardConfigData()
  noteBody = self.scConfigData
  if noteBody then
    return noteBody.delivery
  end
  return nil
end
function SummerThemeSongProxy:GetScFlipCostNum()
  noteBody = self.scConfigData
  if noteBody and noteBody.summer_concert then
    return noteBody.summer_concert.item_num
  end
  return 0
end
function SummerThemeSongProxy:GetExchangeNum()
  noteBody = self.scConfigData
  if noteBody and noteBody.summer_concert then
    return noteBody.summer_concert.exchange_num
  end
  return 0
end
function SummerThemeSongProxy:GetScFlipCostItemId()
  noteBody = self.scConfigData
  if noteBody and noteBody.summer_concert then
    return noteBody.summer_concert.item_id
  end
  return nil
end
function SummerThemeSongProxy:GetAllPhaseFinished()
  return self.bScAllPhaseFinished
end
function SummerThemeSongProxy:SetHasFlipTask(bHas)
  self.bHasFlipTask = bHas
end
function SummerThemeSongProxy:GetHasFlipTask()
  return self.bHasFlipTask
end
function SummerThemeSongProxy:HandleCommonData()
  local commonData = UE4.FActivitySummersongData()
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):GetSummerThemeSongCommonData(commonData)
  return commonData
end
function SummerThemeSongProxy:SendTLOG(data)
  LogDebug("SummerThemeSongProxy", "Data is :")
  table.print(data)
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):SendTLogData(data, false)
end
function SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, shareType, TouchType)
  local commonData = self:HandleCommonData()
  if commonData then
    commonData.Activityeventtime = commonData.Dteventtime
    commonData.Activityevent = eventType
    commonData.Activityshare = shareType
    commonData.Activitytouch = TouchType
  end
  local str = UE4.UPMCliTLogApi.Make_ActivitySummersong_Data(commonData)
  self:SendTLOG(str)
end
function SummerThemeSongProxy:GetScPhaseRewardCfg()
  noteBody = self.scConfigData
  if noteBody and noteBody.phase_reward then
    return noteBody.phase_reward
  end
  return nil
end
function SummerThemeSongProxy:SetShowRedDot(bShow)
  if bShow then
    self.bShowRedRot = true
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, 1)
  else
    self.bShowRedRot = false
    GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, 0)
  end
end
function SummerThemeSongProxy:UpdateMilestoneRewardRedRot(noteBody)
  if noteBody then
    if noteBody.cur_phase and noteBody.phase_reward and noteBody.cfg.summer_concert.max_phase then
      local phaseReward = noteBody.phase_reward
      local maxPhase = noteBody.cfg.summer_concert.max_phase
      local curPhase = noteBody.cur_phase
      local NeedReceiveRewardCnt = 0
      for index = 1, maxPhase do
        if curPhase > 0 and index < curPhase then
          NeedReceiveRewardCnt = NeedReceiveRewardCnt + 1
        elseif index == curPhase and self:IsFinishedAllFlipRound() then
          NeedReceiveRewardCnt = NeedReceiveRewardCnt + 1
        end
      end
      if phaseReward and NeedReceiveRewardCnt > #phaseReward then
        return true
      end
    else
      LogInfo("UpdateMilestoneRewardRedRot:", "noteBody member is nil")
      table.print(noteBody)
    end
  else
    LogInfo("UpdateMilestoneRewardRedRot:", "noteBody is nil")
  end
  return false
end
function SummerThemeSongProxy:GetScTaskIdList()
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
  LogInfo("GetScTaskIdList:", "taskIdList is nil")
  return nil
end
function SummerThemeSongProxy:CheckRedDotShow()
  local taskIdList = self:GetScTaskIdList()
  if taskIdList and #taskIdList > 0 then
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
  else
    LogInfo("CheckRedDotShow:", "taskIdList is nil")
  end
end
function SummerThemeSongProxy:GetActivityId()
  if self.activityId then
    return self.activityId
  end
  LogInfo("SummerThemeSongProxy GetActivityId:", "activityId is nil")
  return nil
end
return SummerThemeSongProxy
