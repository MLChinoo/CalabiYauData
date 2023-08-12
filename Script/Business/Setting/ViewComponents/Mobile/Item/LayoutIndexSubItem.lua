local LayoutIndexSubItem = class("LayoutIndexSubItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function LayoutIndexSubItem:InitializeLuaEvent()
end
function LayoutIndexSubItem:BP_OnItemSelectionChanged(isSelected)
  self.isSelected = isSelected
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(isSelected and 2 or 0)
  end
end
function LayoutIndexSubItem:OnListItemObjectSet(itemObj)
  self.content = itemObj.content
  if self.TextBlock_Content then
    self.TextBlock_Content:SetText(self.content)
  end
  self:BP_OnItemSelectionChanged(itemObj.selected == self.content)
end
function LayoutIndexSubItem:OnMouseEnter(MyGeometry, MouseEvent)
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(1)
  end
end
function LayoutIndexSubItem:OnMouseLeave(MouseEvent)
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(0)
  end
end
return LayoutIndexSubItem
