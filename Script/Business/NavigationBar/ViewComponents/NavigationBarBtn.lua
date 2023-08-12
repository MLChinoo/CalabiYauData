local NavigationBarBtn = class("NavigationBarBtn", PureMVC.ViewComponentPanel)
function NavigationBarBtn:InitializeLuaEvent()
  self.clickEvent = LuaEvent.new()
  self.mouseEnterOrLeaveEvent = LuaEvent.new()
  self.bSelected = false
  self.curType = -1
end
function NavigationBarBtn:Construct()
  NavigationBarBtn.super.Construct(self)
  if self.SelectScale then
    if self.CP_Reverse then
      self.CP_Reverse:SetRenderScale(UE4.FVector2D(self.SelectScale, 1))
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.Image_News then
    self.Image_News:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Bg_Button then
    self.Bg_Button.OnClicked:Add(self, NavigationBarBtn.OnMouseClick)
    self.Bg_Button.OnHovered:Add(self, NavigationBarBtn.OnMouseEnter)
    self.Bg_Button.OnUnhovered:Add(self, NavigationBarBtn.OnMouseLeave)
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarBtn:Destruct()
  NavigationBarBtn.super.Destruct(self)
  if self.Bg_Button then
    self.Bg_Button.OnClicked:Remove(self, NavigationBarBtn.OnMouseClick)
    self.Bg_Button.OnHovered:Remove(self, NavigationBarBtn.OnMouseEnter)
    self.Bg_Button.OnUnhovered:Remove(self, NavigationBarBtn.OnMouseLeave)
  end
end
function NavigationBarBtn:OnMouseClick()
  if not self.bSelected then
    self.clickEvent(self.curType, self.DefaultSecondIndex)
  end
end
function NavigationBarBtn:OnMouseEnter()
  if not self.bSelected then
    self.Image_Hover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParHover:SetReactivate(true)
    end
  end
  self.mouseEnterOrLeaveEvent(self.curType, true)
end
function NavigationBarBtn:OnMouseLeave()
  if not self.bSelected then
    self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.mouseEnterOrLeaveEvent(self.curType, false)
end
function NavigationBarBtn:SetNavigationType(inType)
  self.curType = inType
end
function NavigationBarBtn:GetClickEvent()
  return self.clickEvent
end
function NavigationBarBtn:GetMouseEnterOrLeaveEvent()
  return self.mouseEnterOrLeaveEvent
end
function NavigationBarBtn:SetIsSelect(bSelect)
  self.bSelected = bSelect
  if self.bSelected then
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.TxtSelect and self.TextBlock_UILabel then
      self.TextBlock_UILabel:SetColorAndOpacity(self.TxtSelect)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParSelect:SetReactivate(true)
    end
    if self.Anim_Select then
      self:PlayAnimation(self.Anim_Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
  else
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.TxtUnSelect and self.TextBlock_UILabel then
      self.TextBlock_UILabel:SetColorAndOpacity(self.TxtUnSelect)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function NavigationBarBtn:SetRedDot(cnt)
  if self.Image_News then
    self.Image_News:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return NavigationBarBtn
