local SpaceMusicPage = class("SpaceMusicPage", PureMVC.ViewComponentPage)
local SpaceMusicMediator = require("Business/Activities/SpaceMusic/Mediators/SpaceMusicMediator")
function SpaceMusicPage:ListNeededMediators()
  return {SpaceMusicMediator}
end
function SpaceMusicPage:InitializeLuaEvent()
  self.strDayHours = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
  self.strHoursMinutes = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
  self.strMinutesSecons = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_MinutesSeconds")
end
function SpaceMusicPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Bt_Info then
    self.Bt_Info.OnClicked:Add(self, SpaceMusicPage.OnBtInfoClicked)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnEscBtnClick)
  end
  if self.Img_Shade then
    self.Img_Shade.OnMouseButtonUpEvent:Bind(self, self.OnImgShadeClick)
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):PauseStateMachine()
end
function SpaceMusicPage:OnClose()
  if self.Bt_Info then
    self.Bt_Info.OnClicked:Remove(self, SpaceMusicPage.OnBtInfoClicked)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnEscBtnClick)
  end
  if self.Img_Shade then
    self.Img_Shade.OnMouseButtonUpEvent:Unbind()
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ReStartStateMachine()
end
function SpaceMusicPage:OnBtInfoClicked()
  if self.CP_Info then
    self.CP_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SpaceMusicPage:OnImgShadeClick()
  if self.CP_Info then
    self.CP_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceMusicPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if self.Cp_Info:IsVisible() and "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnImgShadeClick()
    return true
  end
  local ret = false
  if self.Button_Esc and not ret then
    ret = self.Button_Esc:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function SpaceMusicPage:InitView(inData)
  if #inData > 0 then
    for index, value in ipairs(inData) do
      if self.CP_CardList then
        local widget = self.CP_CardList:GetChildAt(index - 1)
        if widget then
          widget:GetClickEvent():Add(self.RewardClick, self)
          widget:InitInfo(value)
        end
      end
    end
  else
    LogDebug("SpaceMusic", "SpaceMusicPage:InitView data.length = 0")
  end
end
function SpaceMusicPage:UpdateRewardState(inData)
  if self.CP_CardList then
    local widget = self.CP_CardList:GetChildAt(inData.day - 1)
    if widget then
      widget:SetStatus(inData.status)
    end
  end
end
function SpaceMusicPage:RewardClick(inStatus, inDay, inItemId)
  if inStatus == GlobalEnumDefine.EMusicRewardStatus.Activate then
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceMusic.SpaceMusicOperatorCmd, {day = inDay})
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.SpaceTimeCardDetailPage, false, {itemId = inItemId})
  end
end
function SpaceMusicPage:InitTimer(inData)
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  if inData.start and inData.expire then
    local tabS = os.date("*t", inData.start)
    local tabE = os.date("*t", inData.expire)
    local strY = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Year")
    local strM = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Month")
    local strD = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
    if self.Txt_ValidTime then
      local outText = tabS.month .. strM .. tabS.day .. strD .. " - " .. tabE.month .. strM .. tabE.day .. strD
      self.Txt_ValidTime:SetText(outText)
    end
    if self.Text_Full_Time then
      local outText = tabS.year .. strY .. tabS.month .. strM .. tabS.day .. strD .. " ~ " .. tabE.year .. strY .. tabE.month .. strM .. tabE.day .. strD
      self.Text_Full_Time:SetText(outText)
    end
  end
  if inData.valid and inData.valid <= 0 then
    return
  end
  self.time = inData.valid
  self:DrawRemainingTimeTxt()
  self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
    self:RemainingTimeTxt()
  end)
end
function SpaceMusicPage:RemainingTimeTxt()
  if self.time <= 0 then
    return
  end
  self.time = self.time - 1
  self:DrawRemainingTimeTxt()
end
function SpaceMusicPage:DrawRemainingTimeTxt()
  local timeTable = FunctionUtil:FormatTime(self.time)
  local outText
  if timeTable.Day > 0 then
    local stringMap = {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    }
    outText = ObjectUtil:GetTextFromFormat(self.strDayHours, stringMap)
  elseif timeTable.Hour > 0 then
    local stringMap = {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(self.strHoursMinutes, stringMap)
  else
    local stringMap = {
      Minutes = timeTable.Minute,
      Seconds = timeTable.Second <= 0 and 1 or timeTable.Second
    }
    outText = ObjectUtil:GetTextFromFormat(self.strMinutesSecons, stringMap)
  end
  if self.Txt_RemainingTime then
    self.Txt_RemainingTime:SetText(outText)
  end
end
function SpaceMusicPage:OnEscBtnClick()
  ViewMgr:ClosePage(self)
end
return SpaceMusicPage
