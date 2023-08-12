local SettingOperationMainPageMediator = class("SettingOperationMainPageMediator", PureMVC.Mediator)
function SettingOperationMainPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.MBSetDragIndex,
    NotificationDefines.Setting.CustomLayoutChangeNtf
  }
end
function SettingOperationMainPageMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.MBSetDragIndex then
    self:GetViewComponent():SetDragItemByDragIndex(body.indexName)
  elseif name == NotificationDefines.Setting.CustomLayoutChangeNtf then
    self:GetViewComponent():SetLayout(body.pageIndex)
  end
end
function SettingOperationMainPageMediator:OnRegister()
  self.super:OnRegister()
end
function SettingOperationMainPageMediator:OnRemove()
  self.super:OnRemove()
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  SettingOperationProxy:ExitPage()
end
return SettingOperationMainPageMediator
