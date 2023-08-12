local FriendListPageMediator = class("FriendListPageMediator", PureMVC.Mediator)
function FriendListPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd,
    NotificationDefines.FriendInfoChange
  }
end
function FriendListPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmd then
    if notify:GetType() == NotificationDefines.FriendCmdType.UpdatePlayerInfo then
      self:GetViewComponent():InitPlayerInfo(notify:GetBody())
    elseif notify:GetType() == NotificationDefines.FriendCmdType.FriendListNtf then
      self:GetViewComponent():InitView()
    elseif notify:GetType() == NotificationDefines.FriendCmdType.FriendDelNtf then
      self:GetViewComponent():DeleteFriend(notify:GetBody())
    elseif notify:GetType() == NotificationDefines.FriendCmdType.FriendChangeNtf then
      self:GetViewComponent():ChangePlayerList(notify:GetBody())
    elseif notify:GetType() == NotificationDefines.FriendCmdType.FriendInfoUpdate then
      for key, value in pairs(notify:GetBody()) do
        self:GetViewComponent():UpdateFriendInfo(value)
      end
    elseif notify:GetType() == NotificationDefines.FriendCmdType.GroupNtf then
      self:GetViewComponent():UpdateGroup()
    elseif notify:GetType() == NotificationDefines.FriendCmdType.OnlineStatusSetup then
      self:GetViewComponent():SetOnlineStatus(notify:GetBody())
    end
  end
  if notify:GetName() == NotificationDefines.FriendInfoChange then
    self:GetViewComponent():UpdateFriendInfo(notify:GetBody())
  end
end
return FriendListPageMediator
