local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local GlobalSensitivityMultiplerMediator = class("GlobalSensitivityMultiplerMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function GlobalSensitivityMultiplerMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.GlobalSensitivityChangeNtf
  })
end
function GlobalSensitivityMultiplerMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.GlobalSensitivityChangeNtf then
    local receiveOriData = body.oriData
    local resTbl = body.value
    local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
    if receiveOriData.indexKey == "GlobalSensitivity" then
      local oriData = self:GetViewComponent().oriData
      self:RefreshView(resTbl[oriData.indexKey])
    end
  end
end
function GlobalSensitivityMultiplerMediator:RefreshView(senseValue)
  self:GetViewComponent():SetCurrentValue(senseValue)
  self:GetViewComponent():RefreshView()
end
function GlobalSensitivityMultiplerMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
  SettingSensitivityProxy:ChangeGlobalSensivity(oriData.indexKey, view.currentValue)
end
return GlobalSensitivityMultiplerMediator
