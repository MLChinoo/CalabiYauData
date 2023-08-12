local GrowthLevelProgressBar = class("GrowthLevelProgressBar", PureMVC.ViewComponentPanel)
function GrowthLevelProgressBar:OnInitialized()
  self.CurrentPercentInfo = {}
  self.NextLevelPercentInfo = {}
  self.CurrentPercentInfo.Time = -1
  self.NextLevelPercentInfo.Time = -1
  self.ProgressAnimTime = 0.3
end
function GrowthLevelProgressBar:SetLevelProgressInfo(info)
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  self.TextBlock_Num:SetText(math.floor(info.InNum))
  if info.InBaseNum then
    if info.InBaseNum < info.InNum then
      self.TextBlock_Num:SetColorAndOpacity(self.ColorUpgrade)
    elseif info.InBaseNum > info.InNum then
      self.TextBlock_Num:SetColorAndOpacity(self.ColorDownUpgrade)
    else
      self.TextBlock_Num:SetColorAndOpacity(self.OriginColorUnUpgrade)
    end
  else
    self.TextBlock_Num:SetColorAndOpacity(self.OriginColorUnUpgrade)
  end
  self.TextBlock_NextLevelNum:SetText(math.floor(info.InNextLevelNum))
  if info.InNextLevelNum >= 0 and info.InNextLevelNum > info.InNum then
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowUpgrade)
  elseif info.InNextLevelNum >= 0 and info.InNextLevelNum < info.InNum then
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorDownUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowDownUpgrade)
  else
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorUnUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowUnUpgrade)
  end
  self.HorizontalBox_NextLevelInfo:SetVisibility(info.InNextLevelNum >= 0 and info.InNextLevelNum ~= info.InNum and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if info.InNextLevenPercent >= info.InBasePercent then
    self.ProgressBar_CurrentPercent.WidgetStyle.FillImage.TintColor = self.ProgressBarUpgradeCurColor
    self.ProgressBar_NextLevelPercent.WidgetStyle.FillImage.TintColor = self.ProgressBarUpgradeNextColor
    self.ProgressBar_NextLevelPercent.Slot:SetZOrder(1)
    self.ProgressBar_CurrentPercent.Slot:SetZOrder(2)
    self.CurrentPercentInfo.StartPercent = info.InBasePercent
    self.CurrentPercentInfo.EndPercent = info.InBasePercent
  else
    self.ProgressBar_CurrentPercent.WidgetStyle.FillImage.TintColor = self.ProgressBarDowngradeCurColor
    self.ProgressBar_NextLevelPercent.WidgetStyle.FillImage.TintColor = self.ProgressBarDowngradeNextColor
    self.ProgressBar_CurrentPercent.Slot:SetZOrder(1)
    self.ProgressBar_NextLevelPercent.Slot:SetZOrder(2)
    self.CurrentPercentInfo.StartPercent = self.ProgressBar_CurrentPercent.Percent
    self.CurrentPercentInfo.EndPercent = info.InPercent
  end
  self.CurrentPercentInfo.Time = 0
  self.NextLevelPercentInfo.Time = 0
  self.NextLevelPercentInfo.StartPercent = self.ProgressBar_NextLevelPercent.Percent
  self.NextLevelPercentInfo.EndPercent = info.InNextLevenPercent
end
function GrowthLevelProgressBar:HideNextLevelInfo()
  self.HorizontalBox_NextLevelInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ProgressBar_NextLevelPercent:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function GrowthLevelProgressBar:Tick(MyGeometry, InDeltaTime)
  if self.CurrentPercentInfo.Time >= 0 then
    self:UpdateProgressAnim(self.ProgressBar_CurrentPercent, self.CurrentPercentInfo, InDeltaTime)
  end
  if self.NextLevelPercentInfo.Time >= 0 then
    self:UpdateProgressAnim(self.ProgressBar_NextLevelPercent, self.NextLevelPercentInfo, InDeltaTime)
  end
end
function GrowthLevelProgressBar:UpdateProgressAnim(InProgressBar, AnimInfo, InDeltaTime)
  AnimInfo.Time = AnimInfo.Time + InDeltaTime
  local Percent = math.min(AnimInfo.Time / self.ProgressAnimTime, 1.0)
  Percent = self.Curve_ProgressBar:GetFloatValue(Percent)
  Percent = AnimInfo.StartPercent + (AnimInfo.EndPercent - AnimInfo.StartPercent) * Percent
  InProgressBar:SetPercent(Percent)
  if AnimInfo.Time >= self.ProgressAnimTime then
    AnimInfo.Time = -1.0
  end
end
return GrowthLevelProgressBar
