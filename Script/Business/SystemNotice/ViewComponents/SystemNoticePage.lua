local SystemNoticePage = class("SystemNoticePage", PureMVC.ViewComponentPage)
local SystemNoticeProxy
function SystemNoticePage:OnOpen(luaOpenData, nativeOpenData)
  SystemNoticeProxy = GameFacade:RetrieveProxy(ProxyNames.SystemNoticeProxy)
  LogDebug("SystemNoticePage", "OnOpen")
end
function SystemNoticePage:OnShow(luaOpenData, nativeOpenData)
  if self.tickHandle then
    self.tickHandle:EndTask()
    self.tickHandle = nil
  end
  LogDebug("SystemNoticePage", "OnShow duration = " .. SystemNoticeProxy.Notices.duration)
  self:ShowNextNotice()
  local duration
  if -1 == SystemNoticeProxy:GetPlayNoticeEndTime() then
    duration = SystemNoticeProxy.Notices.duration
  else
    duration = SystemNoticeProxy:GetPlayNoticeEndTime() - os.time()
  end
  self.tickHandle = TimerMgr:AddTimeTask(duration, 0, 1, function()
    ViewMgr:HidePage(self, UIPageNameDefine.SystemNoticePage)
  end)
end
function SystemNoticePage:OnHide()
  LogDebug("SystemNoticePage", "OnHide")
  if self.tickHandle then
    self.tickHandle:EndTask()
    self.tickHandle = nil
  end
end
function SystemNoticePage:OnClose()
  LogDebug("SystemNoticePage", "OnClose")
end
function SystemNoticePage:ShowNextNotice()
  self.StaticText:SetText(SystemNoticeProxy.Notices.content)
  self:PlayAnimation(self.NoticePlay, 0, 0)
end
return SystemNoticePage
