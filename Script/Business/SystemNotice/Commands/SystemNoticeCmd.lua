local SystemNoticeCmd = class("SystemNoticeCmd", PureMVC.Command)
function SystemNoticeCmd:Execute(notification)
  LogDebug("SystemNoticeCmd", "Execute ")
  if notification:GetName() == NotificationDefines.SystemNotice.AddNotice then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.SystemNoticePage)
  end
  if notification:GetName() == NotificationDefines.SystemNotice.DeleteNotice then
    ViewMgr:HidePage(LuaGetWorld(), UIPageNameDefine.SystemNoticePage)
  end
end
return SystemNoticeCmd
