local ComboText = class("ComboText", PureMVC.ViewComponentPanel)
function ComboText:ListNeededMediators()
  return {}
end
function ComboText:Construct()
  ComboText.super.Construct(self)
  self.content = ""
  self.isSelected = false
end
function ComboText:BP_OnItemSelectionChanged(isSelected)
  if isSelected and self.parent then
    self.parent:SelectContent(self.content)
  end
end
function ComboText:OnItemSelected(isSelected)
  self.isSelected = isSelected
  if self.WidgetSwitcher_State then
    LogDebug("ComboText", "Item selected: %s", isSelected)
    self.WidgetSwitcher_State:SetActiveWidgetIndex(isSelected and 2 or 0)
  end
end
function ComboText:OnListItemObjectSet(itemObj)
  self.content = itemObj.content
  if self.TextBlock_Content then
    self.TextBlock_Content:SetText(self.content)
  end
  self:OnItemSelected(itemObj.isSelected)
  if itemObj.parent then
    self.parent = itemObj.parent
    itemObj.parent.actionOnSelectionChanged:Add(function(content)
      self:OnItemSelected(self.content == content)
    end)
  end
end
function ComboText:OnMouseEnter(MyGeometry, MouseEvent)
  if self.isSelected then
    return
  end
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(1)
  end
end
function ComboText:OnMouseLeave(MouseEvent)
  if self.isSelected then
    return
  end
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(0)
  end
end
return ComboText
