local GetCardTypeDataCmd = class("GetCardTypeDataCmd", PureMVC.Command)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
function GetCardTypeDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeDataCmd then
    local cardTypeData = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardMap()[notification:GetBody()]
    local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
    local cardTypeInfo = {}
    cardTypeInfo.cardIdUsed = cardTypeData.defaultCardId
    if notification:GetBody() == businessCardEnum.cardType.avatar and 0 ~= playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID) then
      cardTypeInfo.cardIdUsed = tonumber(playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID))
    end
    if notification:GetBody() == businessCardEnum.cardType.frame and 0 ~= playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId) then
      cardTypeInfo.cardIdUsed = tonumber(playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId))
    end
    if notification:GetBody() == businessCardEnum.cardType.achieve then
      local cardIdUsed = tonumber(playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAchieId))
      local achieveBaseId, level = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchieveLevel(cardIdUsed)
      local achieveCardShowId = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GroupLvToAchievementId(achieveBaseId, level)
      cardTypeInfo.cardIdUsed = achieveCardShowId or cardIdUsed
    end
    local cardToShow = {}
    for key, value in pairs(cardTypeData.cardList) do
      if value.hasLevel then
        local cardLevel = self:GetCardLevel(key)
        if cardLevel then
          if cardLevel > 0 and cardLevel == value.level then
            local info = table.clone(value)
            info.hasGained = true
            cardToShow[key] = info
          end
          if 0 == cardLevel and 1 == value.level then
            cardToShow[key] = value
          end
        else
          cardToShow[key] = value
        end
      else
        cardToShow[key] = value
      end
    end
    local itemsData = {}
    local itemIndex = 1
    for key, value in pairsByKeys(cardToShow, function(a, b)
      if cardToShow[a].hasGained ~= cardToShow[b].hasGained then
        return cardToShow[a].hasGained
      else
        return a < b
      end
    end) do
      local item = {}
      item.ItemIndex = itemIndex
      item.InItemID = key
      item.softTexture = value.config.IconItem
      item.bEquip = key == cardTypeInfo.cardIdUsed
      item.bUnlock = value.hasGained
      item.quality = value.config.Quality
      if self:IsShow(value.config, item.bUnlock) then
        itemsData[itemIndex] = item
        itemIndex = itemIndex + 1
      end
    end
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_VCARD)
    local businessCardProxy = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy)
    local achievementProxy = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy)
    if redDotList then
      for key, value in pairs(redDotList) do
        local itemId = 0 ~= value.event_id and value.event_id or value.reddot_rid
        if businessCardProxy:GetCardType(itemId) == notification:GetBody() then
          for k, v in pairs(itemsData) do
            local cardIdForReddot = v.InItemID
            if notification:GetBody() == businessCardEnum.cardType.achieve then
              local cardBaseId, _ = achievementProxy:GetAchieveLevel(cardIdForReddot)
              if cardBaseId then
                cardIdForReddot = cardBaseId
              end
            end
            if cardIdForReddot == itemId and value.mark then
              v.redDotID = key
            end
          end
        end
      end
    end
    cardTypeInfo.itemsData = itemsData
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeData, cardTypeInfo, notification:GetBody())
  end
end
function GetCardTypeDataCmd:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
function GetCardTypeDataCmd:GetCardLevel(achieveId)
  local achieveProxy = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy)
  if achieveProxy then
    local _, achieveLevel = achieveProxy:GetAchieveLevel(achieveId)
    return achieveLevel
  end
  return nil
end
return GetCardTypeDataCmd
