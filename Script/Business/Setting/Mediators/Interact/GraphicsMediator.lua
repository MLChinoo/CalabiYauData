local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local GraphicsMediator = class("GraphicsMediator", SuperClass)
function GraphicsMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingScalabilityChangedNtf,
    NotificationDefines.Setting.PerformanceModeChangedNtf
  })
end
function GraphicsMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingScalabilityChangedNtf then
    local receiveOriData = body.oriData
    local value = body.value
    local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local GraphicsQualityArr = SettingVisualProxy:GetGraphicsQualityArr()
    local level = -1
    for i, QualityMap in ipairs(GraphicsQualityArr) do
      local bFlag = true
      for indexKey, v in pairs(QualityMap) do
        if v ~= SettingSaveDataProxy:GetTemplateValueByKey(indexKey) then
          bFlag = false
          break
        end
      end
      if bFlag then
        level = i
        break
      end
    end
    if -1 == level then
      self:RefreshView(6)
    else
      self:RefreshView(level)
    end
    SuperClass.ChangeValueEvent(self)
  elseif name == NotificationDefines.Setting.PerformanceModeChangedNtf then
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local value = SettingSaveDataProxy:GetTemplateValueByKey("MBPerformanceMode")
    local myValue = SettingSaveDataProxy:GetTemplateValueByKey("Graphics")
    local count = #self:GetViewComponent().displayTextArr
    if (value == SettingEnum.PerformaceMode.FrameRate or value == SettingEnum.PerformaceMode.Efficient) and 1 ~= myValue then
      self:GetViewComponent():DoSelectCurrentValue(1, true)
    end
  end
end
function GraphicsMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  local view = self:GetViewComponent()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local oriData = view.oriData
  local value = SettingSaveDataProxy:GetTemplateValueByKey(oriData.Indexkey)
  self.textArrWithCustom = view.displayTextArr
  self.sequenceArrWithCustom = table.clone(view.sequenceArr)
  self.reSequenceArrWithCustom = table.clone(view.reSequenceArr)
  self.textArr = table.clone(view.displayTextArr)
  self.textArr[#self.textArr] = nil
  self.sequenceArr = table.clone(view.sequenceArr)
  self.sequenceArr[#self.sequenceArr] = nil
  self.reSequenceArr = table.clone(view.reSequenceArr)
  self.reSequenceArr[#self.reSequenceArr] = nil
  self:RefreshView(view.reSequenceArr[value])
end
function GraphicsMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
  local QualityMap = SettingHelper.GetGraphicQualityMap()
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  local GraphicsQualityArr = SettingVisualProxy:GetGraphicsQualityArr()
  local QualityArr = GraphicsQualityArr[view.currentValue]
  if QualityArr then
    for indexKey, _ in pairs(QualityMap) do
      local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
      local InOriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
      if InOriData then
        local selectValue = QualityArr[indexKey]
        settingSaveDataProxy:UpdateTemplateData(InOriData, selectValue)
      end
    end
  end
  GameFacade:SendNotification(NotificationDefines.Setting.SettingVisualGraphicsChangedNtf, {
    oriData = oriData,
    value = view.currentValue
  })
  if #view.displayTextArr == SettingEnum.GraphicCustomIndex then
    self:RefreshView(view.showCurrentValue)
  end
end
function GraphicsMediator:RefreshView(selectIndex)
  local showArr = self.textArr
  local view = self:GetViewComponent()
  view.sequenceArr = self.sequenceArr
  view.reSequenceArr = self.reSequenceArr
  if selectIndex > #showArr then
    showArr = self.textArrWithCustom
    view.sequenceArr = self.sequenceArrWithCustom
    view.reSequenceArr = self.reSequenceArrWithCustom
  end
  view:ReloadDisplayText(showArr, selectIndex, true)
end
return GraphicsMediator
