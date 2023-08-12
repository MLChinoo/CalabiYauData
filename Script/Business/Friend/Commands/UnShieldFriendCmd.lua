local UnShieldFriendCmd = class("UnShieldFriendCmd", PureMVC.Command)
function UnShieldFriendCmd:Execute(notification)
  local playerId = notification:GetBody().playerId
  LogInfo("UnShieldFriendCmd playerId:", playerId)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:UnshieldPlayer(playerId)
  end
end
return UnShieldFriendCmd
