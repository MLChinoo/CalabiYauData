local ComboMenu = class("ComboMenu", PureMVC.ViewComponentPanel)
function ComboMenu:ListNeededMediators()
  return {}
end
function ComboMenu:InitializeLuaEvent()
  self.actionOnSelectionChanged = LuaEvent.new(text)
end
function ComboMenu:SetContent(contentList, selectIndex)
  if self.ListView_MenuContent and contentList then
    for key, value in pairs(contentList) do
      local itemObj = ObjectUtil:CreateLuaUObject(self)
      itemObj.content = value
      itemObj.isSelected = selectIndex == key
      itemObj.parent = self
      self.ListView_MenuContent:AddItem(itemObj)
    end
  end
end
function ComboMenu:SelectContent(content)
  if content then
    self.actionOnSelectionChanged(content)
  end
end
return ComboMenu
