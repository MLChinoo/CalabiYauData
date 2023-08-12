local BattleResultVictoryDefeatMediator = class("BattleResultVictoryDefeatMediator", PureMVC.Mediator)
function BattleResultVictoryDefeatMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultReviceData
  }
end
function BattleResultVictoryDefeatMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("BattleResultVictoryDefeatMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultReviceData then
    self.viewComponent:OnRecvMatchEndData()
  end
end
function BattleResultVictoryDefeatMediator:OnRegister()
  LogDebug("BattleResultVictoryDefeatMediator", "OnRegister")
  BattleResultVictoryDefeatMediator.super.OnRegister(self)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  if BattleResultProxy.settle_battle_game_ntf then
    self.viewComponent:OnRecvMatchEndData()
  end
end
return BattleResultVictoryDefeatMediator
