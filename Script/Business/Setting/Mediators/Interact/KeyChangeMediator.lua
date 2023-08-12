local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local KeyChangeMediator = class("KeyChangeMediator", SuperClass)
function KeyChangeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingKeyChangeNtf
  })
end
function KeyChangeMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingKeyChangeNtf then
    local receiveOriData = body.oriData
    if receiveOriData.indexKey == self:GetViewComponent().oriData.indexKey then
      self:GetViewComponent():OnlyRefreshView()
    end
  end
end
function KeyChangeMediator:ApplyDefaultConfig()
  SuperClass.ApplyDefaultConfig(self)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  local oriData = self:GetViewComponent().oriData
  local panelStr = SettingManagerProxy:GetCurPanelTypeStr()
  if panelStr and oriData.Type == panelStr then
    local value = SettingSaveDataProxy:GetDefaultValueByKey(oriData.indexKey)
    local keyMapProxy = self:GetViewComponent().keyMapProxy
    keyMapProxy:UpdateSingleKeyMap(oriData, value)
  end
end
function KeyChangeMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
end
return KeyChangeMediator
