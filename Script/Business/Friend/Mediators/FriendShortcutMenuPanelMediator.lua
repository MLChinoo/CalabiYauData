local FriendShortcutMenuPanelMediator = class("FriendShortcutMenuPanelMediator", PureMVC.Mediator)
function FriendShortcutMenuPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.ResetInviteState,
    NotificationDefines.ResetJoinState
  }
end
function FriendShortcutMenuPanelMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.ResetInviteState then
    self:GetViewComponent():SetInviteState(notify:GetBody(), true)
  end
  if notify:GetName() == NotificationDefines.ResetJoinState then
    self:GetViewComponent():SetJoinState(notify:GetBody(), true)
  end
end
return FriendShortcutMenuPanelMediator
