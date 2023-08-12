local LotteryEntryItem = class("LotteryEntryItem", PureMVC.ViewComponentPanel)
function LotteryEntryItem:OnListItemObjectSet(itemObj)
  if itemObj.data then
    local lotteryCfg = itemObj.data
    if self.Text_LotteryTitle then
      self.Text_LotteryTitle:SetText(lotteryCfg.Name)
    end
    if self.Image_Normal and lotteryCfg.ThumbnailNormal then
      self:SetImageByPaperSprite(self.Image_Normal, lotteryCfg.ThumbnailNormal)
    end
    if self.Image_Hover and lotteryCfg.ThumbnailHovered then
      self:SetImageByPaperSprite(self.Image_Hover, lotteryCfg.ThumbnailHovered)
    end
  end
  self:SetSelectStatus(itemObj.isSelected)
end
function LotteryEntryItem:BP_OnItemSelectionChanged(isSelected)
  self:SetSelectStatus(isSelected)
end
function LotteryEntryItem:SetSelectStatus(isSelected)
  if self.Image_WhiteBorder then
    self.isSelect = isSelected
    self.Image_WhiteBorder:SetVisibility(isSelected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function LotteryEntryItem:OnMouseEnter(MyGeometry, MouseEvent)
  if not self.isSelect and self.WidgetSwitcher_ItemState then
    self.WidgetSwitcher_ItemState:SetActiveWidgetIndex(1)
  end
end
function LotteryEntryItem:OnMouseLeave(MouseEvent)
  if not self.isSelect and self.WidgetSwitcher_ItemState then
    self.WidgetSwitcher_ItemState:SetActiveWidgetIndex(0)
  end
end
return LotteryEntryItem
