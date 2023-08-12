local BattlePassProgressItem = class("BattlePassProgressItem", PureMVC.ViewComponentPanel)
function BattlePassProgressItem:InitializeLuaEvent()
  self.isSelect = false
end
function BattlePassProgressItem:Construct()
  BattlePassProgressItem.super.Construct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, self.OnBtClick)
    self.Btn_Operate.OnHovered:Add(self, self.OnBtHovered)
    self.Btn_Operate.OnUnhovered:Add(self, self.OnBtUnhovered)
  end
end
function BattlePassProgressItem:Destruct()
  BattlePassProgressItem.super.Destruct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, self.OnBtClick)
    self.Btn_Operate.OnHovered:Remove(self, self.OnBtHovered)
    self.Btn_Operate.OnUnhovered:Remove(self, self.OnBtUnhovered)
  end
end
function BattlePassProgressItem:OnBtClick()
  if not self.isSelect then
    self.isSelect = true
    self:SetHovered(true)
    self.parentPage:ItemSelect(self)
    self:PlayAnimSelect(true)
  end
end
function BattlePassProgressItem:OnBtHovered()
  if not self.isSelect then
    self:SetHovered(true)
  end
end
function BattlePassProgressItem:OnBtUnhovered()
  if not self.isSelect then
    self:SetHovered(false)
  end
end
function BattlePassProgressItem:ScrolledIntoItem()
  if not self.isSelect then
    self:SetHovered(true)
    self.parentPage:ItemSelect(self, true)
    self:PlayAnimSelect(true)
  end
end
function BattlePassProgressItem:SetSelect(isSelect)
  self.isSelect = isSelect
  self:SetHovered(isSelect)
  self:PlayAnimSelect(isSelect)
end
function BattlePassProgressItem:SetHovered(isHovered)
  if self.Img_Hovered then
    self.Img_Hovered:SetVisibility(not (not isHovered or self.data.isLock or self.data.isReceived) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Img_Gray then
    if isHovered then
      self.Img_Gray:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif self.data.isLock or self.data.isReceived then
      self.Img_Gray:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function BattlePassProgressItem:PlayAnimSelect(isPlay)
  if isPlay then
    self:PlayAnimation(self.Anim_Select, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, true)
  else
    self:StopAnimation(self.Anim_Select)
  end
end
function BattlePassProgressItem:UpdateView(data, parentPage)
  self.data = data
  self.parentPage = parentPage
  self.isSelect = false
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, self.data.img)
  end
  if self.Img_Quality then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(self.data.qualityColor)))
  end
  if self.Text_Count then
    self.Text_Count:SetText("x" .. self.data.num)
    self.Text_Count:SetVisibility(self.data.num > 1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetVisibility(not (self.data.isLock or self.data.isReceived) and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    self.WidgetSwitcher_State:SetActiveWidgetIndex(not self.data.isLock and 1 or 0)
  end
  if self.Img_Gray then
    self.Img_Gray:SetVisibility(not (self.data.isLock or self.data.isReceived) and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Img_Hovered then
    self.Img_Hovered:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PSW then
    self.PSW:SetVisibility(not (self.data.isLock or self.data.isReceived) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot then
    self.RedDot:SetVisibility(not (self.data.isLock or self.data.isReceived) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Text_Free then
    self.Text_Free:SetVisibility(not self.data.isSenior and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  self:StopAnimation(self.Anim_Select)
end
return BattlePassProgressItem
