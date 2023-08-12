local ShortcutTaskMediator = require("Business/Shortcut/Mediators/ShortcutTaskMediator")
local ShortcutTaskPanel = class("ShortcutTaskPanel", PureMVC.ViewComponentPanel)
function ShortcutTaskPanel:ListNeededMediators()
  return {ShortcutTaskMediator}
end
function ShortcutTaskPanel:InitializeLuaEvent()
  self.updateViewEvent = LuaEvent.new()
  self.dayTaskItems = {}
  self.weekTaskItems = {}
end
function ShortcutTaskPanel:Construct()
  ShortcutTaskPanel.super.Construct(self)
  if self.IsShowNavigationBtn then
    self.Btn_GotoTaskPage:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_GotoTaskPage.OnClicked:Add(self, ShortcutTaskPanel.OnClickGotoBattlePassTask)
  else
    self.Btn_GotoTaskPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.updateViewEvent()
end
function ShortcutTaskPanel:Destruct()
  ShortcutTaskPanel.super.Destruct(self)
  if self.IsShowNavigationBtn then
    self.Btn_GotoTaskPage.OnClicked:Remove(self, ShortcutTaskPanel.OnClickGotoBattlePassTask)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
end
function ShortcutTaskPanel:OnMouseEnter(MyGrometry, MouseEvent)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
end
function ShortcutTaskPanel:OnMouseLeave(MyGrometry)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ShortcutTaskPanel:OnClickGotoBattlePassTask()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, {
    pageType = UE4.EPMFunctionTypes.BattlePass,
    secondIndex = 3
  })
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ShortcutTaskPanel:UpdateLoopTaskItems(data)
  self.LoopTaskItem:UpdateView(data)
end
function ShortcutTaskPanel:UpdateDayTaskItems(data)
  for index, value in ipairs(data) do
    local taskItem
    if index <= table.count(self.dayTaskItems) then
      taskItem = self.dayTaskItems[index]
    else
      taskItem = self.DynamicEntryBox_Day:BP_CreateEntry()
      table.insert(self.dayTaskItems, taskItem)
    end
    taskItem:UpdateView(value)
  end
end
function ShortcutTaskPanel:UpdateWeekTaskItems(data)
  for index, value in ipairs(data) do
    local taskItem
    if index <= table.count(self.weekTaskItems) then
      taskItem = self.weekTaskItems[index]
    else
      taskItem = self.DynamicEntryBox_Week:BP_CreateEntry()
      table.insert(self.weekTaskItems, taskItem)
    end
    taskItem:UpdateView(value)
  end
end
function ShortcutTaskPanel:UpdateFlushTime(inTime)
  self.time = inTime
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  self.timerHandler = TimerMgr:AddTimeTask(0, 1, 0, function()
    self:RemainingTimeTxt()
  end)
end
function ShortcutTaskPanel:RemainingTimeTxt()
  if self.time <= 0 then
    if self.timerHandler then
      self.timerHandler:EndTask()
      self.timerHandler = nil
    end
    return
  end
  self.time = self.time - 1
  local timeTable = FunctionUtil:FormatTime(self.time)
  local outTxt = string.format("%02d : %02d : %02d", timeTable.Hour, timeTable.Minute, timeTable.Second)
  if self.Text_Time then
    self.Text_Time:SetText(outTxt)
  end
end
return ShortcutTaskPanel
