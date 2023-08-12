local GetPlayerDataCmd = class("GetPlayerDataCmd", PureMVC.Command)
function GetPlayerDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.GetPlayerDataCmd then
    local playerIdReq = notification:GetBody() or 0
    if 0 == playerIdReq then
      playerIdReq = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
    end
    GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):ReqPlayerData(playerIdReq)
  end
end
return GetPlayerDataCmd
