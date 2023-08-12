local SettingSensitivityProxy = class("SettingSensitivityProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function SettingSensitivityProxy:OnRegister()
  SettingSensitivityProxy.super.OnRegister(self)
  self.SensitivityArr = {}
  self.SensitivityCfgArr = {
    "GlobalSensitivityMultipler"
  }
  local Map = {}
  for i, v in ipairs(self.SensitivityCfgArr) do
    Map[v] = true
  end
  self.SensitivityMap = Map
end
function SettingSensitivityProxy:OnInit()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for i, indexKey in ipairs(self.SensitivityCfgArr) do
    self:RecordValueByIndexKey(indexKey)
  end
end
function SettingSensitivityProxy:RecordValueByIndexKey(indexKey)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
  if nil == oriData then
    return
  end
  local arr = string.split(oriData.DefaultOption2, ",")
  local vArr = {}
  for i = 1, 3 do
    local senseValue = tonumber(arr[i])
    vArr[i] = senseValue
  end
  self.SensitivityArr[indexKey] = vArr
end
function SettingSensitivityProxy:GetSenseValueByIndexKeyAndLevel(indexKey, level)
  if self.SensitivityArr[indexKey] then
    return self.SensitivityArr[indexKey][level] or 0
  end
  return 0
end
function SettingSensitivityProxy:checkCustomize(value)
  return value - 1 == UE4.EGlobalSensitivity.Custom
end
function SettingSensitivityProxy:IsMBSensitivity(Sensitivity)
  for i, v in ipairs(self.SensitivityCfgArr) do
    if v == Sensitivity then
      return true
    end
  end
  return false
end
function SettingSensitivityProxy:GetLevel(senseTbl)
  for i = 1, 3 do
    local bFind = true
    for _, indexKey in ipairs(self.SensitivityCfgArr) do
      local value = senseTbl[indexKey]
      local standValue = self.SensitivityArr[indexKey][i]
      if value ~= standValue then
        bFind = false
        break
      end
    end
    if bFind then
      return i
    end
  end
  return UE4.EGlobalSensitivity.Custom + 1
end
function SettingSensitivityProxy:ChangeGlobalSensivity(indexKey, SenseValue)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local curResTbl = {}
  for i, rIndexKey in ipairs(self.SensitivityCfgArr) do
    local templateValue = SettingSaveDataProxy:GetTemplateValueByKey(rIndexKey, SenseValue)
    curResTbl[rIndexKey] = templateValue
  end
  curResTbl[indexKey] = SenseValue
  local level = self:GetLevel(curResTbl)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey("GlobalSensitivity")
  SettingSaveDataProxy:UpdateTemplateData(oriData, level)
  GameFacade:SendNotification(NotificationDefines.Setting.MBSensitivityChangeNtf, {value = level})
end
function SettingSensitivityProxy:CheckIsMBSensivity(indexName)
  return self.SensitivityMap[indexName]
end
function SettingSensitivityProxy:OnRemove()
  SettingSensitivityProxy.super.OnRemove(self)
  self.SensitivityArr = {}
  self.SensitivityMap = {}
  self.SensitivityCfgArr = {}
end
return SettingSensitivityProxy
