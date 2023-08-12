local BattlePassTaskTypeItem = class("BattlePassTaskTypeItem", PureMVC.ViewComponentPanel)
function BattlePassTaskTypeItem:Construct()
  BattlePassTaskTypeItem.super.Construct(self)
  if self.Btn_Type then
    self.Btn_Type.OnPMButtonClicked:Add(self, self.OnBtnClick)
  end
  self.isSelected = false
end
function BattlePassTaskTypeItem:Destruct()
  BattlePassTaskTypeItem.super.Destruct(self)
  if self.Btn_Type then
    self.Btn_Type.OnPMButtonClicked:Remove(self, self.OnBtnClick)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
end
function BattlePassTaskTypeItem:OnBtnClick()
  if self.isSelected then
    return
  end
  if self.parentPage then
    if self.taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
      self.parentPage:OnBtnDayType()
    elseif self.taskType == GlobalEnumDefine.EBattlePassTaskType.kWeekTask then
      self.parentPage:OnBtnWeekType()
    end
  end
end
function BattlePassTaskTypeItem:SetSelected(inSelected)
  self.isSelected = inSelected
  if inSelected then
    self.Btn_Type:SetForceBrush(UE4.EForceButtonBrush.Pressed)
  else
    self.Btn_Type:SetForceBrush(UE4.EForceButtonBrush.None)
  end
end
function BattlePassTaskTypeItem:UpdateView(parent, data)
  self.parentPage = parent
  self.taskType = data.inTaskType
  self.time = data.inTime
  if self.Switcher_Desc then
    if self.taskType == GlobalEnumDefine.EBattlePassTaskType.kWeekTask then
      self.Switcher_Desc:SetActiveWidgetIndex(2)
    elseif self.taskType == GlobalEnumDefine.EBattlePassTaskType.kDayTask then
      self.Switcher_Desc:SetActiveWidgetIndex(0)
    end
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  self:DrawRemainingTimeTxt()
  self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
    self:RemainingTimeTxt()
  end)
end
function BattlePassTaskTypeItem:RemainingTimeTxt()
  if self.time <= 0 then
    return
  end
  self.time = self.time - 1
  self:DrawRemainingTimeTxt()
end
function BattlePassTaskTypeItem:DrawRemainingTimeTxt()
  local timeTable = FunctionUtil:FormatTime(self.time)
  local outText
  if timeTable.Day > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
    local stringMap = {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  elseif timeTable.Hour > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
    local stringMap = {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  else
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Minutes")
    local stringMap = {
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  end
  if self.Txt_RemainingTime then
    outText = outText .. ConfigMgr:FromStringTable(StringTablePath.ST_BattlePass, "TimeUpdate")
    self.Txt_RemainingTime:SetText(outText)
  end
end
return BattlePassTaskTypeItem
