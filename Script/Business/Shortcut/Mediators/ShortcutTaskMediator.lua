local ShortcutTaskMediator = class("ShortcutTaskMediator", PureMVC.Mediator)
local SHOWNUM = 3
function ShortcutTaskMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.TaskUpdate
  }
end
function ShortcutTaskMediator:OnRegister()
  self:GetViewComponent().updateViewEvent:Add(self.UpdateViewData, self)
end
function ShortcutTaskMediator:OnRemove()
  self:GetViewComponent().updateViewEvent:Remove(self.UpdateViewData, self)
end
function ShortcutTaskMediator:UpdateViewData()
  GameFacade:SendNotification(NotificationDefines.BattlePass.TaskUpdateCmd)
end
function ShortcutTaskMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.BattlePass.TaskUpdate then
    local proxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    if proxy then
      self:ProcessLoopTaskData(proxy:GetLoopTasks())
      self:ProcessDayTaskData(proxy:GetDayTasks(), proxy:GetNextDayFlushTime())
      self:ProcessWeekTaskData(proxy)
    end
  end
end
function ShortcutTaskMediator:ProcessLoopTaskData(inLoopTasks)
  if table.count(inLoopTasks) < 1 then
    return
  end
  local loopData = {}
  local taskData = inLoopTasks[1]
  loopData.value = taskData.progressMap[1] or 0
  loopData.state = taskData.state
  local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetLoopTaskCfgById(taskData.taskId)
  if taskCfg then
    loopData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
    loopData.desc = taskCfg.Desc
    loopData.prize = taskCfg.Prize:Get(1).ItemAmount
  else
    LogError("ShortcutTaskMediator", "//TaskId = %s, 服务器下发的任务ID和策划配置的任务ID不一致,找策划", taskData.taskId)
  end
  self:GetViewComponent():UpdateLoopTaskItems(loopData)
end
function ShortcutTaskMediator:ProcessDayTaskData(inDayTasks, flushTime)
  if table.count(inDayTasks) < 1 then
    return
  end
  local dayDatas = {}
  for key, value in pairs(inDayTasks) do
    local dayData = {}
    dayData.value = value.progressMap[1] or 0
    dayData.state = value.state
    local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetDayTaskCfgById(value.taskId)
    if taskCfg then
      dayData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
      dayData.desc = taskCfg.Desc
      dayData.prize = taskCfg.Prize:Get(1).ItemAmount
    else
      LogError("ShortcutTaskMediator", "//TaskId = %s, 服务器下发的任务ID和策划配置的任务ID不一致,找策划", value.taskId)
    end
    table.insert(dayDatas, dayData)
  end
  self:GetViewComponent():UpdateDayTaskItems(dayDatas)
  local basicFuncProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  local countDown = 0
  if basicFuncProxy then
    local serverEquationOfTime = basicFuncProxy:GetParameterIntValue("9999")
    countDown = flushTime - (UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() + serverEquationOfTime * 60 * 60)
  end
  self:GetViewComponent():UpdateFlushTime(countDown)
end
function ShortcutTaskMediator:ProcessWeekTaskData(proxy)
  local inWeekTasks = proxy:GetWeekTasks()
  if table.count(inWeekTasks) < 1 then
    return
  end
  local currentWeekId = proxy:GetCurrentWeek()
  local weekDatas = {}
  for key, value in pairs(inWeekTasks) do
    local weekData = {}
    weekData.value = value.progressMap[1] or 0
    weekData.state = value.state
    local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetWeekTaskCfgById(value.taskId)
    if taskCfg then
      weekData.targetValue = taskCfg.TaskConditions:Get(1).MainCondition.Num
      weekData.weekId = taskCfg.Week
      weekData.desc = taskCfg.Desc
      weekData.prize = taskCfg.Prize:Get(1).ItemAmount
      weekData.proRate = weekData.value / weekData.targetValue
    else
      LogError("ShortcutTaskMediator", "//TaskId = %s, 服务器下发的任务ID和策划配置的任务ID不一致,找策划", value.taskId)
    end
    table.insert(weekDatas, weekData)
  end
  table.sort(weekDatas, function(a, b)
    return a.proRate > b.proRate
  end)
  local currentWeekfinishList = {}
  local currentWeekTodoList = {}
  local lastWeekTodoList = {}
  for index, value in ipairs(weekDatas) do
    if value.proRate < 1 then
      if value.weekId == currentWeekId then
        table.insert(currentWeekTodoList, value)
      else
        table.insert(lastWeekTodoList, value)
      end
    elseif value.weekId == currentWeekId then
      table.insert(currentWeekfinishList, value)
    end
  end
  local threeDatas = {}
  local breakNum = SHOWNUM
  while breakNum > 0 do
    local task
    task = table.remove(currentWeekTodoList, 1)
    task = task or table.remove(lastWeekTodoList, 1)
    task = task or table.remove(currentWeekfinishList, 1)
    if task then
      table.insert(threeDatas, task)
    end
    breakNum = breakNum - 1
  end
  table.sort(threeDatas, function(a, b)
    if a.proRate >= 1 then
      return false
    end
    if b.proRate >= 1 then
      return false
    end
    return a.proRate > b.proRate
  end)
  self:GetViewComponent():UpdateWeekTaskItems(threeDatas)
end
return ShortcutTaskMediator
