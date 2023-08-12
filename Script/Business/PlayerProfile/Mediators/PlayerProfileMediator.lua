local PlayerProfileMediator = class("PlayerProfileMediator", PureMVC.Mediator)
function PlayerProfileMediator:ListNotificationInterests()
  return {
    NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData,
    NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle
  }
end
function PlayerProfileMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData then
    self:GetViewComponent():UpdateView(notification:GetBody().cardInfo, notification:GetBody().collectionInfo, notification:GetBody().privilegeInfo)
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle then
    local rebackMsg = notification:GetBody()
    if 0 == rebackMsg.code then
      GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd)
    end
  end
end
return PlayerProfileMediator
