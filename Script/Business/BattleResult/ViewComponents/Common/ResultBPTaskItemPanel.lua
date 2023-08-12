local ResultBPTaskItemPanel = class("ResultBPTaskItemPanel", PureMVC.ViewComponentPanel)
local ProgressAniTimePeriod = 1
function ResultBPTaskItemPanel:OnListItemObjectSet(ResultBPTaskDataObject)
  self.Task = table.clone(ResultBPTaskDataObject.Task)
  if not self.Task then
    LogError("ResultBPTaskItemPanel", "self.Task = nil")
    return
  end
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local TaskCfg = BattlePassProxy:GetTaskCfgById(self.Task.taskId)
  if not TaskCfg then
    LogError("TaskCfg", "Task table not found (taskId=%s)", self.Task.taskId)
    return
  end
  self.TextTaskName:SetText(TaskCfg.Desc)
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local BPTaskPreBattle = battleResultProxy:GetBPTaskPreBattle(self.Task.taskId)
  self.Task.PreTaskProgress = 0
  if BPTaskPreBattle then
    self.Task.PreTaskProgress = BPTaskPreBattle.progressMap[1]
  end
  self.Task.CurTaskProgress = self.Task.PreTaskProgress
  self.Task.NewTaskProgress = self.Task.progressMap[1]
  self.Task.taskTarget = TaskCfg.TaskConditions:Get(1).MainCondition.Num
  self.Text_Num:SetText(TaskCfg.Prize:Get(1).ItemAmount)
  self.AddExp = self.Task.NewTaskProgress - self.Task.PreTaskProgress
  self.ProgressAniTimeTotal = self.AddExp / self.Task.taskTarget * ProgressAniTimePeriod
  self.ProgressAniTime = self.ProgressAniTimeTotal > 0 and 0 or nil
  self.ParticleSystemWidget_Complete:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
end
local MaxProgressWidth = 510
function ResultBPTaskItemPanel:UpdateProgress()
  self.TextTaskProgress:SetText(string.format("%s/%s", math.floor(self.Task.CurTaskProgress), math.floor(self.Task.taskTarget)))
  self.ProgressTask:SetPercent(self.Task.CurTaskProgress / self.Task.taskTarget)
  local percent = self.Task.CurTaskProgress / self.Task.taskTarget
  percent = percent > 1 and 1 or percent
  self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth * percent, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
  if self.Task.CurTaskProgress >= self.Task.taskTarget then
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "TaskFinish")
    self.TextTaskProgress:SetText(str)
    self.SwitcherIcon:SetActiveWidgetIndex(1)
    if self.ParticleSystemWidget_Complete:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      self.ParticleSystemWidget_Complete:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function ResultBPTaskItemPanel:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime >= self.ProgressAniTimeTotal then
    self:StopProgressAni()
  end
  if self.ProgressAniTime and self.ProgressAniTime <= self.ProgressAniTimeTotal then
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, self.ProgressAniTimeTotal)
    self.Task.CurTaskProgress = self.Task.PreTaskProgress + self.AddExp * (self.ProgressAniTime / self.ProgressAniTimeTotal)
    self.Task.CurTaskProgress = math.clamp(self.Task.CurTaskProgress, 0, self.Task.NewTaskProgress)
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.ShowTime then
      self.ShowTime = os.time()
    end
    self:UpdateProgress()
    if self.Task.CurTaskProgress >= self.Task.taskTarget then
      self:K2_PostAkEvent(self.AK_Map:Find("TaskFinish"), true)
      self:StopProgressAni()
    end
  end
end
function ResultBPTaskItemPanel:StopProgressAni()
  self.ProgressAniTime = nil
  self.Task.CurTaskProgress = self.Task.NewTaskProgress
  self:UpdateProgress()
  local AniShowTime = 0.5
  if self.ShowTime and AniShowTime > self.ShowTime then
    TimerMgr:AddTimeTask(AniShowTime - self.ShowTime, 0, 1, function()
      self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
    end)
  else
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
function ResultBPTaskItemPanel:IsProgressAniPlaying()
  return self.ProgressAniTime and 0 ~= self.ProgressAniTime
end
function ResultBPTaskItemPanel:GetProgressAniMaxTime()
  return self.ProgressAniTimeTotal
end
return ResultBPTaskItemPanel
