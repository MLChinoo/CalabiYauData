local UpdateCenterCardCmd = class("UpdateCenterCardCmd", PureMVC.Command)
function UpdateCenterCardCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCardCmd then
    local cardInfo = notification:GetBody()
    local cardInfoShown = {}
    if notification:GetType() == NotificationDefines.PlayerProfile.DataType.Self then
      cardInfoShown.playerAttr = {}
      cardInfoShown.playerAttr.nickName = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emNick)
      cardInfoShown.playerAttr.sex = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emSex)
      cardInfoShown.playerAttr.level = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
      cardInfoShown.cardId = cardInfo
    else
      cardInfoShown = cardInfo
    end
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCard, cardInfoShown)
  end
end
return UpdateCenterCardCmd
