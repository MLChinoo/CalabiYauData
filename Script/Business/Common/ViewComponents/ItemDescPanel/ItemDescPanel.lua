local ItemDescPanel = class("ItemDescPanel", PureMVC.ViewComponentPanel)
function ItemDescPanel:UpdatePanel(PanelDatas)
  self:SetItemQuality(PanelDatas)
  self:SetItemHideStory(PanelDatas)
  if self.Txt_ItemName then
    self.Txt_ItemName:SetText(PanelDatas.itemName)
  end
  if self.TXT_ItemDesc then
    self.TXT_ItemDesc:SetText(PanelDatas.itemDesc)
  end
  self:SetOwonerName(PanelDatas.ownerName)
  self:SetRoleHeadIcon(PanelDatas.softTexture)
  self:SetRoleProfessIcon(PanelDatas.professSoftTexture)
  self:SetRoleProfessIconColor(PanelDatas.professColor)
  self:SetRoleTitle(PanelDatas.roleTitle)
  if self.ScrollBox_Content then
    self.ScrollBox_Content:SetScrollOffset(0)
  end
end
function ItemDescPanel:SetItemQuality(PanelDatas)
  if PanelDatas.qualityName then
    self:ShowUWidget(self.Canvas_Quality)
    self.Txt_QualityName:SetText(PanelDatas.qualityName)
    local qualityColor = self:GetColorFromHex(PanelDatas.qualityColor)
    self.Img_ItemQualityBg:SetColorAndOpacity(qualityColor)
  elseif PanelDatas.qualityID then
    self:ShowUWidget(self.Canvas_Quality)
    local qualityRow = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(PanelDatas.qualityID)
    if qualityRow then
      local qulityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qualityRow.Color))
      local qulityName = qualityRow.Desc
      self.Txt_QualityName:SetText(qulityName)
      self.Img_ItemQualityBg:SetColorAndOpacity(qulityColor)
    end
  else
    self:HideUWidget(self.Canvas_Quality)
  end
end
function ItemDescPanel:SetItemHideStory(PanelDatas)
  if PanelDatas.bHaveHideStory then
    if self.WidgetSwitcher_HideStory then
      self.WidgetSwitcher_HideStory:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    local widgetIndex = 0
    if PanelDatas.storyDesc then
      self.Txt_HideStoryTitle:SetText(PanelDatas.storyTitle)
      self.Txt_HideStoryDesc:SetText(PanelDatas.storyDesc)
      widgetIndex = 1
    end
    self.WidgetSwitcher_HideStory:SetActiveWidgetIndex(widgetIndex)
  elseif self.WidgetSwitcher_HideStory then
    self.WidgetSwitcher_HideStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDescPanel:SetOwonerName(ownerName)
  if ownerName then
    if self.SizeBox_Title then
      self.SizeBox_Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Txt_OwnerName then
      self.Txt_OwnerName:SetText(ownerName)
    end
    self.bShowTitle = true
  else
    if self.SizeBox_Title then
      self.SizeBox_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.bShowTitle = false
  end
end
function ItemDescPanel:SetRoleHeadIcon(sortTexture)
  if self.bShowTitle == false then
    return
  end
  if sortTexture then
    self:ShowUWidget(self.Img_RoleHeadIcon)
    self:SetImageByTexture2D(self.Img_RoleHeadIcon, sortTexture)
  else
    self:HideUWidget(self.Img_RoleHeadIcon)
  end
end
function ItemDescPanel:SetRoleTitle(roleTitle)
  if self.bShowTitle == false then
    return
  end
  if roleTitle then
    if self.SizeBox_RoleTitle then
      self.SizeBox_RoleTitle:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Txt_RoleTitle then
      self.Txt_RoleTitle:SetText(roleTitle)
    end
  elseif self.SizeBox_RoleTitle then
    self.SizeBox_RoleTitle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDescPanel:SetRoleProfessIcon(professSoftTexture)
  if self.bShowTitle == false then
    return
  end
  if professSoftTexture then
    if self.Canvas_RoleProFession then
      self.Canvas_RoleProFession:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Img_RoleProfession then
      self:SetImageByTexture2D(self.Img_RoleProfession, professSoftTexture)
    end
  elseif self.Canvas_RoleProFession then
    self.Canvas_RoleProFession:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDescPanel:SetRoleProfessIconColor(professColor)
  if self.Img_RoleProfession and professColor then
    self.Img_RoleProfession:SetColorAndOpacity(professColor)
  end
end
function ItemDescPanel:ClearPanel()
  if self.Txt_ItemName then
    self.Txt_ItemName:SetText("")
  end
  if self.TXT_ItemDesc then
    self.TXT_ItemDesc:SetText("")
  end
  if self.Img_RoleHeadIcon then
    self:HideUWidget(self.Img_RoleHeadIcon)
  end
  if self.Canvas_Quality then
    self:HideUWidget(self.Canvas_Quality)
  end
  if self.WidgetSwitcher_HideStory then
    self.WidgetSwitcher_HideStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return ItemDescPanel
