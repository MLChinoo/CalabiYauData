local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local ScreenModeMediator = class("ScreenModeMediator", SuperClass)
function ScreenModeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingRefreshResolution
  })
end
function ScreenModeMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingRefreshResolution then
    local view = self:GetViewComponent()
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    local value = SettingSaveDataProxy:GetTemplateValueByKey("ScreenMode")
    view:DoSelectCurrentValue(value, true)
  end
end
function ScreenModeMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SettingScreenModeNtf, {
    oriData = oriData,
    value = view.currentValue
  })
end
return ScreenModeMediator
