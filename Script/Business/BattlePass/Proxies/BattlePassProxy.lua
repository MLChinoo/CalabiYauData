local BattlePassProxy = class("BattlePassProxy", PureMVC.Proxy)
local dayTaskCfg = {}
local weekTaskCfg = {}
local loopTaskCfg = {}
local activityTaskCfg = {}
local apartmentTaskCfg = {}
local taskRefreshCfg = {}
local progressPrizeCfg = {}
local battlePassLvCfg = {}
local backGroundCfg = {}
local clueCfg = {}
local seasonCfg = {}
function BattlePassProxy:ctor(proxyName, data)
  BattlePassProxy.super.ctor(self, proxyName, data)
  self:CleanData()
end
function BattlePassProxy:CleanData()
  dayTaskCfg = {}
  weekTaskCfg = {}
  loopTaskCfg = {}
  activityTaskCfg = {}
  apartmentTaskCfg = {}
  taskRefreshCfg = {}
  progressPrizeCfg = {}
  battlePassLvCfg = {}
  backGroundCfg = {}
  clueCfg = {}
  seasonCfg = {}
  self.dayTaskTable = {}
  self.dayTaskOrderedTable = {}
  self.weekTaskTable = {}
  self.loopTaskTable = {}
  self.activityTaskTable = {}
  self.apartmentTaskTable = {}
  self.taskRefreshCnt = 0
  self.seasonId = 0
  self.seasonStartTime = 0
  self.seasonFinishTime = 0
  self.dayFlushTime = 0
  self.seasonWeekCnt = 0
  self.battlePassVip = false
  self.seniorReward = {}
  self.exploreReward = {}
  self.clueReward = {}
  self.firstEnterBattlepass = true
end
function BattlePassProxy:InitTableCfg()
  self:InitDayTaskCfg()
  self:InitWeekTaskCfg()
  self:InitLoopTaskCfg()
  self:InitActivityTaskCfg()
  self:InitTaskRefreshCfg()
  self:InitRoleFavorableMissionTableCfg()
  self:InitSeasonCfg()
end
function BattlePassProxy:InitRoleFavorableMissionTableCfg()
  local arrRows = ConfigMgr:GetRoleFavorabilityMissionTableRows()
  if arrRows then
    local infoList = arrRows:ToLuaTable()
    for _, v in pairs(infoList) do
      apartmentTaskCfg[v.Id] = v
    end
  end
end
function BattlePassProxy:InitDayTaskCfg()
  local arrRows = ConfigMgr:GetDayTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      dayTaskCfg[rowData.Id] = rowData
    end
  end
end
function BattlePassProxy:InitWeekTaskCfg()
  local arrRows = ConfigMgr:GetWeekTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      weekTaskCfg[rowData.Id] = rowData
    end
  end
end
function BattlePassProxy:InitLoopTaskCfg()
  local arrRows = ConfigMgr:GetLoopTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      loopTaskCfg[rowData.Id] = rowData
    end
  end
end
function BattlePassProxy:InitActivityTaskCfg()
  local arrRows = ConfigMgr:GetActivityTaskTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      activityTaskCfg[rowData.Id] = rowData
    end
  end
end
function BattlePassProxy:InitTaskRefreshCfg()
  local arrRows = ConfigMgr:GetTaskRefreshTableRow()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      taskRefreshCfg[rowData.Circle] = rowData
    end
  end
end
function BattlePassProxy:InitSeasonCfg()
  local arrRows = ConfigMgr:GetBattlePassSeasonTableRows()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      seasonCfg[rowData.Id] = rowData
    end
  end
end
function BattlePassProxy:GetTaskType(taskId)
  if dayTaskCfg[taskId] then
    return GlobalEnumDefine.EBattlePassTaskType.kDayTask
  elseif weekTaskCfg[taskId] then
    return GlobalEnumDefine.EBattlePassTaskType.kWeekTask
  elseif loopTaskCfg[taskId] then
    return GlobalEnumDefine.EBattlePassTaskType.kLoopTask
  elseif apartmentTaskCfg[taskId] then
    return GlobalEnumDefine.EBattlePassTaskType.kApartmentTask
  else
    return GlobalEnumDefine.EBattlePassTaskType.kNone
  end
