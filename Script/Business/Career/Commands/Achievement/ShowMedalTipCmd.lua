local ShowMedalTipCmd = class("ShowMedalTipCmd", PureMVC.Command)
function ShowMedalTipCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowMedalTipCmd then
    local achievementMap = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchievementMap()
    local medalType = notification:GetBody().achievementType
    local medalId = notification:GetBody().medalId
    local MedalInfo = {}
    local itemProperty = achievementMap[medalType].achievementList[medalId]
    MedalInfo.config = itemProperty.itemConfig
    MedalInfo.progress = itemProperty.progress
    MedalInfo.obtainedNum = itemProperty.progress
    MedalInfo.level = itemProperty.level
    MedalInfo.rewardStatus = itemProperty.rewardStatus
    MedalInfo.levelNodes = itemProperty.levelNodes
    local rewardList = itemProperty.itemConfig.Param5
    if rewardList:Length() > 0 then
      MedalInfo.rewardItemInfo = {}
      for index = 1, rewardList:Length() do
        local rewardItem = {}
        rewardItem.itemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemTableConfig(rewardList:Get(index).ItemId)
        rewardItem.itemAmount = rewardList:Get(index).ItemAmount
        table.insert(MedalInfo.rewardItemInfo, rewardItem)
      end
    else
      MedalInfo.rewardItemInfo = nil
    end
    GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowMedalTip, MedalInfo)
  end
end
return ShowMedalTipCmd
