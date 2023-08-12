local GameKeyTipsForNewerMediator = class("GameKeyTipsForNewerMediator", PureMVC.Mediator)
function GameKeyTipsForNewerMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingChangeCompleteNtf
  }
end
function GameKeyTipsForNewerMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.Setting.SettingChangeCompleteNtf then
    self:GetViewComponent():UpdateKey()
  end
end
return GameKeyTipsForNewerMediator
