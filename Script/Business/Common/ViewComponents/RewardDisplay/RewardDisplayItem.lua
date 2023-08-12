local RewardDisplayItem = class("RewardDisplayItem", PureMVC.ViewComponentPanel)
function RewardDisplayItem:Construct()
  RewardDisplayItem.super.Construct(self)
  self.ownersCnt = 0
end
function RewardDisplayItem:Destruct()
  RewardDisplayItem.super.Destruct(self)
  if self.AnimTimerHandler then
    self.AnimTimerHandler:EndTask()
  end
  self:UnbindAllFromAnimationFinished(self.Anim_FadeIn)
end
function RewardDisplayItem:UpdateView(data, animTime)
  self.ownersCnt = table.count(data.ownerList)
  if self.ownersCnt > 0 then
    if self.TextBlock_Type then
      self.TextBlock_Type:SetText(data.ownerList[1] .. "：")
    end
    local str = ""
    for i = 2, #data.ownerList do
      str = str .. data.ownerList[i]
      if i < #data.ownerList then
        str = str .. "\n"
      end
    end
    if self.TextBlock_owner then
      self.TextBlock_owner:SetText(str)
    end
  end
  self.Txt_ItemName:SetText(data.name)
  self.Txt_ItemCount:SetText(data.count)
  if data.count <= 1 then
    self.Txt_ItemCount:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if data.img then
    self:SetImageByTexture2D(self.Img_Item, data.img)
  end
  if data.qualityColor then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(data.qualityColor)))
  end
  if data.currencyImg then
    if self.Img_Gray then
      self.Img_Gray:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Img_Currency then
      self:SetImageByTexture2D(self.Img_Currency, data.currencyImg)
    end
    if self.Txt_Currency then
      self.Txt_Currency:SetText(data.currencyCnt)
    end
    if self.HB_Currency then
      self.HB_Currency:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.AnimTimerHandler = TimerMgr:AddTimeTask(animTime, 0, 1, function()
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if data.currencyImg then
      self:BindToAnimationFinished(self.Anim_FadeIn, {
        self,
        self.ExChangeAnimFinished
      })
    end
    self:PlayAnimation(self.Anim_FadeIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end)
end
function RewardDisplayItem:ExChangeAnimFinished()
  self:PlayAnimation(self.Anim_Conversion, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:UnbindAllFromAnimationFinished(self.Anim_FadeIn)
end
function RewardDisplayItem:OnMouseEnter(MyGrometry, MouseEvent)
  if self.ownersCnt > 0 and self.VerticalBox_Owner then
    self.VerticalBox_Owner:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function RewardDisplayItem:OnMouseLeave(MyGrometry)
  if self.ownersCnt > 0 and self.VerticalBox_Owner then
    self.VerticalBox_Owner:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return RewardDisplayItem
