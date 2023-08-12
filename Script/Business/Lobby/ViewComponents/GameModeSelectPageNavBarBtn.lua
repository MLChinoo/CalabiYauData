local GameModeSelectPageNavBarBtn = class("GameModeSelectPageNavBarBtn", PureMVC.ViewComponentPanel)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function GameModeSelectPageNavBarBtn:Construct()
  GameModeSelectPageNavBarBtn.super.Construct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bIsChecked = false
  self.bInOpenTime = false
  self:InitInfo()
  self.updateLimitTimeCheckTimeHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
    if self.limitTimeData then
      self:SetLimitImageVisibility(self.limitTimeData)
    end
  end)
end
function GameModeSelectPageNavBarBtn:SetModeDatas(data)
  self.limitTimeData = data
  self:SetLimitImageVisibility(self.limitTimeData)
end
function GameModeSelectPageNavBarBtn:ClearUpdateLimitTimeCheckTimeHandle()
  if self.updateLimitTimeCheckTimeHandle then
    self.updateLimitTimeCheckTimeHandle:EndTask()
    self.updateLimitTimeCheckTimeHandle = nil
  end
end
function GameModeSelectPageNavBarBtn:Destruct()
  GameModeSelectPageNavBarBtn.super.Destruct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtn.OnCheckStateChanged)
  end
  self:ClearUpdateLimitTimeCheckTimeHandle()
end
function GameModeSelectPageNavBarBtn:InitInfo()
  if self.TextBlock_Template then
    self.TextBlock_Template:SetText(self.bp_btnText)
  end
  if self.WS_Style then
    self.WS_Style:SetActiveWidgetIndex(self.bp_btnType)
  end
end
function GameModeSelectPageNavBarBtn:OnCheckStateChanged(bIsChecked)
  self:SetBtnStyle(false)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomDataProxy:GetTeamInfo()
  if not teamInfo or not teamInfo.teamId then
    LogInfo("GameModeSelectPageNavBarBtn:", "teamInfo is InValid")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamInfoInValid"))
    GameFacade:SendNotification(NotificationDefines.GameModeSelect, true, NotificationDefines.GameModeSelect.QuitRoomByEsc)
    return
  end
  if not roomDataProxy:IsTeamLeader() and not self.bIsChecked then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.RestoreGameMode)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "NonOwnerCantSelectmode"))
  elseif roomDataProxy:GetIsInMatch() and not self.bIsChecked then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.RestoreGameMode)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MatchingCantSwitchMode"))
  elseif roomDataProxy:GetTeamMemberCount() > 5 and roomDataProxy:GetGameModeType() == GameModeSelectNum.GameModeType.Room then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CantSwitchModesForLimitPeople"))
  end
  if bIsChecked then
    if self.bIsChecked ~= bIsChecked then
      self.bIsChecked = bIsChecked
      GameFacade:SendNotification(NotificationDefines.GameModeSelect.ClickGameModeSelectNavBtn, self.bp_btnIndex)
    end
  else
    local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
    if checkbox then
      checkbox:SetIsChecked(true)
    end
  end
end
function GameModeSelectPageNavBarBtn:SetBtnStyle(bIsChecked)
  self.bIsChecked = bIsChecked
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParSelect:SetReactivate(true)
  end
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ClearAllGameModeSelectNavBtn)
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(bIsChecked)
    if bIsChecked then
      local audio = UE4.UPMLuaAudioBlueprintLibrary
      audio.PostEvent(audio.GetID(self.bp_clickSound))
    end
  end
