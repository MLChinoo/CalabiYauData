local SettingTabItem = class("SettingTabItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local TabStyle = SettingEnum.TabStyle
function SettingTabItem:InitView(args)
  if args.text then
    self.ShowStr = args.text
    self.TextBlock:SetText(args.text)
  end
  self:SetDelegateFunc(args.callfunc)
  if self.Image_Select then
    self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Image_Hover then
    self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetSelectState(false)
end
function SettingTabItem:SetDelegateFunc(delegateFunc)
  self.delFunc = delegateFunc
end
function SettingTabItem:OnCheckBox(bChecked)
  if self.delFunc and type(self.delFunc) == "function" then
    self.delFunc(bChecked)
  end
end
function SettingTabItem:SetIsChecked(bChecked)
  if self.bSelected == bChecked then
    return
  end
  self:SetSelectState(bChecked)
  if bChecked then
    self:OnCheckBox(true)
  end
end
function SettingTabItem:OnClose()
  self.delFunc = nil
end
function SettingTabItem:OnInitialized()
end
function SettingTabItem:OnLuaItemClick()
  self:SetIsChecked(true)
end
function SettingTabItem:OnLuaItemHovered()
  print("OnLuaItemHovered", self.bSelected)
  if not self.bSelected then
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParHover:SetReactivate(true)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function SettingTabItem:OnLuaItemUnhovered()
  print("OnLuaItemUnhovered", self.bSelected)
  if not self.bSelected then
    if self.ParHover then
      self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function SettingTabItem:SetSelectState(bSelect)
  print("SetSelectState ", bSelect)
  self.bSelected = bSelect
  if self.bSelected then
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Image_Hover then
      self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ParSelect:SetReactivate(true)
    end
    if self.SelectColor and self.TextBlock then
      self.TextBlock:SetColorAndOpacity(self.SelectColor)
    end
  else
    if self.Image_Select then
      self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.ParSelect then
      self.ParSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.UnSelectColor and self.TextBlock then
      self.TextBlock:SetColorAndOpacity(self.UnSelectColor)
    end
  end
end
function SettingTabItem:SetTabStyle(barType)
  self.WidgetSwitcher_Item:SetActiveWidgetIndex(barType)
end
return SettingTabItem
