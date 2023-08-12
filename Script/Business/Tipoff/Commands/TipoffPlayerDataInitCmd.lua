local TipoffPlayerDataInitCmd = class("TipoffPlayerDataInitCmd", PureMVC.Command)
function TipoffPlayerDataInitCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.TipoffPlayerDataInitCmd then
    GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy):InitTipoffPlayerData(notification:GetBody())
  end
end
return TipoffPlayerDataInitCmd
