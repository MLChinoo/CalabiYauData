local SettingPercentSliderItem = class("SettingPercentSliderItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function SettingPercentSliderItem:InitializeLuaEvent()
  if self.MonitorSlider then
    self.MonitorSlider.OnValueChanged:Add(self, SettingPercentSliderItem.OnValueChanged)
    self.MonitorSlider.OnMouseCaptureEnd:Add(self, SettingPercentSliderItem.OnMouseCaptureEnd)
  end
  if self.Slider then
    self.Slider.OnValueChanged:Add(self, SettingPercentSliderItem.OnValueChanged)
    self.Slider.OnMouseCaptureEnd:Add(self, SettingPercentSliderItem.OnMouseCaptureEnd)
  end
  if self.Button_Minus then
    self.Button_Minus.OnClicked:Add(self, SettingPercentSliderItem.OnClickedMinus)
  end
  if self.Button_Plus then
    self.Button_Plus.OnClicked:Add(self, SettingPercentSliderItem.OnClickedPlus)
  end
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local Config = SettingConfigProxy:GetCommonConfigMap()
  if self.Name == "ButtonAlpha" then
    self.TextBlock_Type:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "1"))
    self.config = Config.opacityRange
  elseif self.Name == "ButtonSize" then
    self.TextBlock_Type:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "2"))
    self.config = Config.scaleRange
  end
  self.minValue = self.config.min
  self.maxValue = self.config.max
  self.digitValue = self.config.step
  self.currentValue = self.config.default
end
function SettingPercentSliderItem:InitView(parent)
  self.parent = parent
end
function SettingPercentSliderItem:SetCurrentValue(currentValue)
  self.currentValue = currentValue
  self:RefreshView()
end
function SettingPercentSliderItem:RefreshView()
  self.currentValue = math.clamp(self.currentValue, self.minValue, self.maxValue)
  self.TextBlock_Value:SetText(self:GetShowText())
  local percent = (self.currentValue - self.minValue) / (self.maxValue - self.minValue)
  self.ProgressBar:SetPercent(percent)
  if self.Slider then
    self.Slider:SetValue(percent)
  end
  if self.MonitorSlider then
    self.MonitorSlider:SetValue(percent)
  end
  LogInfo("SettingPercentSliderItem", "" .. tostring(self.currentValue))
  if self.SliderBar then
    local width = 380 * percent
    self.SliderBar.Slot:SetPosition(UE4.FVector2D(width, 10))
  end
  if self.parent.DragItem and self.parent.DragItem.SetPercent then
    self.parent.DragItem:SetPercent(self.currentValue, self.Name)
  end
end
function SettingPercentSliderItem:OnValueChanged(value)
  self.currentValue = self.minValue + math.floor((self.maxValue - self.minValue) * value)
  if 0 ~= self.digitValue and 0 ~= self.currentValue % self.digitValue then
    self.currentValue = math.floor(self.currentValue / self.digitValue) * self.digitValue
  end
  self:RefreshView()
end
function SettingPercentSliderItem:OnMouseCaptureEnd()
end
function SettingPercentSliderItem:GetShowText()
  return string.format("%d", math.floor(self.currentValue)) .. "%"
end
function SettingPercentSliderItem:OnClickedMinus()
  self.currentValue = self.currentValue - self.digitValue
  self:RefreshView()
end
function SettingPercentSliderItem:OnClickedPlus()
  self.currentValue = self.currentValue + self.digitValue
  self:RefreshView()
end
return SettingPercentSliderItem
