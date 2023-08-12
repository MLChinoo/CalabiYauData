local ApartmentPledgeGridItem = class("ApartmentPledgeGridItem", PureMVC.ViewComponentPanel)
function ApartmentPledgeGridItem:Init(Index, Data)
  self.Index = Index
  self.ItemInfo = Data
  if self.BtnLockedBG then
    self.BtnLockedBG.OnClicked:Add(self, self.OnGridClicked)
    self.BtnLockedBG.OnHovered:Add(self, self.OnGridHovered)
    self.BtnLockedBG.OnUnhovered:Add(self, self.OnGridUnhovered)
  end
  if self.BtnUnlockBG then
    self.BtnUnlockBG.OnClicked:Add(self, self.OnGridClicked)
    self.BtnUnlockBG.OnHovered:Add(self, self.OnGridHovered)
    self.BtnUnlockBG.OnUnhovered:Add(self, self.OnGridUnhovered)
  end
  if self.ImgIcon_1 then
    self.ImgIcon_1.OnMouseButtonDownEvent:Bind(self, self.OnIconClicked)
  end
  self.UnreadMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if Data.unlocked then
    self.WidgetSwitcherBg:SetActiveWidgetIndex(1)
    self.SwitcherIcon:SetActiveWidgetIndex(1)
    if Data.itemCfg and Data.itemCfg.ItemIcon then
      self.ImgIcon_1:SetBrushFromSoftTexture(Data.itemCfg.ItemIcon)
    end
    self.TxtItemName:SetText(Data.itemCfg.Name)
    self.TxtItemDesc:SetText("-" .. Data.itemCfg.Desc)
    if Data.newUnlock then
      self.UnreadMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.WidgetSwitcherBg:SetActiveWidgetIndex(0)
    self.TextBlock_Tip:SetText(string.format("好感度达到%d级解锁", Data.unlockedLv))
  end
end
function ApartmentPledgeGridItem:OnIconClicked()
  if self.ItemInfo.unlocked then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ApartmentUnlockPromiseItemPage, nil, {
      itemInfo = self.ItemInfo,
      noAutoClose = true
    })
  end
end
function ApartmentPledgeGridItem:OnGridClicked()
  if self.BeSelected then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  self.BeSelected = true
  self:ShowSelectFrame()
  if self.ItemInfo.newUnlock then
    self.UnreadMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemInfo.newUnlock = false
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentPromiseScrollItemClicked, self.Index)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ApartmentPledgeGridItem:OnGridHovered()
  if self.ItemInfo.unlocked then
    self.ImgUnlockHovered:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ImgLockedHovered:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ApartmentPledgeGridItem:OnGridUnhovered()
  if self.ItemInfo.unlocked then
    self.ImgUnlockHovered:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ImgLockedHovered:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ApartmentPledgeGridItem:ShowSelectFrame()
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.ItemInfo.newUnlock then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseItem, -1)
  end
end
function ApartmentPledgeGridItem:SetNotBeSelected()
  self.BeSelected = false
  self.ImgSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ApartmentPledgeGridItem:GetItemStory()
  return self.ItemInfo.ItemStory
end
return ApartmentPledgeGridItem