end
function BattlePassProxy:SetUpTableCfg(seasonId)
  self:InitClueCfg(seasonId)
  self:InitPrizeCfg(seasonId)
  self:InitBackGroundCfg(seasonId)
end
function BattlePassProxy:InitClueCfg(seasonId)
  local arrRows = ConfigMgr:GetBattlePassClueTableRows()
  if arrRows then
    clueCfg = {}
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData.Season == seasonId then
        clueCfg[rowData.ClueId] = rowData
      end
    end
  end
end
function BattlePassProxy:InitPrizeCfg(seasonId)
  local arrRows = ConfigMgr:GetBattlePassPrizeTableRows()
  if arrRows then
    progressPrizeCfg = {}
    battlePassLvCfg = {}
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData.Season == seasonId then
        progressPrizeCfg[rowData.Id] = rowData
        battlePassLvCfg[rowData.Id] = rowData.Explore
      end
    end
  end
end
function BattlePassProxy:InitBackGroundCfg(seasonId)
  local arrRows = ConfigMgr:GetBattlePassBackGroudTableRows()
  if arrRows then
    backGroundCfg = {}
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData.Season == seasonId then
        backGroundCfg[rowData.Index] = rowData
      end
    end
  end
end
function BattlePassProxy:OnRegister()
  BattlePassProxy.super.OnRegister(self)
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_PROGRESS_NTF, FuncSlot(self.OnNtfTaskProgress, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_CHANGE_RES, FuncSlot(self.OnResTaskChange, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TAKE_PRIZE_NTF, FuncSlot(self.OnNtfTakePrize, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_SEASON_NTF, FuncSlot(self.OnNtfSeason, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_INFO_NTF, FuncSlot(self.OnNtfInfo, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLUEBOARD_RES, FuncSlot(self.OnResClubBoard, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_RES, FuncSlot(self.OnResReward, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_VIP_NTF, FuncSlot(self.OnNtfVip, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_ALL_RES, FuncSlot(self.OnResRewardAll, self))
end
function BattlePassProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_PROGRESS_NTF, FuncSlot(self.OnNtfTaskProgress, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_CHANGE_RES, FuncSlot(self.OnResTaskChange, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TAKE_PRIZE_NTF, FuncSlot(self.OnNtfTakePrize, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_SEASON_NTF, FuncSlot(self.OnNtfSeason, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_INFO_NTF, FuncSlot(self.OnNtfInfo, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLUEBOARD_RES, FuncSlot(self.OnResClubBoard, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_RES, FuncSlot(self.OnResReward, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_VIP_NTF, FuncSlot(self.OnNtfVip, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_ALL_RES, FuncSlot(self.OnResRewardAll, self))
  self:CleanData()
end
function BattlePassProxy:ReqTaskChange(taskId)
  local data = {tar_task_id = taskId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_CHANGE_REQ, pb.encode(Pb_ncmd_cs_lobby.battlepass_task_change_req, data))
end
function BattlePassProxy:ReqClueReward(clueId)
  local data = {clue_id = clueId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLUEBOARD_REQ, pb.encode(Pb_ncmd_cs_lobby.battlepass_clueboard_req, data))
end
function BattlePassProxy:ReqProgressReward(inLevel, inVip)
  local data = {level = inLevel, vip = inVip}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.battlepass_reward_req, data))
end
function BattlePassProxy:ReqAllProgressReward()
  local data = {}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_REWARD_ALL_REQ, pb.encode(Pb_ncmd_cs_lobby.battlepass_reward_all_req, data))
end
function BattlePassProxy:OnNtfTaskProgress(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.battlepass_task_progress_ntf, data)
  local taskDatas = {}
  local dropIds = {}
  if netData.update_task_datas then
    for key, value in pairs(netData.update_task_datas) do
      local taskData = {}
      taskData.taskId = value.task_id
      taskData.taskType = value.task_type
      taskData.state = value.state
      if value.progresses then
        taskData.progressMap = {}
        for key, sValue in pairs(value.progresses) do
          table.insert(taskData.progressMap, sValue.value)
        end
      end
      table.insert(taskDatas, taskData)
    end
  end
  if netData.drop_task_ids then
    for key, value in pairs(netData.drop_task_ids) do
      table.insert(dropIds, value)
    end
  end
  self:AssembleOrderedDayTaskNtf(dropIds, taskDatas)
  self:AssembleData(dropIds, taskDatas, netData.day_task_refresh_cnt)
end
function BattlePassProxy:OnResTaskChange(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.battlepass_task_change_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  local taskDatas = {}
  local dropIds = {}
  local newTask = netData.new_task_data
  if not newTask then
    LogError("BattlePassProxy:OnResTaskChange", "//服务器下发任务为空，new_task_data = nil")
    return
  end
  local taskData = {}
  taskData.taskId = newTask.task_id
  taskData.taskType = newTask.task_type
  taskData.state = newTask.state
  if newTask.progresses then
    taskData.progressMap = {}
    for key, value in pairs(newTask.progresses) do
      table.insert(taskData.progressMap, value.value)
    end
  end
  table.insert(taskDatas, taskData)
  table.insert(dropIds, netData.old_task_id)
  self:AssembleOrderedDayTaskChange(netData.old_task_id, taskData.taskId)
  self:AssembleData(dropIds, taskDatas, netData.day_task_refresh_cnt, true)
end
function BattlePassProxy:AssembleData(inDropTaskIds, inTaskDatas, inTaskRefreshCnt, inIsFlush)
  for key, value in pairs(inDropTaskIds) do
    local taskType = self:GetTaskType(value)
    if taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
      self.dayTaskTable[value] = nil
    elseif taskType == GlobalEnumDefine.EBattlePassTaskType.kWeekTask then
      self.weekTaskTable[value] = nil
    elseif taskType == GlobalEnumDefine.EBattlePassTaskType.kLoopTask then
      self.loopTaskTable[value] = nil
    elseif taskType == GlobalEnumDefine.EBattlePassTaskType.KActivityTask then
      self.activityTaskTable[value] = nil
    end
  end
  for key, value in pairs(inTaskDatas) do
    if value.taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
      self.dayTaskTable[value.taskId] = value
    elseif value.taskType == GlobalEnumDefine.EBattlePassTaskType.kWeekTask then
      self.weekTaskTable[value.taskId] = value
    elseif value.taskType == GlobalEnumDefine.EBattlePassTaskType.kLoopTask then
      self.loopTaskTable[value.taskId] = value
    elseif value.taskType == GlobalEnumDefine.EBattlePassTaskType.kApartmentTask then
      self.apartmentTaskTable[value.taskId] = value
      if value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseTaskRewards, 1)
      elseif value.state == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseTaskRewards, -1)
      end
    elseif value.taskType == GlobalEnumDefine.EBattlePassTaskType.KActivityTask then
      self.activityTaskTable[value.taskId] = value
    end
  end
  self.taskRefreshCnt = inTaskRefreshCnt
  self:UpdateTask(inIsFlush)
end
function BattlePassProxy:AssembleOrderedDayTaskNtf(inDropTaskIds, inTaskDatas)
  for key, value in pairs(inDropTaskIds) do
    local taskType = self:GetTaskType(value)
    if taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
      self.dayTaskOrderedTable = {}
    end
  end
  if 0 == #self.dayTaskOrderedTable then
    for key, value in pairs(inTaskDatas) do
      if value.taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
        table.insert(self.dayTaskOrderedTable, value.taskId)
      end
    end
    table.sort(self.dayTaskOrderedTable, function(a, b)
      local aCfg = self:GetTaskCfgById(a)
      local bCfg = self:GetTaskCfgById(b)
      if aCfg and bCfg then
        local va = aCfg.Permanent and 1 or 0
        local vb = bCfg.Permanent and 1 or 0
        return va > vb
      else
        return false
      end
    end)
  end
end
function BattlePassProxy:AssembleOrderedDayTaskChange(oldTaskId, newTaskId)
  local index = table.index(self.dayTaskOrderedTable, oldTaskId)
  if index then
    self.dayTaskOrderedTable[index] = newTaskId
  end
end
function BattlePassProxy:UpdateTask(inIsFlush)
  GameFacade:SendNotification(NotificationDefines.BattlePass.TaskUpdate, {isFlush = inIsFlush})
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  SummerThemeSongProxy:CheckRedDotShow()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  MichellePlaytimeProxy:CheckRedDotShow()
end
function BattlePassProxy:OnNtfTakePrize(data)
end
function BattlePassProxy:OnNtfSeason(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_season_ntf, data)
  local oldSeasonId = self.seasonId
  self.seasonId = netData.season_id
  self.seasonStartTime = netData.season_start_time
  self.seasonFinishTime = netData.season_finish_time
  self.dayFlushTime = netData.day_flush_time
  self.seasonWeekCnt = netData.week_cnt
  self:SetUpTableCfg(self.seasonId)
  if 0 ~= oldSeasonId then
    self.dayTaskTable = {}
    self.weekTaskTable = {}
    self.loopTaskTable = {}
    self.dayTaskOrderedTable = {}
  end
end
function BattlePassProxy:OnNtfInfo(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_info_ntf, data)
  self:SetBattlePassVip(netData.battlepass_vip)
  if netData.senior_rewards then
    for key, value in pairs(netData.senior_rewards) do
      self:UpdateProgressRewardInfo(value, true, false)
    end
  end
  if netData.explore_rewards then
    for key, value in pairs(netData.explore_rewards) do
      self:UpdateProgressRewardInfo(value, false, false)
    end
  end
  if netData.clueboard_rewards then
    for key, value in pairs(netData.clueboard_rewards) do
      self:UpdateClueRewardInfo(value, false)
    end
  end
  self:CalculatePregressRedDot()
  self:CalculateClueRedDot()
end
function BattlePassProxy:OnResClubBoard(data)
  do return end
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_clueboard_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  self:UpdateClueRewardInfo(netData.clue_id, true)
  RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.BPClue, -1)
end
function BattlePassProxy:OnResReward(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_reward_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  self:UpdateProgressRewardInfo(netData.level, netData.vip, true)
  RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.BPProgress, -1)
end
function BattlePassProxy:OnNtfVip(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_vip_ntf, data)
  self:SetBattlePassVip(netData.battlepass_vip, true)
  self:CalculatePregressRedDot()
end
function BattlePassProxy:OnResRewardAll(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.battlepass_reward_all_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if playerProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = self:GetLvByExplore(explore)
    for level = 1, curLevel do
      self.exploreReward[level] = true
      if self.battlePassVip then
        self.seniorReward[level] = true
      end
    end
  end
  GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressUpdateView)
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.BPProgress, 0)
end
function BattlePassProxy:UpdateProgressRewardInfo(level, isSenior, isNotify)
  if isSenior then
    self.seniorReward[level] = true
  else
    self.exploreReward[level] = true
  end
  if isNotify then
    GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressUpdateView)
  end
end
function BattlePassProxy:CalculatePregressRedDot()
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if playerProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = self:GetLvByExplore(explore)
    local isVip = self.battlePassVip
    local cfg = progressPrizeCfg
    local cnt = 0
    for level, prizeCfg in ipairs(cfg) do
      for i = 1, prizeCfg.Prize2:Length() do
        local isLock = level > curLevel or not isVip
        local isReceived = self:IsRewardReceived(level, true)
        if not isLock and not isReceived then
          cnt = cnt + 1
        end
      end
      for i = 1, prizeCfg.Prize1:Length() do
        local isLock = level > curLevel
        local isReceived = self:IsRewardReceived(level, false)
        if not isLock and not isReceived then
          cnt = cnt + 1
        end
      end
    end
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.BPProgress, cnt)
  end
end
function BattlePassProxy:CalculateClueRedDot()
  do return end
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if playerProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = self:GetLvByExplore(explore)
    local cnt = 0
    for clueId, value in ipairs(self:GetClueCfgList()) do
      local isUnlock = curLevel >= value.UnlockLevel and true or false
      local isRewardRecevied = self:IsClueRewardReceived(clueId)
      if isUnlock and not isRewardRecevied then
        cnt = cnt + 1
      end
    end
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.BPClue, cnt)
  end
end
function BattlePassProxy:UpdateClueRewardInfo(clueId, isNotify)
  self.clueReward[clueId] = true
  if isNotify then
    GameFacade:SendNotification(NotificationDefines.BattlePass.ClueRewardUpdate, clueId)
  end
end
function BattlePassProxy:SetBattlePassVip(isVip, isNotify)
  self.battlePassVip = isVip
  if isNotify then
    GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressUpdateView)
  end
end
function BattlePassProxy:GetLoopTasks()
  local loopTasks = {}
  for key, value in pairs(self.loopTaskTable) do
    table.insert(loopTasks, value)
  end
  return loopTasks
end
function BattlePassProxy:GetActivityTasks()
  local activityTasks = {}
  for key, value in pairs(self.activityTaskTable) do
    table.insert(activityTasks, value)
  end
  return activityTasks
end
function BattlePassProxy:GetDayTasks()
  local dayTasks = {}
  for index, value in ipairs(self.dayTaskOrderedTable) do
    if self.dayTaskTable[value] then
      table.insert(dayTasks, self.dayTaskTable[value])
    end
  end
  return dayTasks
end
function BattlePassProxy:GetWeekTasks()
  local weekTasks = {}
  for key, value in pairs(self.weekTaskTable) do
    table.insert(weekTasks, value)
  end
  return weekTasks
end
function BattlePassProxy:GetWeekTasksById(weekId)
  local weekTasks = {}
  for key, value in pairs(self.weekTaskTable) do
    local row = self:GetWeekTaskCfgById(key)
    if row and row.Week == weekId then
      table.insert(weekTasks, value)
    end
  end
  return weekTasks
end
function BattlePassProxy:GetApartmentTaskByRoleIdNLv(roleId, intimacyLv)
  local data = {}
  for k, v in pairs(self.apartmentTaskTable) do
    if apartmentTaskCfg[k] then
      local taskInfo = apartmentTaskCfg[k]
      if taskInfo.RoleId == roleId and taskInfo.RoleLevel == intimacyLv then
        local apartmentTask = {}
        apartmentTask.taskId = v.taskId
        apartmentTask.taskState = v.state
        apartmentTask.taskDesc = taskInfo.Desc
        apartmentTask.taskProgress = v.progressMap[1]
        apartmentTask.taskTarget = taskInfo.TaskConditions:Get(1).MainCondition.Num
        apartmentTask.taskReward = taskInfo.Prize:Get(1)
        table.insert(data, apartmentTask)
      end
    end
  end
  return data
end
function BattlePassProxy:GetApartmentRoleAllTask(roleId)
  local data = {}
  for k, cfg in pairs(apartmentTaskCfg) do
    if cfg.RoleId == roleId then
      local taskInfo = self.apartmentTaskTable[k]
      local apartmentTask = {}
      apartmentTask.roleId = roleId
      apartmentTask.taskId = cfg.id
      apartmentTask.taskState = taskInfo and taskInfo.state or nil
      apartmentTask.taskDesc = cfg.Desc
      apartmentTask.taskLv = cfg.RoleLevel
      apartmentTask.avgEventId = cfg.MissionAvgId
      apartmentTask.avgSequenceId = cfg.MissionSeqId
      apartmentTask.taskProgress = taskInfo and taskInfo.progressMap[1] or nil
      apartmentTask.taskTarget = cfg.TaskConditions:Get(1).MainCondition.Num
      apartmentTask.taskReward = cfg.Prize:Get(1)
      apartmentTask.taskRewardArray = cfg.Prize
      table.insert(data, apartmentTask)
    end
  end
  table.sort(data, function(a, b)
    return a.taskId < b.taskId
  end)
  return data
end
function BattlePassProxy:GetApartmentTaskByRoleId(roleId)
  local data = {}
  for k, v in pairs(self.apartmentTaskTable) do
    if apartmentTaskCfg[k] then
      local taskInfo = apartmentTaskCfg[k]
      if tonumber(taskInfo.RoleId) == tonumber(roleId) then
        local apartmentTask = {}
        apartmentTask.taskId = v.taskId
        apartmentTask.taskState = v.state
        apartmentTask.taskDesc = taskInfo.Desc
        apartmentTask.taskProgress = v.progressMap[1]
        apartmentTask.taskTarget = taskInfo.TaskConditions:Get(1).MainCondition.Num
        apartmentTask.taskReward = taskInfo.Prize:Get(1)
        data[apartmentTask.taskId] = apartmentTask
      end
    end
  end
  return data
end
function BattlePassProxy:GetLoopTaskCfgById(taskId)
  return loopTaskCfg[taskId]
end
function BattlePassProxy:GetDayTaskCfgById(taskId)
  return dayTaskCfg[taskId]
end
function BattlePassProxy:GetWeekTaskCfgById(taskId)
  return weekTaskCfg[taskId]
end
function BattlePassProxy:GetActivityTaskCfgById(taskId)
  return activityTaskCfg[taskId]
end
function BattlePassProxy:GetTaskCfgById(taskId)
  if dayTaskCfg[taskId] then
    return dayTaskCfg[taskId]
  end
  if weekTaskCfg[taskId] then
    return weekTaskCfg[taskId]
  end
  if loopTaskCfg[taskId] then
    return loopTaskCfg[taskId]
  end
  return nil
end
function BattlePassProxy:GetTaskRefreshCfgByCnt(cnt)
  return taskRefreshCfg[cnt]
end
function BattlePassProxy:GetTaskRefreshCfgMax()
  return #taskRefreshCfg
end
function BattlePassProxy:GetTaskRefreshCnt()
  return self.taskRefreshCnt
end
function BattlePassProxy:GetSeasonWeekCount()
  return self.seasonWeekCnt
end
function BattlePassProxy:GetSeasonFinshTime()
  return self.seasonFinishTime
end
function BattlePassProxy:GetSeasonName()
  local str = "default"
  local season = seasonCfg[self.seasonId]
  if season then
    str = season.Name
  end
  return str
end
function BattlePassProxy:IsSeasonIntermission()
  return 0 == self.seasonId
end
function BattlePassProxy:GetCurrentSeasonID()
  return self.seasonId
end
function BattlePassProxy:GetNextDayFlushTime()
  local serverEquationOfTime = 0
  local basicFuncProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if basicFuncProxy then
    serverEquationOfTime = basicFuncProxy:GetParameterIntValue("9999")
  end
  local seconds = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() + serverEquationOfTime * 60 * 60
  local todayGoneSeconds = seconds % 86400
  local todayZeroSeconds = seconds - todayGoneSeconds
  local nextDayFlushTime = todayZeroSeconds + self.dayFlushTime
  if seconds >= nextDayFlushTime then
    nextDayFlushTime = nextDayFlushTime + 86400
  end
  return nextDayFlushTime
end
function BattlePassProxy:GetSubWeekTaskUnlockTime(weekId)
  if 1 == weekId then
    return self.seasonStartTime
  end
  return self.seasonStartTime + (weekId - 1) * 604800
end
function BattlePassProxy:GetPrizeCfgList()
  return progressPrizeCfg
end
function BattlePassProxy:GetLvByExplore(explore)
  local exp = tonumber(explore)
  for level, lvExplore in ipairs(battlePassLvCfg) do
    if lvExplore > exp then
      return level - 1
    else
      exp = exp - lvExplore
    end
  end
  return #battlePassLvCfg
end
function BattlePassProxy:GetExploreProgress(explore)
  local curExp = 0
  local maxExp = 0
  local exp = tonumber(explore)
  for level, lvExplore in ipairs(battlePassLvCfg) do
    if lvExplore > exp then
      curExp = exp
      maxExp = lvExplore
      break
    else
      exp = exp - lvExplore
    end
  end
  if 0 == curExp and 0 == maxExp then
    curExp = 1
    maxExp = 1
  end
  return curExp, maxExp
end
function BattlePassProxy:IsBattlePassVip()
  return self.battlePassVip
end
function BattlePassProxy:IsRewardReceived(lv, isSenior)
  if isSenior then
    return self.seniorReward[lv]
  else
    return self.exploreReward[lv]
  end
end
function BattlePassProxy:GetExploreLvMax()
  return #battlePassLvCfg
end
function BattlePassProxy:GetExploreBetweenLv(explore, targetLv)
  local totalEx = 0
  for level, lvExplore in ipairs(battlePassLvCfg) do
    if level <= targetLv then
      totalEx = totalEx + lvExplore
    else
      break
    end
  end
  return totalEx - explore
end
function BattlePassProxy:GetRewardsBetweenLv(startLv, targetLv, isVip)
  local rewards = {}
  for id = startLv + 1, targetLv do
    if progressPrizeCfg[id] then
      table.insert(rewards, progressPrizeCfg[id].Prize1)
      if isVip then
        table.insert(rewards, progressPrizeCfg[id].Prize2)
      end
    end
  end
  return rewards
end
function BattlePassProxy:GetClueCfgList()
  return clueCfg
end
function BattlePassProxy:IsClueRewardReceived(clueId)
  return self.clueReward[clueId]
end
function BattlePassProxy:GetBackGroundCfg()
  return backGroundCfg
end
function BattlePassProxy:GetPromiseTaskCfg(taskId)
  return taskId and apartmentTaskCfg[taskId]
end
function BattlePassProxy:GetFirstEnter()
  if self.firstEnterBattlepass then
    local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
    if playerProxy then
      local info = playerProxy:GetPlayerInfo()
      if info then
        self.firstEnterBattlepass = false
        return info.is_today_first_login
      end
    end
  end
  self.firstEnterBattlepass = false
  return self.firstEnterBattlepass
end
function BattlePassProxy:GetSeasonConfig(seasonID)
  if seasonCfg then
    return seasonCfg[seasonID]
  end
  return nil
end
function BattlePassProxy:IsWeekTaskFinish(weekTaskId)
  local weekTasks = self:GetWeekTasksById(weekTaskId)
  if weekTasks then
    for key, value in pairs(weekTasks) do
      if value and value.state < 3 then
        return false
      end
    end
  else
    return false
  end
  return true
end
function BattlePassProxy:GetCurrentWeek()
  local weekCnt = self:GetSeasonWeekCount()
  local currentWeekId = weekCnt
  for weekId = 1, weekCnt do
    local FlushTimeList = self:GetSubWeekTaskUnlockTime(weekId) - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    if FlushTimeList > 0 then
      currentWeekId = weekId - 1
      break
    end
  end
  return currentWeekId
end
function BattlePassProxy:GetSeasonFinishRestShowTime()
  if self.seasonFinishTime then
    local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    local resttime = self.seasonFinishTime - servertime
    if resttime > 0 then
      local BuffProxy = GameFacade:RetrieveProxy(ProxyNames.BuffProxy)
      return BuffProxy:SecondToStrFormat(resttime), true
    end
  end
end
local HIDETIME = 1209600
function BattlePassProxy:CheckHideRestTime()
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local resttime = self.seasonFinishTime - servertime
  return resttime >= HIDETIME
end
return BattlePassProxy
