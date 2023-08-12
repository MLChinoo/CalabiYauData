local BattleResultCommand = class("BattleResultCommand", PureMVC.Command)
function BattleResultCommand:Execute(notification)
  LogDebug("BattleResultCommand", "Execute ")
  if notification:GetName() == NotificationDefines.BattleResult.BattleResultReviceData then
  end
end
return BattleResultCommand
