local GrowthTeamUpgradeProgressMediator = class("GrowthTeamUpgradeProgressMediator", PureMVC.Mediator)
function GrowthTeamUpgradeProgressMediator:ListNotificationInterests()
  return {
    NotificationDefines.Growth.GrowthLevelUpdateCmd
  }
end
function GrowthTeamUpgradeProgressMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Growth.GrowthLevelUpdateCmd then
    self.viewComponent:Update()
  end
end
return GrowthTeamUpgradeProgressMediator
