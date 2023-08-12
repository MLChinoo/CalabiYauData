local AchievementRewardImg = class("AchievementRewardImg", PureMVC.ViewComponentPanel)
function AchievementRewardImg:SetRewardItem(rewardItemInfo, isUnlocked)
  self.itemConfig = rewardItemInfo.itemConfig
  if self.Image_Item then
    self:SetImageByTexture2D(self.Image_Item, self.itemConfig.image)
    if isUnlocked and self.CanvasPanel_Lock then
      self.CanvasPanel_Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CanvasPanel_Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.Image_Quality then
    local color = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(self.itemConfig.quality).Color
    self.Image_Quality:SetColorandOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(color)))
    self.Image_Quality:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Image_Bottom and self.MenuAnchor_ItemTip then
    self.MenuAnchor_ItemTip.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
    self.Image_Bottom.OnMouseEnterEvent:Bind(self, self.OnMouseEnter)
    self.Image_Bottom.OnMouseLeaveEvent:Bind(self, self.OnMouseLeave)
  end
end
function AchievementRewardImg:SetItemOpacity(opacity)
  if self.Image_Item then
    self.Image_Item:SetRenderOpacity(opacity)
  end
end
function AchievementRewardImg:OnGetMenuContent()
  local itemTip = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_ItemTip.MenuClass)
  if itemTip then
    itemTip:SetTipsContent(self.itemConfig.name, self.itemConfig.desc)
    return itemTip
  else
    LogDebug("AchievementPage", "Panel create failed")
    return nil
  end
end
function AchievementRewardImg:OnMouseEnter()
  if self.MenuAnchor_ItemTip then
    self.MenuAnchor_ItemTip:Open(false)
  end
end
function AchievementRewardImg:OnMouseLeave()
  if self.MenuAnchor_ItemTip then
    self.MenuAnchor_ItemTip:Close()
  end
end
return AchievementRewardImg
