local FriendSearchStrangePageMediator = class("FriendSearchStrangePageMediator", PureMVC.Mediator)
function FriendSearchStrangePageMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd
  }
end
function FriendSearchStrangePageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmd and notify:GetType() == NotificationDefines.FriendCmdType.SearchFriendRes then
    self:OnSearchFriendResCallback(notify:GetBody())
  end
end
function FriendSearchStrangePageMediator:OnRegister()
end
function FriendSearchStrangePageMediator:OnRemove()
end
function FriendSearchStrangePageMediator:OnSearchFriendResCallback(inList)
  local cnt = table.count(inList)
  if 0 == cnt then
    self:GetViewComponent():ShowNotFindStatus()
  else
    self:GetViewComponent():ShowFindStatusByArr(inList)
  end
end
return FriendSearchStrangePageMediator
