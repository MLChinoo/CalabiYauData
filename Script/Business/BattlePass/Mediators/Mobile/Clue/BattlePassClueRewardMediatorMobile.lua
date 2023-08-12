local BattlePassClueRewardMediatorMobile = class("BattlePassClueRewardMediatorMobile", PureMVC.Mediator)
function BattlePassClueRewardMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.ClueRewardUpdate
  }
end
function BattlePassClueRewardMediatorMobile:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.BattlePass.ClueRewardUpdate then
    local clueId = notification:GetBody()
    self:GetViewComponent():UpdateRewardState(clueId)
  end
end
return BattlePassClueRewardMediatorMobile
