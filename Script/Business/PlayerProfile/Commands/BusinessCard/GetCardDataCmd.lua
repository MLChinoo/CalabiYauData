local GetCardDataCmd = class("GetCardDataCmd", PureMVC.Command)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
function GetCardDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.GetCardDataCmd then
    local cardId = notification:GetBody()
    local cardMap = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardMap()
    local cardInfo = cardMap[notification:GetType()].cardList[cardId]
    local cardInfoShown = {}
    if nil ~= cardInfo then
      cardInfoShown.cardId = cardId
      cardInfoShown.obtainTime = cardInfo.obtainTime
      cardInfoShown.expireTime = cardInfo.expireTime
      cardInfoShown.unlocked = cardInfo.hasGained
      if notification:GetType() == businessCardEnum.cardType.achieve then
        local achieveBaseId, _ = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchieveLevel(cardId)
        if achieveBaseId then
          cardInfoShown.unlocked = cardMap[notification:GetType()].cardList[achieveBaseId].hasGained
        end
      end
      local cardUnlockInfo = {}
      cardInfoShown.name = cardInfo.config.Name
      cardInfoShown.icon = cardInfo.config.IconIdcardL
      cardInfoShown.desc = cardInfo.config.Desc
      cardInfoShown.qualityID = cardInfo.config.Quality
      cardUnlockInfo.itemType = UE4.EItemIdIntervalType.VCardAvatar
      cardUnlockInfo.config = cardInfo.config
      if not cardInfoShown.unlocked then
        GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, cardUnlockInfo)
      end
    end
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardData, cardInfoShown, notification:GetType())
  end
end
return GetCardDataCmd
