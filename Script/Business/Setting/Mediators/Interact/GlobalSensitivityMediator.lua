local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local GlobalSensitivityMediator = class("GlobalSensitivityMediator", SuperClass)
function GlobalSensitivityMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.MBSensitivityChangeNtf
  })
end
function GlobalSensitivityMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.MBSensitivityChangeNtf then
    local value = body.value
    self:UpdateView(value)
  end
end
function GlobalSensitivityMediator:UpdateView(level)
  self:GetViewComponent():SetCurrentValue(level)
  self:GetViewComponent():RefreshView()
end
function GlobalSensitivityMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  self:UpdateSenseValue(view.currentValue)
end
function GlobalSensitivityMediator:UpdateSenseValue(level)
  local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
  if SettingSensitivityProxy:checkCustomize(level) then
    return
  end
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local resTbl = {}
  for i, indexKey in ipairs(SettingSensitivityProxy.SensitivityCfgArr) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    if oriData then
      local value = SettingSensitivityProxy:GetSenseValueByIndexKeyAndLevel(indexKey, level)
      SettingSaveDataProxy:UpdateTemplateData(oriData, value)
      resTbl[indexKey] = value
    end
  end
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.GlobalSensitivityChangeNtf, {oriData = oriData, value = resTbl})
end
return GlobalSensitivityMediator
