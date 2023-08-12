local RoleMatchDataMediator = class("RoleMatchDataMediator", PureMVC.Mediator)
function RoleMatchDataMediator:ListNotificationInterests()
  return {
    NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData,
    NotificationDefines.PlayerProfile.PlayerData.GetRoleMatchData
  }
end
function RoleMatchDataMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData then
    self:GetViewComponent():InitView()
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.GetRoleMatchData then
    self:GetViewComponent():UpdateView(notification:GetBody())
  end
end
return RoleMatchDataMediator
