local MichellePlaytimeMainPage = class("MichellePlaytimeMainPage", PureMVC.ViewComponentPage)
local MichellePlaytimeMainPageMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeMainPageMediator")
function MichellePlaytimeMainPage:ListNeededMediators()
  return {MichellePlaytimeMainPageMediator}
end
function MichellePlaytimeMainPage:Construct()
  MichellePlaytimeMainPage.super.Construct(self)
  self.Btn_OpenRulesPage.OnClicked:Add(self, self.OnClickOpenActivityRulesPage)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  self.Btn_PlayCharacterVoice.OnClicked:Add(self, self.OnClickPlayCharacterVoice)
  self.Btn_GetGamePoints.OnClicked:Add(self, self.OnClickGetGamePoints)
  self.Btn_OpenRewardChest.OnClicked:Add(self, self.OnClickOpenRewardChest)
  self.Btn_OpenRewardChest_Big.OnClicked:Add(self, self.OnClickOpenRewardChest)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local ActivityPreTable = ActivitiesProxy:GetActivityPreTable()
  local ActivityId = MichellePlaytimeProxy:GetActivityId()
  if ActivityPreTable and ActivityPreTable[ActivityId] and ActivityPreTable[ActivityId].cfg then
    self:InitPageData(ActivityPreTable[ActivityId].cfg)
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):PauseStateMachine()
  MichellePlaytimeProxy:ReqGetMichellePlaytimeData()
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryMainPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, 0)
  self.opentime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  MichellePlaytimeProxy:SetShowRedDot(false)
  self:SetGamePointRedDot()
  self:OnClickPlayCharacterVoice()
end
function MichellePlaytimeMainPage:Destruct()
  MichellePlaytimeMainPage.super.Destruct(self)
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  self.Btn_OpenRulesPage.OnClicked:Remove(self, self.OnClickOpenActivityRulesPage)
  self.Btn_PlayCharacterVoice.OnClicked:Remove(self, self.OnClickPlayCharacterVoice)
  self.Btn_GetGamePoints.OnClicked:Remove(self, self.OnClickGetGamePoints)
  self.Btn_OpenRewardChest.OnClicked:Remove(self, self.OnClickOpenRewardChest)
  self.Btn_OpenRewardChest_Big.OnClicked:Remove(self, self.OnClickOpenRewardChest)
  self:ClearUpdateRemainingTimeHandle()
  self:ClearUpdateVoiceStateTimeHandle()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ReStartStateMachine()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local timeStr = MichellePlaytimeProxy:GetRemainingTimeStrFromTimeStamp(UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() - self.opentime)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryMainPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, timeStr)
  self:UpdateRedDot()
end
function MichellePlaytimeMainPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function MichellePlaytimeMainPage:OnClickOpenActivityRulesPage()
  ViewMgr:OpenPage(self, UIPageNameDefine.MichellePlaytimeMainRulesPage)
end
function MichellePlaytimeMainPage:OnClickGetGamePoints()
  ViewMgr:OpenPage(self, UIPageNameDefine.MichellePlaytimeTaskPage)
end
function MichellePlaytimeMainPage:OnClickPlayCharacterVoice()
  local audio = UE4.UPMLuaAudioBlueprintLibrary
  if self.currentVoicePlayingID then
    local eventID = audio.GetID(self.currentVoiceSource)
    if audio.IsActivePlayingID(eventID, self.currentVoicePlayingID) then
      LogInfo("OnClickPlayCharacterVoice:", "Voice is already playing")
      return
    end
  end
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  if not MichellePlaytimeProxy:GetIsFirstPlayVoice() then
    MichellePlaytimeProxy:SetIsFirstPlayVoice(true)
    self.currentVoiceSource = self.bp_firstFixedVoice
    self:PlayCurrentVoiceSource()
    return
  end
  if self.bp_randomVoices then
    local randomNum = math.random(1, self.bp_randomVoices:Num())
    self.currentVoiceSource = self.bp_randomVoices:Get(randomNum)
    self:PlayCurrentVoiceSource()
  end
end
function MichellePlaytimeMainPage:OnClickOpenRewardChest()
  ViewMgr:OpenPage(self, UIPageNameDefine.MichellePlaytimeRewardChestPage)
end
function MichellePlaytimeMainPage:PlayCurrentVoiceSource()
  if self.currentVoiceSource then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    self.currentVoicePlayingID = audio.PostEvent(audio.GetID(self.currentVoiceSource))
    self.WS_PlayState:SetActiveWidgetIndex(1)
    self:ClearUpdateVoiceStateTimeHandle()
    local voiceTime = audio.GetAkEventMinimumDuration(self.currentVoiceSource)
    self.updateVoiceStateTimeHandle = TimerMgr:AddTimeTask(voiceTime, 0, 1, function()
      self.WS_PlayState:SetActiveWidgetIndex(0)
    end)
  end
end
function MichellePlaytimeMainPage:InitPageData(pageData)
  local monthStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Month")
  local dayStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
  local startTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  startTimeStr = os.date(startTimeStr, pageData.start_time)
  local expireTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  expireTimeStr = os.date(expireTimeStr, pageData.expire_time)
  self.remainingTimeStamp = pageData.expire_time - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local remainingTimeStampStr = self:GetRemainingTimeStrFromTimeStamp(self.remainingTimeStamp)
  self.Txt_ActivityTime:SetText(remainingTimeStampStr)
  self:ClearUpdateRemainingTimeHandle()
  self.updateRemainingTimeHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
    self.remainingTimeStamp = self.remainingTimeStamp - 1
    if self.remainingTimeStamp < 0 then
      self:ClearUpdateRemainingTimeHandle()
      local ActivityTimeExpiresStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ActivityTimeExpires")
      self.Txt_ActivityTime:SetText(ActivityTimeExpiresStr)
    else
      remainingTimeStampStr = self:GetRemainingTimeStrFromTimeStamp(self.remainingTimeStamp)
      self.Txt_ActivityTime:SetText(remainingTimeStampStr)
    end
  end)
end
function MichellePlaytimeMainPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function MichellePlaytimeMainPage:GetRemainingTimeStrFromTimeStamp(timeStamp)
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
function MichellePlaytimeMainPage:ClearUpdateRemainingTimeHandle()
  if self.updateRemainingTimeHandle then
    self.updateRemainingTimeHandle:EndTask()
    self.updateRemainingTimeHandle = nil
  end
end
function MichellePlaytimeMainPage:ClearUpdateVoiceStateTimeHandle()
  if self.updateVoiceStateTimeHandle then
    self.updateVoiceStateTimeHandle:EndTask()
    self.updateVoiceStateTimeHandle = nil
  end
end
function MichellePlaytimeMainPage:UpdateConsumeNum()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local consumId = MichellePlaytimeProxy:GetConsumeId()
  local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  local itemCnt = warehouseProxy:GetItemCnt(consumId)
  self.Txt_GamePointNum:SetText(itemCnt)
end
function MichellePlaytimeMainPage:UpdateRedDot()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  if self:HasFlipTaskRewardPendingReceive() then
    MichellePlaytimeProxy:SetShowRedDot(true)
    return
  end
  if MichellePlaytimeProxy:GetGamePointCnt() > 0 then
    MichellePlaytimeProxy:SetShowRedDot(true)
    return
  end
end
function MichellePlaytimeMainPage:HasFlipTaskRewardPendingReceive()
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
function MichellePlaytimeMainPage:SetGamePointRedDot()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  if MichellePlaytimeProxy:HasTaskRewardPendingReceive() then
    self.RedDot_GetGamePoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.RedDot_GetGamePoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return MichellePlaytimeMainPage
