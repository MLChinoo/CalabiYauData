local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingCustomLayoutMap = require("Business/Setting/Proxies/Map/SettingCustomLayoutMap")
local CustomeKeyList = SettingCustomLayoutMap.KeyList
local SettingOperationProxy = class("SettingOperationProxy", PureMVC.Proxy)
function SettingOperationProxy:OnRegister()
  self.super.OnRegister(self)
  self.currentTemplateData = {}
end
function SettingOperationProxy:OnRemove()
  self.super.OnRemove(self)
end
function SettingOperationProxy:OnInit()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  self.currentSaveData = SettingSaveDataProxy:GetCurrentSaveData()
end
function SettingOperationProxy:SaveAllData()
  local diffList = {}
  for indexKey, v in pairs(self.currentTemplateData) do
    self:StoreDataByIndexKey(indexKey, v, diffList)
  end
  if next(diffList) == nil then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "SettingApply")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    return
  end
  local setting_list = {}
  for indexKey, value in pairs(diffList) do
    local saveKey = SettingStoreMap.indexKeyToSaveKey[indexKey]
    setting_list[#setting_list + 1] = {key = saveKey, value = value}
  end
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
  local SettingNetProxy = GameFacade:RetrieveProxy(ProxyNames.SettingNetProxy)
  SettingNetProxy:ReqUpdateSetting(setting_list)
  local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "SettingApply")
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
end
function SettingOperationProxy:NotSaveData()
end
function SettingOperationProxy:CheckTemplateDataChanged()
  for indexKey, v in pairs(self.currentTemplateData) do
    if "MoveLine" == indexKey then
      local keyName = indexKey .. "_" .. self.LayoutIndex
      local num = v.difLength * SettingEnum.Multipler
      if num ~= self.currentSaveData[keyName] then
        return true
      end
    else
      local num1, num2 = self:ZipData(v.difX, v.difY, v.opa, v.scale)
      local keyName1 = self:GetKey(indexKey, self.LayoutIndex, 1)
      local keyName2 = self:GetKey(indexKey, self.LayoutIndex, 2)
      if num1 ~= self.currentSaveData[keyName1] or num2 ~= self.currentSaveData[keyName2] then
        return true
      end
    end
  end
  return false
end
function SettingOperationProxy:GetTemplateData(keyName)
  self.currentTemplateData[keyName] = self.currentTemplateData[keyName] or {}
  return self.currentTemplateData[keyName]
end
function SettingOperationProxy:SetLayoutIndex(index)
  self.LayoutIndex = index
end
function SettingOperationProxy:GetLayoutIndex()
  return self.LayoutIndex
end
function SettingOperationProxy:GetKey(keyName, layoutIndex, index)
  return keyName .. "_" .. tostring(layoutIndex) .. "_" .. index
end
function SettingOperationProxy:StoreDataByIndexKey(indexKey, value, diffList)
  if "MoveLine" == indexKey then
    local newValue = math.floor(value.difLength * SettingEnum.Multipler)
    local keyName = indexKey .. "_" .. self.LayoutIndex
    if self.currentSaveData[keyName] ~= newValue then
      diffList[keyName] = newValue
    end
  else
    local num1, num2 = self:ZipData(value.difX, value.difY, value.opa, value.scale)
    local keyName1 = self:GetKey(indexKey, self.LayoutIndex, 1)
    local keyName2 = self:GetKey(indexKey, self.LayoutIndex, 2)
    if num1 ~= self.currentSaveData[keyName1] or num2 ~= self.currentSaveData[keyName2] then
      diffList[keyName1] = num1
      diffList[keyName2] = num2
    end
  end
end
function SettingOperationProxy:RestoreDataByIndexKey(indexKey, showIndex)
  print("RestoreDataByIndexKey showIndex", showIndex)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  showIndex = showIndex or self.LayoutIndex
  if "MoveLine" == indexKey then
    local keyName = indexKey .. "_" .. showIndex
    self.currentSaveData[keyName] = self.currentSaveData[keyName] or 0
    return self.currentSaveData[keyName] / SettingEnum.Multipler
  else
    local keyName1 = self:GetKey(indexKey, showIndex, 1)
    local keyName2 = self:GetKey(indexKey, showIndex, 2)
    local num1 = self.currentSaveData[keyName1]
    local num2 = self.currentSaveData[keyName2]
    if nil == num1 or nil == num2 then
      local _num1, _num2 = self:ZipData(0, 0, 1, 1)
      if nil == num1 then
        self.currentSaveData[keyName1] = _num1
        num1 = _num1
      end
      if nil == num2 then
        self.currentSaveData[keyName2] = _num2
        num2 = _num2
      end
    end
    return self:UnZipData(num1, num2)
  end
end
local seg = 100000
function SettingOperationProxy:ZipData(difX, difY, opa, scale)
  local num1 = 0
  num1 = num1 + math.floor(math.abs(difX))
  num1 = num1 + math.floor(opa * 100) * seg
  if difX < 0 then
    num1 = -num1
  end
  local num2 = 0
  num2 = num2 + math.floor(math.abs(difY))
  num2 = num2 + math.floor(scale * 100) * seg
  if difY < 0 then
    num2 = -num2
  end
  return num1, num2
end
function SettingOperationProxy:UnZipData(num1, num2)
  local neg1 = num1 < 0 and -1 or 1
  local neg2 = num2 < 0 and -1 or 1
  if num1 < 0 then
    num1 = -num1
  end
  if num2 < 0 then
    num2 = -num2
  end
  local difX = num1 % seg
  local opa = (num1 - difX) / seg / 100
  local difY = num2 % seg
  local scale = (num2 - difY) / seg / 100
  return neg1 * difX, neg2 * difY, opa, scale
end
function SettingOperationProxy:CheckIsCustomOperation(indexKey)
  local attrName, _ = SettingOperationProxy:SolveIndexKey(indexKey)
  if attrName and nil ~= CustomeKeyList[attrName] then
    return true
  end
  return false
end
function SettingOperationProxy:SolveIndexKey(indexKey)
  local res = string.split(indexKey, "_")
  if 2 == #res then
    return res[1], tonumber(res[2])
  elseif 3 == #res then
    return res[1], tonumber(res[2]), tonumber(res[3])
  end
end
function SettingOperationProxy:EnterPage(layoutIndex)
  self.LayoutIndex = layoutIndex
end
function SettingOperationProxy:ExitPage()
  self.LayoutIndex = nil
end
function SettingOperationProxy:GetShowPage(layoutIndex)
end
return SettingOperationProxy
