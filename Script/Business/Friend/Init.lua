local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.FriendDataProxy,
    Path = "Business/Friend/Proxies/FriendProxy"
  },
  {
    Name = ProxyNames.TeamApplyAndInviteProxy,
    Path = "Business/Friend/Proxies/TeamApplyAndInviteProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.FriendGetPlayerInfoCmd,
    Path = "Business/Friend/Commands/FriendListPageCmd"
  },
  {
    Name = NotificationDefines.ShowPlayerApplyTeamPopPageCmd,
    Path = "Business/Friend/Commands/ShowPlayerApplyTeamPopPageCmd"
  },
  {
    Name = NotificationDefines.AddFriendCmd,
    Path = "Business/Friend/Commands/AddFriendCmd"
  },
  {
    Name = NotificationDefines.OpenFriendApplyCmd,
    Path = "Business/Friend/Commands/OpenFriendApplyCmd"
  },
  {
    Name = NotificationDefines.ShieldFriendCmd,
    Path = "Business/Friend/Commands/ShieldFriendCmd"
  },
  {
    Name = NotificationDefines.UnShieldFriendCmd,
    Path = "Business/Friend/Commands/UnShieldFriendCmd"
  },
  {
    Name = NotificationDefines.InviteFriendCmd,
    Path = "Business/Friend/Commands/InviteFriendCmd"
  },
  {
    Name = NotificationDefines.DeleteFriendCmd,
    Path = "Business/Friend/Commands/DeleteFriendCmd"
  },
  {
    Name = NotificationDefines.FriendReplyCmd,
    Path = "Business/Friend/Commands/FriendReplyCmd"
  },
  {
    Name = NotificationDefines.InviteFriendCountdownCmd,
    Path = "Business/Friend/Commands/InviteFriendCountdownCmd"
  },
  {
    Name = NotificationDefines.ReqJoinFriendCountdownCmd,
    Path = "Business/Friend/Commands/ReqJoinFriendCountdownCmd"
  }
}
return M
