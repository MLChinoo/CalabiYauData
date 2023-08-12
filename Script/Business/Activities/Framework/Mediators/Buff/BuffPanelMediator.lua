local BuffPanelMediator = class("BuffPanelMediator", PureMVC.Mediator)
function BuffPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.BuffShowData,
    NotificationDefines.OnNtfCafePrivilegeCfg
  }
end
function BuffPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.BuffShowData then
    if noteBody.data then
      viewComponent:SetData(noteBody.data, noteBody.sourceType)
    end
  elseif noteName == NotificationDefines.OnNtfCafePrivilegeCfg then
    viewComponent:RefreshPrivilegeCfg()
  end
end
return BuffPanelMediator
