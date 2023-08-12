local SettingComInteractItem = require("Business/Setting/ViewComponents/Item/SettingComInteractItem")
local SettingSwitcherItem = class("SettingSliderItem", SettingComInteractItem)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function SettingSwitcherItem:InitializeLuaEvent()
  if self.Button_Last then
    self.Button_Last.OnClicked:Add(self, SettingSwitcherItem.OnClickedLast)
  end
  if self.Button_Next then
    self.Button_Next.OnClicked:Add(self, SettingSwitcherItem.OnClickedNext)
  end
  self.currentValue = 1
  self.showCurrentValue = 1
  self.displayTextArr = {}
  self.dotArr = {}
  self.sequenceArr = nil
  self.reSequenceArr = nil
  self.WBP_SettingSwitherHoverItem:SetDelegate(self)
end
function SettingSwitcherItem:InitView(oriData, extraData)
  LogDebug("SettingSwitcherItem: indexKey ", oriData.indexKey)
  local arr = {}
  for i = 1, oriData.Options:Length() do
    arr[#arr + 1] = oriData.Options:Get(i)
  end
  self.oriData = oriData
  self:SetContent(oriData.Name, arr, oriData.DefaultOption2)
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = settingSaveDataProxy:GetTemplateValueByKey(self.oriData.Indexkey)
  self:SetCurrentValue(value)
  self:InitIndicateBox()
  self:RefreshView()
end
function SettingSwitcherItem:SetContent(typeStr, displayTextArr, sequenceStr)
  self.TextBlock_Type:SetText(typeStr)
  self.displayTextArr = displayTextArr
  self.typeStr = typeStr
  self.sequenceArr = {}
  self.reSequenceArr = {}
  local vArr = {}
  if "" == sequenceStr then
    for i = 1, #self.displayTextArr do
      self.sequenceArr[i] = i
      self.reSequenceArr[i] = i
    end
  else
    local arr = string.split(sequenceStr, ",")
    for i = 1, #arr do
      local v = tonumber(arr[i]) or i
      self.sequenceArr[i] = v
      self.reSequenceArr[v] = i
    end
    local _displayTextArr = {}
    for i, v in ipairs(self.sequenceArr) do
      _displayTextArr[i] = self.displayTextArr[v]
    end
    self.displayTextArr = _displayTextArr
  end
end
function SettingSwitcherItem:SetCurrentValue(value)
  self.showCurrentValue = self.reSequenceArr[value]
  self.currentValue = value
end
function SettingSwitcherItem:SetShowCurrentValue(value)
  value = self:GetIndexByOffset(value, 0)
  self.showCurrentValue = value
  self.currentValue = self.sequenceArr[value]
end
function SettingSwitcherItem:RefreshView()
  self:RefreshDisplayText()
  self:RefreshIndicateBox()
end
function SettingSwitcherItem:GetIndexByOffset(curValue, offset)
  local value = curValue + (offset or 0)
  if value > #self.displayTextArr then
    value = 1
  elseif value <= 0 then
    value = #self.displayTextArr
  end
  return value
end
function SettingSwitcherItem:OnClickedLast()
  self:DoSelectShowCurrentValue(self:GetIndexByOffset(self.showCurrentValue, -1))
end
function SettingSwitcherItem:OnClickedNext()
  self:DoSelectShowCurrentValue(self:GetIndexByOffset(self.showCurrentValue, 1))
end
function SettingSwitcherItem:DoSelectCurrentValue(currentValue, bNotChangeValueEvent)
  local showCurrentValue = self.reSequenceArr[currentValue]
  self:DoSelectShowCurrentValue(showCurrentValue, bNotChangeValueEvent)
end
function SettingSwitcherItem:DoSelectShowCurrentValue(showValue, bNotChangeValueEvent)
  self:SetShowCurrentValue(showValue)
  self:RefreshView()
  if true == bNotChangeValueEvent then
    local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    settingSaveDataProxy:UpdateTemplateData(self.oriData, self.currentValue)
  else
    self.ChangeValueEvent()
  end
end
function SettingSwitcherItem:InitIndicateBox()
  if self.HorizontalBox_Indicate then
    local count = #self.displayTextArr
    local dotCount = self.HorizontalBox_Indicate:GetChildrenCount()
    local bAdd = count > dotCount
    if bAdd then
      local DotClass = ObjectUtil:LoadClass(self.DotClass)
      for i = 1, count - dotCount do
        local dotView = UE4.UWidgetBlueprintLibrary.Create(self, DotClass)
        local slot = self.HorizontalBox_Indicate:AddChild(dotView)
        local sizeRule = UE4.FSlateChildSize()
        sizeRule.SizeRule = UE4.ESlateSizeRule.Fill
        sizeRule.Value = 1.0
        slot:SetSize(sizeRule)
        if dotCount > 0 or i > 1 then
          local margin = UE4.FMargin()
          margin.Left = 2
          slot:SetPadding(margin)
        end
      end
    else
      for i = 1, dotCount - count do
        self.HorizontalBox_Indicate:RemoveChildAt(dotCount - i)
      end
    end
    for i = 1, count do
      self.dotArr[i] = self.HorizontalBox_Indicate:GetchildAt(i)
    end
  end
end
function SettingSwitcherItem:RefreshDisplayText()
  self.TextBlock_Display:SetText(self.displayTextArr[self.showCurrentValue])
end
function SettingSwitcherItem:RefreshIndicateBox()
  if self.HorizontalBox_Indicate then
    local dotCount = self.HorizontalBox_Indicate:GetChildrenCount()
    for i = 1, dotCount do
      local item = self.HorizontalBox_Indicate:GetChildAt(i - 1)
      item.ShowImage:SetColorAndOpacity(item.UnSelectedColor)
    end
    local item = self.HorizontalBox_Indicate:GetChildAt(self.showCurrentValue - 1)
    if item then
      item.ShowImage:SetColorAndOpacity(item.SelectedColor)
    end
  end
end
function SettingSwitcherItem:DoChangeValueEvent()
  self.ChangeValueEvent()
end
function SettingSwitcherItem:SetEnabled(bEnabled)
  if bEnabled then
    self.Button_Last:SetIsEnabled(true)
    self.Button_Next:SetIsEnabled(true)
    self.BgImage:SetColorAndOpacity(self.EnableColor)
  else
    self.Button_Last:SetIsEnabled(false)
    self.Button_Next:SetIsEnabled(false)
    self.BgImage:SetColorAndOpacity(self.DisabledColor)
  end
end
function SettingSwitcherItem:DisplayTextArrChanged(displayTextArr)
  if #self.displayTextArr ~= displayTextArr then
    return true
  end
  for i, v in ipairs(self.displayTextArr) do
    if v ~= displayTextArr[i] then
      return true
    end
  end
  return false
end
function SettingSwitcherItem:ReloadDisplayText(displayTextArr, selectIndex, bNotChangeValueEvent)
  if self:DisplayTextArrChanged(displayTextArr) then
    self.HorizontalBox_Indicate:ClearChildren()
    self.displayTextArr = displayTextArr
    self:InitIndicateBox()
  end
  if selectIndex then
    self:DoSelectShowCurrentValue(selectIndex, bNotChangeValueEvent)
  elseif self.showCurrentValue > #displayTextArr then
    self:DoSelectShowCurrentValue(1, bNotChangeValueEvent)
  else
    self:DoSelectShowCurrentValue(self.showCurrentValue, bNotChangeValueEvent)
  end
end
function SettingSwitcherItem:OnMouseEnterByDel(pos, size)
end
function SettingSwitcherItem:OnMouseMoveByDel(pos, size)
end
function SettingSwitcherItem:OnMouseLeaveByDel()
end
function SettingSwitcherItem:OnMouseButtonDownByDel(pos, size)
  if self.Button_Last:GetIsEnabled() then
    local num = #self.displayTextArr
    local width = size.X / num
    local index = math.ceil(pos.X / width)
    self:DoSelectShowCurrentValue(self:GetIndexByOffset(index, 0))
  end
end
function SettingSwitcherItem:OnlyRefreshView()
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = settingSaveDataProxy:GetTemplateValueByKey(self.oriData.indexKey)
  self:SetCurrentValue(value)
  self:RefreshView()
end
return SettingSwitcherItem
