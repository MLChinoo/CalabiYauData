local SettingComboxItem = class("SettingComboxItem", PureMVC.ViewComponentPanel)
function SettingComboxItem:InitializeLuaEvent()
  self.options = {"0", "1"}
  for i, v in ipairs(self.options) do
    self.ComboBoxString_22:AddOption(v)
  end
  self.ComboBoxString_22.OnSelectionChanged:Add(self, self.OnChanged)
  self.ComboBoxString_22.OnMenuOpenChanged:Add(self, self.OnMenuOpenChanged)
  self.ComboBoxString_22:SetSelectedIndex(0)
  self:SetSelectIndexEx(0)
end
function SettingComboxItem:OnGenerateWidget_0(option)
  local widgetPath = "/Game/PaperMan/UI/BP/Mobile/Frontend/Setting/Item/WBP_SettingComboSubItem_MB.WBP_SettingComboSubItem_MB"
  local itemClass = UE4.UClass.Load(widgetPath)
  if itemClass:IsValid() then
    local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), itemClass)
    if item.InitView then
      item:InitView({combox = self, option = option})
    end
    return item
  end
end
function SettingComboxItem:OnChanged()
end
function SettingComboxItem:GetSelectIndex(option)
  for i, v in ipairs(self.options) do
    if v == option then
      return i - 1
    end
  end
  return 0
end
function SettingComboxItem:SetSelectIndexEx(index)
  self.selectIndex = index
end
function SettingComboxItem:OnMenuOpenChanged(bOpen)
end
return SettingComboxItem
