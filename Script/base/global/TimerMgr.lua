local TimesRelatedTask = class("TimesRelatedTask")
function TimesRelatedTask:ctor(delay, period, runTimes, funcHandle)
  self.delay = delay or 0
  self.period = period or 0
  self.runTimes = runTimes or 1
  self.funcHandle = funcHandle
  self.accumulateTime = nil
  self.haveRunTimes = 0
  self.firstRun = false
  self.bFinished = false
  self.bPaused = false
  if 0 == delay then
    self.funcHandle()
    self.haveRunTimes = 1
    self.firstRun = true
    if self.runTimes > 0 and self.runTimes <= 1 then
      self.bFinished = true
    end
  end
  self.accumulateTime = 0
end
function TimesRelatedTask:FinishedTask()
  self.funcHandle()
  self.bFinished = true
end
function TimesRelatedTask:EndTask()
  self.bFinished = true
end
function TimesRelatedTask:IsFinished()
  return self.bFinished
end
function TimesRelatedTask:PauseTask()
  self.bPaused = true
end
function TimesRelatedTask:UnPauseTask()
  self.bPaused = false
end
function TimesRelatedTask:IsPaused()
  return self.bPaused
end
function TimesRelatedTask:Tick(deltaTime)
  if self.bFinished and self.bPaused then
    return
  end
  self.accumulateTime = self.accumulateTime + deltaTime
  if not self.firstRun then
    if self.accumulateTime >= self.delay then
      self.funcHandle()
      self.haveRunTimes = 1
      self.firstRun = true
    end
  elseif self.period <= 0 then
    self.bFinished = true
  else
    if self.accumulateTime >= self.period then
      self.funcHandle()
      self.haveRunTimes = self.haveRunTimes + 1
      self.accumulateTime = 0
    end
    if 0 ~= self.runTimes and self.haveRunTimes >= self.runTimes then
      self.bFinished = true
    end
  end
end
local FrameTask = class("FrameTask", TimesRelatedTask)
function FrameTask:Tick(deltaTime)
  self.super.Tick(self, 1)
end
local TimerMgr = class("TimerMgr")
function TimerMgr:ctor(tickHandler)
  self.taskList = {}
  tickHandler:Add(self.Tick, self)
end
function TimerMgr:Tick(deltaTime)
  for i = #self.taskList, 1, -1 do
    local task = self.taskList[i]
    if task:IsFinished() then
      table.remove(self.taskList, i)
    elseif task:IsPaused() then
    else
      task:Tick(deltaTime)
    end
  end
end
function TimerMgr:AddTimeTask(delayTime, periodTime, maxRunTimes, funcHandle)
  local task = TimesRelatedTask.new(delayTime, periodTime, maxRunTimes, funcHandle)
  table.insert(self.taskList, task)
  return task
end
function TimerMgr:RunNextFrame(funcHandle)
  local task = FrameTask.new(1, 0, 1, funcHandle)
  table.insert(self.taskList, task)
  return task
end
function TimerMgr:AddFrameTask(delayFrame, periodFrame, maxRunTimes, funcHandle)
  local task = FrameTask.new(delayFrame, periodFrame, maxRunTimes, funcHandle)
  table.insert(self.taskList, task)
  return task
end
return TimerMgr
