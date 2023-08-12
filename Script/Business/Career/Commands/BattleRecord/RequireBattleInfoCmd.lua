local RequireBattleInfoCmd = class("RequireBattleInfoCmd", PureMVC.Command)
function RequireBattleInfoCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.BattleRecord.RequireBattleInfoCmd then
    GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):ReqBattleInfo(notification:GetBody())
  end
end
return RequireBattleInfoCmd
