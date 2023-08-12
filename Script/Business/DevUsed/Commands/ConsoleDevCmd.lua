local ConsoleDevCmd = class("ConsoleDevCmd", PureMVC.Command)
function ConsoleDevCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.ConsoleDevCmd and notification:GetType() == NotificationDefines.ConsoleDevCmdType.StatProxy then
    LogDebug("Current Proxy Count: xxx ")
  end
end
return ConsoleDevCmd
