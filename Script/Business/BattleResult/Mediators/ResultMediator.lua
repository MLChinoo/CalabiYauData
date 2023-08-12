local ResultMediator = class("ResultMediator", PureMVC.Mediator)
function ResultMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultReviceData,
    NotificationDefines.LevelUpGrade.LevelUpPageOpen,
    NotificationDefines.LevelUpGrade.LevelUpPageClose
  }
end
function ResultMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultReviceData then
    self.viewComponent:UpdatePanelType()
  elseif name == NotificationDefines.LevelUpGrade.LevelUpPageOpen then
  end
end
function ResultMediator:OnRegister()
  LogDebug("ResultMediator", "OnRegister")
  ResultMediator.super.OnRegister(self)
end
function ResultMediator:OnRemove()
  LogDebug("ResultMediator", "OnRemove")
  ResultMediator.super.OnRemove(self)
end
return ResultMediator
