local UpdateInGameTipoffDataCmd = class("UpdateInGameTipoffDataCmd", PureMVC.Command)
function UpdateInGameTipoffDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.UpdateInGameTipoffDataCmd then
    local proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
    if proxy then
      proxy:UpdateTipoffPlayerData()
    end
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffPlayerDataChange)
  end
end
return UpdateInGameTipoffDataCmd
