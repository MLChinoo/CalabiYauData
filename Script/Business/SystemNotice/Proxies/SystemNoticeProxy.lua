local SystemNoticeProxy = class("SystemNoticeProxy", PureMVC.Proxy)
function SystemNoticeProxy:OnRegister()
  LogDebug("SystemNoticeProxy", "OnRegister")
  self.Notices = nil
  if nil ~= self.timeHandle then
    self.timeHandle:EndTask()
    self.timeHandle = nil
  end
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_COMMON_BANNER_NTF, FuncSlot(self.OnNtfCommonBanner, self))
  end
end
function SystemNoticeProxy:OnRemove()
  LogDebug("SystemNoticeProxy", "OnRemove")
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_COMMON_BANNER_NTF, FuncSlot(self.OnNtfCommonBanner, self))
  end
  if self.timeHandle ~= nil then
    self.timeHandle:EndTask()
    self.timeHandle = nil
  end
  GameFacade:SendNotification(NotificationDefines.SystemNotice.DeleteNotice)
end
function SystemNoticeProxy:OnNtfCommonBanner(data)
  LogDebug("SystemNoticeProxy", "OnNtfCommonBanner")
  local common_banner_ntf = pb.decode(Pb_ncmd_cs_lobby.common_banner_ntf, data)
  LogDebug("common_banner_ntf", TableToString(common_banner_ntf))
  GameFacade:SendNotification(NotificationDefines.SystemNotice.DeleteNotice)
  self.Notices = common_banner_ntf
  if self.timeHandle ~= nil then
    self.timeHandle:EndTask()
    self.timeHandle = nil
  end
  if self:GetInPlayNotice() then
    GameFacade:SendNotification(NotificationDefines.SystemNotice.AddNotice)
  else
    GameFacade:SendNotification(NotificationDefines.SystemNotice.DeleteNotice)
  end
  if -1 ~= self:GetPlayNoticeIndex() then
    local delayTime = self:GetNextPlayNoticeStartTime() - os.time()
    local interval = common_banner_ntf.interval
    self.maxRunTimes = common_banner_ntf.times - self:GetPlayNoticeIndex()
    LogDebug("SystemNoticeProxy", "os.time() = " .. os.time() .. "  delayTime = " .. delayTime .. "  interval  = " .. interval .. "  maxRunTimes = " .. self.maxRunTimes)
    self:PlayNotice(delayTime)
  end
end
function SystemNoticeProxy:PlayNotice(delayTime)
  self.timeHandle = TimerMgr:AddTimeTask(delayTime, 0, 1, function()
    LogDebug("SystemNoticeProxy", " SystemNotice.AddNotice  os.time() = " .. os.time())
    GameFacade:SendNotification(NotificationDefines.SystemNotice.AddNotice)
    self.maxRunTimes = self.maxRunTimes - 1
    if self.maxRunTimes > 0 then
      self:PlayNotice(self.Notices.interval)
    end
  end)
end
function SystemNoticeProxy:GetInPlayNotice()
  if self.Notices == nil then
    LogDebug("SystemNoticeProxy", "GetInPlayNotice index == " .. -1)
    return false
  end
  for index = 1, self.Notices.times do
    local startTime = self.Notices.start_time + self.Notices.interval * (index - 1)
    local endTime = self.Notices.start_time + self.Notices.interval * (index - 1) + self.Notices.duration
    if startTime <= os.time() and endTime > os.time() then
      LogDebug("SystemNoticeProxy", "GetInPlayNotice index == " .. index)
      return true
    end
  end
  LogDebug("SystemNoticeProxy", "GetInPlayNotice index == " .. -1)
  return false
end
function SystemNoticeProxy:GetPlayNoticeIndex()
  if self.Notices == nil then
    LogDebug("SystemNoticeProxy", "GetPlayNoticeIndex index == " .. -1)
    return -1
  end
  if os.time() < self.Notices.start_time then
    LogDebug("SystemNoticeProxy", "GetPlayNoticeIndex index == " .. 0)
    return 0
  end
  for index = 1, self.Notices.times - 1 do
    local StartTime = self.Notices.start_time + self.Notices.interval * (index - 1)
    local NextStartTime = self.Notices.start_time + self.Notices.interval * index
    if StartTime <= os.time() and NextStartTime > os.time() then
      LogDebug("SystemNoticeProxy", "GetPlayNoticeIndex index == " .. index)
      return index
    end
  end
  LogDebug("SystemNoticeProxy", "GetPlayNoticeIndex index == " .. -1)
  return -1
end
function SystemNoticeProxy:GetNextPlayNoticeStartTime()
  if self.Notices == nil then
    LogDebug("SystemNoticeProxy", "GetNextPlayNoticeStartTime NextStartTime == " .. -1)
    return -1
  end
  if os.time() < self.Notices.start_time then
    LogDebug("SystemNoticeProxy", "GetNextPlayNoticeStartTime NextStartTime == " .. self.Notices.start_time)
    return self.Notices.start_time
  end
  for index = 1, self.Notices.times - 1 do
    local StartTime = self.Notices.start_time + self.Notices.interval * (index - 1)
    local NextStartTime = self.Notices.start_time + self.Notices.interval * index
    if StartTime <= os.time() and NextStartTime > os.time() then
      LogDebug("SystemNoticeProxy", "GetNextPlayNoticeStartTime NextStartTime == " .. NextStartTime)
      return NextStartTime
    end
  end
  LogDebug("SystemNoticeProxy", "GetNextPlayNoticeStartTime NextStartTime == " .. -1)
  return -1
end
function SystemNoticeProxy:GetPlayNoticeEndTime()
  if self.Notices == nil then
    LogDebug("SystemNoticeProxy", "GetPlayNoticeEndTime EndTime == " .. -1)
    return -1
  end
  if os.time() < self.Notices.start_time then
    LogDebug("SystemNoticeProxy", "GetPlayNoticeEndTime EndTime == " .. self.Notices.start_time + self.Notices.duration)
    return self.Notices.start_time + self.Notices.duration
  end
  for index = 1, self.Notices.times do
    local StartTime = self.Notices.start_time + self.Notices.interval * (index - 1)
    local endTime = self.Notices.start_time + self.Notices.interval * (index - 1) + self.Notices.duration
    if StartTime <= os.time() and endTime > os.time() then
      LogDebug("SystemNoticeProxy", "GetPlayNoticeEndTime endTime == " .. endTime)
      return endTime
    end
  end
  for index = 1, self.Notices.times - 1 do
    local StartTime = self.Notices.start_time + self.Notices.interval * (index - 1)
    local NextStartTime = self.Notices.start_time + self.Notices.interval * index
    if StartTime <= os.time() and NextStartTime > os.time() then
      local NextEndTime = NextStartTime + self.Notices.duration
      LogDebug("SystemNoticeProxy", "GetPlayNoticeEndTime NextEndTime == " .. NextEndTime)
      return NextEndTime
    end
  end
  LogDebug("SystemNoticeProxy", "GetPlayNoticeEndTime EndTime == " .. -1)
  return -1
end
return SystemNoticeProxy
