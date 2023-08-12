local SecondaryNavBarBtn = class("SecondaryNavBarBtn", PureMVC.ViewComponentPanel)
local ECheckBoxStyle = {
  left = 0,
  middle = 1,
  right = 2
}
function SecondaryNavBarBtn:InitializeLuaEvent()
end
function SecondaryNavBarBtn:Construct()
  SecondaryNavBarBtn.super.Construct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Add(self, SecondaryNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Add(self, SecondaryNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Add(self, SecondaryNavBarBtn.OnCheckStateChanged)
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bIsChecked = false
end
function SecondaryNavBarBtn:Destruct()
  SecondaryNavBarBtn.super.Destruct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Remove(self, SecondaryNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Remove(self, SecondaryNavBarBtn.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Remove(self, SecondaryNavBarBtn.OnCheckStateChanged)
  end
end
function SecondaryNavBarBtn:OnMouseEnter(MyGrometry, MouseEvent)
  LogDebug("SecondaryNavBarBtn", "OnMouseEnter")
  if self.bIsChecked then
    return
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParHover:SetReactivate(true)
  end
end
function SecondaryNavBarBtn:OnMouseLeave(MyGrometry)
  LogDebug("SecondaryNavBarBtn", "OnMouseLeave")
  if self.bIsChecked then
    return
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SecondaryNavBarBtn:InitInfo(style, text, pageName, index, parent, custom)
  self.style = style
  self.index = index
  self.pageName = pageName
  self.parentNavbar = parent
  self.strCustom = custom
  if self.TextBlock_Template then
    self.TextBlock_Template:SetText(text)
  end
  if self.WS_Style then
    self.WS_Style:SetActiveWidgetIndex(ECheckBoxStyle[style])
  end
end
function SecondaryNavBarBtn:SetChecked(bIsChecked, exData, isDefaultCheck)
  local checkbox = self.WS_Style:GetWidgetAtIndex(ECheckBoxStyle[self.style])
  self.bIsChecked = bIsChecked
  if checkbox then
    checkbox:SetIsChecked(bIsChecked)
    if bIsChecked then
      self:OnCheckStateChanged(bIsChecked, exData, isDefaultCheck)
    else
      ViewMgr:ClosePage(self, self.pageName)
      LogDebug("SecondaryNavBarBtn", "UnCheck")
      if self.ParSelect then
        self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end
function SecondaryNavBarBtn:CloseBindPage()
  ViewMgr:ClosePage(self, self.pageName)
end
function SecondaryNavBarBtn:OnCheckStateChanged(bIsChecked, exData, isDefaultCheck)
  if bIsChecked then
    self.bIsChecked = bIsChecked
    if self.parentNavbar then
      self.parentNavbar:NotifyActiveButton(self.index)
    end
    if self.strCustom then
      exData = self.strCustom
    end
    if self.pageName then
      if exData then
        ViewMgr:OpenPage(self, self.pageName, false, exData)
      else
        ViewMgr:OpenPage(self, self.pageName)
      end
    end
    LogDebug("SecondaryNavBarBtn", "OnCheck")
    if self.ParSelect and not isDefaultCheck then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParSelect:SetReactivate(true)
    end
  else
    self.WS_Style:GetWidgetAtIndex(ECheckBoxStyle[self.style]):SetIsChecked(true)
  end
end
function SecondaryNavBarBtn:SetRedDot(cnt)
  if self.Image_News then
    self.Image_News:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return SecondaryNavBarBtn
