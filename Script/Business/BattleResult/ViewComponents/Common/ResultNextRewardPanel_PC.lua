local ResultNextRewardPanel_PC = class("ResultNextRewardPanel_PC", PureMVC.ViewComponentPanel)
function ResultNextRewardPanel_PC:UpdatePanel(data)
  if not data then
    return
  end
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, data.img)
  end
  if self.Img_Quality then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(data.qualityColor)))
  end
  if self.Text_Count then
    self.Text_Count:SetText("x" .. data.num)
    self.Text_Count:SetVisibility(data.num > 1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
  end
end
return ResultNextRewardPanel_PC
