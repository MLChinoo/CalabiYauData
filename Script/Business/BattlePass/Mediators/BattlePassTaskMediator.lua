local BattlePassTaskMediator = class("BattlePassTaskMediator", PureMVC.Mediator)
function BattlePassTaskMediator:ctor(mediatorName, viewComponent)
  BattlePassTaskMediator.super.ctor(self, mediatorName, viewComponent)
  self.view = viewComponent
end
function BattlePassTaskMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.TaskUpdate
  }
end
function BattlePassTaskMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.BattlePass.TaskUpdate then
    local body = notification:GetBody()
    self:ProcessData(body.isFlush)
  end
end
function BattlePassTaskMediator:OnRegister()
  self.view.dayTaskClickEvent:Add(self.ClickDayTask, self)
  self.view.weekTaskClickEvent:Add(self.ClickWeekTask, self)
  self.view.subWeekTaskClickEvent:Add(self.ClickSubWeekTask, self)
  self.view.taskRefreshEvent:Add(self.ClickRefreshTask, self)
end
function BattlePassTaskMediator:OnRemove()
  self.view.dayTaskClickEvent:Remove(self.ClickDayTask, self)
  self.view.weekTaskClickEvent:Add(self.ClickWeekTask, self)
  self.view.subWeekTaskClickEvent:Remove(self.ClickSubWeekTask, self)
  self.view.taskRefreshEvent:Remove(self.ClickRefreshTask, self)
end
function BattlePassTaskMediator:OnViewComponentPagePostOpen()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if bpProxy then
    if bpProxy:IsSeasonIntermission() then
      self:GetViewComponent():SeasonIntermission()
    else
      GameFacade:SendNotification(NotificationDefines.BattlePass.TaskUpdateCmd)
    end
  end
end
function BattlePassTaskMediator:ProcessData(inIsflush)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if proxy then
    self:ProcessDayTaskData(proxy, inIsflush)
    self:ProcessLoopTaskData(proxy)
    self:processWeekTaskData(proxy)
  end
end
function BattlePassTaskMediator:ProcessDayTaskData(proxy, inIsflush)
  local basicFuncProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  local countDown = 0
  if basicFuncProxy then
    local serverEquationOfTime = basicFuncProxy:GetParameterIntValue("9999")
    local nextFlushTime = proxy:GetNextDayFlushTime()
    countDown = nextFlushTime - (UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() + serverEquationOfTime * 60 * 60)
  end
  self.dayTaskList = {}
  local inDayTasks = proxy:GetDayTasks()
  for key, value in pairs(inDayTasks) do
    local dayData = {}
    dayData.taskId = value.taskId
    dayData.type = GlobalEnumDefine.EBattlePassTaskType.kDayTask
    dayData.value = value.progressMap[1] or 0
    dayData.state = value.state
    local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetDayTaskCfgById(value.taskId)
    if taskCfg then
      dayData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
      dayData.desc = taskCfg.Desc
      dayData.prize = taskCfg.Prize:Get(1).ItemAmount
      dayData.permanent = taskCfg.Permanent
    end
    table.insert(self.dayTaskList, dayData)
  end
  self.view:UpdateDayTaskType({
    inTime = countDown,
    inTaskType = GlobalEnumDefine.EBattlePassTaskType.kDayTask
  })
  self.view:UpdateDayTaskItems(self.dayTaskList, inIsflush)
end
function BattlePassTaskMediator:ProcessLoopTaskData(proxy)
  self.loopData = {}
  local inLoopTasks = proxy:GetLoopTasks()
  local taskData = inLoopTasks[1]
  if taskData then
    self.loopData.taskId = taskData.taskId
    self.loopData.type = GlobalEnumDefine.EBattlePassTaskType.kLoopTask
    self.loopData.value = taskData.progressMap[1] or 0
    self.loopData.state = taskData.state
    local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetLoopTaskCfgById(taskData.taskId)
    if taskCfg then
      self.loopData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
      self.loopData.desc = taskCfg.Desc
      self.loopData.prize = taskCfg.Prize:Get(1).ItemAmount
    end
    self.view:UpdateLoopTaskItem(self.loopData)
  end
