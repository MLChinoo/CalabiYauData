local OnServerSessionOpenCmd = class("OnServerSessionOpenCmd", PureMVC.Command)
function OnServerSessionOpenCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.GameServerConnect then
    LogDebug("OnServerSessionOpenCmd", "ServerConnected " .. tostring(notification:GetBody()))
  end
end
return OnServerSessionOpenCmd
