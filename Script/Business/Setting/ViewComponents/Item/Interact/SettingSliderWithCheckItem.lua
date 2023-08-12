local SettingComInteractItem = require("Business/Setting/ViewComponents/Item/SettingComInteractItem")
local SettingSliderWithCheckItem = class("SettingSliderWithCheckItem", SettingComInteractItem)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function SettingSliderWithCheckItem:InitializeLuaEvent()
  if self.Slider then
    self.Slider.OnValueChanged:Add(self, SettingSliderWithCheckItem.OnValueChanged)
    self.Slider.OnMouseCaptureEnd:Add(self, SettingSliderWithCheckItem.OnMouseCaptureEnd)
  end
  if self.CheckBox_Slider then
    self.CheckBox_Slider.OnCheckStateChanged:Add(self, SettingSliderWithCheckItem.OnCheckStateChanged)
  end
  self.minValue = 0
  self.maxValue = 100
  self.digitValue = 0
  self.currentValue = 50
end
function SettingSliderWithCheckItem:InitView(oriData)
  self.oriData = oriData
  self.ShowStep = SettingHelper.GetShowStep(oriData.Step)
  self:SetType(oriData.Name)
  self:SetShowStyle(oriData.Min, oriData.Max, oriData.Step)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey(self.oriData.Indexkey)
  self:SetCurrentValue(value)
  self:RefreshView()
end
function SettingSliderWithCheckItem:SetType(typeStr)
  self.TextBlock_Type:SetText(typeStr)
end
function SettingSliderWithCheckItem:SetShowStyle(minValue, maxValue, digit)
  self.minValue = minValue or self.minValue
  self.maxValue = maxValue or self.maxValue
  self.digitValue = digit or self.digitValue
end
function SettingSliderWithCheckItem:SetCurrentValue(currentValue)
  self.currentValue = currentValue
end
function SettingSliderWithCheckItem:RefreshView()
  self.currentValue = math.clamp(self.currentValue, self.minValue, self.maxValue)
  local percent = (self.currentValue - self.minValue) / (self.maxValue - self.minValue)
  self.ProgressBar:SetPercent(percent)
  self.Slider:SetValue(percent)
  self:RefreshCheckItem()
  SettingHelper.DirectAdjustMap(self.oriData, self.currentValue)
end
function SettingSliderWithCheckItem:OnValueChanged(value)
  self.currentValue = self.minValue + math.floor((self.maxValue - self.minValue) * value)
  if 0 ~= self.digitValue and 0 ~= self.currentValue % self.digitValue then
    self.currentValue = math.floor(self.currentValue / self.digitValue) * self.digitValue
  end
  self:RefreshView()
  self.ChangeValueEvent()
end
function SettingSliderWithCheckItem:RefreshCheckItem()
  if self.currentValue == self.minValue then
    if self.CheckBox_Slider:IsChecked() then
      self.CheckBox_Slider:SetIsChecked(false)
    end
  elseif self.CheckBox_Slider:IsChecked() == false then
    self.CheckBox_Slider:SetIsChecked(true)
  end
end
function SettingSliderWithCheckItem:OnMouseCaptureEnd()
  self.ChangeValueEvent()
end
function SettingSliderWithCheckItem:OnCheckStateChanged(bIsChecked)
  if bIsChecked then
    self.currentValue = 50 * SettingEnum.Multipler
  else
    self.currentValue = self.minValue
  end
  self:RefreshView()
  self.ChangeValueEvent()
end
function SettingSliderWithCheckItem:GetShowText()
  if 0 == self.ShowStep then
    return self.currentValue / SettingEnum.Multipler .. ""
  else
    return string.format("%." .. self.ShowStep .. "f", self.currentValue / SettingEnum.Multipler)
  end
end
return SettingSliderWithCheckItem
