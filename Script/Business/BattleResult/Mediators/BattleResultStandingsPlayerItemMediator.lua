local BattleResultStandingsPlayerItemMediator = class("BattleResultStandingsPlayerItemMediator", PureMVC.Mediator)
function BattleResultStandingsPlayerItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultLikeNtf,
    NotificationDefines.TipoffPlayer.TipoffPlayerDataChange
  }
end
function BattleResultStandingsPlayerItemMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.BattleResult.BattleResultLikeNtf then
    self.viewComponent:OnStandingsLikeNtf(body)
  elseif name == NotificationDefines.TipoffPlayer.TipoffPlayerDataChange then
    self.viewComponent:OnRefreshTipoff()
  end
end
function BattleResultStandingsPlayerItemMediator:OnRegister()
  BattleResultStandingsPlayerItemMediator.super.OnRegister(self)
end
function BattleResultStandingsPlayerItemMediator:OnRemove()
  BattleResultStandingsPlayerItemMediator.super.OnRemove(self)
end
return BattleResultStandingsPlayerItemMediator
