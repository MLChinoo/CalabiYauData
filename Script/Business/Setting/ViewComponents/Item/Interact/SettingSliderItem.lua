local SettingComInteractItem = require("Business/Setting/ViewComponents/Item/SettingComInteractItem")
local SettingSliderItem = class("SettingSliderItem", SettingComInteractItem)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function SettingSliderItem:InitializeLuaEvent()
  if self.Button_Minus then
    self.Button_Minus.OnClicked:Add(self, SettingSliderItem.OnClickedMinus)
  end
  if self.Button_Plus then
    self.Button_Plus.OnClicked:Add(self, SettingSliderItem.OnClickedPlus)
  end
  if self.Slider then
    self.Slider.OnValueChanged:Add(self, SettingSliderItem.OnValueChanged)
    self.Slider.OnMouseCaptureEnd:Add(self, SettingSliderItem.OnMouseCaptureEnd)
  end
  self.minValue = 1
  self.maxValue = 100
  self.digitValue = 1
  self.currentValue = 50
end
function SettingSliderItem:InitView(oriData)
  self.oriData = oriData
  self.ShowStep = SettingHelper.GetShowStep(oriData.Step)
  self:SetType(oriData.Name)
  self:SetShowStyle(oriData.Min, oriData.Max, oriData.Step)
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = settingSaveDataProxy:GetTemplateValueByKey(self.oriData.Indexkey)
  self:SetCurrentValue(value)
  self:RefreshView(true)
end
function SettingSliderItem:SetType(typeStr)
  self.TextBlock_Type:SetText(typeStr)
end
function SettingSliderItem:SetShowStyle(minValue, maxValue, digit)
  self.minValue = minValue or self.minValue
  self.maxValue = maxValue or self.maxValue
  self.digitValue = digit or self.digitValue
end
function SettingSliderItem:SetCurrentValue(currentValue)
  self.currentValue = currentValue
end
function SettingSliderItem:RefreshView(bInit)
  self.currentValue = math.clamp(self.currentValue, self.minValue, self.maxValue)
  self.TextBlock_Value:SetText(self:GetShowText())
  local percent = (self.currentValue - self.minValue) / (self.maxValue - self.minValue)
  self.ProgressBar:SetPercent(percent)
  self.Slider:SetValue(percent)
  SettingHelper.DirectAdjustMap(self.oriData, self.currentValue, bInit)
end
function SettingSliderItem:OnClickedMinus()
  self.currentValue = self.currentValue - self.digitValue
  self:RefreshView()
  self.ChangeValueEvent()
end
function SettingSliderItem:OnClickedPlus()
  self.currentValue = self.currentValue + self.digitValue
  self:RefreshView()
  self.ChangeValueEvent()
end
function SettingSliderItem:OnValueChanged(value)
  self.currentValue = self.minValue + math.floor((self.maxValue - self.minValue) * value)
  if 0 ~= self.digitValue and 0 ~= self.currentValue % self.digitValue then
    self.currentValue = math.floor(self.currentValue / self.digitValue) * self.digitValue
  end
  self:RefreshView()
  self.ChangeValueEvent()
end
function SettingSliderItem:OnMouseCaptureEnd(...)
  self.ChangeValueEvent()
end
function SettingSliderItem:GetShowText()
  if 0 == self.ShowStep then
    return self.currentValue / SettingEnum.Multipler .. ""
  else
    return string.format("%." .. self.ShowStep .. "f", self.currentValue / SettingEnum.Multipler)
  end
end
return SettingSliderItem
