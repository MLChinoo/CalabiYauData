local SummerThemeSongMainPage = class("SummerThemeSongMainPage", PureMVC.ViewComponentPage)
local SummerThemeSongMainPageMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongMainPageMediator")
function SummerThemeSongMainPage:ListNeededMediators()
  return {SummerThemeSongMainPageMediator}
end
function SummerThemeSongMainPage:Construct()
  SummerThemeSongMainPage.super.Construct(self)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  self.Btn_ShowActivityRules.OnClicked:Add(self, self.OnClickOpenActivityRulesPage)
  self.Btn_GetFlipChance.OnClicked:Add(self, self.OnClickGetFlipChance)
  self.Btn_OpenDeliverPage.OnClicked:Add(self, self.OnClickDeliverChance)
  self.Btn_UnableOpenDeliverPage.OnClicked:Add(self, self.OnClickUnableOpenDeliverPage)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryMainPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  SummerThemeSongProxy:SetShowRedDot(false)
  self:InitPageData()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):PauseStateMachine()
end
function SummerThemeSongMainPage:Destruct()
  SummerThemeSongMainPage.super.Destruct(self)
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  self.Btn_ShowActivityRules.OnClicked:Remove(self, self.OnClickOpenActivityRulesPage)
  self.Btn_GetFlipChance.OnClicked:Remove(self, self.OnClickGetFlipChance)
  self.Btn_OpenDeliverPage.OnClicked:Remove(self, self.OnClickDeliverChance)
  self.Btn_UnableOpenDeliverPage.OnClicked:Remove(self, self.OnClickUnableOpenDeliverPage)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.QuitActivity
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ReStartStateMachine()
  self:UpdateRedRot()
  self:ClearUpdateRemainingTimeHandle()
end
function SummerThemeSongMainPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function SummerThemeSongMainPage:OnClickOpenActivityRulesPage()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickRulesBtn
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
  ViewMgr:OpenPage(self, UIPageNameDefine.SummerThemeSongActivityRulesPage)
end
function SummerThemeSongMainPage:OnClickGetFlipChance()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickTaskBtn
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
  ViewMgr:OpenPage(self, UIPageNameDefine.SummerThemeSongDailyFlipTimesPage)
end
function SummerThemeSongMainPage:OnClickDeliverChance()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickDeliveryBtn
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
  local TipText = ""
  if not SummerThemeSongProxy:IsFinishedAllFlipRound() then
    TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "STS_AllFlipRoundsNotCompleted")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  elseif not SummerThemeSongProxy:IsReceivedAllFlipReward() then
    TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "STS_AllFlipRewardNotReceived")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.SummerThemeSongDeliveryOpportunityPage)
  end
end
function SummerThemeSongMainPage:OnClickUnableOpenDeliverPage()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local TipText = ""
  if not SummerThemeSongProxy:IsFinishedAllFlipRound() then
    TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "STS_AllFlipRoundsNotCompleted")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  elseif not SummerThemeSongProxy:IsReceivedAllFlipReward() then
    TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "STS_AllFlipRewardNotReceived")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  end
end
function SummerThemeSongMainPage:InitPageData()
  local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local ActivityPreTable = ActivitiesProxy:GetActivityPreTable()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local ActivityId = SummerThemeSongProxy:GetActivityId()
  if ActivityPreTable and ActivityPreTable[ActivityId] and ActivityPreTable[ActivityId].cfg then
    pageData = ActivityPreTable[ActivityId].cfg
  else
    LogInfo("SummerThemeSongMainPage Log", "Activity cfg nil")
    return
  end
  local monthStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Month")
  local dayStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
  local startTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  startTimeStr = os.date(startTimeStr, pageData.start_time)
  local expireTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  expireTimeStr = os.date(expireTimeStr, pageData.expire_time)
  local activityTimeIntervalStr = startTimeStr .. "-" .. expireTimeStr
  self.Txt_ActivityTimeInterval:SetText(activityTimeIntervalStr)
  self.remainingTimeStamp = pageData.expire_time - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  self:ClearUpdateRemainingTimeHandle()
  self.updateRemainingTimeHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
    self.remainingTimeStamp = self.remainingTimeStamp - 1
    if self.remainingTimeStamp < 0 then
      self:ClearUpdateRemainingTimeHandle()
      local ActivityTimeExpiresStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ActivityTimeExpires")
      self.Txt_ActivityTimeRemaining:SetText(ActivityTimeExpiresStr)
    else
      local remainingTimeStampStr = self:GetRemainingTimeStrFromTimeStamp(self.remainingTimeStamp)
      self.Txt_ActivityTimeRemaining:SetText(remainingTimeStampStr)
    end
  end)
  self:UpdateFlipChanceState()
  self:UpdateRemainingFlipTimes()
  self:SetOpenDeliverPageBtnState()
