local SettingVisualProxy = class("SettingVisualProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function SettingVisualProxy:OnRegister()
  SettingVisualProxy.super.OnRegister(self)
  self.MBResolutionValueArr = {
    80,
    100,
    120,
    150
  }
  self.resolutionArr = nil
end
function SettingVisualProxy:OnInit()
  self:ReloadResolutionData()
  self:InitMaxFrameLimit()
  self:InitTotalMemory()
  local DataCenterCPP = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  local GraphicsQualityArr = {}
  for i = 0, 4 do
    local QualityMap = DataCenterCPP.GetGraphicsQualityByLevels(i):ToTable()
    local TempQualityMap = {}
    for k, v in pairs(QualityMap) do
      TempQualityMap[k] = v + 1
    end
    GraphicsQualityArr[i + 1] = TempQualityMap
  end
  self.GraphicsQualityArr = GraphicsQualityArr
end
function SettingVisualProxy:GetStandardResolutionIndex(resolution)
  for i, v in ipairs(self.resolutionArr) do
    if resolution.X == v.X and resolution.Y == v.Y then
      return i
    end
  end
  return #self.resolutionArrTextWithCustom
end
function SettingVisualProxy:CheckIsStandardResolutionIndex(resolution)
  for i, v in ipairs(self.resolutionArr) do
    if resolution.X == v.X and resolution.Y == v.Y then
      return true
    end
  end
  return false
end
function SettingVisualProxy:GetScreenResolutionArr()
  if self.resolutionArr == nil then
    self:OnInit()
  end
  return self.resolutionArr
end
function SettingVisualProxy:GetScreenResolutionTextArr()
  if self.resolutionArrText == nil then
    self:OnInit()
  end
  return self.resolutionArrText
end
function SettingVisualProxy:GetScreenResolutionTextArrWithCustom()
  if self.resolutionArrTextWithCustom == nil then
    self:OnInit()
  end
  return self.resolutionArrTextWithCustom
end
function SettingVisualProxy:GetFullScreenResolutionIndex()
  local resolutionDisplayArr = self:GetScreenResolutionArr()
  return #resolutionDisplayArr
end
function SettingVisualProxy:GetDefaultResolutionIndex()
  local resolutionDisplayArr = self:GetScreenResolutionArr()
  return #resolutionDisplayArr
end
function SettingVisualProxy:GetCustomResolutionIndex()
  local arrCustomText = self:GetScreenResolutionTextArrWithCustom()
  return #arrCustomText
end
function SettingVisualProxy:GetGraphicsQualityArr()
  return self.GraphicsQualityArr
end
function SettingVisualProxy:ReloadResolutionData()
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local bSupported, resoultion = UserSetting:GetSupportedFullscreenResolutions()
  if type(resoultion) == "boolean" then
    resoultion, bSupported = bSupported, resoultion
  end
  local resolution = UserSetting:GetDesktopResolution()
  LogInfo("SettingVisualProxy:OnInit()", "resolution X: " .. tostring(resolution.X) .. " y: " .. tostring(resolution.Y))
  local arr = {}
  local arrText = {}
  local arrCustomText = {}
  if bSupported then
    for i = 1, resoultion:Length() do
      local item = resoultion:Get(i)
      arr[#arr + 1] = item
      arrText[#arrText + 1] = string.format("%d x %d", item.X, item.Y)
      arrCustomText[#arrCustomText + 1] = string.format("%d x %d", item.X, item.Y)
    end
  end
  self.resolutionArr = arr
  arrCustomText[#arrCustomText + 1] = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "17")
  self.resolutionArrText = arrText
  self.resolutionArrTextWithCustom = arrCustomText
end
function SettingVisualProxy:ReloadCfgData(bCustom)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey("Resolution")
  if oriData then
    oriData.Options:Clear()
    local itemArr
    if bCustom then
      itemArr = self:GetScreenResolutionTextArrWithCustom()
    else
      itemArr = self:GetScreenResolutionTextArr()
    end
    for i, item in ipairs(itemArr) do
      oriData.Options:Add(item)
    end
    oriData.DefaultOptions = self:GetDefaultResolutionIndex()
  end
end
function SettingVisualProxy:Reload(bReloadResolutionData)
  local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  if bReloadResolutionData then
    self:ReloadResolutionData()
  end
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local resolution = UserSetting:GetScreenResolution()
  local ResolutionIndex = SettingVisualProxy:GetStandardResolutionIndex(resolution)
  SettingVisualProxy:ReloadCfgData(ResolutionIndex == SettingVisualProxy:GetCustomResolutionIndex())
  local ScreenMode = SettingHelper.GetScreenModeType(UserSetting:GetFullscreenMode(), false)
  local setting_list = {}
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.ScreenMode,
    value = ScreenMode
  }
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.Resolution,
    value = ResolutionIndex
  }
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToCurrent)
  SettingSaveDataProxy.templateSaveData.ScreenMode = nil
  SettingSaveDataProxy.templateSaveData.Resolution = nil
end
function SettingVisualProxy:InitMaxFrameLimit()
  self.MaxFrameLimit = 1000
end
function SettingVisualProxy:InitTotalMemory()
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local TotalMemory = UserSetting:GetTotalMemory()
  self.TotalMemory = TotalMemory
  LogDebug("SettingVisualProxy", "TotalMemory " .. tostring(TotalMemory))
end
function SettingVisualProxy:FixFrameRateData()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey("FrameRate")
  if oriData then
    local arr = {}
    for i = 1, oriData.Options:Length() do
      local value = oriData.Options:Get(i)
      if tonumber(value) <= self.MaxFrameLimit then
        arr[#arr + 1] = value
      end
    end
    oriData.Options:Clear()
    for i = 1, #arr do
      oriData.Options:Add(tostring(arr[i]))
      LogDebug("SettingVisualProxy", "FrameRate: " .. tostring(arr[i]))
    end
    self.MaxFrameRateIndex = #arr
  end
end
function SettingVisualProxy:GetMaxFrameRateIndex()
  return self.MaxFrameRateIndex
end
function SettingVisualProxy:FixResolutionData()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey("MBResolution")
  if oriData then
    local showCnt = 2
    if self.TotalMemory <= 4 then
      showCnt = 2
    elseif self.TotalMemory <= 6 and self.TotalMemory > 4 then
      showCnt = 3
    elseif self.TotalMemory > 6 then
      showCnt = 4
    end
    local arr = {}
    for i = 1, oriData.Options:Length() do
      local value = oriData.Options:Get(i)
      if i <= showCnt then
        arr[#arr + 1] = value
      end
    end
    oriData.Options:Clear()
    for i = 1, #arr do
      oriData.Options:Add(tostring(arr[i]))
      LogDebug("SettingVisualProxy", "frameRate: %s", tostring(arr[i]))
    end
  end
end
function SettingVisualProxy:GetResoulutionValue(resoultionIndex)
  if self.MBResolutionValueArr[resoultionIndex] then
    return self.MBResolutionValueArr[resoultionIndex]
  end
  return self.MBResolutionValueArr[1]
end
function SettingVisualProxy:OnRemove()
  SettingVisualProxy.super.OnRemove(self)
  self.resolutionArr = nil
  self.resolutionArrText = nil
  self.resolutionArrTextWithCustom = nil
  self.GraphicsQualityArr = nil
end
return SettingVisualProxy
