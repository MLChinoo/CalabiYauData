local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local ResolutionMediator = class("ResolutionMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function ResolutionMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingScreenModeNtf,
    NotificationDefines.Setting.SettingRefreshResolution
  })
end
local checkWindowedFullscreen = function(value)
  return value == SettingEnum.WindowType.ShowFullScreen
end
local checkWindowed = function(value)
  return value == SettingEnum.WindowType.ShowWindowed
end
function ResolutionMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  local view = self:GetViewComponent()
  if name == NotificationDefines.Setting.SettingScreenModeNtf then
    local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
    if #view.displayTextArr == SettingVisualProxy:GetCustomResolutionIndex() then
      view:DoSelectShowCurrentValue(#view.displayTextArr - 1)
    end
  elseif name == NotificationDefines.Setting.SettingRefreshResolution then
    view:InitView(view.oriData)
  end
end
function ResolutionMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  if #view.displayTextArr == SettingVisualProxy:GetCustomResolutionIndex() then
    SettingVisualProxy:ReloadCfgData()
    view:InitView(view.oriData)
  end
end
return ResolutionMediator
