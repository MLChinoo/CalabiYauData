local RankPrepareCardPanelMediator = require("Business/Room/Mediators/RankRoom/RankPrepareCardPanelMediator")
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
  local randomNum = math.random(0, 5)
  self.WS_CardLink:SetActiveWidgetIndex(randomNum)
  if cardDataProxy then
    local avatarId = matchPlayerInfo.avatarId
    if matchPlayerInfo.avatarId and 0 == matchPlayerInfo.avatarId then
      avatarId = cardDataProxy:GetDefaultAvatarId()
    end
    if self.CardPattern and avatarId then
      local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
      local avatarIdTableRow = cardDataProxy:GetCardResourceTableFromId(avatarId)
      self:SetImageByTexture2D(self.CardPattern, avatarIdTableRow.IconIdcardL)
    end
  end
end
function RankPrepareCardPanel:PlayStartAnimation()
  self:PlayAnimation(self.DiveIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RankPrepareCardPanel:GetPlayerID()
  return self.cachedPlayerID
end
function RankPrepareCardPanel:UpdatePrepareState(bConfirm)
  if bConfirm then
    self.confirmStatus = true
    self:PlayAnimation(self.Connected, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    self.confirmStatus = false
  end
end
function RankPrepareCardPanel:GetConfirmStatus()
  return self.confirmStatus
end
function RankPrepareCardPanel:PlayCardRevealAnimation()
  self:PlayAnimation(self.Reveal, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
return RankPrepareCardPanel
