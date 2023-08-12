local TipoffContentUpdateCmd = class("TipoffContentUpdateCmd", PureMVC.Command)
function TipoffContentUpdateCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.TipoffContentUpdateCmd then
    GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy):UpdateTipDesc(notification:GetBody())
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffPlayerDataChange)
  end
end
return TipoffContentUpdateCmd
