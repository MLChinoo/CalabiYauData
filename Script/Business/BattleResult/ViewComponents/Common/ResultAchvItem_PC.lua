local ResultAchvItem_PC = class("ResultAchvItem_PC", PureMVC.ViewComponentPanel)
function ResultAchvItem_PC:OnListItemObjectSet(AchievementItemDataObject)
  self.Image_Icon:SetBrushFromSoftTexture(AchievementItemDataObject.Icon)
  self.Text_Achivement:SetText(AchievementItemDataObject.TableRow.name)
  self:PlayAnimation(self.Animation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self.Image_click.OnMouseButtonDownEvent:Bind(self, self.OnIconClicked)
  self.Text_Achivement:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function ResultAchvItem_PC:OnIconClicked()
  if self.Text_Achivement:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
    self.Text_Achivement:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.Text_Achivement:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return ResultAchvItem_PC
