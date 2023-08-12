local AchievementReward = class("AchievementReward", PureMVC.ViewComponentPanel)
function AchievementReward:InitRewardInfo(rewardInfo)
  if self.Image_Item and self.CanvasPanel_Lock and self.TextBlock_Name and self.TextBlock_Description and self.Button_AcquireReward and self.TextBlock_RewardAvailable then
    if rewardInfo.rewardItemInfo[1].itemConfig then
      self:SetImageByTexture2D(self.Image_Item, rewardInfo.rewardItemInfo[1].itemConfig.IconItem)
      self.TextBlock_Name:SetText(rewardInfo.rewardItemInfo[1].itemConfig.Name)
      self.TextBlock_Description:SetText(rewardInfo.rewardItemInfo[1].itemConfig.Desc)
    end
    if 0 == rewardInfo.rewardStatus then
      self.Button_AcquireReward:SetIsEnabled(false)
      self.TextBlock_RewardAvailable:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "Locked"))
    elseif 1 == rewardInfo.rewardStatus then
      self.Button_AcquireReward:SetIsEnabled(true)
      self.TextBlock_RewardAvailable:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "AcquireReward"))
    else
      self.Button_AcquireReward:SetIsEnabled(false)
      self.TextBlock_RewardAvailable:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "HasAcquired"))
    end
  end
end
return AchievementReward
