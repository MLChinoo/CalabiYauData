local SettingDragItemMediator = class("SettingDragItemMediator", PureMVC.Mediator)
function SettingDragItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.MBResetLayout
  }
end
function SettingDragItemMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if self:GetViewComponent().indexName == nil then
    return
  end
  if name == NotificationDefines.Setting.MBResetLayout then
    if nil == body then
      self:GetViewComponent():Reset()
    elseif body and body.indexName == self:GetViewComponent().indexName then
      self:GetViewComponent():Reset(true)
    end
  elseif name == NotificationDefines.Setting.MBSaveLayout then
  end
end
function SettingDragItemMediator:OnRegister()
  self.super:OnRegister()
end
function SettingDragItemMediator:OnRemove()
  self.super:OnRemove()
end
return SettingDragItemMediator
