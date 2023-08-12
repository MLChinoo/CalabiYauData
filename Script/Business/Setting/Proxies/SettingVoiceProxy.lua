local SettingVoiceProxy = class("SettingVoiceProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function SettingVoiceProxy:OnRegister()
  SettingVoiceProxy.super.OnRegister(self)
  self.PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
end
function SettingVoiceProxy:OnInit()
  self:ReloadData()
  self:ApplySaveData()
end
local getList = function(list)
  local retList = {}
  for i = 1, list:Length() do
    local item = list:Get(i)
    retList[#retList + 1] = item
  end
  if 0 == #retList then
    retList = {
      SettingEnum.NoDevice
    }
  end
  return retList
end
function SettingVoiceProxy:ReloadData()
  self.inputList = getList(self.PMVoiceManager:GetMicDeviceNameList())
  self.inputIDList = getList(self.PMVoiceManager:GetMicDeviceIDList())
  self.outputList = getList(self.PMVoiceManager:GetSpeakerDeviceNameList())
  self.outputIDList = getList(self.PMVoiceManager:GetSpeakerDeviceIDList())
end
local FillData = function(oriData, list)
  if oriData then
    oriData.Options:Clear()
    local itemArr = list
    for i, item in ipairs(itemArr) do
      oriData.Options:Add(item)
    end
    oriData.DefaultOptions = 1
  end
end
function SettingVoiceProxy:ReloadCfgData()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  FillData(SettingConfigProxy:GetOriDataByIndexKey("VoiceInputDevice"), self.inputList)
  FillData(SettingConfigProxy:GetOriDataByIndexKey("VoiceOutputDevice"), self.outputList)
end
function SettingVoiceProxy:ApplySaveData()
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  local saveExtraGameData = SettingSaveGameProxy:GetSaveExtraGameData()
  if saveExtraGameData.VoiceInputDevice then
    local vdName = saveExtraGameData.VoiceInputDevice
    for i, v in ipairs(self.inputIDList) do
      if v == vdName then
        self.PMVoiceManager:SetMicDeviceByID(vdName)
      end
    end
  end
  if saveExtraGameData.VoiceOutputDevice then
    local vdName = saveExtraGameData.VoiceOutputDevice
    for i, v in ipairs(self.outputIDList) do
      if v == vdName then
        self.PMVoiceManager:SetSpeakerDeviceByID(vdName)
      end
    end
  end
end
function SettingVoiceProxy:GetInputList()
  return self.inputList
end
function SettingVoiceProxy:GetOutputList()
  return self.outputList
end
function SettingVoiceProxy:GetInputIndex()
  local deviceId = self.PMVoiceManager:GetCurrentMicDeviceID()
  for i, v in ipairs(self.inputIDList) do
    if v == deviceId then
      return i
    end
  end
  return 1
end
function SettingVoiceProxy:GetOutputIndex()
  local deviceId = self.PMVoiceManager:GetCurrentSpeakerDeviceID()
  for i, v in ipairs(self.outputIDList) do
    if v == deviceId then
      return i
    end
  end
  return 1
end
function SettingVoiceProxy:SetInputDeviceByIndex(index)
  local deviceId = self.inputIDList[index]
  if self.inputList[index] ~= SettingEnum.NoDevice then
    self.PMVoiceManager:SetMicDeviceByID(deviceId)
    local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
    SettingSaveGameProxy:StoreDataToExtraGameData("VoiceInputDevice", deviceId)
  end
end
function SettingVoiceProxy:SetOutputDeviceByIndex(index)
  local deviceId = self.outputIDList[index]
  if self.outputList[index] ~= SettingEnum.NoDevice then
    self.PMVoiceManager:SetSpeakerDeviceByID(deviceId)
    local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
    SettingSaveGameProxy:StoreDataToExtraGameData("VoiceOutputDevice", deviceId)
  end
end
function SettingVoiceProxy:PrintInfomation()
  self.inputList = getList(self.PMVoiceManager:GetMicDeviceNameList())
  self.inputIDList = getList(self.PMVoiceManager:GetMicDeviceIDList())
  self.outputList = getList(self.PMVoiceManager:GetSpeakerDeviceNameList())
  self.outputIDList = getList(self.PMVoiceManager:GetSpeakerDeviceIDList())
  for i, v in ipairs(self.inputList) do
    LogDebug("SettingVoiceProxy", "inputList " .. tostring(i) .. " " .. tostring(v))
  end
  for i, v in ipairs(self.inputIDList) do
    LogDebug("SettingVoiceProxy", "inputIDList " .. tostring(i) .. " " .. tostring(v))
  end
  for i, v in ipairs(self.outputList) do
    LogDebug("SettingVoiceProxy", "outputList " .. tostring(i) .. " " .. tostring(v))
  end
  for i, v in ipairs(self.outputIDList) do
    LogDebug("SettingVoiceProxy", "outputIDList " .. tostring(i) .. " " .. tostring(v))
  end
  LogDebug("SettingVoiceProxy", "GetCurrentMicDeviceID =>" .. tostring(self.PMVoiceManager:GetCurrentMicDeviceID()))
  LogDebug("SettingVoiceProxy", "GetCurrentSpeakerDeviceID =>" .. tostring(self.PMVoiceManager:GetCurrentSpeakerDeviceID()))
end
function SettingVoiceProxy:OnRemove()
  self.PMVoiceManager = nil
  self.outputList = nil
  self.inputList = nil
  self.outputIDList = nil
  self.inputIDList = nil
  SettingVoiceProxy.super.OnRemove(self)
end
return SettingVoiceProxy
