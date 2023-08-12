local AchievementMedalTipsMediator = require("Business/Career/Mediators/Achievement/AchievementMedalTipsMediator")
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local AchievementMedalTips = class("AchievementMedalTips", PureMVC.ViewComponentPanel)
function AchievementMedalTips:ListNeededMediators()
  return {AchievementMedalTipsMediator}
end
function AchievementMedalTips:InitializeLuaEvent()
  self.actionOnAcquireReward = LuaEvent.new()
end
function AchievementMedalTips:Construct()
  AchievementMedalTips.super.Construct(self)
  if self.Button_AcquireReward then
    self.Button_AcquireReward.OnClickEvent:Add(self, self.OnAcquireReward)
  end
end
function AchievementMedalTips:Destruct()
  if self.Button_AcquireReward then
    self.Button_AcquireReward.OnClickEvent:Remove(self, self.OnAcquireReward)
  end
  AchievementMedalTips.super.Destruct(self)
end
function AchievementMedalTips:SetRewardOpacity(opacity)
  for key, value in pairs(self.rewardItemList) do
    value:SetItemOpacity(opacity)
  end
end
function AchievementMedalTips:ShowMedalInfo(achievementMedalInfo)
  local curLv = achievementMedalInfo.level
  local nextLv = curLv + 1
  local totalLv = table.count(achievementMedalInfo.levelNodes)
  if curLv == totalLv then
    nextLv = curLv
  end
  if self.WidgetSwitcher_MedalType then
    local lvOwn = achievementMedalInfo.obtainedNum
    local lvTarget = achievementMedalInfo.levelNodes[nextLv]
    if lvOwn > lvTarget then
      lvOwn = lvTarget
    end
    if self.TxtCurObtain then
      self.TxtCurObtain:SetText(tostring(lvOwn))
    end
    if self.TxtLevelTarget then
      self.TxtLevelTarget:SetText(string.format("/%d", achievementMedalInfo.levelNodes[nextLv]))
    end
    if self.TxtCurLevel then
      self.TxtCurLevel:SetText(string.format("%d级", curLv))
    end
    if self.TxtLevelNodes then
      local lvNodesDesc = string.format("共%d级- ", totalLv)
      for lv = 1, totalLv do
        local addInfo = tostring(achievementMedalInfo.levelNodes[lv])
        if lv ~= totalLv then
          addInfo = addInfo .. " | "
        end
        lvNodesDesc = lvNodesDesc .. addInfo
      end
      self.TxtLevelNodes:SetText(lvNodesDesc)
    end
    if self.ProgressCurLevel then
      local pct = achievementMedalInfo.obtainedNum / achievementMedalInfo.levelNodes[nextLv]
      self.ProgressCurLevel:SetPercent(pct)
    end
    if self.CanvasPanel_Glory then
      self.CanvasPanel_Glory:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.WidgetSwitcher_MedalType:SetActiveWidgetIndex(0)
  end
  if self.AchievementIcon then
    self.AchievementIcon:InitView(achievementMedalInfo.config.Id)
    self.AchievementIcon:ForbidNameInteraction()
  end
  if self.TextBlock_Name then
    self.TextBlock_Name:SetText(achievementMedalInfo.config.Name)
  end
  if self.TextBlock_Description and self.TextBlock_Detail then
    local achvCfg = achievementMedalInfo.config
    local explainMsg = achvCfg.Explain
    local strMap = {}
    strMap[0] = achievementMedalInfo.levelNodes[nextLv]
    explainMsg = ObjectUtil:GetTextFromFormat(explainMsg, strMap)
    self.TextBlock_Description:SetText(explainMsg)
    self.TextBlock_Detail:SetText(achvCfg.Details)
  end
  if self.PanelLevelDetail then
    self.PanelLevelDetail:SetLevelProgress(achievementMedalInfo.mileStone, achievementMedalInfo.level, achievementMedalInfo.progress)
  end
end
function AchievementMedalTips:OnAcquireReward()
  LogDebug("AchievementMedalTips", "Acquire achievement reward")
  self.actionOnAcquireReward()
end
function AchievementMedalTips:AcquireRewardSucceed()
  self:SetRewardOpacity(0.45)
  self.Button_AcquireReward:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "HasAcquired"))
  self.Button_AcquireReward:SetButtonIsEnabled(false)
end
return AchievementMedalTips
