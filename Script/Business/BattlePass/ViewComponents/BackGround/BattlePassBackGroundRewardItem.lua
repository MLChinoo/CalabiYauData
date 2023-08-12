local BattlePassBackGroundRewardItem = class("BattlePassBackGroundRewardItem", PureMVC.ViewComponentPanel)
function BattlePassBackGroundRewardItem:UpdateView(data)
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, data.img)
  end
  if self.Img_Quality then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(data.qualityColor)))
  end
  if self.Text_Count then
    self.Text_Count:SetText("x" .. data.num)
    if data.num > 1 then
      self.Text_Count:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.Text_Name and data.name then
    self.Text_Name:SetText(data.name)
    if self.ShowName then
      self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
return BattlePassBackGroundRewardItem
