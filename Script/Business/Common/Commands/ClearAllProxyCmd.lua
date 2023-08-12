local ClearAllProxyCmd = class("ClearAllProxyCmd", PureMVC.Command)
function ClearAllProxyCmd:Execute(notification)
  GameFacade:Uninstall()
  GameFacade:Setup()
end
return ClearAllProxyCmd
