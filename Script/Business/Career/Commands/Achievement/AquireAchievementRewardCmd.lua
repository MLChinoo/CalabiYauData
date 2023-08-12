local AquireAchievementRewardCmd = class("AquireAchievementRewardCmd", PureMVC.Command)
function AquireAchievementRewardCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.AcquireRewardCmd then
    GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):ReqAchievementReward(notification:GetBody())
  end
end
return AquireAchievementRewardCmd
