local CareerDataMediator = class("CareerDataMediator", PureMVC.Mediator)
function CareerDataMediator:ListNotificationInterests()
  return {
    NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData,
    NotificationDefines.PlayerProfile.PlayerData.GetCareerData
  }
end
function CareerDataMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData then
    self:GetViewComponent():InitView()
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.GetCareerData then
    self:GetViewComponent():UpdateView(notification:GetBody())
  end
end
return CareerDataMediator
