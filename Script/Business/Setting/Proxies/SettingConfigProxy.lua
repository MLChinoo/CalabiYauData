local SettingConfigProxy = class("SettingConfigProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
local PanelTypeStr = SettingEnum.PanelTypeStr
local addValueToArr = function(array, v)
  array[#array + 1] = v
end
local GetTblByKey = function(mapValue, keyTbl)
  local t = mapValue
  for i, v in ipairs(keyTbl) do
    t[v] = t[v] or {}
    t = t[v]
  end
  return t
end
function SettingConfigProxy:OnRegister()
  self.super.OnRegister(self)
  self.mainTypeMap = {}
  self.subTypeMap = {}
  self.titleTypeMap = {}
  self.allTypeMap = {}
  self.allValueMap = {}
  self.tabCfgMap = {}
  self.commonConfigMap = {}
end
function SettingConfigProxy:OnRemove()
  self.super.OnRemove(self)
  self.mainTypeMap = {}
  self.subTypeMap = {}
  self.titleTypeMap = {}
  self.allTypeMap = {}
  self.allValueMap = {}
  self.tabCfgMap = {}
  self.commonConfigMap = {}
end
function SettingConfigProxy:OnInit()
  local data = ConfigMgr:GetSettingTableRow()
  local configTbl = data:ToLuaTable()
  local arr = {}
  for i, v in pairs(configTbl) do
    arr[#arr + 1] = v
  end
  table.sort(arr, function(a, b)
    return a.Id < b.Id
  end)
  local lastType, lastSubType, lastTitle
  local mainTypeMap = self.mainTypeMap
  local subTypeMap = self.subTypeMap
  local titleTypeMap = self.titleTypeMap
  local allTypeMap = self.allTypeMap
  local allValueMap = self.allValueMap
  for i, v in ipairs(arr) do
    if lastType ~= v.Type then
      mainTypeMap[#mainTypeMap + 1] = v.Type
      lastType = v.Type
      lastSubType = nil
      lastTitle = nil
      subTypeMap[v.Type] = {}
    end
    if lastSubType ~= v.SubType then
      subTypeMap[v.Type][#subTypeMap[v.Type] + 1] = v.SubType
      titleTypeMap[v.Type] = titleTypeMap[v.Type] or {}
      titleTypeMap[v.Type][v.SubType] = titleTypeMap[v.Type][v.SubType] or {}
      lastSubType = v.SubType
      lastTitle = nil
    end
    if lastTitle ~= v.Title and v.Title ~= "" then
      addValueToArr(titleTypeMap[v.Type][v.SubType], v.Title)
      lastTitle = v.Title
    end
    local tbl = GetTblByKey(allTypeMap, {
      lastType,
      lastSubType,
      lastTitle
    })
    addValueToArr(tbl, v)
    allValueMap[v.indexKey] = v
  end
  LogInfo("SettingConfigProxy", "Init Complete")
  self.mainTypeMap = mainTypeMap
  self.subTypeMap = subTypeMap
  self.titleTypeMap = titleTypeMap
  self.allTypeMap = allTypeMap
  self.allValueMap = allValueMap
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  SettingVisualProxy:ReloadCfgData()
  SettingVisualProxy:FixFrameRateData()
  SettingVisualProxy:FixResolutionData()
  if self.allValueMap.Graphics then
    local oriData = self.allValueMap.Graphics
    local customText = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "17")
    oriData.Options:Add(customText)
  end
  local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
  SettingVoiceProxy:ReloadCfgData()
  if self.allValueMap.SpecialShapedAdaption then
    local maxValue, desiredValue = UE4.UPMSafeZone.GetSafeZoneSettingParameter(0, 0)
    self.allValueMap.SpecialShapedAdaption.Max = math.ceil(maxValue * SettingEnum.Multipler)
    self.allValueMap.SpecialShapedAdaption.DefaultOptions = math.ceil(desiredValue * SettingEnum.Multipler)
  end
  self:InitCommonConfig()
end
function SettingConfigProxy:InitCommonConfig()
  local SettingConfigSolveMap = require("Business/Setting/Proxies/Map/SettingConfigSolveMap")
  local data = ConfigMgr:GetCommonSettingConfigTableRow()
  local configTbl = data:ToLuaTable()
  local ret = {}
  for k, v in pairs(configTbl) do
    ret[v.indexKey] = SettingConfigSolveMap[v.indexKey](v.content)
  end
  self.commonConfigMap = ret
end
function SettingConfigProxy:Print()
  LogInfo("SettingConfigProxy:Print", "Info")
  LogInfo("SettingConfigProxy:Print", TableToString(self.mainTypeMap))
  LogInfo("SettingConfigProxy:Print", TableToString(self.subTypeMap))
  LogInfo("SettingConfigProxy:Print", TableToString(self.titleTypeMap))
  LogInfo("SettingConfigProxy:Print", TableToString(self.allTypeMap))
end
function SettingConfigProxy:InitTabCfg(pathCfg)
  self.pathCfg = pathCfg
end
function SettingConfigProxy:GetDataByPanelStr(panelStr)
  return self.subTypeMap[panelStr], self.titleTypeMap[panelStr], self.allTypeMap[panelStr]
end
function SettingConfigProxy:GetOriDataByIndexKey(indexKey)
  return self.allValueMap[indexKey]
end
function SettingConfigProxy:GetOriDataBySaveKey(saveKey)
  local indexKey = SettingStoreMap.saveKeyToindexKey[saveKey]
  return self.allValueMap[indexKey]
end
function SettingConfigProxy:CheckCurIndexKeyIsCurPanel(indexKey, panelStr)
  local oriData = self.allValueMap[indexKey]
  if oriData.Type == panelStr then
    return true
  end
  return false
end
function SettingConfigProxy:GetCommonConfigMap()
  return self.commonConfigMap
end
return SettingConfigProxy
