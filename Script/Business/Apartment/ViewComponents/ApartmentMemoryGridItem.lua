local ApartmentMemoryGridItem = class("ApartmentMemoryGridItem", PureMVC.ViewComponentPanel)
function ApartmentMemoryGridItem:Init(Index, Data)
  self.Index = Index
  self.MemInfo = Data
  self.SequenceId = Data.SequenceId
  if self.BtnLockBG then
    self.BtnLockBG.OnClicked:Add(self, self.OnGridClicked)
    self.BtnLockBG.OnHovered:Add(self, self.OnGridHovered)
    self.BtnLockBG.OnUnhovered:Add(self, self.OnGridUnhovered)
  end
  if self.BtnUnlockBg then
    self.BtnUnlockBg.OnClicked:Add(self, self.OnGridClicked)
    self.BtnUnlockBg.OnHovered:Add(self, self.OnGridHovered)
    self.BtnUnlockBg.OnUnhovered:Add(self, self.OnGridUnhovered)
  end
  self.UnreadMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if Data.bIsUnLock then
    self.WidgetSwitcherBg:SetActiveWidgetIndex(1)
    self.ImgPic:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtVedioName:SetText(Data.Title)
    self.TxtDesc:SetText(Data.Desc)
    if Data.newUnlock then
      self.UnreadMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.WidgetSwitcherBg:SetActiveWidgetIndex(0)
    self.TxtHowToUnlock:SetText(Data.UnlockTips)
  end
end
function ApartmentMemoryGridItem:OnGridClicked()
  if self.BeSelected then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  self.BeSelected = true
  self:ShowSelectFrame()
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.MemInfo.newUnlock then
    self.UnreadMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MemInfo.newUnlock = false
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentMemScrollItemClicked, self.Index)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ApartmentMemoryGridItem:OnGridHovered()
  self.ImgHovered:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function ApartmentMemoryGridItem:OnGridUnhovered()
  self.ImgHovered:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ApartmentMemoryGridItem:ShowSelectFrame()
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function ApartmentMemoryGridItem:SetNotBeSelected()
  self.BeSelected = false
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
return ApartmentMemoryGridItem
