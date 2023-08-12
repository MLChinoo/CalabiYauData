local SettingPageDelegateMediator = class("SettingPageDelegateMediator", PureMVC.Mediator)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local TabStyle = SettingEnum.TabStyle
local PanelTypeStr = SettingEnum.PanelTypeStr
function SettingPageDelegateMediator:OnRegister()
  self.super:OnRegister()
  local LoginSubSystem = UE4.UPMLoginSubSystem.GetInstance(self:GetViewComponent())
  self.OnSteamUnBindQQHandler = DelegateMgr:AddDelegate(LoginSubSystem.OnSteamUnBindQQ, self, "OnSteamUnBindQQ")
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  self.OnGameUserSettingsUINeedsUpdateHandler = DelegateMgr:AddDelegate(UserSetting.OnGameUserSettingsUINeedsUpdate, self, "OnGameUserSettingsUINeedsUpdate")
  local SettingDataCenter = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  self.OnApplyViewportResizedHandler = DelegateMgr:AddDelegate(SettingDataCenter.OnApplyViewportResized, self, "OnApplyViewportResized")
  self.OnToggleVoiceEffectDelegateHandler = DelegateMgr:AddDelegate(SettingDataCenter.OnToggleVoiceEffectDelegate, self, "OnToggleVoiceEffectChanged")
  local PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  self.OnMicDeviceChangeEventHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnMicDeviceChangeEvent, self, "OnMicDeviceChangeEvent")
  self.OnSpeakerDeviceChangeEventHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnSpeakerDeviceChangeEvent, self, "OnSpeakerDeviceChangeEvent")
  self:UpdateVisualData()
  self:UpdateVoiceData()
end
function SettingPageDelegateMediator:UpdateVisualData()
  local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  SettingVisualProxy:Reload()
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local setting_list = {}
  if UserSetting.GetPMFrameRateLimit then
    local maxFpsValue = UserSetting:GetPMFrameRateLimit()
    setting_list[#setting_list + 1] = {
      key = SettingStoreMap.indexKeyToSaveKey.MaxFPS,
      value = maxFpsValue * SettingEnum.Multipler
    }
  end
  local isEnabled = UserSetting:GetPMVSyncEnabled()
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.Switch_VerticalSync,
    value = isEnabled and 1 or 2
  }
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToCurrent)
end
function SettingPageDelegateMediator:UpdateVoiceData()
  local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
  local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
  SettingVoiceProxy:ReloadData()
  SettingVoiceProxy:ReloadCfgData()
  local setting_list = {}
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.VoiceInputDevice,
    value = SettingVoiceProxy:GetInputIndex()
  }
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.VoiceOutputDevice,
    value = SettingVoiceProxy:GetOutputIndex()
  }
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToCurrent)
end
function SettingPageDelegateMediator:OnSteamUnBindQQ(errCode)
  if 0 == errCode then
    local msg = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "34")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
    GameFacade:SendNotification(NotificationDefines.Setting.QQUnbindSteamNtf)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errCode)
  end
end
function SettingPageDelegateMediator:OnGameUserSettingsUINeedsUpdate()
end
function SettingPageDelegateMediator:OnApplyViewportResized()
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  SettingVisualProxy:Reload()
  GameFacade:SendNotification(NotificationDefines.Setting.SettingRefreshResolution)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf)
end
function SettingPageDelegateMediator:OnToggleVoiceEffectChanged()
  GameFacade:SendNotification(NotificationDefines.Setting.ToggleVoiceEffectChanged)
end
function SettingPageDelegateMediator:OnMicDeviceChangeEvent()
  self:OnDeviceChangeEvent()
end
function SettingPageDelegateMediator:OnSpeakerDeviceChangeEvent()
  self:OnDeviceChangeEvent()
end
function SettingPageDelegateMediator:OnDeviceChangeEvent()
  local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
  local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
  SettingVoiceProxy:ReloadData()
  SettingVoiceProxy:ReloadCfgData()
  local setting_list = {}
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.VoiceInputDevice,
    value = SettingVoiceProxy:GetInputIndex()
  }
  setting_list[#setting_list + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.VoiceOutputDevice,
    value = SettingVoiceProxy:GetOutputIndex()
  }
  SettingVoiceProxy:PrintInfomation()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToCurrent)
  SettingSaveDataProxy.templateSaveData.VoiceInputDevice = nil
  SettingSaveDataProxy.templateSaveData.VoiceOutputDevice = nil
  GameFacade:SendNotification(NotificationDefines.Setting.SettingDeviceChangeNtf)
end
function SettingPageDelegateMediator:OnRemove()
  local LoginSubSystem = UE4.UPMLoginSubSystem.GetInstance(self:GetViewComponent())
  if self.OnSteamUnBindQQHandler then
    DelegateMgr:RemoveDelegate(LoginSubSystem.OnSteamUnBindQQ, self.OnSteamUnBindQQHandler)
    self.OnSteamUnBindQQHandler = nil
  end
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  if self.OnGameUserSettingsUINeedsUpdateHandler then
    DelegateMgr:RemoveDelegate(UserSetting.OnGameUserSettingsUINeedsUpdate, self.OnGameUserSettingsUINeedsUpdateHandler)
    self.OnGameUserSettingsUINeedsUpdateHandler = nil
  end
  local SettingDataCenter = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  if self.OnApplyViewportResizedHandler then
    DelegateMgr:RemoveDelegate(SettingDataCenter.OnApplyViewportResized, self.OnApplyViewportResizedHandler)
    self.OnApplyViewportResizedHandler = nil
  end
  if self.OnToggleVoiceEffectDelegateHandler then
    DelegateMgr:RemoveDelegate(SettingDataCenter.OnToggleVoiceEffectDelegate, self.OnToggleVoiceEffectDelegateHandler)
    self.OnToggleVoiceEffectDelegateHandler = nil
  end
  local PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if self.OnMicDeviceChangeEventHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnMicDeviceChangeEvent, self.OnMicDeviceChangeEventHandler)
    self.OnMicDeviceChangeEventHandler = nil
  end
  if self.OnSpeakerDeviceChangeEventHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnSpeakerDeviceChangeEvent, self.OnSpeakerDeviceChangeEventHandler)
    self.OnSpeakerDeviceChangeEventHandler = nil
  end
end
return SettingPageDelegateMediator
