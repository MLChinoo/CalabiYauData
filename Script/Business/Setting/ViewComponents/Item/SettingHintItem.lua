local SettingHintItem = class("SettingHintItem", PureMVC.ViewComponentPanel)
function SettingHintItem:ListNeededMediators()
  return {}
end
function SettingHintItem:InitializeLuaEvent()
end
function SettingHintItem:OnListItemObjectSet(itemObj)
  self.itemInfo = itemObj.data
  self:UpdateView()
end
function SettingHintItem:UpdateView()
  local inData = self.itemInfo
  if self.itemInfo.KeyName then
    self.TextBlock_KeyName:SetText(inData.KeyName)
  end
  if self.itemInfo.Key1 then
    self.TextBlock_CurrentKey:SetText(inData.Key1)
  else
    self.TextBlock_CurrentKey:SetText("")
  end
  if self.itemInfo.Key2 then
    self.TextBlock_NextKey:SetText(inData.Key2)
  else
    self.TextBlock_NextKey:SetText("")
  end
  if 1 == self.itemInfo.ConflictIndex then
    ObjectUtil:SetTextColor(self.TextBlock_CurrentKey, 1, 0.18, 0.32, 1)
    ObjectUtil:SetTextColor(self.TextBlock_NextKey, 1, 1, 1, 1)
  else
    ObjectUtil:SetTextColor(self.TextBlock_NextKey, 1, 0.18, 0.32, 1)
    ObjectUtil:SetTextColor(self.TextBlock_CurrentKey, 1, 1, 1, 1)
  end
end
return SettingHintItem
