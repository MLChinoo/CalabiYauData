local UnBlackFriendCmd = class("UnBlackFriendCmd", PureMVC.Command)
function UnBlackFriendCmd:Execute(notification)
  local playerId = notification:GetBody().playerId
  local friendType = notification:GetBody().friendType
  local playerName = notification:GetBody().playerName
  LogInfo("UnBlackFriendCmd playerId:", playerId)
  LogInfo("UnBlackFriendCmd friendType:", friendType)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendDel(playerId, friendType, playerName)
  end
end
return UnBlackFriendCmd
