local AchievementLevelReward = class("AchievementLevelReward", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementLevelReward:SetRewardOpacity(opacity)
  for key, value in pairs(self.rewardItemList) do
    value:SetItemOpacity(opacity)
  end
end
function AchievementLevelReward:InitLevelReward(achievementLevelInfo, hasReached)
  if self.TextBlock_RewardName and self.DynamicEntryBox_RewardItemList then
    self.level = achievementLevelInfo.levelConfig.Level
    if self.TextBlock_Level then
      self.TextBlock_Level:SetText(CareerEnumDefine.achievementLevel[self.level])
      if 5 == self.level then
        local slateColor = UE4.FSlateColor()
        slateColor.SpecifiedColor = UE4.UKismetMathLibrary.MakeColor(0.51, 0.03, 0.04, 1.0)
        self.TextBlock_Level:SetColorandOpacity(slateColor)
      end
    end
    self.rewardItemList = {}
    for key, value in pairs(achievementLevelInfo.levelReward) do
      if table.count(value) > 0 then
        local rewardIns = self.DynamicEntryBox_RewardItemList:BP_CreateEntry()
        if rewardIns then
          rewardIns:SetRewardItem(value, hasReached)
          table.insert(self.rewardItemList, rewardIns)
        end
      end
    end
    if achievementLevelInfo.hasAcquired or not hasReached then
      self:SetRewardOpacity(0.45)
    end
  end
end
function AchievementLevelReward:UpdateRewardState(acquiredLevel)
  if acquiredLevel >= self.level and self.DynamicEntryBox_RewardItemList then
    self:SetRewardOpacity(0.45)
  end
end
return AchievementLevelReward
