local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local MBPerformanceModeMediator = class("MBPerformanceModeMediator", SuperClass)
function MBPerformanceModeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingVisualGraphicsChangedNtf,
    NotificationDefines.Setting.FrameRateChangedNtf,
    NotificationDefines.Setting.MBResolutionChangedNtf
  })
end
function MBPerformanceModeMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingVisualGraphicsChangedNtf or name == NotificationDefines.Setting.FrameRateChangedNtf or name == NotificationDefines.Setting.MBResolutionChangedNtf then
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local GraphicsValue = SettingSaveDataProxy:GetTemplateValueByKey("Graphics")
    local FrameRateValue = SettingSaveDataProxy:GetTemplateValueByKey("FrameRate")
    local MBResolutionValue = SettingSaveDataProxy:GetTemplateValueByKey("MBResolution")
    local targetValue = SettingEnum.PerformaceMode.Normal
    local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
    if 1 == GraphicsValue then
      if 1 == MBResolutionValue and 1 == FrameRateValue then
        targetValue = SettingEnum.PerformaceMode.Efficient
      end
      if 2 == MBResolutionValue and FrameRateValue == SettingVisualProxy:GetMaxFrameRateIndex() then
        targetValue = SettingEnum.PerformaceMode.FrameRate
      end
    end
    local value = SettingSaveDataProxy:GetTemplateValueByKey("MBPerformanceMode")
    if value ~= targetValue then
      self:GetViewComponent():DoSelectCurrentValue(targetValue, true)
    end
  end
end
function MBPerformanceModeMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
end
function MBPerformanceModeMediator:ChangeValueEvent()
  local view = self:GetViewComponent()
  local oriData = view.oriData
  SuperClass.ChangeValueEvent(self, function()
    GameFacade:SendNotification(NotificationDefines.Setting.PerformanceModeChangedNtf)
  end)
end
function MBPerformanceModeMediator:RefreshView(selectIndex)
end
return MBPerformanceModeMediator