end
function GameModeSelectPageNavBarBtn:OnClearBtnStyle()
  self.bIsChecked = false
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(self.bIsChecked)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GameModeSelectPageNavBarBtn:SetLimitImageVisibility(data)
  if data and data.time_limit then
    self.bInOpenTime = self:CheckLimitTimeIsToday(data.start_time, data.end_time, data.start_sec, data.end_sec)
    if self.bInOpenTime then
      if self.Panel_LimitTime and self.Panel_LimitTime:IsVisible() then
        self.Panel_LimitTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.Panel_OnGoing and not self.Panel_OnGoing:IsVisible() then
        self.Panel_OnGoing:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if self.Panel_LimitTime and not self.Panel_LimitTime:IsVisible() then
        self.Panel_LimitTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.Panel_OnGoing and self.Panel_OnGoing:IsVisible() then
        self.Panel_OnGoing:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    if self.Panel_LimitTime then
      self.Panel_LimitTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Panel_OnGoing then
      self.Panel_OnGoing:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GameModeSelectPageNavBarBtn:CheckLimitTimeIsToday(limitStartTimestamp, limitEndTimestamp, startSecTimestamp, endSecTimestamp)
  if limitStartTimestamp <= 0 or limitEndTimestamp <= 0 then
    LogInfo("CheckLimitTimeIsToday", "limitStartTimestamp or limitEndTimestamp <= 0")
    return false
  end
  if limitEndTimestamp <= limitStartTimestamp then
    LogInfo("CheckLimitTimeIsToday", "limitStartTimestamp >= limitEndTimestamp")
    return false
  end
  local IsInTime = false
  local currentTimestamp = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if currentTimestamp - limitStartTimestamp >= 0 and limitEndTimestamp - currentTimestamp >= 0 then
    if startSecTimestamp >= 0 and endSecTimestamp >= 0 then
      local curHour = tonumber(os.date("%H", currentTimestamp))
      local curMinutes = tonumber(os.date("%M", currentTimestamp))
      local curSecond = tonumber(os.date("%S", currentTimestamp))
      local currentTime = curHour * 3600 + curMinutes * 60 + curSecond
      if startSecTimestamp <= currentTime and endSecTimestamp >= currentTime then
        IsInTime = true
      end
    else
      IsInTime = true
    end
  end
  return IsInTime
end
function GameModeSelectPageNavBarBtn:GetLimitTimeStr()
  if self.limitTimeData and self.limitTimeData.time_limit then
    return self:GetLimitTimeStrFromTimeStamp(self.limitTimeData.start_time, self.limitTimeData.end_time, self.limitTimeData.start_sec, self.limitTimeData.end_sec)
  else
    return ""
  end
end
function GameModeSelectPageNavBarBtn:GetLimitTimeStrFromTimeStamp(timeStamp1, timeStamp2, timeStamp3, timeStamp4)
  local str = ""
  if timeStamp1 <= 0 or timeStamp2 <= 0 then
    return str
  end
  local year1 = os.date("%Y", timeStamp1)
  local month1 = os.date("%m", timeStamp1)
  local day1 = os.date("%d", timeStamp1)
  local year2 = os.date("%Y", timeStamp2)
  local month2 = os.date("%m", timeStamp2)
  local day2 = os.date("%d", timeStamp2)
  local hour3 = math.floor(timeStamp3 / 3600)
  local minute3 = math.floor(timeStamp3 % 3600 / 60)
  if 0 == minute3 then
    minute3 = "00"
  end
  local hour4 = math.floor(timeStamp4 / 3600)
  local minute4 = math.floor(timeStamp4 % 3600 / 60)
  if 0 == minute4 then
    minute4 = "00"
  end
  local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
  local arg1 = UE4.FFormatArgumentData()
  arg1.ArgumentName = "0"
  arg1.ArgumentValue = year1
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "1"
  arg1.ArgumentValue = month1
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "2"
  arg1.ArgumentValue = day1
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "3"
  arg1.ArgumentValue = year2
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "4"
  arg1.ArgumentValue = month2
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "5"
  arg1.ArgumentValue = day2
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "6"
  arg1.ArgumentValue = hour3
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "7"
  arg1.ArgumentValue = minute3
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "8"
  arg1.ArgumentValue = hour4
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  arg1.ArgumentName = "9"
  arg1.ArgumentValue = minute4
  arg1.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "GameModeLimitTimeText")
  str = UE4.UKismetTextLibrary.Format(showMsg, inArgsTarry)
  return str
end
return GameModeSelectPageNavBarBtn
