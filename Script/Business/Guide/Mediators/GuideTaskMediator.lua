local GuideTaskMediator = class("GuideTaskMediator", PureMVC.Mediator)
local ModuleProxyNames = ProxyNames
local ModuleNotificationDefines = NotificationDefines.Guide
local ESlateVisibility = UE4.ESlateVisibility
function GuideTaskMediator:ListNotificationInterests()
  return {
    ModuleNotificationDefines.GuideTask
  }
end
function GuideTaskMediator:HandleNotification(notification)
  local notificationType = notification:GetType()
  if ModuleNotificationDefines.GuideTaskType.Begin == notificationType then
    self:OnGuideTaskBegin(notification:GetBody())
  elseif ModuleNotificationDefines.GuideTaskType.Update == notificationType then
    self:OnGuideTaskUpdate(notification:GetBody())
  end
end
function GuideTaskMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  local World = viewComponent:GetWorld()
  if not World then
    return
  end
  if viewComponent then
    viewComponent:SetVisibility(ESlateVisibility.Collapsed)
  end
  if GameFacade then
    local GuideProxy = GameFacade:RetrieveProxy(ModuleProxyNames.GuideProxy)
    if GuideProxy then
      GuideProxy:TryInitGuideTask(World)
    end
  end
end
function GuideTaskMediator:OnRemove()
  if self.UIHideTask then
    self.UIHideTask:EndTask()
    self.UIHideTask = nil
  end
end
function GuideTaskMediator:OnGuideTaskBegin(InData)
  local viewComponent = self.viewComponent
  if not (InData and InData.TaskData) or not viewComponent then
    return
  end
  local TaskData = InData.TaskData
  self.TaskData = nil
  viewComponent:StopAllAnimations()
  viewComponent:SetVisibility(ESlateVisibility.Collapsed)
  if self.UIHideTask then
    self.UIHideTask:EndTask()
    self.UIHideTask = nil
  end
  if TaskData.TaskId <= 0 or TaskData.TaskState ~= UE4.ECyGuideTaskStateType.Begin or not TaskData.bShow then
    return
  end
  LogInfo("GuideTaskMediator", "OnGuideTaskBegin")
  self.TaskData = TaskData
  viewComponent:SetVisibility(ESlateVisibility.HitTestInvisible)
  if viewComponent.TextBlock_Name then
    viewComponent.TextBlock_Name:SetText(TaskData.TaskName)
  end
  if viewComponent.ParticleSystemWidget_TaskIcon then
    viewComponent.ParticleSystemWidget_TaskIcon:ActivateParticles(true, true)
    viewComponent.ParticleSystemWidget_TaskIcon:SetVisibility(ESlateVisibility.HitTestInvisible)
  end
  if viewComponent.DynamicEntryBox_SubTaskList then
    viewComponent.DynamicEntryBox_SubTaskList:Reset(true)
    local SubTaskIndex = 1
    local ItemWidget
    for _, SubTask in ipairs(TaskData.SubTasks) do
      if SubTask.bShow then
        ItemWidget = viewComponent.DynamicEntryBox_SubTaskList:BP_CreateEntry()
        if ItemWidget then
          ItemWidget:InitPanel({SubTaskIndex = SubTaskIndex, SubTaskData = SubTask})
        end
        SubTaskIndex = SubTaskIndex + 1
      end
    end
  end
  if viewComponent.Anim_Begin then
    viewComponent:PlayAnimation(viewComponent.Anim_Begin, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
  if viewComponent.AkOnTaskBegin then
    viewComponent:K2_PostAkEvent(viewComponent.AkOnTaskBegin, false)
  end
end
function GuideTaskMediator:OnGuideTaskUpdate(InData)
  local viewComponent = self.viewComponent
  if not (InData and self.TaskData) or not viewComponent then
    return
  end
  if self.TaskData.TaskId <= 0 or not self.TaskData.bShow then
    return
  end
  LogInfo("GuideTaskMediator", "OnGuideTaskUpdate")
  self.TaskData.TaskState = InData.TaskState
  if UE4.ECyGuideTaskStateType.Finish == InData.TaskState and not self.TaskData.bGuideEnd then
    if viewComponent.ParticleSystemWidget_TaskIcon then
      viewComponent.ParticleSystemWidget_TaskIcon:ActivateParticles(false, false)
      viewComponent.ParticleSystemWidget_TaskIcon:SetVisibility(ESlateVisibility.Collapsed)
    end
    if viewComponent.Anim_Finish then
      viewComponent:PlayAnimation(viewComponent.Anim_Finish, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    end
    if viewComponent.AkOnTaskFinish then
      viewComponent:K2_PostAkEvent(viewComponent.AkOnTaskFinish, false)
    end
    if TimerMgr and viewComponent.AkOnTaskUIHide then
      local DelayTime = viewComponent.UIHideDelay or 3.0
      self.UIHideTask = TimerMgr:AddTimeTask(DelayTime, 0, 0, function()
        self:UIHide()
      end)
    end
  end
end
function GuideTaskMediator:UIHide()
  self.UIHideTask = nil
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  if viewComponent.AkOnTaskUIHide then
    viewComponent:K2_PostAkEvent(viewComponent.AkOnTaskUIHide, false)
  end
end
return GuideTaskMediator
