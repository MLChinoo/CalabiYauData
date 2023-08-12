local BattleResultRewardMediator = class("BattleResultRewardMediator", PureMVC.Mediator)
function BattleResultRewardMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultReviceData
  }
end
function BattleResultRewardMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("BattleResultRewardMediator", "HandleNotification")
  if name == NotificationDefines.BattleResult.BattleResultReviceData then
    self:GetViewComponent():UpdateRewardList()
    self:GetViewComponent():UpdateAchievementList()
  end
end
function BattleResultRewardMediator:OnRegister()
  LogDebug("BattleResultRewardMediator", "OnRegister")
  BattleResultRewardMediator.super.OnRegister(self)
end
function BattleResultRewardMediator:OnRemove()
  LogDebug("BattleResultRewardMediator", "OnRemove")
  BattleResultRewardMediator.super.OnRemove(self)
end
return BattleResultRewardMediator
