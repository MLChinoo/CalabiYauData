local ChatEmotionPanelMediator = class("ChatEmotionPanelMediator", PureMVC.Mediator)
function ChatEmotionPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.GetChatEmotionList,
    NotificationDefines.Chat.AddFavorEmotion
  }
end
function ChatEmotionPanelMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Chat.GetChatEmotionList then
    self:GetViewComponent():InitView(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Chat.AddFavorEmotion then
    self:GetViewComponent():UpdateFavor()
  end
end
return ChatEmotionPanelMediator