end
function SummerThemeSongMainPage:UpdateFlipChanceState()
  local bHasTask = self:HasFlipTask()
  self.WS_GetFlipChanceState:SetActiveWidgetIndex(bHasTask)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  SummerThemeSongProxy:SetHasFlipTask(bHasTask)
  if self:HasFlipTaskRewardPendingReceive() then
    if self.RedDot_GetFlipChance then
      self.RedDot_GetFlipChance:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.RedDot_GetFlipChance then
    self.RedDot_GetFlipChance:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SummerThemeSongMainPage:HasFlipTask()
  if self.bp_FlipTaskIDList then
    for key1, value1 in pairs(self.bp_FlipTaskIDList) do
      local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
      local activityTasks = BattlePassProxy:GetActivityTasks()
      if activityTasks then
        for key, value in pairs(activityTasks) do
          if value.taskId == value1 and (value.state == Pb_ncmd_cs.ETaskState.TaskState_PROGRESSING or value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH) then
            return 0
          end
        end
      end
    end
  end
  return 1
end
function SummerThemeSongMainPage:HasFlipTaskRewardPendingReceive()
  if self.bp_FlipTaskIDList then
    for key1, value1 in pairs(self.bp_FlipTaskIDList) do
      local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
      local activityTasks = BattlePassProxy:GetActivityTasks()
      if activityTasks then
        for key, value in pairs(activityTasks) do
          if value.taskId == value1 and value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
            return true
          end
        end
      end
    end
  end
  return false
end
function SummerThemeSongMainPage:GetRemainingTimeStrFromTimeStamp(timeStamp)
  local str = ""
  if timeStamp < 0 then
    self:ClearUpdateRemainingTimeHandle()
    return str
  end
  local day = math.floor(timeStamp / 86400)
  local hour = math.floor(timeStamp % 86400 / 3600)
  local minute = math.floor(timeStamp % 86400 % 3600 / 60)
  local seconds = math.floor(timeStamp % 86400 % 3600 % 60)
  local dayStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
  local hourStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Hours")
  local minuteStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Minutes")
  local secondsStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Seconds")
  if day > 0 then
    str = tostring(day) .. dayStr .. tostring(hour) .. hourStr
  elseif hour > 0 then
    str = tostring(hour) .. hourStr .. tostring(minute) .. minuteStr
  else
    str = tostring(minute) .. minuteStr .. tostring(seconds) .. secondsStr
  end
  return str
end
function SummerThemeSongMainPage:ClearUpdateRemainingTimeHandle()
  if self.updateRemainingTimeHandle then
    self.updateRemainingTimeHandle:EndTask()
    self.updateRemainingTimeHandle = nil
  end
end
function SummerThemeSongMainPage:UpdateRemainingFlipTimes()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local flipTimes = SummerThemeSongProxy:GetFlipChanceItemCnt()
  self.Txt_RemainingFlipTimes:SetText(tostring(flipTimes))
end
function SummerThemeSongMainPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function SummerThemeSongMainPage:SetOpenDeliverPageBtnState()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local activeIndex = 0
  if SummerThemeSongProxy:GetAllPhaseFinished() and SummerThemeSongProxy:IsReceivedAllFlipReward() then
    activeIndex = 1
    local flipTimes = SummerThemeSongProxy:GetFlipChanceItemCnt() - SummerThemeSongProxy:GetExchangeNum()
    if flipTimes >= 0 then
      if self.RedDot_OpenDeliverPage then
        self.RedDot_OpenDeliverPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif self.RedDot_OpenDeliverPage then
      self.RedDot_OpenDeliverPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.WS_OpenDeliverPageState:SetActiveWidgetIndex(activeIndex)
end
function SummerThemeSongMainPage:UpdateRedRot()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  if SummerThemeSongProxy:UpdateMilestoneRewardRedRot(SummerThemeSongProxy:GetScData()) then
    SummerThemeSongProxy:SetShowRedDot(true)
    return
  end
  if SummerThemeSongProxy:GetAllPhaseFinished() and SummerThemeSongProxy:IsReceivedAllFlipReward() then
    local flipTimes = SummerThemeSongProxy:GetFlipChanceItemCnt() - SummerThemeSongProxy:GetExchangeNum()
    if flipTimes >= 0 then
      SummerThemeSongProxy:SetShowRedDot(true)
      return
    end
  end
  if self:HasFlipTaskRewardPendingReceive() then
    SummerThemeSongProxy:SetShowRedDot(true)
    return
  end
  SummerThemeSongProxy:SetShowRedDot(false)
end
return SummerThemeSongMainPage
