local ApartmentInformationItem = class("ApartmentInformationItem", PureMVC.ViewComponentPage)
local SwitcherIndex = {
  RedDot = 0,
  Exp = 1,
  Normal = 2,
  Locked = 3
}
local Valid
function ApartmentInformationItem:Init(PageData)
  if not PageData then
    return nil
  end
  self.RoleId = PageData.RoleId
  self.BiographyId = PageData.BiographyId
  self.Title = PageData.Title
  Valid = self.TextBlock_Title and self.TextBlock_Title:SetText(PageData.Title)
  Valid = self.TextBlock_Content and self.TextBlock_Content:SetText(PageData.Content)
  Valid = self.RedDot and self.RedDot:SetVisibility(not (not PageData.bIsUnlock or PageData.bIsRead) and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  self.ButtonEnable = PageData.bIsUnlock
  Valid = self.SizeBox_ProgressBarBG and self.SizeBox_ProgressBarBG:SetRenderTransformAngle(0)
  Valid = self.TextBlock_CurExp and self.TextBlock_CurExp:SetText(PageData.CurExpText)
  Valid = self.TextBlock_TotalExp and self.TextBlock_TotalExp:SetText(PageData.TotalExpText)
  Valid = self.TextBlock_LockTip and self.TextBlock_LockTip:SetText(PageData.TotalExpText)
  local Index = SwitcherIndex.RedDot
  if PageData.bIsUnlock then
    if PageData.bIsRead then
      Index = SwitcherIndex.Normal
    end
  elseif PageData.bIsLock then
    Index = SwitcherIndex.Locked
  else
    Index = SwitcherIndex.Exp
  end
  Valid = self.Image_Lock and self.Image_Lock:SetVisibility(PageData.bIsLock and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(Index)
  local ProgressMax = self.SizeBox_ProgressBarBG and self.SizeBox_ProgressBarBG.WidthOverride
  local ProgressCur = math.clamp(ProgressMax * PageData.ExpProgress, 20, ProgressMax)
  Valid = self.SizeBox_ProgressBar and self.SizeBox_ProgressBar:SetWidthOverride(ProgressCur)
end
function ApartmentInformationItem:Construct()
  ApartmentInformationItem.super.Construct(self)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.ClickedButton)
  Valid = self.SizeBox_Content and self.SizeBox_Content:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  self.ButtonClicked = false
end
function ApartmentInformationItem:Destruct()
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.ClickedButton)
  ApartmentInformationItem.super.Destruct(self)
end
function ApartmentInformationItem:ClickedButton()
  if not self.ButtonEnable then
    Valid = self.DisableButton and self:PlayAnimation(self.DisableButton, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    return
  end
  Valid = self.SizeBox_Content and self.SizeBox_Content:SetVisibility(self.ButtonClicked and UE.ESlateVisibility.Collapsed or UE.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.OpenContent and self:PlayAnimation(self.OpenContent, 0, 1, self.ButtonClicked and UE4.EUMGSequencePlayMode.Reverse or UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.ButtonClicked = not self.ButtonClicked
  if self.RedDot and self.RedDot:GetVisibility() == UE.ESlateVisibility.SelfHitTestInvisible then
    self.RedDot:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(SwitcherIndex.Normal)
  end
  GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):InteractOperateReq(2, self.RoleId, self.BiographyId)
end
function ApartmentInformationItem:GetTitleSize()
  local ProgressSize = self.SizeBox_ProgressBarBG and self.SizeBox_ProgressBarBG:GetDesiredSize().Y or 0
  local SpacerSize = self.Spacer and self.Spacer:GetDesiredSize().Y or 0
  return ProgressSize + SpacerSize
end
return ApartmentInformationItem
