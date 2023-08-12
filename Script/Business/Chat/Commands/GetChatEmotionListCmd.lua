local GetChatEmotionListCmd = class("GetChatEmotionListCmd", PureMVC.Command)
function GetChatEmotionListCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Chat.GetChatEmotionListCmd then
    local emotions = {}
    for key, value in pairs(GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetChatEmotionList()) do
      local chatEmotion = {}
      chatEmotion.id = value.Id
      chatEmotion.icon = value.Icon
      emotions[value.id] = chatEmotion
    end
    GameFacade:SendNotification(NotificationDefines.Chat.GetChatEmotionList, emotions)
  end
end
return GetChatEmotionListCmd
