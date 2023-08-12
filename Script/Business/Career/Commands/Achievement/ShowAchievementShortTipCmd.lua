local ShowAchievementShortTipCmd = class("ShowAchievementShortTipCmd", PureMVC.Command)
function ShowAchievementShortTipCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowAchievementShortTipCmd then
    local achievementId = notification:GetBody()
    local achievementCfg = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchievementTableRow(achievementId)
    GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowAchievementShortTip, achievementCfg)
  end
end
return ShowAchievementShortTipCmd
