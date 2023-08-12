local BattlePassTaskChangeCmd = class("BattlePassTaskChangeCmd", PureMVC.Command)
function BattlePassTaskChangeCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.BattlePass.TaskChangeCmd then
    GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):ReqTaskChange(notification:GetBody())
  end
end
return BattlePassTaskChangeCmd
