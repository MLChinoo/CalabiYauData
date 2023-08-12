local BattlePassTaskUpdateCmd = class("BattlePassTaskUpdateCmd", PureMVC.Command)
function BattlePassTaskUpdateCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.BattlePass.TaskUpdateCmd then
    GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):UpdateTask()
  end
end
return BattlePassTaskUpdateCmd