end
function BattlePassTaskMediator:processWeekTaskData(proxy)
  local weekCnt = proxy:GetSeasonWeekCount()
  self.subWeekTaskFlushTimeList = {}
  self.subWeekTaskList = {}
  local findCurrentWeek = false
  for weekId = 1, weekCnt do
    self.subWeekTaskFlushTimeList[weekId] = proxy:GetSubWeekTaskUnlockTime(weekId) - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    if not findCurrentWeek and self.subWeekTaskFlushTimeList[weekId] > 0 then
      findCurrentWeek = true
      self.currentWeekId = weekId - 1
    end
    local inWeekTasks = proxy:GetWeekTasksById(weekId)
    local subWeekDatas = {}
    for key, value in pairs(inWeekTasks) do
      local weekData = {}
      weekData.taskId = value.taskId
      weekData.type = GlobalEnumDefine.EBattlePassTaskType.kWeekTask
      weekData.value = value.progressMap[1] or 0
      weekData.state = value.state
      local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetWeekTaskCfgById(value.taskId)
      if taskCfg then
        weekData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
        weekData.desc = taskCfg.Desc
        weekData.prize = taskCfg.Prize:Get(1).ItemAmount
      end
      table.insert(subWeekDatas, weekData)
    end
    self.subWeekTaskList[weekId] = subWeekDatas
  end
  if not self.currentWeekId then
    self.currentWeekId = weekCnt
  end
  local data = {
    inTime = proxy:GetSeasonFinshTime() - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime(),
    inTaskType = GlobalEnumDefine.EBattlePassTaskType.kWeekTask
  }
  self.view:UpdateWeekTaskType(data)
  self.view:UpdateSubWeekTaskTypes(self.subWeekTaskFlushTimeList, self.currentWeekId)
end
function BattlePassTaskMediator:ClickDayTask()
  self.view:UpdateDayTaskItems(self.dayTaskList)
end
function BattlePassTaskMediator:ClickWeekTask()
  self.view:UpdateSubWeekTaskItems(self.currentWeekId, self.subWeekTaskList[self.currentWeekId])
  self.view:UpdateCurrentWeek(self.currentWeekId)
end
function BattlePassTaskMediator:ClickSubWeekTask(weekId)
  self.view:UpdateSubWeekTaskItems(weekId, self.subWeekTaskList[weekId])
end
function BattlePassTaskMediator:ClickRefreshTask(taskId)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if bpProxy then
    self.refreshTaskId = taskId
    local cnt = bpProxy:GetTaskRefreshCnt()
    local cfgMax = bpProxy:GetTaskRefreshCfgMax()
    local nextCnt = cnt >= cfgMax and cfgMax or cnt + 1
    local refreshCfg = bpProxy:GetTaskRefreshCfgByCnt(nextCnt)
    if refreshCfg then
      local cost = refreshCfg.Prize:Get(1).ItemAmount
      local currencyId = refreshCfg.Prize:Get(1).ItemId
      if cost > 0 then
        local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
        local tipText = ""
        if itemsProxy then
          local currencyCfg = itemsProxy:GetCurrencyConfig(currencyId)
          if currencyCfg then
            local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_BattlePass, "DayTaskRefresh")
            local stringMap = {
              ItemCnt = cost,
              ItemType = currencyCfg.Name
            }
            tipText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
          end
        end
        local pageData = {
          contentTxt = tipText,
          source = self,
          cb = self.MsgDialogCb
        }
        ViewMgr:OpenPage(self.view, UIPageNameDefine.MsgDialogPage, false, pageData)
      else
        self:MsgDialogCb(true)
      end
    end
  end
end
function BattlePassTaskMediator:MsgDialogCb(bIsConfirm)
  if bIsConfirm then
    GameFacade:SendNotification(NotificationDefines.BattlePass.TaskChangeCmd, self.refreshTaskId)
  end
end
return BattlePassTaskMediator
