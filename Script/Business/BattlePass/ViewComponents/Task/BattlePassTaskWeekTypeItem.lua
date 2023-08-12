local BattlePassTaskWeekTypeItem = class("BattlePassTaskWeekTypeItem", PureMVC.ViewComponentPanel)
function BattlePassTaskWeekTypeItem:Construct()
  BattlePassTaskWeekTypeItem.super.Construct(self)
  if self.Btn_Type then
    self.Btn_Type.OnPMButtonClicked:Add(self, self.OnBtnClick)
  end
  self.isSelected = false
end
function BattlePassTaskWeekTypeItem:Destruct()
  BattlePassTaskWeekTypeItem.super.Destruct(self)
  if self.Btn_Type then
    self.Btn_Type.OnPMButtonClicked:Remove(self, self.OnBtnClick)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
end
function BattlePassTaskWeekTypeItem:OnBtnClick()
  if self.isSelected then
    return
  end
  if self.parentPage then
    self.parentPage:OnBtnSubWeekType(self.weekId)
  end
end
function BattlePassTaskWeekTypeItem:SetSelected(inSelected)
  self.isSelected = inSelected
  if inSelected then
    self.Btn_Type:SetForceBrush(UE4.EForceButtonBrush.Pressed)
  else
    self.Btn_Type:SetForceBrush(UE4.EForceButtonBrush.None)
  end
end
function BattlePassTaskWeekTypeItem:UpdateView(parent, data)
  self.parentPage = parent
  self.weekId = data.inWeekId
  self.time = data.inTime
  if self.Switcher_SubWeekUnlock then
    self.Switcher_SubWeekUnlock:SetActiveWidgetIndex(self.time > 0 and 1 or 0)
  end
  if self.Txt_SubWeek then
    self.Txt_SubWeek:SetText(self.weekId)
  end
  self:SetCurrentWeekIconVisible(data.bCurrentWeek)
  self:SetWeekFinishIconVisible(data)
  if self.Btn_Type then
    self.Btn_Type:SetIsEnabled(self.time <= 0 and true or false)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  if self.time > 0 then
    self.timerHandler = TimerMgr:AddTimeTask(0, 1, 0, function()
      self:RemainingTimeTxt()
    end)
  end
end
function BattlePassTaskWeekTypeItem:RemainingTimeTxt()
  if self.time <= 0 then
    if self.timerHandler then
      self.timerHandler:EndTask()
      self.timerHandler = nil
    end
    return
  end
  self.time = self.time - 1
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
  if self.Txt_SubWeekUnlockTime then
    self.Txt_SubWeekUnlockTime:SetText(outText)
  end
end
function BattlePassTaskWeekTypeItem:SetCurrentWeekIconVisible(bShow)
  if self.Overlay_CurrentWeek then
    self.Overlay_CurrentWeek:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    if bShow then
      local currentWeekText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CurrentWeek")
      if self.Txt_CurrentWeek then
        self.Txt_CurrentWeek:SetText(currentWeekText)
      end
    end
  end
end
function BattlePassTaskWeekTypeItem:SetWeekFinishIconVisible(data)
  if data then
    local bShow = data.inTime < 0 and GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):IsWeekTaskFinish(data.inWeekId)
    if self.Overlay_Finish then
      self.Overlay_Finish:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
  end
end
return BattlePassTaskWeekTypeItem
