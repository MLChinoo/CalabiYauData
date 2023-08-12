local ResultRoleTaskPanel_PC = class("ResultRoleTaskPanel_PC", PureMVC.ViewComponentPanel)
local ProgressAniTimePeriod = 1
function ResultRoleTaskPanel_PC:OnListItemObjectSet(ResultRoleTaskDataObject)
  local RoleTask = table.clone(ResultRoleTaskDataObject.TaskData)
  self.RoleTask = RoleTask
  self.RoleTask.CurProgress = self.RoleTask.PreTaskProgress
  self.TextTaskName:SetText(RoleTask.taskDesc)
  self.Particle_TaskComplete:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.AddExp = self.RoleTask.taskProgress - self.RoleTask.PreTaskProgress
  self.AddedExp = 0
  self.ProgressAniTimeTotal = self.AddExp / self.RoleTask.taskTarget * ProgressAniTimePeriod
  self.ProgressAniTime = self.ProgressAniTimeTotal > 0 and 0 or nil
  self.SwitcherHeart:SetActiveWidgetIndex(0)
  self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:UpdateProgress()
end
local MaxProgressWidth = 510
function ResultRoleTaskPanel_PC:UpdateProgress()
  self.TextTaskProgress:SetText(string.format("%s/%s", math.floor(self.RoleTask.CurProgress), math.floor(self.RoleTask.taskTarget)))
  self.ProgressTask:SetPercent(self.RoleTask.CurProgress / self.RoleTask.taskTarget)
  local percent = self.RoleTask.CurProgress / self.RoleTask.taskTarget
  percent = percent > 1 and 1 or percent
  self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth * percent, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
  if self.RoleTask.CurProgress >= self.RoleTask.taskTarget then
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "TaskFinish")
    self.TextTaskProgress:SetText(str)
    self.SwitcherHeart:SetActiveWidgetIndex(1)
    if self.Particle_TaskComplete:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      self.Particle_TaskComplete:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Particle_TaskComplete:SetReactivate(true)
    else
      self.Particle_TaskComplete:SetReactivate(true)
    end
  end
end
function ResultRoleTaskPanel_PC:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime >= self.ProgressAniTimeTotal then
    self:StopProgressAni()
  end
  if self.ProgressAniTime and self.ProgressAniTime <= self.ProgressAniTimeTotal then
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, self.ProgressAniTimeTotal)
    local CurAddExp = self.AddExp * (self.ProgressAniTime / self.ProgressAniTimeTotal) - self.AddedExp
    self.RoleTask.CurProgress = self.RoleTask.CurProgress + CurAddExp
    self.RoleTask.CurProgress = math.clamp(self.RoleTask.CurProgress, 0, self.RoleTask.taskProgress)
    self:UpdateProgress()
    self.AddedExp = self.AddedExp + CurAddExp
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.ShowTime then
      self.ShowTime = os.time()
    end
    if self.RoleTask.CurProgress >= self.RoleTask.taskTarget then
      self:StopProgressAni()
    end
  end
end
function ResultRoleTaskPanel_PC:StopProgressAni()
  self.ProgressAniTime = nil
  self.RoleTask.CurProgress = self.RoleTask.taskProgress
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
function ResultRoleTaskPanel_PC:IsProgressAniPlaying()
  return self.ProgressAniTime and 0 ~= self.ProgressAniTime
end
function ResultRoleTaskPanel_PC:GetProgressAniMaxTime()
  return self.ProgressAniTimeTotal
end
return ResultRoleTaskPanel_PC
