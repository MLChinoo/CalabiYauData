local OnServerSessionCloseCmd = class("OnServerSessionCloseCmd", PureMVC.Command)
function OnServerSessionCloseCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.GameServerDisconnect then
    LogDebug("OnServerSessionCloseCmd", "ServerDisconnected " .. notification:GetBody())
  end
end
return OnServerSessionCloseCmd
