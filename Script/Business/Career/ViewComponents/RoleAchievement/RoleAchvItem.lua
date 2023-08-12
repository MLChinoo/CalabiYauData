local RoleAchvItem = class("RoleAchvItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function RoleAchvItem:InitializeLuaEvent()
end
function RoleAchvItem:Construct()
  RoleAchvItem.super.Construct(self)
end
function RoleAchvItem:ResetItem()
  self.isChosen = false
  self:StopAnimation(self.Anim_Selected)
  self:StopAnimation(self.Anim_Hover)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RoleAchvItem:InitNormalItem(slotIdx, posIdx, itemProperty)
  self:ResetItem()
  self.ParentSlotIdx = slotIdx
  self.ItemIdx = self.ParentSlotIdx * 2 + posIdx
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
    if lvOwn > 0 then
      local lvTarget = itemProperty.levelNodes[nextLv]
      local progressPct = lvOwn / lvTarget
      self.ProgressBar_Completed:SetPercent(progressPct)
    else
      self.ProgressBar_Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if itemProperty.level > 0 then
    self.AchievementIcon:SetOpacity(1.0)
    self.CanvasPanel_Normal:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_ObtainedNum:SetText(string.format("Lv.%d", curLv))
  else
    self.AchievementIcon:SetOpacity(0.3)
    self.CanvasPanel_Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot_New then
    self.RedDot_New:SetVisibility(self.redDotId and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function RoleAchvItem:OnLuaItemClick()
  LogDebug("RoleAchvItem", "Image mouse button down")
  if self.isChosen then
    return
  end
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Select:SetRenderOpacity(1.0)
  end
  self.isChosen = true
  self.AchvInfo.redDotId = nil
  GameFacade:SendNotification(NotificationDefines.Career.RoleAchievement.RoleAchvItemSelected, self)
  self:PlayAnimation(self.Anim_Selected, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if self.redDotId then
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(self.redDotId)
    self.redDotId = nil
    if self.RedDot_New then
      self.RedDot_New:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RoleAchvItem:SetUnchosen()
  self:StopAnimation(self.Anim_Selected)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isChosen = false
end
function RoleAchvItem:OnLuaItemHovered()
  if self.isChosen then
    return
  end
  self:PlayAnimation(self.Anim_Hover, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Select:SetRenderOpacity(0.6)
  end
end
function RoleAchvItem:OnLuaItemUnhovered()
  if self.isChosen then
    return
  end
  self:StopAnimation(self.Anim_Hover)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return RoleAchvItem
