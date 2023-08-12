local SummerThemeSongDailyFlipTimesPage = class("SummerThemeSongDailyFlipTimesPage", PureMVC.ViewComponentPage)
function SummerThemeSongDailyFlipTimesPage:ListNeededMediators()
  return {}
end
function SummerThemeSongDailyFlipTimesPage:Construct()
  SummerThemeSongDailyFlipTimesPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryTaskPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.bActiveClosePage = false
  self.delayActiveClosePageFunctionTime = 0.8
  self.delayActiveClosePageFunctionHandle = TimerMgr:AddTimeTask(self.delayActiveClosePageFunctionTime, 0, 1, function()
    self.bActiveClosePage = true
  end)
  local taskIdList = SummerThemeSongProxy:GetScTaskIdList()
  if taskIdList and #taskIdList > 0 then
    table.sort(taskIdList, function(a, b)
      return a < b
    end)
    local taskItemListNum = self.VB_TaskItemList:GetChildrenCount()
    for index = 0, taskItemListNum - 1 do
      local taskItem = self.VB_TaskItemList:GetChildAt(index)
      if taskItem then
        local taskNum = taskItem:GetTaskNumber()
        local taskId = taskIdList[taskNum]
        if taskId then
          taskItem:SetTaskId(taskId)
          taskItem:InitTaskItemData()
        end
      end
    end
    self:DelayUpdateTaskTotalRewardTimesTimerHandle()
  else
    LogInfo("SummerThemeSongDailyFlipTimesPage Construct:", "taskIdList is nil")
  end
end
function SummerThemeSongDailyFlipTimesPage:Destruct()
  SummerThemeSongDailyFlipTimesPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self:ClearTimerHandle()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.QuitTaskPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:ClearDelayActiveClosePageHandle()
end
function SummerThemeSongDailyFlipTimesPage:DelayUpdateTaskTotalRewardTimesTimerHandle()
  self:ClearTimerHandle()
  self.updateTaskTotalRewardTimesTimerHandle = TimerMgr:AddTimeTask(0.05, 0, 1, function()
    self:UpdateTaskTotalRewardTimes()
  end)
end
function SummerThemeSongDailyFlipTimesPage:ClearTimerHandle()
  if self.updateTaskTotalRewardTimesTimerHandle then
    self.updateTaskTotalRewardTimesTimerHandle:EndTask()
    self.updateTaskTotalRewardTimesTimerHandle = nil
  end
end
function SummerThemeSongDailyFlipTimesPage:OnClickClosePage()
  if self.bActiveClosePage then
    ViewMgr:ClosePage(self)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SummerThemeSongDailyFlipTimesPage:UpdateTaskTotalRewardTimes()
  local taskTotalRewardTimes = 0
  local taskItemListNum = self.VB_TaskItemList:GetChildrenCount()
  for index = 0, taskItemListNum - 1 do
    local taskItem = self.VB_TaskItemList:GetChildAt(index)
    if taskItem then
      taskTotalRewardTimes = taskTotalRewardTimes + taskItem:GetTaskRewardTimesIfTaskUnCompeleted()
    end
  end
  self.Txt_CalculateFlipTimesTips:SetText(tostring(taskTotalRewardTimes))
end
function SummerThemeSongDailyFlipTimesPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
    return true
  end
  return false
end
function SummerThemeSongDailyFlipTimesPage:ClearDelayActiveClosePageHandle()
  if self.delayActiveClosePageFunctionHandle then
    self.delayActiveClosePageFunctionHandle:EndTask()
    self.delayActiveClosePageFunctionHandle = nil
  end
end
return SummerThemeSongDailyFlipTimesPage
