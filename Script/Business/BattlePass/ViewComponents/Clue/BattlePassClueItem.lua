local BattlePassClueItem = class("BattlePassClueItem", PureMVC.ViewComponentPanel)
function BattlePassClueItem:InitializeLuaEvent()
  self.itemIndex = 0
end
function BattlePassClueItem:Construct()
  BattlePassClueItem.super.Construct(self)
  if self.Button_Clue then
    self.Button_Clue.OnPMButtonClicked:Add(self, self.OnBtClickItem)
  end
end
function BattlePassClueItem:Destruct()
  BattlePassClueItem.super.Destruct(self)
  if self.Button_Clue then
    self.Button_Clue.OnPMButtonClicked:Remove(self, self.OnBtClickItem)
  end
end
function BattlePassClueItem:OnBtClickItem()
  if self.parentPage then
    self.parentPage:ItemClick(self.itemIndex)
  end
end
function BattlePassClueItem:SetItemInfo(parent, data, selected)
  self.parentPage = parent
  self.itemIndex = data.clueId
  self:UpdateView(data)
  self:SetSelected(selected)
end
function BattlePassClueItem:SetSelected(selected)
  if self.Img_Selected then
    self.Img_Selected:SetVisibility(selected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassClueItem:UpdateView(data)
  if data then
    if data.isUnlock then
      if self.WidgetSwitcher_Clue then
        self.WidgetSwitcher_Clue:SetActiveWidgetIndex(1)
      end
      if self.Button_Clue then
        self.Button_Clue:SetBrushTexture(data.iconNormal, UE4.EForceButtonBrush.Normal)
        self.Button_Clue:SetBrushTexture(data.iconHovered, UE4.EForceButtonBrush.Hovered)
        self.Button_Clue:SetBrushTexture(data.iconPressed, UE4.EForceButtonBrush.Pressed)
      end
      if self.Img_RedDot then
        self.Img_RedDot:SetVisibility(not data.isRewardRecevied and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
      end
    else
      if self.WidgetSwitcher_Clue then
        self.WidgetSwitcher_Clue:SetActiveWidgetIndex(0)
      end
      if self.Txt_LockLevel then
        self.Txt_LockLevel:SetText(data.unlockLevel)
      end
      if self.Img_LockNum then
        self:SetImageByTexture2D(self.Img_LockNum, data.iconClueId)
      end
    end
  end
end
function BattlePassClueItem:UpdateRewardState(inVisible)
  if self.Img_RedDot then
    self.Img_RedDot:SetVisibility(inVisible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return BattlePassClueItem
