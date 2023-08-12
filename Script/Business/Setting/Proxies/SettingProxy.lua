local SettingProxy = class("SettingProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingCustomLayoutMap = require("Business/Setting/Proxies/Map/SettingCustomLayoutMap")
local ItemType = SettingEnum.ItemType
local MB2PCkeyMap = {
  MBAutoJumpDelayTime = "AutoJumpDelayTime",
  MBSwitch_AutoJumpOnWall = "Switch_AutoJumpOnWall"
}
function SettingProxy:OnRegister()
  SettingProxy.super.OnRegister(self)
  self.DataCenterCPP = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  if self.DataCenterCPP == nil then
    LogError("SettingProxy", "DataCenterCPP is nil")
  else
    self.AllSettingInfoCPP = self.DataCenterCPP.AllSettingInfo
    self.SoundSetting = self.DataCenterCPP.SoundSetting
  end
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  self.OnMonitorResolutionChangedHandler = DelegateMgr:AddDelegate(UserSetting.OnMonitorResolutionChanged, self, "OnMonitorResolutionChanged")
end
function SettingProxy:UpdateCPPSingleConfig(oriData, value, indexKey)
  if oriData then
    local cppIndexKey = MB2PCkeyMap[oriData.indexKey] or oriData.indexKey
    local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
    if oriData.UiType == ItemType.SwitchItem then
      self.AllSettingInfoCPP[cppIndexKey] = value - 1
    elseif oriData.UiType == ItemType.SliderItem then
      self.AllSettingInfoCPP[cppIndexKey] = value / SettingEnum.Multipler
    elseif oriData.UiType == ItemType.OperateItem then
      SettingInputUtilProxy:ChangeActionInputSetting(oriData, value)
    elseif oriData.UiType == ItemType.SliderItemWithCheck then
      self.AllSettingInfoCPP[cppIndexKey] = value / SettingEnum.Multipler
    elseif oriData.UiType == ItemType.CustomItem then
      if "LayoutIndex" == cppIndexKey then
        self.AllSettingInfoCPP[cppIndexKey] = value - 1
      elseif "SpecialShapedAdaption" == cppIndexKey then
        self.AllSettingInfoCPP[cppIndexKey] = value / SettingEnum.Multipler
      elseif "OperationIndex" == cppIndexKey then
        self.AllSettingInfoCPP[cppIndexKey] = value - 1
      end
    end
    self:SetVolume(oriData, self.AllSettingInfoCPP[cppIndexKey])
  else
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
    if SettingOperationProxy:CheckIsCustomOperation(indexKey) and self.RecordIndexKey[indexKey] == nil then
      self:UpdateLayoutConfig(indexKey, value)
    end
  end
end
function SettingProxy:UpdateLayoutConfig(indexKey, value)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local attrName, indexStyle, index = SettingOperationProxy:SolveIndexKey(indexKey)
  if self.AllSettingInfoCPP and self.AllSettingInfoCPP.AllCustomLayoutData then
    if self.AllSettingInfoCPP.AllCustomLayoutData:IsValidIndex(indexStyle) == false then
      LogError("SettingProxy", "AllCustomLayoutData not valid index")
    end
  else
    LogError("SettingProxy", "no AllCustomLayoutData ")
  end
  local layoutData = self.AllSettingInfoCPP.AllCustomLayoutData:GetRef(indexStyle)
  local cppAttrName = SettingCustomLayoutMap.KeyList[attrName][2]
  if "MoveLine" == attrName then
    layoutData[cppAttrName] = -1 * value / SettingEnum.Multipler
  else
    local otherIndex = 1 == index and 2 or 1
    local relativeIndexKey = SettingOperationProxy:GetKey(attrName, indexStyle, otherIndex)
    local num1 = SettingSaveDataProxy:GetCurrentValueByKey(indexKey)
    local num2 = SettingSaveDataProxy:GetCurrentValueByKey(relativeIndexKey)
    if nil == num1 or nil == num2 then
      local _num1, _num2 = SettingOperationProxy:ZipData(0, 0, 1, 1)
      if nil == num1 then
        num1 = _num1
      end
      if nil == num1 then
        num1 = _num1
      end
    end
    if 1 == otherIndex then
      num1, num2 = num2, num1
    end
    self.RecordIndexKey[indexKey] = true
    self.RecordIndexKey[relativeIndexKey] = true
    local difX, difY, opacity, scale = SettingOperationProxy:UnZipData(num1, num2)
    local layoutDataMap = layoutData.CustomLayoutDataMap
    local layoutInfo = layoutDataMap:FindRef(cppAttrName)
    if nil == layoutInfo then
      layoutInfo = UE4.FLayoutInfo()
      layoutDataMap:Add(cppAttrName, layoutInfo)
      layoutInfo = layoutDataMap:FindRef(cppAttrName)
    end
    layoutInfo.DifX = difX
    layoutInfo.DifY = difY
    layoutInfo.Scale = scale
    layoutInfo.Opacity = opacity
  end
end
function SettingProxy:UpdateCPPConfig(saveDataMap, saveStatus)
  LogInfo("SettingProxy", "UpdateCPPConfig")
  self.RecordIndexKey = {}
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for indexKey, value in pairs(saveDataMap) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    self:UpdateCPPSingleConfig(oriData, value, indexKey)
  end
  self.RecordIndexKey = {}
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    self.AllSettingInfoCPP.ButtonStyle_FlyMode = 1
    self.AllSettingInfoCPP.ButtonStyle_SideMode = 1
  end
  self:UpdateAxisInputSetting(saveDataMap)
  if saveStatus == SettingEnum.SaveStatus.SaveToApplyChange then
    if saveDataMap.SpecialShapedAdaption then
      UE4.UPMSafeZone.UpdateWithSetting(saveDataMap.SpecialShapedAdaption / SettingEnum.Multipler)
    end
    local inputSetting = UE4.UInputSettings.GetInputSettings()
    inputSetting:ForceRebuildKeymaps()
    self:SyncVisualSetting(saveDataMap)
    UE4.UPMInputSubsystem.Get(LuaGetWorld()):ExecuteInputSettingChanged()
    self:ChangeCV(saveDataMap)
    self.DataCenterCPP:ApplyNewSetting()
    GameFacade:SendNotification(NotificationDefines.Setting.SettingApplyChange, saveDataMap)
    local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
    if chatDataProxy then
      chatDataProxy:SendMicStateReq()
    end
    if saveDataMap.VoiceInputDevice then
      local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
      SettingVoiceProxy:SetInputDeviceByIndex(saveDataMap.VoiceInputDevice)
    end
    if saveDataMap.VoiceOutputDevice then
      local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
      SettingVoiceProxy:SetOutputDeviceByIndex(saveDataMap.VoiceOutputDevice)
    end
  end
end
function SettingProxy:SetVolume(oriData, value)
  if self.SoundSetting[oriData.indexKey] == nil then
    return
  end
  self.SoundSetting[oriData.indexKey] = value
  local keyMap = {
    Volume = UE4.EVolumeType.Master,
    GameVolume = UE4.EVolumeType.InGame,
    MusicVolume = UE4.EVolumeType.Music,
    UIVolume = UE4.EVolumeType.Ui,
    CharacterVoice = UE4.EVolumeType.CharacterVoice,
    MicrophoneVolume = UE4.EVolumeType.MicrophoneVolume,
    VoiceChatVolume = UE4.EVolumeType.VoiceChatVolume
  }
  local volumeType = keyMap[oriData.indexKey]
  if volumeType then
    self.DataCenterCPP:CommonSetVolume(volumeType)
  end
end
function SettingProxy:GetDataCenterCPP()
  return self.DataCenterCPP
end
function SettingProxy:SyncVisualSetting(saveDataMap)
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local bChangedSetting = false
  if saveDataMap.MaxFPS then
    UserSetting:SetPMFrameRateLimit(saveDataMap.MaxFPS / SettingEnum.Multipler)
    bChangedSetting = true
  end
  if saveDataMap.ScreenMode then
    local screenMode = SettingHelper.GetScreenModeType(saveDataMap.ScreenMode, true)
    UserSetting:SetPMFullscreenMode(screenMode)
    bChangedSetting = true
  end
  if saveDataMap.Resolution then
    local reIndex = saveDataMap.Resolution
    local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
    local resolution = SettingVisualProxy:GetScreenResolutionArr()
    UserSetting:SetPMScreenResolution(resolution[reIndex])
    bChangedSetting = true
  end
  if saveDataMap.RenderPercentage then
    self.DataCenterCPP:SetScalabilityQuality("RenderPercentage", saveDataMap.RenderPercentage - 1)
  end
  if saveDataMap.Graphics == nil or saveDataMap.Graphics == SettingEnum.GraphicCustomIndex then
    for indexName, value in pairs(saveDataMap) do
      if SettingHelper.CheckIsGraphicQuality(indexName) then
        self.DataCenterCPP:SetScalabilityQuality(indexName, value - 1)
      end
    end
  else
    local level = saveDataMap.Graphics - 1
    self.DataCenterCPP:SetScalabilityQuality("Graphics", level)
    LogDebug("SettingProxy", "Graphics: " .. tostring(level))
  end
  if saveDataMap.Switch_VerticalSync then
    UserSetting:SetPMVSyncEnabled(1 == saveDataMap.Switch_VerticalSync)
    bChangedSetting = true
  end
  if saveDataMap.FrameRate then
    self.DataCenterCPP:SetScalabilityQuality("FrameRate", saveDataMap.FrameRate - 1)
    LogDebug("SettingProxy", "FrameRate: " .. tostring(saveDataMap.FrameRate - 1))
  end
  if saveDataMap.MBResolution then
    local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
    local value = SettingVisualProxy:GetResoulutionValue(saveDataMap.MBResolution)
    LogDebug("SettingProxy", "MBResolution: " .. value)
    UserSetting:SetResolutionScaleValueEx(value)
  end
  self:ApplyBrightnessChanged(50)
  if bChangedSetting then
    UserSetting:ApplySettings(true)
  end
end
function SettingProxy:ApplyBrightnessChanged(dValue)
  LogInfo("SettingProxy", "Bright value:" .. tostring(dValue))
  self.AllSettingInfoCPP.ScreenBrightness = dValue
  self.DataCenterCPP:ApplyBrightnessChanged(dValue)
end
function SettingProxy:ChangeCV(saveDataMap)
  if saveDataMap.CvStyle then
    local cvStyle = self.AllSettingInfoCPP.CvStyle
    if cvStyle == UE4.ECVStyle.Chinese then
      self.DataCenterCPP:ApplyCV("Chinese")
    elseif cvStyle == UE4.ECVStyle.Japanese then
      self.DataCenterCPP:ApplyCV("Japanese")
    else
      self.DataCenterCPP:ApplyCV("Japanese")
    end
  end
end
function SettingProxy:GetValueByKey(keyname)
  return self.AllSettingInfoCPP[keyname]
end
function SettingProxy:UpdateAxisInputSetting(saveDataMap)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local ChangeInputAxisFunc = function(posName, negName)
    if saveDataMap[posName] or saveDataMap[negName] then
      local v1 = SettingSaveDataProxy:GetCurrentValueByKey(posName)
      local v2 = SettingSaveDataProxy:GetCurrentValueByKey(negName)
      SettingInputUtilProxy:ChangeAxisInputSetting(posName, negName, v1, v2)
    end
  end
  if saveDataMap then
    ChangeInputAxisFunc("Up", "Down")
    ChangeInputAxisFunc("Right", "Left")
  end
end
function SettingProxy:ReturnToLobby()
  self.DataCenterCPP:GoBackToLobby()
end
function SettingProxy:OnMonitorResolutionChanged()
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  SettingVisualProxy:Reload(true)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingRefreshResolution)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf)
end
function SettingProxy:OnRemove()
  SettingProxy.super.OnRemove(self)
  self.DataCenterCPP = nil
  self.AllSettingInfoCPP = nil
  self.SoundSetting = nil
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  if self.OnMonitorResolutionChangedHandler then
    DelegateMgr:RemoveDelegate(UserSetting.OnMonitorResolutionChanged, self.OnMonitorResolutionChangedHandler)
    self.OnMonitorResolutionChangedHandler = nil
  end
end
return SettingProxy
