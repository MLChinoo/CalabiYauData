local OnServerSessionReopenCmd = class("OnServerSessionReopenCmd", PureMVC.Command)
function OnServerSessionReopenCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.GameServerReconnect then
    LogDebug("OnServerSessionReopenCmd", "ServerReConnected ")
    local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
    if roomProxy then
      roomProxy:SendRoomReconnectReq()
    end
  end
end
return OnServerSessionReopenCmd
