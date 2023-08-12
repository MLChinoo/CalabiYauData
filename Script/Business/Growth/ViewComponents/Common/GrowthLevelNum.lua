local GrowthLevelNum = class("GrowthLevelNum", PureMVC.ViewComponentPanel)
function GrowthLevelNum:SetLevelInfo(info)
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
  if info.InNextLevelNum > info.InNum then
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowUpgrade)
  elseif info.InNextLevelNum < info.InNum then
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorDownUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowDownUpgrade)
  else
    self.TextBlock_NextLevelNum:SetColorAndOpacity(self.ColorUnUpgrade)
    self.Img_Arrow:SetColorAndOpacity(self.ArrowUnUpgrade)
  end
  self.HorizontalBox_NextLevelInfo:SetVisibility(info.InNextLevelNum >= 0 and info.InNextLevelNum ~= info.InNum and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function GrowthLevelNum:HideNextLevelInfo()
  self.HorizontalBox_NextLevelInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
return GrowthLevelNum
