local FriendMsgMediator = class("FriendMsgMediator", PureMVC.Mediator)
function FriendMsgMediator:ListNotificationInterests()
  return {}
end
function FriendMsgMediator:HandleNotification(notify)
end
function FriendMsgMediator:OnRegister()
end
function FriendMsgMediator:OnRemove()
end
return FriendMsgMediator
