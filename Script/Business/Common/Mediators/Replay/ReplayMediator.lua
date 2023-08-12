local ReplayMediator = class("ReplayMediator", PureMVC.Mediator)
function ReplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.Replay.GetDownloadUrl,
    NotificationDefines.Replay.DownloadUrlPrepareWell
  }
end
function ReplayMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local body = notification:GetBody()
  if NtfName == NotificationDefines.Replay.GetDownloadUrl then
    if self:GetViewComponent():CheckFileExist() then
      self:GetViewComponent():PlayVideo()
    else
      self:GetViewComponent():BeginDownloadUrl(body.downloadurl)
    end
  elseif NtfName == NotificationDefines.Replay.DownloadUrlPrepareWell then
    self:GetViewComponent():PrepareDownload(body.roomid)
  end
end
return ReplayMediator
