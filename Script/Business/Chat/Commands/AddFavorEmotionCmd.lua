local AddFavorEmotionCmd = class("AddFavorEmotionCmd", PureMVC.Command)
function AddFavorEmotionCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Chat.AddFavorEmotionCmd and notification:GetBody() then
    local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    for key, value in pairs(chatDataProxy:GetChatEmotionList()) do
      if value.Id == notification:GetBody() then
        local chatEmotion = {}
        chatEmotion.id = value.Id
        chatEmotion.icon = value.Icon
        chatDataProxy:AddFavorEmotion(chatEmotion)
        return
      end
    end
  end
end
return AddFavorEmotionCmd
