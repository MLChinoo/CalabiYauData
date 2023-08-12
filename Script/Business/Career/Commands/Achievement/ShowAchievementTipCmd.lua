local ShowAchievementTipCmd = class("ShowAchievementTipCmd", PureMVC.Command)
function ShowAchievementTipCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowAchievementTipCmd then
    local achievementMap = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchievementMap()
    local achievementTypeChosen = notification:GetBody()
    local typeInfo = {}
    typeInfo.typeId = achievementTypeChosen
    typeInfo.level = achievementMap[achievementTypeChosen].level
    typeInfo.config = achievementMap[achievementTypeChosen].config
    typeInfo.configRow = typeInfo.config[1]
    typeInfo.totalNum = achievementMap[achievementTypeChosen].totalNum
    typeInfo.rank = achievementMap[achievementTypeChosen].rank
    typeInfo.rewardReceivedLevel = achievementMap[achievementTypeChosen].rewardReceivedLevel
    typeInfo.rewardList = {}
    for i = 1, table.count(typeInfo.config) do
      typeInfo.rewardList[i] = {}
    end
    for key, value in pairs(typeInfo.config) do
      typeInfo.rewardList[value.Level].levelConfig = value
      typeInfo.rewardList[value.Level].levelReward = {}
      for i = 1, value.Reward:Length() do
        local rewardItem = {}
        rewardItem.itemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemInfoById(value.Reward:Get(i).ItemId)
        rewardItem.itemAmount = value.Reward:Get(i).ItemAmount
        table.insert(typeInfo.rewardList[value.Level].levelReward, rewardItem)
      end
      typeInfo.rewardList[value.Level].hasAcquired = achievementMap[achievementTypeChosen].rewardReceivedLevel >= value.Level
      if value.Level == typeInfo.level then
        typeInfo.configRow = value
      end
    end
    GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowAchievementTip, typeInfo)
  end
end
return ShowAchievementTipCmd
