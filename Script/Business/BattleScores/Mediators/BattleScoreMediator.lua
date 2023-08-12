local BattleScoreMediator = class("BattleScoreMediator", PureMVC.Mediator)
function BattleScoreMediator:OnRegister()
  LogDebug("BattleScoreMediator", "OnRegister")
  BattleScoreMediator.super.OnRegister(self)
end
function BattleScoreMediator:OnRemove()
  LogDebug("BattleScoreMediator", "OnRemove")
  BattleScoreMediator.super.OnRemove(self)
end
return BattleScoreMediator
