local BattlePassLvItem = class("BattlePassLvItem", PureMVC.ViewComponentPanel)
function BattlePassLvItem:UpdateView(data)
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, data.img)
  end
  if self.Img_Quality then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(data.qualityColor)))
  end
  if self.Text_Count then
    self.Text_Count:SetText("x" .. data.num)
  end
end
return BattlePassLvItem
