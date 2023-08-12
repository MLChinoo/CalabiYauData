local ChatPanelMobileMediator = class("ChatPanelMobileMediator", PureMVC.Mediator)
function ChatPanelMobileMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.ChatPanelStatusChange,
    NotificationDefines.Chat.UpdateChatPanelSetting,
    NotificationDefines.Chat.StartChatCD
  }
end
function ChatPanelMobileMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Chat.ChatPanelStatusChange then
    self:GetViewComponent():ChangeChatState(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Chat.UpdateChatPanelSetting then
    local location, size = self:GetViewComponent():GetPanelLoc()
    location = UE4.UKismetMathLibrary.GetAbs2D(location)
    local panelLoc = {position = location, desiredSize = size}
    GameFacade:SendNotification(NotificationDefines.Chat.SetChatPanelLoc, panelLoc)
  end
  if notification:GetName() == NotificationDefines.Chat.StartChatCD then
    self:GetViewComponent():ShowChatCD(notification:GetBody())
  end
end
return ChatPanelMobileMediator
