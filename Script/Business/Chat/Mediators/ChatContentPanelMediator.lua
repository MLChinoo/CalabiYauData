local ChatContentPanelMediator = class("ChatContentPanelMediator", PureMVC.Mediator)
function ChatContentPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.ClearBlacklistMsg
  }
end
function ChatContentPanelMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Chat.ClearBlacklistMsg then
    self:GetViewComponent():DeleteMsgOfPlayer(notification:GetBody())
  end
end
return ChatContentPanelMediator
