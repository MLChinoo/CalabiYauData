local SettingInputUtilProxy = class("SettingInputUtilProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local InputName = require("Business/Setting/Proxies/Map/InputNameMap")
local ItemType = SettingEnum.ItemType
function SettingInputUtilProxy:OnRegister()
  SettingInputUtilProxy.super.OnRegister(self)
end
function SettingInputUtilProxy:VKeyToFKey(vkey)
  local SettingInputKeyCode = require("Business/Setting/Proxies/Map/SettingInputKeyCodeMap")
  if SettingInputKeyCode.indexMap[vkey] then
    return SettingInputKeyCode.indexMap[vkey]
  else
    LogInfo("SettingInputUtilProxy:FKeyToVKey", "fkey is error：" .. tostring(vkey))
    return 0
  end
end
function SettingInputUtilProxy:FKeyToVKey(fkey)
  local SettingInputKeyCode = require("Business/Setting/Proxies/Map/SettingInputKeyCodeMap")
  if SettingInputKeyCode.keyMap[fkey] then
    return SettingInputKeyCode.keyMap[fkey]
  else
    LogInfo("SettingInputUtilProxy:FKeyToVKey", "fkey is error：" .. tostring(fkey))
    return 0
  end
end
local KeyTotal = 512
function SettingInputUtilProxy:GetValueByInputChord(inputChordTbl)
  local inputChord1 = inputChordTbl[1]
  local inputChord2 = inputChordTbl[2]
  local KeyName1 = inputChord1.Key.KeyName
  local keyNumber1 = self:FKeyToVKey(KeyName1)
  local KeyName2 = inputChord2.Key.KeyName
  local keyNumber2 = self:FKeyToVKey(KeyName2)
  local keyNumber = KeyTotal * keyNumber1 + keyNumber2
  local keyMultiTotal = KeyTotal * KeyTotal
  local encryptDetail = function(bDetail)
    if bDetail then
      keyNumber = keyNumber | keyMultiTotal << 1
    end
    keyMultiTotal = keyMultiTotal << 1
  end
  encryptDetail(inputChord1.bShift)
  encryptDetail(inputChord1.bCtrl)
  encryptDetail(inputChord1.bAlt)
  encryptDetail(inputChord1.bCmd)
  encryptDetail(inputChord2.bShift)
  encryptDetail(inputChord2.bCtrl)
  encryptDetail(inputChord2.bAlt)
  encryptDetail(inputChord2.bCmd)
  return keyNumber
end
function SettingInputUtilProxy:CheckInputChordValueValid(value)
  local keyNumber = value & KeyTotal * KeyTotal - 1
  local keyNumber2 = keyNumber % KeyTotal
  local keyNumber1 = (keyNumber - keyNumber2) / KeyTotal
  local SettingInputKeyCode = require("Business/Setting/Proxies/Map/SettingInputKeyCodeMap")
  if 0 == keyNumber1 or keyNumber1 > #SettingInputKeyCode.indexMap then
    return false
  end
  if 0 == keyNumber2 or keyNumber2 > #SettingInputKeyCode.indexMap then
    return false
  end
  return true
end
function SettingInputUtilProxy:GetInputKeyByValue(value)
  local keyNumber = value & KeyTotal * KeyTotal - 1
  local keyNumber2 = keyNumber % KeyTotal
  local keyNumber1 = (keyNumber - keyNumber2) / KeyTotal
  local key1 = self:VKeyToFKey(keyNumber1)
  local key2 = self:VKeyToFKey(keyNumber2)
  return key1, key2
end
function SettingInputUtilProxy:GetInputChordByValue(value)
  local inputChord1 = UE4.FInputChord()
  local inputChord2 = UE4.FInputChord()
  local keyNumber = value & KeyTotal * KeyTotal - 1
  local keyNumber2 = keyNumber % KeyTotal
  local keyNumber1 = (keyNumber - keyNumber2) / KeyTotal
  inputChord1.Key.KeyName = self:VKeyToFKey(keyNumber1)
  inputChord2.Key.KeyName = self:VKeyToFKey(keyNumber2)
  local detailNumber = value - keyNumber
  local keyMultiTotal = KeyTotal * KeyTotal
  local decryptDetail = function()
    local ret = detailNumber & keyMultiTotal
    keyMultiTotal = keyMultiTotal << 1
    return ret > 0
  end
  inputChord1.bShift = decryptDetail()
  inputChord1.bCtrl = decryptDetail()
  inputChord1.bAlt = decryptDetail()
  inputChord1.bCmd = decryptDetail()
  inputChord2.bShift = decryptDetail()
  inputChord2.bCtrl = decryptDetail()
  inputChord2.bAlt = decryptDetail()
  inputChord2.bCmd = decryptDetail()
  return {inputChord1, inputChord2}
end
function SettingInputUtilProxy:GetValueByDefaultData(DefaultOption)
  local tmp = string.split(DefaultOption, ",")
  local inputChord1 = UE4.FInputChord()
  local inputChord2 = UE4.FInputChord()
  inputChord1.Key.KeyName = tmp[1]
  inputChord2.Key.KeyName = tmp[2]
  return self:GetValueByInputChord({inputChord1, inputChord2})
end
local checkAxis = function(name)
  if name == InputName.MoveForward or name == InputName.MoveRight or name == InputName.MoveUp then
    return true
  end
  return false
end
local getInputName = function(name)
  if "Up" == name or "Down" == name then
    return InputName.MoveForward
  elseif "Left" == name or "Right" == name then
    return InputName.MoveRight
  end
  return name
end
local getScale = function(name)
  if "Up" == name or "Right" == name then
    return 1
  elseif "Down" == name or "Left" == name then
    return -1
  end
  return 0
end
function SettingInputUtilProxy:__ReplaceActionInputSetting(inputName, inputChordArr)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(inputName, arr)
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    inputSetting:RemoveActionMapping(ele, false)
  end
  for _, chord in ipairs(inputChordArr) do
    local keyMapping = UE4.FInputActionKeyMapping()
    keyMapping.ActionName = inputName
    keyMapping.bShift = chord.bShift
    keyMapping.bCtrl = chord.bCtrl
    keyMapping.bAlt = chord.bAlt
    keyMapping.Key = chord.Key
    keyMapping.bCmd = chord.bCmd
    if self:isValidKey(chord.Key.KeyName) then
      inputSetting:AddActionMapping(keyMapping, false)
    end
  end
end
function SettingInputUtilProxy:__ChangeActionInputSetting(name, value)
  local inputName = getInputName(name)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
  self:__ReplaceActionInputSetting(inputName, inputChordArr)
end
function SettingInputUtilProxy:ChangeActionInputSetting(oriData, value)
  local name = oriData.indexKey
  if "Side2D" == name then
    self:__ChangeActionInputSetting("Side2D", value)
    self:__ChangeActionInputSetting("Fly2D", value)
  else
    self:__ChangeActionInputSetting(name, value)
  end
end
function SettingInputUtilProxy:ChangeAxisInputSetting(posName, negName, posValue, negValue)
  local inputName = getInputName(posName)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local posInputChordArr = SettingInputUtilProxy:GetInputChordByValue(posValue)
  local negInputChordArr = SettingInputUtilProxy:GetInputChordByValue(negValue)
  local arr = UE4.TArray(UE4.FInputAxisKeyMapping)
  inputSetting:GetAxisMappingByName(inputName, arr)
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    if UE4.UKismetInputLibrary.Key_IsGamepadKey(ele.Key) == false and (ele.Scale == getScale(posName) or ele.Scale == getScale(negName)) then
      inputSetting:RemoveAxisMapping(ele, false)
    end
  end
  local addInputAxisFunc = function(inputChordArr, name)
    for _, chord in ipairs(inputChordArr) do
      local keyMapping = UE4.FInputAxisKeyMapping()
      keyMapping.AxisName = inputName
      keyMapping.Key = chord.Key
      keyMapping.Scale = getScale(name)
      if self:isValidKey(chord.Key.KeyName) then
        inputSetting:AddAxisMapping(keyMapping, false)
      end
    end
  end
  addInputAxisFunc(posInputChordArr, posName)
  addInputAxisFunc(negInputChordArr, negName)
end
function SettingInputUtilProxy:GetKeyName(inputChord)
  if self:isValidKey(inputChord.Key.KeyName) then
    return UE4.UKismetInputLibrary.Key_GetDisplayName(inputChord.Key)
  else
    return ""
  end
end
function SettingInputUtilProxy:isValidKey(keyName)
  return keyName ~= SettingEnum.Invalid
end
function SettingInputUtilProxy:CreateInputChord(keyName)
  local inputChord = UE4.FInputChord()
  inputChord.Key.KeyName = keyName
  return inputChord
end
function SettingInputUtilProxy:GetNewValueByInputChord(value, index, inputChordKeyName)
  local inputChordArr = self:GetInputChordByValue(value)
  local modifyValue = value
  if 1 == index and inputChordKeyName ~= inputChordArr[1].Key.KeyName then
    inputChordArr[1].Key.KeyName = inputChordKeyName
    modifyValue = self:GetValueByInputChord({
      inputChordArr[1],
      inputChordArr[2]
    })
  elseif 2 == index and inputChordKeyName ~= inputChordArr[2].Key.KeyName then
    inputChordArr[2].Key.KeyName = inputChordKeyName
    modifyValue = self:GetValueByInputChord({
      inputChordArr[1],
      inputChordArr[2]
    })
  end
  return modifyValue
end
function SettingInputUtilProxy:GetKeyByInputName(inputName)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey(inputName)
  if value then
    local inputChordArr = self:GetInputChordByValue(value)
    local keyStr1 = self:GetKeyName(inputChordArr[1])
    local keyStr2 = self:GetKeyName(inputChordArr[2])
    return keyStr1, keyStr2
  else
    LogDebug("SettingInputUtilProxy", "value is nil")
    return "", ""
  end
end
return SettingInputUtilProxy
