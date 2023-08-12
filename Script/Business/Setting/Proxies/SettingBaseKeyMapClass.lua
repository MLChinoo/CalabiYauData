local SettingBaseKeyMapClass = class("SettingBaseKeyMapClass")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
local compatibleHelperMap
local compatibleKeyPairs = {
  {
    "UseSecondary",
    "SettingAiming"
  },
  {
    "UseSecondary",
    "SettingADS"
  },
  {
    "UseSecondary",
    "SettingAimingAndADS"
  }
}
local constructComptibleHelperMap = function()
  if nil == compatibleHelperMap then
    compatibleHelperMap = {}
    for i, v in ipairs(compatibleKeyPairs) do
      compatibleHelperMap[v[1]] = compatibleHelperMap[v[1]] or {}
      compatibleHelperMap[v[2]] = compatibleHelperMap[v[2]] or {}
      compatibleHelperMap[v[1]][v[2]] = true
      compatibleHelperMap[v[2]][v[1]] = true
    end
  end
end
local findIndexKey = function(indexKeyList, indexKey)
  for i, v in ipairs(indexKeyList) do
    if v == indexKey then
      return i
    end
  end
  return -1
end
local getCountExcludeTarget = function(indexKeyList, targetMap)
  local cnt = 0
  for i, v in ipairs(indexKeyList) do
    if not targetMap[v] then
      cnt = cnt + 1
    end
  end
  return cnt
end
function SettingBaseKeyMapClass:ctor(keyMapType)
  self.keyMapType = keyMapType
  self.keyChordInputMap = {}
  constructComptibleHelperMap()
end
function SettingBaseKeyMapClass:clear()
  self.keyChordInputMap = {}
end
function SettingBaseKeyMapClass:GetKeyMapType()
  return self.keyMapType
end
function SettingBaseKeyMapClass:AddKeyMap(KeyName, indexKey)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  self.keyChordInputMap[KeyName] = self.keyChordInputMap[KeyName] or {}
  if SettingInputUtilProxy:isValidKey(KeyName) then
    table.insert(self.keyChordInputMap[KeyName], indexKey)
  end
end
function SettingBaseKeyMapClass:ClearKeyMap()
  self.keyChordInputMap = {}
end
function SettingBaseKeyMapClass:CheckShowConflictUI(keyName, oriData)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  if compatibleHelperMap[oriData.indexKey] then
    if SettingInputUtilProxy:isValidKey(keyName) and self.keyChordInputMap[keyName] ~= nil and getCountExcludeTarget(self.keyChordInputMap[keyName], compatibleHelperMap[oriData.indexKey]) > 0 then
      return true
    end
    return false
  end
  if SettingInputUtilProxy:isValidKey(keyName) and self.keyChordInputMap[keyName] ~= nil and #self.keyChordInputMap[keyName] > 0 then
    return true
  end
  return false
end
function SettingBaseKeyMapClass:ShowKeyConfictUI(oriIndexKey, keyName, OkCallfunc, CancelCallfunc, args, context)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local indexKeyList = self.keyChordInputMap[keyName]
  local oriDataList = {}
  local inputChordArrList = {}
  for i, indexKey in ipairs(indexKeyList) do
    if compatibleHelperMap[oriIndexKey] and compatibleHelperMap[oriIndexKey][indexKey] then
    else
      local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
      oriDataList[#oriDataList + 1] = oriData
      local value = SettingSaveDataProxy:GetTemplateValueByKey(indexKey)
      local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
      inputChordArrList[#inputChordArrList + 1] = inputChordArr
    end
  end
  local paras = {}
  local keyItemList = {}
  local indexList = {}
  for i, oriData in ipairs(oriDataList) do
    local tmp = {}
    tmp.KeyName = oriData.name
    tmp.Key1 = SettingInputUtilProxy:GetKeyName(inputChordArrList[i][1])
    tmp.Key2 = SettingInputUtilProxy:GetKeyName(inputChordArrList[i][2])
    tmp.ConflictIndex = inputChordArrList[i][1].Key.KeyName == keyName and 1 or 2
    keyItemList[#keyItemList + 1] = tmp
    indexList[#indexList + 1] = keyName == inputChordArrList[i][1].Key.KeyName and 1 or 2
  end
  paras.keyItemList = keyItemList
  function paras.OkCallfunc()
    if args.changeOther then
      self:ReplaceAnotherKeyListByNewKey(oriDataList, indexList, SettingEnum.Invalid)
    end
    OkCallfunc()
  end
  paras.CancelCallfunc = CancelCallfunc
  ViewMgr:OpenPage(context, UIPageNameDefine.HintPge, false, paras)
end
function SettingBaseKeyMapClass:UpdateSingleKeyMap(oriData, value)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
  local keyNameList = {}
  local idx
  for KeyName, indexKeyList in pairs(self.keyChordInputMap) do
    idx = findIndexKey(indexKeyList, oriData.indexKey)
    if -1 ~= idx then
      table.remove(indexKeyList, idx)
    end
  end
  self:AddKeyMap(inputChordArr[1].Key.KeyName, oriData.indexKey)
  self:AddKeyMap(inputChordArr[2].Key.KeyName, oriData.indexKey)
end
function SettingBaseKeyMapClass:ReplaceAnotherKeyListByNewKey(oriDataList, indexList, newKeyName)
  for i, oriData in ipairs(oriDataList) do
    self:ReplaceAnotherKeyByNewKey(oriData, indexList[i], newKeyName)
  end
end
function SettingBaseKeyMapClass:ReplaceAnotherKeyByNewKey(oriData, index, newKeyName)
  LogInfo("SettingBaseKeyMapClass", "ReplaceAnotherKeyByNewKey" .. tostring(oriData.indexKey) .. " " .. tostring(index) .. " " .. tostring(newKeyName))
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey(oriData.indexKey)
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
  local oldKeyName = inputChordArr[index].Key.KeyName
  local iIdx = findIndexKey(self.keyChordInputMap[oldKeyName], oriData.indexKey)
  if -1 ~= iIdx then
    table.remove(self.keyChordInputMap[oldKeyName], iIdx)
  end
  inputChordArr[index].Key.KeyName = newKeyName
  local newValue = SettingInputUtilProxy:GetValueByInputChord({
    inputChordArr[1],
    inputChordArr[2]
  })
  SettingSaveDataProxy:UpdateTemplateData(oriData, newValue)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingKeyChangeNtf, {oriData = oriData})
  if oriData.indexKey == "EnableRoomVoice" then
    GameFacade:SendNotification(NotificationDefines.Setting.SettingRoomVoiceKeyChanged)
  elseif oriData.indexKey == "EnableTeamVoice" then
    GameFacade:SendNotification(NotificationDefines.Setting.SettingTeamVoiceKeyChanged)
  end
end
return SettingBaseKeyMapClass
