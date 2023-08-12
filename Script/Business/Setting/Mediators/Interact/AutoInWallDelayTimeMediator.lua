local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local AutoInWallDelayTimeMediator = class("AutoInWallDelayTimeMediator", SuperClass)
function AutoInWallDelayTimeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SmartInWallChangeNtf
  })
end
function AutoInWallDelayTimeMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SmartInWallChangeNtf then
    local value = body.value
    self:UpdateView(value)
  end
end
function AutoInWallDelayTimeMediator:UpdateView(level)
  local bShow = level == UE4.ESmartAutoInWall.TopWall + 1
  if bShow then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function AutoInWallDelayTimeMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("SmartAutoInWall")
  self:UpdateView(value)
end
return AutoInWallDelayTimeMediator
