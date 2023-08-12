local TipoffPlayerInitCmd = class("TipoffPlayerInitCmd", PureMVC.Command)
function TipoffPlayerInitCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.TipoffPlayerInitCmd then
    GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy):InitTipoffPlayerData(notification:GetBody())
  end
end
return TipoffPlayerInitCmd
