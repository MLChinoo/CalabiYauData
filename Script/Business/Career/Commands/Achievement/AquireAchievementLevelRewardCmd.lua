local AquireAchievementLevelRewardCmd = class("AquireAchievementLevelRewardCmd", PureMVC.Command)
function AquireAchievementLevelRewardCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.AcquireLevelRewardCmd then
    GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):ReqAchievementLevelReward(notification:GetBody())
  end
end
return AquireAchievementLevelRewardCmd
