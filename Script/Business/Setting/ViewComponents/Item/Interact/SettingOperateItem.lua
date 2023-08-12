local SettingComInteractItem = require("Business/Setting/ViewComponents/Item/SettingComInteractItem")
local SettingOperateItem = class("SettingOperateItem", SettingComInteractItem)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local InputName = require("Business/Setting/Proxies/Map/InputNameMap")
function SettingOperateItem:InitializeLuaEvent()
  self.InputKeySelector1.OnKeySelected:Add(self, function(_, inputChord)
    self:OnSelectedKey(inputChord, 1)
  end)
  self.InputKeySelector2.OnKeySelected:Add(self, function(_, inputChord)
    self:OnSelectedKey(inputChord, 2)
  end)
  self.InputKeySelector1.OnIsSelectingKeyChanged:Add(self, function()
    self:OnIsKeyChanged(1)
  end)
  self.InputKeySelector2.OnIsSelectingKeyChanged:Add(self, function()
    self:OnIsKeyChanged(2)
  end)
  self.isSelecting = {false, false}
  self.selectedIndex = nil
  self.currentValue = 0
  self.oriData = nil
  self.bReverting = false
  self.keyMapProxy = nil
end
function SettingOperateItem:OnMouseWheel(geometry, mouseEvent)
  if self.selectedIndex == nil then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local delta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(mouseEvent)
  local keyName
  if delta > 0 then
    keyName = "MouseScrollUp"
  end
  if delta < 0 then
    keyName = "MouseScrollDown"
  end
  if nil == keyName then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local inputChord = SettingInputUtilProxy:CreateInputChord(keyName)
  if 1 == self.selectedIndex then
    self.InputKeySelector1:SetSelectedKey(inputChord)
  else
    self.InputKeySelector2:SetSelectedKey(inputChord)
  end
  self:SetFocus()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingOperateItem:InitView(oriData)
  self.oriData = oriData
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  local keyMapType = SettingHelper.GetKeyMapType(oriData)
  self.keyMapProxy = SettingKeyMapManagerProxy:GetProxy(keyMapType)
  self.TextBlock_Type:SetText(oriData.Name)
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = settingSaveDataProxy:GetTemplateValueByKey(self.oriData.Indexkey)
  self:SetCurrentValue(value)
  self:RefreshView()
end
function SettingOperateItem:SetCurrentValue(value)
  self.currentValue = value
end
function SettingOperateItem:RefreshView()
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(self.currentValue)
  self.InputKeySelector1:SetSelectedKey(inputChordArr[1])
  self.InputKeySelector2:SetSelectedKey(inputChordArr[2])
end
function SettingOperateItem:ModifyKeyByValue(modifyValue)
  self:SetCurrentValue(modifyValue)
  self:RefreshView()
  self.ChangeValueEvent()
  self.keyMapProxy:UpdateSingleKeyMap(self.oriData, self.currentValue)
end
function SettingOperateItem:OnSelectedKey(inputChord, index)
  if self.bReverting == true then
    return
  end
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  if inputChord.Key.KeyName == "None" then
    inputChord.Key.KeyName = SettingEnum.Invalid
    self:K2_PostAkEvent(self.CancelAudio)
  end
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(self.currentValue)
  local noChanged = false
  if inputChord.Key.KeyName == inputChordArr[index].Key.KeyName then
    noChanged = true
  end
  local selfChanged = false
  if false == noChanged then
    local keyName = inputChord.Key.KeyName
    local otherIndex = 1 == index and 2 or 1
    if keyName == inputChordArr[otherIndex].Key.KeyName then
      selfChanged = true
    end
  end
  local inputChordKeyName = inputChord.Key.KeyName
  local ChangeKeyFunc = function()
    self.bReverting = true
    if noChanged then
      self:RefreshView()
    elseif selfChanged then
      local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(self.currentValue)
      inputChordArr[index].Key.KeyName = inputChordKeyName
      local otherIndex = 1 == index and 2 or 1
      inputChordArr[otherIndex].Key.KeyName = SettingEnum.Invalid
      local modifyValue = SettingInputUtilProxy:GetValueByInputChord(inputChordArr)
      self:ModifyKeyByValue(modifyValue)
    else
      local modifyValue = SettingInputUtilProxy:GetNewValueByInputChord(self.currentValue, index, inputChordKeyName)
      self:ModifyKeyByValue(modifyValue)
    end
    self.bReverting = false
  end
  local keyName = inputChord.Key.KeyName
  if false == noChanged and self.keyMapProxy:CheckShowConflictUI(keyName, self.oriData) then
    local paras = {}
    if false == selfChanged then
      paras.changeOther = true
    end
    self.keyMapProxy:ShowKeyConfictUI(self.oriData.indexKey, keyName, function()
      ChangeKeyFunc()
    end, function()
      self.bReverting = true
      self:RefreshView()
      self.bReverting = false
    end, paras, self)
  else
    ChangeKeyFunc()
  end
end
function SettingOperateItem:OnlyRefreshView()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local newValue = SettingSaveDataProxy:GetTemplateValueByKey(self.oriData.Indexkey)
  self:SetCurrentValue(newValue)
  self:RefreshView()
end
function SettingOperateItem:OnIsKeyChanged(index)
  self.isSelecting[index] = not self.isSelecting[index]
  local bSelect = self.isSelecting[index]
  if self.isSelecting[index] then
    self.selectedIndex = index
  else
    self.selectedIndex = nil
  end
  if self.isSelecting[1] or self.isSelecting[2] then
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  else
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
  end
end
return SettingOperateItem
