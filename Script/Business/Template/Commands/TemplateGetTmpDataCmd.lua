local TemplateGetTmpDataCmd = class("TemplateGetTmpDataCmd", PureMVC.Command)
function TemplateGetTmpDataCmd:Execute(notification)
  if notification.GetName() == NotificationDefines.EnterLobbyScene then
    if notification.GetType() == NotificationDefines.EnterLobbySceneType.Normal then
      LogDebug("Noraml Type")
    elseif notification.GetType() == NotificationDefines.EnterLobbySceneType.Special then
      LogDebug("Special Type")
    end
  end
end
