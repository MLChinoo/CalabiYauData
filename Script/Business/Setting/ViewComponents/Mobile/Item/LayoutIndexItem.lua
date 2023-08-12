local LayoutIndexItem = class("LayoutIndexItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function LayoutIndexItem:InitializeLuaEvent()
  self.ComboBoxString_Index:ClearOptions()
  self.defaultOptions = {
    ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "44"),
    ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "45")
  }
  for i, v in ipairs(self.defaultOptions) do
    self.ComboBoxString_Index:AddOption(v)
  end
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local layoutIndex = SettingOperationProxy:GetLayoutIndex()
  self.ComboBoxString_Index:SetSelectedIndex(layoutIndex - 1)
  self.ComboBoxString_Index.OnMenuOpenChanged:Add(self, self.OnMenuOpen)
  self.ComboBoxString_Index.OnSelectionChanged:Add(self, self.OnSelectionChanged)
end
function LayoutIndexItem:InitView(parent)
  self.parent = parent
end
function LayoutIndexItem:OnMenuOpen(isOpen)
  if self.Image_Arrow then
    if isOpen then
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
    end
  end
  if isOpen then
    self.Image_Fake:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Image_Fake:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function LayoutIndexItem:OnSelectionChanged(selectedStr)
  LogDebug("LayoutIndexItem", selectedStr)
  local index = self:GetIndexFromOption(selectedStr)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  if index == SettingOperationProxy:GetLayoutIndex() then
    LogInfo("LayoutIndexItem", "index is " .. index)
  else
    GameFacade:SendNotification(NotificationDefines.Setting.CustomLayoutChangeNtf, {pageIndex = index})
  end
end
function LayoutIndexItem:GetIndexFromOption(optionStr)
  for i, v in ipairs(self.defaultOptions) do
    if v == optionStr then
      return i
    end
  end
  return 1
end
return LayoutIndexItem
