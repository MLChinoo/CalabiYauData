local GuideSubTaskMediator = class("GuideSubTaskMediator", PureMVC.Mediator)
local ModuleNotificationDefines = NotificationDefines.Guide
local ESlateVisibility = UE4.ESlateVisibility
function GuideSubTaskMediator:ListNotificationInterests()
  return {
    ModuleNotificationDefines.GuideSubTask
  }
end
function GuideSubTaskMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnInitPanelEvent:Add(self.OnGuideSubTaskInit, self)
end
function GuideSubTaskMediator:OnRemove()
  if self.DelayShowTask then
    self.DelayShowTask:EndTask()
    self.DelayShowTask = nil
  end
end
function GuideSubTaskMediator:HandleNotification(notification)
  local notificationType = notification:GetType()
  if ModuleNotificationDefines.GuideSubTaskType.Update == notificationType then
    self:OnGuideSubTaskUpdate(notification:GetBody())
  end
end
function GuideSubTaskMediator:OnViewComponentPagePreOpen()
  if self.viewComponent then
    self.viewComponent:SetVisibility(ESlateVisibility.Collapsed)
  end
end
function GuideSubTaskMediator:OnGuideSubTaskInit(InData)
  local viewComponent = self.viewComponent
  if not (InData and InData.SubTaskData and viewComponent) or self.bInit then
    return
  end
  LogInfo("GuideSubTaskMediator", "OnGuideSubTaskInit SubTaskId=%d", InData.SubTaskData.SubTaskId)
  self.bInit = true
  local SubTaskData = InData.SubTaskData
  self.SubTaskData = SubTaskData
  if viewComponent.TextBlock_Name then
    viewComponent.TextBlock_Name:SetText(SubTaskData.TaskName)
  end
  if viewComponent.CheckBox_State then
    viewComponent.CheckBox_State:SetCheckedState(UE4.ECheckBoxState.Unchecked)
  end
  local bShowKey = "string" == type(SubTaskData.KeyText) and #SubTaskData.KeyText > 0
  if viewComponent.HorizontalBox_Key then
    viewComponent.HorizontalBox_Key:SetVisibility(bShowKey and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
  end
  if bShowKey then
    if viewComponent.TextBlock_Key then
      viewComponent.TextBlock_Key:SetText(SubTaskData.KeyText)
    end
    if viewComponent.TextBlock_KeyStr then
      local bShowKeyStr = string.find(SubTaskData.KeyText, viewComponent.TextBlock_KeyStr:GetText())
      viewComponent.TextBlock_KeyStr:SetVisibility(bShowKeyStr and ESlateVisibility.Collapsed or ESlateVisibility.HitTestInvisible)
    end
  end
  local bShowTips = SubTaskData.TipDatas and #SubTaskData.TipDatas > 0
  if viewComponent.VerticalBox_Tips then
    viewComponent.VerticalBox_Tips:SetVisibility(bShowTips and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
  end
  if bShowTips and viewComponent.DynamicEntryBox_Tips then
    viewComponent.DynamicEntryBox_Tips:Reset(true)
    local ItemWidget
    for _, TipData in ipairs(SubTaskData.TipDatas) do
      ItemWidget = viewComponent.DynamicEntryBox_Tips:BP_CreateEntry()
      if ItemWidget then
        ItemWidget:InitPanel({TipData = TipData})
      end
    end
  end
  viewComponent:StopAllAnimations()
  if InData.SubTaskIndex <= 1 or not TimerMgr then
    self:ShowSubTaskBeginAnim()
  else
    viewComponent:SetVisibility(ESlateVisibility.Hidden)
    local DelayInterval = viewComponent.ShowAnimDelayInterval or 0.1
    self.DelayShowTask = TimerMgr:AddTimeTask(DelayInterval * (InData.SubTaskIndex - 1), 0, 0, function()
      self:ShowSubTaskBeginAnim()
    end)
  end
end
function GuideSubTaskMediator:OnGuideSubTaskUpdate(InData)
  local viewComponent = self.viewComponent
  if not self.SubTaskData or self.SubTaskData.SubTaskId ~= InData.SubTaskId or self.SubTaskData.TaskState ~= UE4.ECyGuideSubTaskStateType.Begin or not viewComponent then
    return
  end
  LogInfo("GuideSubTaskMediator", "OnGuideSubTaskUpdate SubTaskId=%d", InData.SubTaskId)
  self.SubTaskData.TaskState = InData.TaskState
  if UE4.ECyGuideSubTaskStateType.Finish == InData.TaskState then
    if viewComponent.CheckBox_State then
      viewComponent.CheckBox_State:SetCheckedState(UE4.ECheckBoxState.Checked)
    end
    if viewComponent.Anim_Finish then
      viewComponent:PlayAnimation(viewComponent.Anim_Finish, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    end
    if viewComponent.AkOnTaskFinish then
      viewComponent:K2_PostAkEvent(viewComponent.AkOnTaskFinish, false)
    end
  elseif UE4.ECyGuideSubTaskStateType.Failed == InData.TaskState then
    if viewComponent.Anim_Fail then
      viewComponent:PlayAnimation(viewComponent.Anim_Fail, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    end
    if viewComponent.AkOnTaskFailed then
      viewComponent:K2_PostAkEvent(viewComponent.AkOnTaskFailed, false)
    end
  end
end
function GuideSubTaskMediator:ShowSubTaskBeginAnim()
  self.DelayShowTask = nil
  local viewComponent = self.viewComponent
  if not viewComponent or not viewComponent:IsValid() then
    return
  end
  viewComponent:SetVisibility(ESlateVisibility.HitTestInvisible)
  if viewComponent.Anim_Begin then
    viewComponent:PlayAnimation(viewComponent.Anim_Begin, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end
return GuideSubTaskMediator
