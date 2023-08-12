local ChangeBCStyleCmd = class("ChangeBCStyleCmd", PureMVC.Command)
function ChangeBCStyleCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyleCmd then
    local cardMap = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardMap()
    local cardIdSelected = notification:GetBody()
    for key, value in pairs(cardIdSelected) do
      if 0 ~= value and not cardMap[key].cardList[value].hasGained then
        local rebackMsg = {}
        rebackMsg.code = 2
        rebackMsg.errorId = 8301
        GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle, rebackMsg)
        return
      end
    end
    GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):ReqUpdateCard(cardIdSelected)
  end
end
return ChangeBCStyleCmd
