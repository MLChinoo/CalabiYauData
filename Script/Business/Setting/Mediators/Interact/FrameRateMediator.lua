local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local FrameRateMediator = class("FrameRateMediator", SuperClass)
function FrameRateMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.PerformanceModeChangedNtf
  })
end
function FrameRateMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.PerformanceModeChangedNtf then
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local value = SettingSaveDataProxy:GetTemplateValueByKey("MBPerformanceMode")
    local myValue = SettingSaveDataProxy:GetTemplateValueByKey("FrameRate")
    local count = #self:GetViewComponent().displayTextArr
    if value == SettingEnum.PerformaceMode.Normal then
    elseif value == SettingEnum.PerformaceMode.FrameRate then
      if count ~= myValue then
        self:GetViewComponent():DoSelectCurrentValue(count, true)
      end
    elseif value == SettingEnum.PerformaceMode.Efficient and 1 ~= myValue then
      self:GetViewComponent():DoSelectCurrentValue(1, true)
    end
  end
end
function FrameRateMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self, function()
    GameFacade:SendNotification(NotificationDefines.Setting.FrameRateChangedNtf)
  end)
end
return FrameRateMediator
