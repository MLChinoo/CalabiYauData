local SettingSaveGameProxy = class("SettingSaveGameProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingSlotName = "SettingGameSlot"
function SettingSaveGameProxy:OnRegister()
  SettingSaveGameProxy.super.OnRegister(self)
  local saveGameData = self:GetSaveGameData()
end
function SettingSaveGameProxy:WriteExtraData(keyMap)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local saveGameData = self:GetSaveGameData()
  if saveGameData then
    for key, value in pairs(keyMap) do
      saveGameData.SaveExtraMap:Add(key, value)
    end
    UE4.UGameplayStatics.SaveGameToSlot(saveGameData, SettingSlotName, 0)
  end
end
function SettingSaveGameProxy:GetExtraDataByKey(key)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local saveGameData = self:GetSaveGameData()
  if saveGameData then
    local saveExtraGameData = saveGameData.SaveExtraMap:ToTable()
    return saveExtraGameData[key]
  end
end
function SettingSaveGameProxy:WriteData(setting_list)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local saveGameData = self:GetSaveGameData()
  if saveGameData then
    for _, v in ipairs(setting_list) do
      local oriData = SettingConfigProxy:GetOriDataBySaveKey(v.key)
      if oriData and SettingHelper.IsVisualAndSaveAttribute(oriData) then
        saveGameData.SaveMap:Add(v.key, v.value)
      else
        LogDebug("SettingSaveGameProxy", v.key)
      end
    end
    UE4.UGameplayStatics.SaveGameToSlot(saveGameData, SettingSlotName, 0)
  end
end
function SettingSaveGameProxy:GetFirstLoginAndSaveFirstLogin()
  local bFirstLogin = false
  if self.saveGameData[0] == nil then
    bFirstLogin = true
  end
  if bFirstLogin then
    self:WriteData({
      {key = 0, value = 0}
    })
  end
end
function SettingSaveGameProxy:SaveGameDataByIndexKey(indexKey, value)
  local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
  if self.saveGameData[saveKey] == nil then
    self:WriteData({
      {key = saveKey, value = value}
    })
  end
end
function SettingSaveGameProxy:RemoveListByIndexKey(list, indexKey)
  local idx = -1
  for i, v in ipairs(list) do
    if v.key == SettingStoreMap.indexKeyToSaveKey[indexKey] then
      idx = i
    end
  end
  if -1 ~= idx then
    table.remove(list, idx)
  end
end
function SettingSaveGameProxy:GetSaveGameData()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(SettingSlotName, 0)
  if nil == saveGameData then
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.USettingSaveGame)
    UE4.UGameplayStatics.SaveGameToSlot(saveGameData, SettingSlotName, 0)
  end
  return saveGameData
end
function SettingSaveGameProxy:PreInit()
  local saveGameData = self:GetSaveGameData()
  self.saveExtraGameData = saveGameData.SaveExtraMap:ToTable()
  self:SaveExtraValue()
end
function SettingSaveGameProxy:GetSaveExtraGameData()
  return self.saveExtraGameData
end
function SettingSaveGameProxy:OnInit()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  LogInfo("SettingSaveGameProxy", ":OnInit()")
  local saveGameData = self:GetSaveGameData()
  self.saveGameData = saveGameData.SaveMap:ToTable()
  self.saveExtraGameData = saveGameData.SaveExtraMap:ToTable()
  local defaultData = SettingSaveDataProxy:GetDefaultData()
  local setting_list = {}
  local DataCenterCPP = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  local savelist = {}
  for indexKey, v in pairs(defaultData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
    if not SettingHelper.IsVisualAttribute(oriData) and oriData.indexKey ~= "CvStyle" or "ScreenMode" == indexKey or "Resolution" == indexKey then
    else
      local value = self.saveGameData[saveKey] or v
      setting_list[#setting_list + 1] = {key = saveKey, value = value}
      if self.saveGameData[saveKey] == nil then
        savelist[#savelist + 1] = {key = saveKey, value = value}
      end
    end
  end
  if #savelist > 0 then
    self:WriteData(savelist)
  end
  SettingHelper.PrintSettingList(setting_list)
  local bFirstLogin = self:GetFirstLoginAndSaveFirstLogin()
  LogInfo("SettingSaveGameProxy", "bFirstLogin " .. tostring(bFirstLogin))
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
  if UE4.UAkGameplayStatics.IsEditor() then
    SettingSaveDataProxy:InitApplyDefaultDataOnce()
  else
    SettingSaveDataProxy:InitApplyDefaultDataOnce(bFirstLogin)
  end
end
function SettingSaveGameProxy:SaveExtraValue()
  local keyName = "Apartment"
  local DataCenterCPP = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  if self.saveExtraGameData[keyName] == nil then
    DataCenterCPP:SetScalabilityQuality(keyName, 0)
    local level = DataCenterCPP.GetCustomQualityLevels(keyName)
    self.saveExtraGameData[keyName] = tostring(level)
    self:WriteExtraData(self.saveExtraGameData)
  else
    DataCenterCPP:SetScalabilityQuality(keyName, tonumber(self.saveExtraGameData[keyName]))
  end
end
function SettingSaveGameProxy:StoreDataToExtraGameData(key, value)
  self.saveExtraGameData[key] = value
  self:WriteExtraData(self.saveExtraGameData)
end
function SettingSaveGameProxy:StoreLayoutMapToSaveGame(LayoutMapData)
  local saveGameData = self:GetSaveGameData()
  if saveGameData then
    for key, value in pairs(LayoutMapData) do
      saveGameData.LayoutMap:Add(key, value)
    end
    UE4.UGameplayStatics.SaveGameToSlot(saveGameData, SettingSlotName, 0)
  end
end
function SettingSaveGameProxy:OnRemove()
  SettingSaveGameProxy.super.OnRemove(self)
  self.saveGameData = nil
end
return SettingSaveGameProxy
