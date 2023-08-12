local AchievementMedalTipsMediator = class("AchievementMedalTipsMediator", PureMVC.Mediator)
function AchievementMedalTipsMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.Achievement.ShowMedalTip,
    NotificationDefines.Career.Achievement.OnResAcquireReward
  }
end
function AchievementMedalTipsMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowMedalTip then
    self:GetViewComponent():ShowMedalInfo(notification:GetBody())
    self.achievementId = notification:GetBody().config.Id
    self.achievementType = notification:GetBody().config.Type
  end
  if notification:GetName() == NotificationDefines.Career.Achievement.OnResAcquireReward then
    local rewardData = notification:GetBody()
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
    if 0 == rewardData.code then
      LogDebug("AchievementMedalTipsMediator", "Acquire reward succeed")
      self:GetViewComponent():AcquireRewardSucceed()
      local rewardItems = {}
      for key, value in pairs(rewardData.items) do
        local item = {}
        item.itemId = value.item_id
        item.itemCnt = value.item_count
        table.insert(rewardItems, item)
      end
    else
      LogDebug("AchievementMedalTipsMediator", "Acquire reward failed")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, rewardData.code)
    end
  end
end
function AchievementMedalTipsMediator:OnRegister()
  LogDebug("AchievementMedalTipsMediator", "On register")
  AchievementMedalTipsMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnAcquireReward:Add(self.AcquireReward, self)
end
function AchievementMedalTipsMediator:OnRemove()
  self:GetViewComponent().actionOnAcquireReward:Remove(self.AcquireReward, self)
  AchievementMedalTipsMediator.super.OnRemove(self)
end
function AchievementMedalTipsMediator:AcquireReward()
  LogDebug("AchievementMedalTipsMediator", "Acquire achievement %d reward", self.achievementId)
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.AcquireRewardCmd, self.achievementId)
end
return AchievementMedalTipsMediator
