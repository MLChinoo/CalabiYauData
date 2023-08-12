local AchievementTipsMediator = class("AchievementTipsMediator", PureMVC.Mediator)
function AchievementTipsMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.Achievement.OnResAcquireLevelReward,
    NotificationDefines.Career.Achievement.ShowAchievementTip
  }
end
function AchievementTipsMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowAchievementTip then
    self.achievementTypeShown = notification:GetBody().typeId
    self:GetViewComponent():ShowAchievementInfo(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Career.Achievement.OnResAcquireLevelReward then
    local levelRewardData = notification:GetBody()
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
    if 0 == levelRewardData.code then
      self:GetViewComponent():AcquireLevelRewardSucceed(levelRewardData.level)
      local rewardItems = {}
      for key, value in pairs(levelRewardData.items) do
        local item = {}
        item.itemId = value.item_id
        item.itemCnt = value.item_count
        table.insert(rewardItems, item)
      end
      local openData = {itemList = rewardItems}
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, levelRewardData.code)
    end
  end
end
function AchievementTipsMediator:OnRegister()
  LogDebug("AchievementTipsMediator", "On register")
  AchievementTipsMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnAcquireReward:Add(self.AcquireLevelReward, self)
end
function AchievementTipsMediator:OnRemove()
  self:GetViewComponent().actionOnAcquireReward:Remove(self.AcquireLevelReward, self)
  AchievementTipsMediator.super.OnRemove(self)
end
function AchievementTipsMediator:AcquireLevelReward()
  LogDebug("AchievementTipsMediator", "Acquire %s level reward", self.achievementTypeShown)
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.AcquireLevelRewardCmd, self.achievementTypeShown)
end
return AchievementTipsMediator
