local TemplateGetTmpDataCmd = class("TemplateGetTmpDataCmd", PureMVC.Command)
function TemplateGetTmpDataCmd:Execute(notification)
  if notification.GetName() == NotificationDefines.GameServerDisconnect and notification.GetBody() == "reason:NetworkErr" then
    LogDebug(" Disconnect for NetworkErr")
  end
end
