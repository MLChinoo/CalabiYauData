local ReqTipoffPlayerInfoCmd = class("ReqTipoffPlayerInfoCmd", PureMVC.Command)
function ReqTipoffPlayerInfoCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.ReqTipoffPlayerInfoCmd then
    local Proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerNetProxy)
    if Proxy then
      Proxy:OnNetTipoffReq()
    end
  end
end
return ReqTipoffPlayerInfoCmd
