local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local MBResolutionMediator = class("MBResolutionMediator", SuperClass)
function MBResolutionMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.PerformanceModeChangedNtf
  })
end
function MBResolutionMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.PerformanceModeChangedNtf then
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local value = SettingSaveDataProxy:GetTemplateValueByKey("MBPerformanceMode")
    local myValue = SettingSaveDataProxy:GetTemplateValueByKey("MBResolution")
    local count = #self:GetViewComponent().displayTextArr
    if value == SettingEnum.PerformaceMode.Normal then
    elseif value == SettingEnum.PerformaceMode.FrameRate then
      if 2 ~= myValue then
        self:GetViewComponent():DoSelectCurrentValue(2, true)
      end
    elseif value == SettingEnum.PerformaceMode.Efficient and 1 ~= myValue then
      self:GetViewComponent():DoSelectCurrentValue(1, true)
    end
  end
end
function MBResolutionMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
end
function MBResolutionMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self, function()
    GameFacade:SendNotification(NotificationDefines.Setting.MBResolutionChangedNtf)
  end)
end
function MBResolutionMediator:RefreshView(selectIndex)
end
return MBResolutionMediator
