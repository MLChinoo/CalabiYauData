local WorldChannelSettingMediator = class("WorldChannelSettingMediator", PureMVC.Mediator)
function WorldChannelSettingMediator:ListNotificationInterests()
  return {
    NotificationDefines.Chat.OnResAllWorldChannel
  }
end
function WorldChannelSettingMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Chat.OnResAllWorldChannel then
    self:GetViewComponent():InitView(notification:GetBody())
  end
end
return WorldChannelSettingMediator
