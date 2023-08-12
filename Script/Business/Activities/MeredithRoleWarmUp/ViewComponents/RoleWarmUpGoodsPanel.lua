local RoleWarmUpGoodsPanelMediator = require("Business/Activities/MeredithRoleWarmUp/Mediators/RoleWarmUpGoodsPanelMediator")
local RoleWarmUpGoodsPanel = class("RoleWarmUpGoodsPanel", PureMVC.ViewComponentPage)
function RoleWarmUpGoodsPanel:ListNeededMediators()
  return {RoleWarmUpGoodsPanelMediator}
end
function RoleWarmUpGoodsPanel:InitializeLuaEvent()
end
function RoleWarmUpGoodsPanel:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("RoleWarmUpGoodsPanel", "luaOpenData.StoreId = " .. tostring(luaOpenData.StoreId))
  LogDebug("RoleWarmUpGoodsPanel", "luaOpenData.ActivityId = " .. tostring(luaOpenData.ActivityId))
  self:PlayAnimationForward(self.Check_Pop, 1, false)
  local activitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if activitiesProxy then
    self.RoleWarmUpGoodsTip:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleWarmUpGoodsTip"))
    local RoleWarmUpGoodsTimeText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleWarmUpGoodsTimeText")
    local activityInfo = activitiesProxy:GetActivityById(luaOpenData.ActivityId)
    if activityInfo then
      LogDebug("RoleWarmUpGoodsPanel", "activityInfo.cfg.expire_time = " .. tostring(activityInfo.cfg.expire_time))
      if self.updateTimer == nil then
        self.updateTimer = TimerMgr:AddTimeTask(0, 1, 0, function()
          local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
          local countDownTime = activityInfo.cfg.expire_time - servertime
          if countDownTime >= 0 then
            local countDownTimeText = RoleWarmUpGoodsTimeText .. self:UpdataCountDownTimeText(countDownTime)
            self.countDownTimeText:SetText(countDownTimeText)
          else
            self:ClosePage()
          end
        end)
      end
    end
  end
  self.Button_Return.OnClickEvent:Add(self, self.OnClickReturnBtn)
  self.Button_Goto.OnClickEvent:Add(self, self.OnClickGotoBtn)
end
function RoleWarmUpGoodsPanel:UpdataCountDownTimeText(countDownTime)
  local CountDownTimeText
  local timeTable = FunctionUtil:FormatTime(countDownTime)
  if countDownTime >= 86400 then
    local DaysHoursText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(DaysHoursText, {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    })
  elseif countDownTime >= 3600 then
    local HoursMinutesText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(HoursMinutesText, {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute
    })
  elseif countDownTime >= 60 then
    local MinutesSecondsText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_MinutesSeconds")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(MinutesSecondsText, {
      Minutes = timeTable.Minute,
      Seconds = timeTable.Second
    })
  else
    local SecondsText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Seconds")
    CountDownTimeText = ObjectUtil:GetTextFromFormat(SecondsText, {
      Seconds = timeTable.Second
    })
  end
  return CountDownTimeText
end
function RoleWarmUpGoodsPanel:LuaHandleKeyEvent(key, inputEvent)
  self.Button_Goto:MonitorKeyDown(key, inputEvent)
  return self.Button_Return:MonitorKeyDown(key, inputEvent)
end
function RoleWarmUpGoodsPanel:OnClickReturnBtn()
  LogDebug("RoleWarmUpGoodsPanel", "OnClickReturnBtn")
  self:ClosePage()
end
function RoleWarmUpGoodsPanel:OnClickGotoBtn()
  LogDebug("RoleWarmUpGoodsPanel", "OnClickGotoBtn")
  self:ClosePage()
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RoleWarmUpPage)
end
function RoleWarmUpGoodsPanel:OnClose()
  self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturnBtn)
  self.Button_Goto.OnClickEvent:Remove(self, self.OnClickGotoBtn)
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
function RoleWarmUpGoodsPanel:ClosePage()
  local WaitingTime = 0
  if self.Check_Pop_Close then
    self:PlayAnimationForward(self.Check_Pop_Close, 1, false)
    WaitingTime = self.Check_Pop_Close:GetEndTime()
  end
  if TimerMgr then
    if self.WaitingCloseTask then
      self.WaitingCloseTask:EndTask()
      self.WaitingCloseTask = nil
    end
    self.WaitingCloseTask = TimerMgr:AddTimeTask(WaitingTime, 0.0, 0, function()
      ViewMgr:ClosePage(self)
      self.WaitingCloseTask = nil
    end)
  end
end
function RoleWarmUpGoodsPanel:Init(GoodsData)
  if not GoodsData then
    return nil
  end
  local Item
  for index, value in pairs(GoodsData.ItemsData or {}) do
    if self.DynamicEntryBox then
      Item = nil
      Item = self.DynamicEntryBox:BP_CreateEntry()
      Valid = Item and Item:Init(value)
    end
  end
end
return RoleWarmUpGoodsPanel
