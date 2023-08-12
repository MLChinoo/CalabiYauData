local RankPrepareCardPanelMediator = require("Business/Room/Mediators/RankRoom/RankPrepareCardPanelMediator")
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local cardDataProxy
local RankPrepareCardPanel = class("RankPrepareCardPanel", PureMVC.ViewComponentPanel)
function RankPrepareCardPanel:ListNeededMediators()
  return {RankPrepareCardPanelMediator}
end
function RankPrepareCardPanel:InitializeLuaEvent()
end
function RankPrepareCardPanel:Construct()
  RankPrepareCardPanel.super.Construct(self)
  cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  self.confirmStatus = false
end
function RankPrepareCardPanel:SetPlayerData(matchPlayerInfo)
  if matchPlayerInfo and matchPlayerInfo.playerId then
    self.cachedPlayerID = matchPlayerInfo.playerId
  end
  if cardDataProxy then
    local avatarId = matchPlayerInfo.avatarId
    if matchPlayerInfo.avatarId and 0 == matchPlayerInfo.avatarId then
      avatarId = cardDataProxy:GetDefaultAvatarId()
    end
    if self.CardBack then
      self.CardBack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local frameId = matchPlayerInfo.frameId
      if matchPlayerInfo.frameId and 0 == matchPlayerInfo.frameId then
        frameId = cardDataProxy:GetDefaultFrameId()
      end
      local cardInfo = {}
      cardInfo.cardId = {}
      cardInfo.cardId[businessCardEnum.cardType.avatar] = avatarId
      cardInfo.cardId[businessCardEnum.cardType.frame] = frameId
      cardInfo.stars = matchPlayerInfo.stars
      self.CardBack:InitView(cardInfo, false)
    end
  end
end
function RankPrepareCardPanel:PlayStartAnimation()
end
function RankPrepareCardPanel:GetPlayerID()
  return self.cachedPlayerID
end
function RankPrepareCardPanel:UpdatePrepareState(bConfirm)
  if bConfirm then
    self.CanvasPanel_Confirm:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CardBack:SetRenderOpacity(1)
  end
end
function RankPrepareCardPanel:GetConfirmStatus()
  return self.confirmStatus
end
function RankPrepareCardPanel:PlayCardRevealAnimation()
end
return RankPrepareCardPanel
