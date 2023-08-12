local AchievementItem = class("AchievementItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementItem:InitializeLuaEvent()
end
function AchievementItem:Construct()
  AchievementItem.super.Construct(self)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isChosen = false
end
function AchievementItem:InitNormalItem(itemProperty)
  if not itemProperty or not itemProperty.itemConfig then
    return
  end
  self.AchvInfo = itemProperty
  self.achievementType = itemProperty.itemConfig.Type
  self.medalId = itemProperty.baseId
  self.medalLvId = itemProperty.itemConfig.Id
  self.redDotId = itemProperty.redDotId
  if self.ProgressBar_Completed then
    self.ProgressBar_Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.AchievementIcon and self.CanvasPanel_Normal and self.TextBlock_ObtainedNum then
    self.AchievementIcon:InitView(self.medalLvId, true, true)
    self.AchievementIcon:SetTextSize(CareerEnumDefine.textSize.large)
    local curLv = itemProperty.level
    local nextLv = curLv + 1
    local totalLv = table.count(itemProperty.levelNodes)
    if curLv == totalLv then
      nextLv = curLv
    else
      self.ProgressBar_Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local lvOwn = itemProperty.progress
      local lvTarget = itemProperty.levelNodes[nextLv]
      local progressPct = lvOwn / lvTarget
      self.ProgressBar_Completed:SetPercent(progressPct)
    end
    if itemProperty.level > 0 then
      self.AchievementIcon:SetOpacity(1.0)
      self.CanvasPanel_Normal:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.TextBlock_ObtainedNum:SetText(string.format("Lv.%d", curLv))
    else
      self.AchievementIcon:SetOpacity(0.3)
      self.CanvasPanel_Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.RedDot_New then
    self.RedDot_New:SetVisibility(self.redDotId and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function AchievementItem:InitGloryItem(itemProperty)
  if itemProperty and itemProperty.itemConfig then
    self.AchvInfo = itemProperty
    self.achievementType = itemProperty.itemConfig.Type
    self.medalId = itemProperty.baseId
    self.medalLvId = itemProperty.itemConfig.Id
    self.redDotId = itemProperty.redDotId
    if self.CanvasPanel_Normal then
      self.CanvasPanel_Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.AchievementIcon and self.ProgressBar_Completed then
      self.AchievementIcon:InitView(self.medalLvId, true, true)
      self.AchievementIcon:SetTextSize(CareerEnumDefine.textSize.large)
      local obtainedNum = itemProperty.progress
      local requiredNum = 1
      if itemProperty.itemConfig.Param2:Length() > 0 then
        requiredNum = itemProperty.itemConfig.Param2:Get(1)
      end
      if requiredNum <= 1 or obtainedNum >= requiredNum then
        self.ProgressBar_Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
        if obtainedNum > 0 and obtainedNum >= requiredNum then
          self.AchievementIcon:SetOpacity(1.0)
        else
          self.AchievementIcon:SetOpacity(0.3)
        end
      else
        self.AchievementIcon:SetOpacity(0.3)
        self.ProgressBar_Completed:SetPercent(obtainedNum / requiredNum)
        self.ProgressBar_Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    if self.RedDot_New then
      self.RedDot_New:SetVisibility(self.redDotId and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
  end
end
function AchievementItem:OnLuaItemClick()
  LogDebug("AchievementItem", "Image mouse button down")
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Select:SetRenderOpacity(1.0)
  end
  self.isChosen = true
  self.AchvInfo.redDotId = nil
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowMedalTipCmd, self)
  if self.redDotId then
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(self.redDotId)
    self.redDotId = nil
    if self.RedDot_New then
      self.RedDot_New:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function AchievementItem:SetUnchosen()
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isChosen = false
end
function AchievementItem:OnLuaItemHovered()
  if self.isChosen then
    return
  end
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Select:SetRenderOpacity(0.6)
  end
end
function AchievementItem:OnLuaItemUnhovered()
  if self.isChosen then
    return
  end
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return AchievementItem
