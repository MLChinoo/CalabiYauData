local SettingSaveDataProxy = class("SettingSaveDataProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
local ItemType = SettingEnum.ItemType
function SettingSaveDataProxy:OnRegister()
  self.super.OnRegister(self)
  self.defaultSaveData = {}
  self.currentSaveData = {}
  self.templateSaveData = {}
end
function SettingSaveDataProxy:OnRemove()
  self.super.OnRemove(self)
  self.defaultSaveData = nil
  self.currentSaveData = nil
  self.templateSaveData = nil
end
function SettingSaveDataProxy:OnInit()
  self:InitDefaultData()
end
function SettingSaveDataProxy:InitDefaultData()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local DataCenterCPP = UE4.UPMSettingDataCenter.Get(LuaGetWorld())
  local GraphicQualitySum = 0
  for i, keyPanelStr in ipairs(SettingConfigProxy.mainTypeMap) do
    local subTypeList, titleTypeMap, allItemMap = SettingConfigProxy:GetDataByPanelStr(keyPanelStr)
    for _, subTypeStr in ipairs(subTypeList) do
      local titleList = titleTypeMap[subTypeStr]
      for _, titleStr in ipairs(titleList) do
        local oriDataList = allItemMap[subTypeStr][titleStr]
        for _, oriData in ipairs(oriDataList) do
          if oriData and oriData.Indexkey and oriData.Indexkey ~= "" then
            if SettingHelper.CheckIsGraphicQuality(oriData.Indexkey) or oriData.Indexkey == "Graphics" then
              local v = DataCenterCPP.GetCustomQualityLevels(oriData.Indexkey) + 1
              self.defaultSaveData[oriData.Indexkey] = v
            elseif oriData.Indexkey == "FrameRate" then
              local v = DataCenterCPP.GetCustomQualityLevels(oriData.Indexkey) + 1
              self.defaultSaveData[oriData.Indexkey] = v
            else
              self.defaultSaveData[oriData.Indexkey] = self:GetSingleDefaultData(oriData)
            end
          end
        end
      end
    end
  end
end
function SettingSaveDataProxy:FixCurrentValue(value, indexKey)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
  if nil == oriData then
    return value
  end
  local retValue = value
  if oriData.UiType == ItemType.SwitchItem then
    retValue = math.clamp(value, 1, oriData.Options:Length())
    retValue = self:GetDefaultSwitcherLimitData(oriData.indexKey, retValue)
  elseif oriData.UiType == ItemType.SliderItem then
    retValue = math.clamp(value, oriData.Min, oriData.Max)
  elseif oriData.UiType == ItemType.OperateItem then
    if SettingInputUtilProxy:CheckInputChordValueValid(value) == false then
      retValue = nil
    end
  elseif oriData.UiType == ItemType.SliderItemWithCheck then
    retValue = math.clamp(value, oriData.Min, oriData.Max)
  elseif oriData.UiType == ItemType.CustomItem then
    if oriData.indexKey == "LayoutIndex" then
      retValue = math.clamp(value, oriData.Min, oriData.Max)
    elseif oriData.indexKey == "SpecialShapedAdaption" then
      retValue = math.clamp(value, oriData.Min, oriData.Max)
    elseif oriData.indexKey == "OperationIndex" then
      retValue = math.clamp(value, oriData.Min, oriData.Max)
    end
  end
  return retValue
end
function SettingSaveDataProxy:UpdateCurrentData(setting_list, changeStatus)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  self.currentSaveData = self.currentSaveData or {}
  local changeData = {}
  for index, value in pairs(setting_list) do
    local saveKey = value.key
    local indexKey = SettingStoreMap.saveKeyToindexKey[saveKey]
    if indexKey then
      local curValue = self:FixCurrentValue(value.value, indexKey) or self.defaultSaveData[indexKey]
      if curValue ~= self.currentSaveData[indexKey] then
        changeData[indexKey] = curValue
        self.currentSaveData[indexKey] = curValue
        LogInfo("UpdateCurrentData", indexKey .. ": " .. tostring(curValue))
      end
    end
  end
  if changeStatus ~= SettingEnum.SaveStatus.SaveToCurrent then
    local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
    SettingProxy:UpdateCPPConfig(changeData, changeStatus)
  end
end
local defaultSwitcherLimitData = {}
function SettingSaveDataProxy:SetDefaultSwitcherLimitData(arr, indexKey)
  defaultSwitcherLimitData[indexKey] = defaultSwitcherLimitData[indexKey] or {}
  for i, v in ipairs(arr) do
    defaultSwitcherLimitData[indexKey][tonumber(v)] = true
  end
end
function SettingSaveDataProxy:GetDefaultSwitcherLimitData(indexKey, value)
  if defaultSwitcherLimitData[indexKey] then
    if defaultSwitcherLimitData[indexKey][value] then
      return value
    else
      local key, _ = next(defaultSwitcherLimitData[indexKey])
      return key
    end
  end
  return value
end
function SettingSaveDataProxy:GetSingleDefaultData(oriData)
  if oriData.UiType == ItemType.SwitchItem then
    if oriData.DefaultOption2 == "" then
      return oriData.DefaultOptions
    else
      local s, e = string.find(oriData.DefaultOption2, oriData.DefaultOptions .. "")
      local arr = string.split(oriData.DefaultOption2, ",")
      self:SetDefaultSwitcherLimitData(arr, oriData.indexKey)
      if nil == s or -1 == s then
        return tonumber(arr[1])
      else
        return oriData.DefaultOptions
      end
    end
  elseif oriData.UiType == ItemType.SliderItem then
    return oriData.DefaultOptions
  elseif oriData.UiType == ItemType.OperateItem then
    local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
    local keyTotalNumber = SettingInputUtilProxy:GetValueByDefaultData(oriData.DefaultOption2)
    return keyTotalNumber
  elseif oriData.UiType == ItemType.SliderItemWithCheck then
    return oriData.DefaultOptions
  elseif oriData.UiType == ItemType.CustomItem then
    if oriData.indexKey == "LayoutIndex" then
      return oriData.DefaultOptions
    elseif oriData.indexKey == "SpecialShapedAdaption" then
      return oriData.DefaultOptions
    elseif oriData.indexKey == "OperationIndex" then
      return oriData.DefaultOptions
    end
  end
end
function SettingSaveDataProxy:GetChangedDataForServer(saveTbl)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local setting_list = {}
  for indexKey, v in pairs(saveTbl) do
    local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    local valid = true
    if oriData and oriData.UiType == ItemType.OperateItem and SettingInputUtilProxy:CheckInputChordValueValid(v) == false then
      valid = false
    end
    if valid then
      setting_list[#setting_list + 1] = {key = saveKey, value = v}
    end
  end
  return setting_list
end
function SettingSaveDataProxy:ClearTemplateData()
  self.templateSaveData = {}
end
function SettingSaveDataProxy:CheckTemplateDataChanged()
  for k, v in pairs(self.templateSaveData) do
    if v ~= self.currentSaveData[k] then
      return true
    end
  end
  return false
end
function SettingSaveDataProxy:CheckCurrentIsDefaultByPanelStr(panelStr)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for indexKey, v in pairs(self.defaultSaveData) do
    if SettingConfigProxy:CheckCurIndexKeyIsCurPanel(indexKey, panelStr) then
      if self.templateSaveData[indexKey] then
        if v ~= self.templateSaveData[indexKey] then
          return false
        end
      elseif v ~= self.currentSaveData[indexKey] then
        return false
      end
    end
  end
  return true
end
function SettingSaveDataProxy:UpdateTemplateData(oriData, value)
  if self.currentSaveData[oriData.indexKey] == value then
    self.templateSaveData[oriData.indexKey] = nil
  else
    self.templateSaveData[oriData.indexKey] = value
  end
end
function SettingSaveDataProxy:ApplyTemplateDataToDefaultDataByPanelStr(panelStr)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for indexKey, value in pairs(self.defaultSaveData) do
    if SettingConfigProxy:CheckCurIndexKeyIsCurPanel(indexKey, panelStr) then
      if self.currentSaveData[indexKey] ~= value then
        self.templateSaveData[indexKey] = value
      else
        self.templateSaveData[indexKey] = nil
      end
    end
  end
end
function SettingSaveDataProxy:ApplyTemplateDataChanged()
  LogInfo("SettingSaveDataProxy", "ApplyTemplateDataChanged")
  table.print(self.templateSaveData)
  local setting_list = self:GetChangedDataForServer(self.templateSaveData)
  local SettingNetProxy = GameFacade:RetrieveProxy(ProxyNames.SettingNetProxy)
  SettingNetProxy:ReqUpdateSetting(setting_list)
  local keylist = {}
  local valuelist = {}
  if self.templateSaveData.Switch_PrivacyProtect then
    keylist[#keylist + 1] = Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_SECRET
    valuelist[#valuelist + 1] = self.templateSaveData.Switch_PrivacyProtect
  end
  if self.templateSaveData.Switch_FriendApplyProtect then
    keylist[#keylist + 1] = Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_FRIEND_APPLY
    valuelist[#valuelist + 1] = self.templateSaveData.Switch_FriendApplyProtect
  end
  if self.templateSaveData.Switch_AreaPrivacy then
    keylist[#keylist + 1] = Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_HIDE_LOCA
    valuelist[#valuelist + 1] = self.templateSaveData.Switch_AreaPrivacy
  end
  if #keylist > 0 then
    SettingNetProxy:ReqSetPlayerSetting(keylist, valuelist)
  end
  self:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  SettingSaveGameProxy:WriteData(setting_list)
  local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "SettingApply")
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingChangeCompleteNtf)
end
function SettingSaveDataProxy:RevokeCurrentData()
  local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for indexKey, value in pairs(self.currentSaveData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    if oriData and SettingHelper.IsVolume(oriData) and self.templateSaveData[indexKey] ~= nil then
      SettingProxy:SetVolume(oriData, math.floor(value / SettingEnum.Multipler))
    end
  end
end
function SettingSaveDataProxy:GetCurrentValueByKey(indexKey)
  local value = self.currentSaveData[indexKey] or self.defaultSaveData[indexKey]
  return value
end
function SettingSaveDataProxy:GetTemplateValueByKey(indexKey)
  local value = self.templateSaveData[indexKey] or self:GetCurrentValueByKey(indexKey)
  return value
end
function SettingSaveDataProxy:GetDefaultValueByKey(indexKey)
  return self.defaultSaveData[indexKey]
end
function SettingSaveDataProxy:GetDefaultData()
  return self.defaultSaveData
end
function SettingSaveDataProxy:GetCurrentSaveData()
  return self.currentSaveData
end
function SettingSaveDataProxy:GetTemplateData()
  return self.templateSaveData
end
local bInit = false
function SettingSaveDataProxy:InitApplyDefaultDataOnce(bFirstLogin)
  if true == bInit then
    return
  end
  bInit = false
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
  local setting_list = {}
  for indexKey, v in pairs(self.defaultSaveData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    if true == SettingHelper.CheckApplyDefaultStatus(oriData.status) then
      if bFirstLogin then
        if SettingHelper.IsVisualAttribute(oriData) == false then
          local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
          setting_list[#setting_list + 1] = {key = saveKey, value = v}
        end
      elseif SettingHelper.IsVisualAttribute(oriData) == false and false == SettingHelper.IsVolume(oriData) and oriData.indexKey ~= "CvStyle" then
        local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
        setting_list[#setting_list + 1] = {key = saveKey, value = v}
      end
    end
  end
  self:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
end
return SettingSaveDataProxy
