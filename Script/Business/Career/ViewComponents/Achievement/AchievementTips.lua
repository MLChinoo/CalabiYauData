local AchievementTipsMediator = require("Business/Career/Mediators/Achievement/AchievementTipsMediator")
local AchievementTips = class("AchievementTips", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementTips:ListNeededMediators()
  return {AchievementTipsMediator}
end
function AchievementTips:InitializeLuaEvent()
  self.actionOnAcquireReward = LuaEvent.new()
end
function AchievementTips:Construct()
  AchievementTips.super.Construct(self)
  if self.Button_AcquireReward then
    self.Button_AcquireReward.OnClickEvent:Add(self, self.OnAcquireReward)
  end
  self.redDotName = ""
end
function AchievementTips:Destruct()
  if self.Button_AcquireReward then
    self.Button_AcquireReward.OnClickEvent:Remove(self, self.OnAcquireReward)
  end
  RedDotTree:Unbind(self.redDotName)
  AchievementTips.super.Destruct(self)
end
function AchievementTips:ShowAchievementInfo(typeInfo)
  LogDebug("AchievementTips", "Show achievement info")
  if self.redDotName ~= "" then
    RedDotTree:Unbind(self.redDotName)
    self.redDotName = ""
  end
  if typeInfo.typeId == CareerEnumDefine.achievementType.combat then
    self.redDotName = RedDotModuleDef.ModuleName.CareerACReward
  elseif typeInfo.typeId == CareerEnumDefine.achievementType.hornor then
    self.redDotName = RedDotModuleDef.ModuleName.CareerAHReward
  elseif typeInfo.typeId == CareerEnumDefine.achievementType.glory then
    self.redDotName = RedDotModuleDef.ModuleName.CareerAGReward
  end
  if self.redDotName ~= "" then
    RedDotTree:Bind(self.redDotName, function(cnt)
      self:UpdateRedDotAchieveReward(cnt)
    end)
    self:UpdateRedDotAchieveReward(RedDotTree:GetRedDotCnt(self.redDotName))
  end
  self.level = typeInfo.level
  local achievementName = ConfigMgr:FromStringTable(StringTablePath.ST_Career, CareerEnumDefine.achievementName[typeInfo.typeId])
  if self.WidgetSwitcher_TypeImage then
    self.WidgetSwitcher_TypeImage:SetActiveWidgetIndex(typeInfo.typeId - 1)
  end
  if self.TextBlock_Type and self.Text_Title and self.TextBlock_Progress then
    self.TextBlock_Type:SetText(achievementName)
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "AchievementCount")
    local stringMap = {
      [0] = achievementName
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.Text_Title:SetText(text)
    self.TextBlock_Progress:SetText(typeInfo.GotNum)
  end
  if self.TextBlock_Level then
    self.TextBlock_Level:SetText(CareerEnumDefine.achievementLevel[typeInfo.level])
  end
  if self.WBP_AchievementLevelProgress then
    local requiredNumList = {}
    for key, value in pairs(typeInfo.rewardList) do
      requiredNumList[key] = value.levelConfig.Need
    end
    self.WBP_AchievementLevelProgress:SetLevelProgress(requiredNumList, typeInfo.level, typeInfo.GotNum)
  end
  self.HB_RankPercent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local levelCount = 0
  if self.ScrollBox_Reward then
    self.rewardList = {}
    self.ScrollBox_Reward:ClearChildren()
    if self.AchievementLevelReward then
      local PanelClass = ObjectUtil:LoadClass(self.AchievementLevelReward)
      if PanelClass then
        for k, v in pairs(typeInfo.rewardList) do
          if table.count(v.levelReward) > 0 then
            local LevelRewardIns = UE4.UWidgetBlueprintLibrary.Create(self, PanelClass)
            LevelRewardIns:InitLevelReward(v, k <= typeInfo.level)
            self.ScrollBox_Reward:AddChild(LevelRewardIns)
            table.insert(self.rewardList, LevelRewardIns)
          end
          levelCount = levelCount + 1
        end
      else
        LogError("AchievementTips", "Level reward panel create failed")
      end
    end
    self.ScrollBox_Reward:ScrollToStart()
  end
  self.hasReward = typeInfo.rewardReceivedLevel < typeInfo.level
  self.maxLevel = levelCount
  if self.Button_AcquireReward then
    if levelCount >= typeInfo.rewardReceivedLevel then
      self.Button_AcquireReward:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "AcquireReward"))
      self.Button_AcquireReward:SetButtonIsEnabled(true)
    elseif self.hasReward then
      self.Button_AcquireReward:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "AcquireReward"))
      self.Button_AcquireReward:SetButtonIsEnabled(true)
    else
      self.Button_AcquireReward:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "HasAcquiredAll"))
      self.Button_AcquireReward:SetButtonIsEnabled(false)
    end
  end
end
function AchievementTips:OnAcquireReward()
  if self.hasReward then
    self.actionOnAcquireReward()
  else
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "NoRewardAvailable")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  end
end
function AchievementTips:AcquireLevelRewardSucceed(rewardLevelAcquired)
  for key, value in pairs(self.rewardList) do
    value:UpdateRewardState(rewardLevelAcquired)
  end
  if rewardLevelAcquired >= self.level then
    self.hasReward = false
  end
  if rewardLevelAcquired >= self.maxLevel then
    self.Button_AcquireReward:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "HasAcquiredAll"))
    self.Button_AcquireReward:SetButtonIsEnabled(false)
  end
end
function AchievementTips:UpdateRedDotAchieveReward(cnt)
  if self.Button_AcquireReward then
    self.Button_AcquireReward:SetRedDotVisible(cnt > 0)
  end
end
return AchievementTips
