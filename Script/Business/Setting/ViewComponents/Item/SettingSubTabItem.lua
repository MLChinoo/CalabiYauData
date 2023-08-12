local SettingSubTabItem = class("SettingSubTabItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local TabStyle = SettingEnum.TabStyle
function SettingSubTabItem:InitializeLuaEvent()
  self.CheckBox.OnCheckStateChanged:Add(self, self.OnCheckBox)
  self:SetIsChecked(false)
end
function SettingSubTabItem:InitView(args)
  if args.text then
    self.ShowStr = args.text
    self.TextBlock:SetText(args.text)
  end
  self:SetDelegateFunc(args.callfunc)
end
function SettingSubTabItem:SetTabStyle(tabStyle)
  self.CheckBox.WidgetStyle = self:GetStyle(tabStyle)
end
function SettingSubTabItem:GetStyle(styleType)
  if styleType == TabStyle.Left then
    return self.Style1
  elseif styleType == TabStyle.Middle then
    return self.Style2
  else
    return self.Style3
  end
end
function SettingSubTabItem:SetDelegateFunc(delegateFunc)
  self.delFunc = delegateFunc
end
function SettingSubTabItem:OnCheckBox(bChecked)
  if self.delFunc and type(self.delFunc) == "function" then
    self.delFunc(bChecked)
  end
  if bChecked and self.ParSelect then
    self.ParSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParSelect:SetReactivate(true)
  end
end
function SettingSubTabItem:SetIsChecked(bChecked)
  self.CheckBox:SetIsChecked(bChecked)
  self.bIsChecked = bChecked
end
function SettingSubTabItem:OnClose()
  self.delFunc = nil
end
function SettingSubTabItem:OnMouseEnter(MyGrometry, MouseEvent)
  LogDebug("SettingSubTabItem", "OnMouseEnter")
  if self.bIsChecked then
    return
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParHover:SetReactivate(true)
  end
end
function SettingSubTabItem:OnMouseLeave(MyGrometry)
  LogDebug("SettingSubTabItem", "OnMouseLeave")
  if self.bIsChecked then
    return
  end
  if self.ParHover then
    self.ParHover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SettingSubTabItem
