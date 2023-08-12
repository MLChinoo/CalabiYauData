local ReqJoinFriendCountdownCmd = class("ReqJoinFriendCountdownCmd", PureMVC.Command)
function ReqJoinFriendCountdownCmd:Execute(notification)
  local playerId = notification:GetBody()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:SetReqJoinFriendRoomState(playerId, false)
    TimerMgr:AddTimeTask(15, 0, 1, function()
      friendDataProxy:SetReqJoinFriendRoomState(playerId, true)
      GameFacade:SendNotification(NotificationDefines.ResetJoinState, playerId)
    end)
  end
end
return ReqJoinFriendCountdownCmd
