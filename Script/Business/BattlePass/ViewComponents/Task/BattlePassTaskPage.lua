local BattlePassTaskPage = class("BattlePassTaskPage", PureMVC.ViewComponentPage)
local BattlePassTaskMediator = require("Business/BattlePass/Mediators/BattlePassTaskMediator")
function BattlePassTaskPage:ListNeededMediators()
  return {BattlePassTaskMediator}
end
function BattlePassTaskPage:InitializeLuaEvent()
  self.dayTaskClickEvent = LuaEvent.new()
  self.weekTaskClickEvent = LuaEvent.new()
  self.subWeekTaskClickEvent = LuaEvent.new()
  self.taskRefreshEvent = LuaEvent.new()
  self.curSelectedWeekId = 0
  self.taskItems = {}
  self.subWeekTaskTypes = {}
end
function BattlePassTaskPage:OnOpen(luaOpenData, nativeOpenData)
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  self:StartRestTimer()
end
function BattlePassTaskPage:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Anim_PanelIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassTaskPage:OnClose()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  self:DestoryRestTimer()
end
function BattlePassTaskPage:OnBtnDayType()
  self.dayTaskClickEvent()
end
function BattlePassTaskPage:OnBtnWeekType()
  self.weekTaskClickEvent()
end
function BattlePassTaskPage:OnBtnSubWeekType(weekId)
  self.subWeekTaskClickEvent(weekId)
end
function BattlePassTaskPage:OnBtnFlushTask(clickItem)
  self.flushItem = clickItem
  self.taskRefreshEvent(clickItem.taskId)
end
function BattlePassTaskPage:OnEscHotKeyClick()
  LogInfo("BattlePassTaskPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function BattlePassTaskPage:UpdateDayTaskType(data)
  if self.DayTaskTypeItem then
    self.DayTaskTypeItem:UpdateView(self, data)
  end
end
function BattlePassTaskPage:UpdateWeekTaskType(data)
  if self.WeekTaskTypeItem then
    self.WeekTaskTypeItem:UpdateView(self, data)
  end
end
function BattlePassTaskPage:UpdateDayTaskItems(data, inIsFlush)
  for index, value in ipairs(data) do
    local taskItem
    if index <= #self.taskItems then
      taskItem = self.taskItems[index]
    else
      taskItem = self.DynamicEntryBox_TaskItem:BP_CreateEntry()
      table.insert(self.taskItems, taskItem)
    end
    taskItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    taskItem:UpdateView(self, value)
  end
  for index = #data + 1, #self.taskItems do
    self.taskItems[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 ~= self.curSelectedWeekId then
    if self.subWeekTaskTypes[self.curSelectedWeekId] then
      self.subWeekTaskTypes[self.curSelectedWeekId]:SetSelected(false)
    end
    self.curSelectedWeekId = 0
  end
  self.DayTaskTypeItem:SetSelected(true)
  self.WeekTaskTypeItem:SetSelected(false)
  if inIsFlush and self.flushItem then
    self.flushItem:FlushAnim()
    self.flushItem = nil
  end
end
function BattlePassTaskPage:UpdateLoopTaskItem(data)
  if self.LoopTaskItem then
    self.LoopTaskItem:UpdateView(self, data)
  end
end
function BattlePassTaskPage:UpdateSubWeekTaskTypes(data, currentWeekID)
  for weekId, time in ipairs(data) do
    local typeItem
    if weekId <= #self.subWeekTaskTypes then
      typeItem = self.subWeekTaskTypes[weekId]
    else
      typeItem = self.DynamicEntryBox_SubWeek:BP_CreateEntry()
      self.subWeekTaskTypes[weekId] = typeItem
    end
    typeItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    typeItem:UpdateView(self, {
      inWeekId = weekId,
      inTime = time,
      bCurrentWeek = weekId == currentWeekID
    })
  end
  for index = #data + 1, #self.subWeekTaskTypes do
    self.subWeekTaskTypes[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassTaskPage:UpdateSubWeekTaskItems(weekId, data)
  for index, value in ipairs(data) do
    local taskItem
    if index <= #self.taskItems then
      taskItem = self.taskItems[index]
    else
      taskItem = self.DynamicEntryBox_TaskItem:BP_CreateEntry()
      table.insert(self.taskItems, taskItem)
    end
    taskItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    taskItem:UpdateView(self, value)
  end
  for index = #data + 1, #self.taskItems do
    self.taskItems[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 ~= self.curSelectedWeekId then
    if self.subWeekTaskTypes[self.curSelectedWeekId] then
      self.subWeekTaskTypes[self.curSelectedWeekId]:SetSelected(false)
    end
  else
    self.DayTaskTypeItem:SetSelected(false)
  end
  self.curSelectedWeekId = weekId
  if self.subWeekTaskTypes[self.curSelectedWeekId] then
    self.subWeekTaskTypes[self.curSelectedWeekId]:SetSelected(true)
  end
  self.WeekTaskTypeItem:SetSelected(false)
end
function BattlePassTaskPage:UpdateCurrentWeek(weekId)
  self.WeekTaskTypeItem:SetSelected(true)
end
function BattlePassTaskPage:SeasonIntermission()
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
function BattlePassTaskPage:StartRestTimer()
  self:DestoryRestTimer()
  if self.updateTimer == nil then
    self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local intervalTime = 60
    local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    self.updateTimer = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      local bHide = BattlePassProxy:CheckHideRestTime()
      if bHide then
        self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local showTime = BattlePassProxy:GetSeasonFinishRestShowTime()
        if showTime then
          self.TextBlock_RestTime:SetText(showTime)
        else
          self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self:DestoryRestTimer()
        end
      end
    end)
  end
end
function BattlePassTaskPage:DestoryRestTimer()
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
return BattlePassTaskPage
