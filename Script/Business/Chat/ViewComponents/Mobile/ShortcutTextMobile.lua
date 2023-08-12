local ShortcutTextMobile = class("ShortcutTextMobile", PureMVC.ViewComponentPanel)
function ShortcutTextMobile:ListNeededMediators()
  return {}
end
function ShortcutTextMobile:InitializeLuaEvent()
end
function ShortcutTextMobile:OnListItemObjectSet(itemObj)
  if itemObj.text and self.Text_Content then
    self.Text_Content:SetText(itemObj.text)
  end
end
function ShortcutTextMobile:OnMouseEnter(MyGeometry, MouseEvent)
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(1)
  end
end
function ShortcutTextMobile:OnMouseLeave(MouseEvent)
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(0)
  end
end
return ShortcutTextMobile
