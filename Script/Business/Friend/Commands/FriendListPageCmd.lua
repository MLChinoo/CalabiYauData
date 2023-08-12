local FriendListPageCmd = class("FriendGetPlayerInfoCmd", PureMVC.Command)
function FriendListPageCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.FriendGetPlayerInfoCmd then
    local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
    local playerInfoTable = {}
    if friendDataProxy then
      playerInfoTable.playerID = friendDataProxy:GetPlayerID()
      playerInfoTable.nick = friendDataProxy:GetNick()
      playerInfoTable.onlineStatus = friendDataProxy:GetOnlineStatus()
      playerInfoTable.stars = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetRankInfo().stars
      GameFacade:SendNotification(NotificationDefines.FriendCmd, playerInfoTable, NotificationDefines.FriendCmdType.UpdatePlayerInfo)
    end
  end
end
return FriendListPageCmd
