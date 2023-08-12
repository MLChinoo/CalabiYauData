local InviteFriendCountdownCmd = class("InviteFriendCountdownCmd", PureMVC.Command)
function InviteFriendCountdownCmd:Execute(notification)
  local playerId = notification:GetBody()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:SetFriendInviteState(playerId, false)
    TimerMgr:AddTimeTask(15, 0, 1, function()
      friendDataProxy:SetFriendInviteState(playerId, true)
      GameFacade:SendNotification(NotificationDefines.ResetInviteState, playerId)
    end)
  end
end
return InviteFriendCountdownCmd
