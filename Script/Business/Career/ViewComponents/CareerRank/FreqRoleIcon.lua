local FreqRoleIcon = class("FreqRoleIcon", PureMVC.ViewComponentPanel)
function FreqRoleIcon:ListNeededMediators()
  return {}
end
function FreqRoleIcon:UpdateView(iconTexture)
  if self.Image_Use then
    if iconTexture then
      self.Image_Use:SetBrushFromSoftTexture(iconTexture)
      self.Image_Use:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_Use:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return FreqRoleIcon
