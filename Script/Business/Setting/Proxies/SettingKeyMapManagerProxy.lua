local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingBaseKeyMapClass = require("Business/Setting/Proxies/SettingBaseKeyMapClass")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingKeyMapManagerProxy = class("SettingKeyMapManagerProxy", PureMVC.Proxy)
local ItemType = SettingEnum.ItemType
function SettingKeyMapManagerProxy:OnRegister()
  SettingKeyMapManagerProxy.super.OnRegister(self)
end
function SettingKeyMapManagerProxy:InitKeyMap()
  local list = {}
  for k, v in pairs(SettingEnum.KeyMapType) do
    list[v] = SettingBaseKeyMapClass.new(v)
  end
  self.keyMapProxyList = list
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  for indexKey, value in pairs(SettingSaveDataProxy.currentSaveData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    if oriData and oriData.UiType == ItemType.OperateItem then
      for k, v in pairs(self.keyMapProxyList) do
        if v:GetKeyMapType() == SettingHelper.GetKeyMapType(oriData) then
          local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
          v:AddKeyMap(inputChordArr[1].Key.KeyName, indexKey)
          v:AddKeyMap(inputChordArr[2].Key.KeyName, indexKey)
        end
      end
    end
  end
end
function SettingKeyMapManagerProxy:GetProxy(keyMapType)
  return self.keyMapProxyList[keyMapType]
end
function SettingKeyMapManagerProxy:ApplyDefaultConfig()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  for k, v in pairs(self.keyMapProxyList) do
    v:ClearKeyMap()
  end
  for indexKey, value in pairs(SettingSaveDataProxy.defaultSaveData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    if oriData and oriData.UiType == ItemType.OperateItem then
      for k, v in pairs(self.keyMapProxyList) do
        if v:GetKeyMapType() == SettingHelper.GetKeyMapType(oriData) then
          local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
          v:AddKeyMap(inputChordArr[1].Key.KeyName, indexKey)
          v:AddKeyMap(inputChordArr[2].Key.KeyName, indexKey)
        end
      end
    end
  end
end
function SettingKeyMapManagerProxy:ClearKeyMap()
  self.keyMapProxyList = nil
end
function SettingKeyMapManagerProxy:CheckAimingAndAdsIsSame()
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local keyStr1, keyStr2 = SettingInputUtilProxy:GetKeyByInputName("SettingAiming")
  local keyStr3, keyStr4 = SettingInputUtilProxy:GetKeyByInputName("SettingADS")
  local checkSame = function(key1, key2)
    if key1 == key2 and "" ~= key1 and "" ~= key2 then
      return true
    end
    return false
  end
  if checkSame(keyStr1, keyStr3) or checkSame(keyStr2, keyStr3) or checkSame(keyStr1, keyStr4) or checkSame(keyStr2, keyStr4) then
    return true
  end
  return false
end
function SettingKeyMapManagerProxy:OnRemove()
  SettingKeyMapManagerProxy.super.OnRemove(self)
  self.keyMapProxyList = nil
end
return SettingKeyMapManagerProxy
