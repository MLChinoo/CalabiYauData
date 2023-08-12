local RoomSettingPanel = class("RoomSettingPanel", PureMVC.ViewComponentPage)
function RoomSettingPanel:ListNeededMediators()
  return {}
end
function RoomSettingPanel:InitializeLuaEvent()
end
function RoomSettingPanel:Construct()
  RoomSettingPanel.super.Construct(self)
end
function RoomSettingPanel:Destruct()
  RoomSettingPanel.super.Destruct(self)
end
function RoomSettingPanel:SetComboBoxData(inTitle, indataArr)
  self.Text_Title:SetText(inTitle)
  self.ComboBox_Content:ClearOptions()
  for i, v in ipairs(indataArr) do
    self.ComboBox_Content:AddOption(v)
  end
  self.ComboBox_Content:SetSelectedIndex(0)
  self.ComboBox_Content:RefreshOptions()
end
function RoomSettingPanel:GetSelectIndex()
  return self.ComboBox_Content:GetSelectedIndex()
end
function RoomSettingPanel:SetSelectIndex(inSelect)
  self.ComboBox_Content:SetSelectedIndex(inSelect)
end
return RoomSettingPanel
