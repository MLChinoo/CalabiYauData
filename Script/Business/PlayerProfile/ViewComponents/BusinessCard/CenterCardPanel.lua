local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local CenterCardPanel = class("CenterCardPanel", PureMVC.ViewComponentPanel)
function CenterCardPanel:ListNeededMediators()
  return {}
end
function CenterCardPanel:Construct()
  CenterCardPanel.super.Construct(self)
  self.hasHidden = true
end
function CenterCardPanel:InitView(cardInfo, isRoomOwner)
  local cardInfoShown = {}
  cardInfoShown.playerAttr = cardInfo.playerAttr
  cardInfoShown.cardChanged = {}
  for key, value in pairs(cardInfo.cardId) do
    cardInfoShown.cardChanged[key] = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardConfig(key, value)
  end
  if cardInfo.cardId[businessCardEnum.cardType.achieve] == nil then
    cardInfoShown.cardChanged[businessCardEnum.cardType.achieve] = 0
  end
  cardInfoShown.stars = cardInfo.stars
  self:UpdateCard(cardInfoShown, isRoomOwner)
end
function CenterCardPanel:UpdateCard(cardInfoShown, isRoomOwner)
  if self.TextBlock_NickName and cardInfoShown.playerAttr and cardInfoShown.playerAttr.nickName then
    self.TextBlock_NickName:SetText(cardInfoShown.playerAttr.nickName)
  else
    self.TextBlock_NickName:SetText("")
    self.Image_box_name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.TextBlock_Level and cardInfoShown.playerAttr and cardInfoShown.playerAttr.level then
    self.TextBlock_Level:SetText(cardInfoShown.playerAttr.level)
  else
    self.TextBlock_Level:SetText("")
  end
  if isRoomOwner then
    if self.TextBlock_NickName then
      ObjectUtil:SetTextColor(self.TextBlock_NickName, 1, 0.63, 0.05)
    end
  elseif self.TextBlock_NickName then
    ObjectUtil:SetTextColor(self.TextBlock_NickName, 0.723055, 0.723055, 0.723055)
  end
  if self.CardBG then
    for key, value in pairs(cardInfoShown.cardChanged) do
      if key ~= businessCardEnum.cardType.achieve then
        self.CardBG:ChangeCardAppearance(key, value)
      elseif self.AchievementIcon then
        if 0 == value then
          self.AchievementIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        else
          local achieveBaseId, level = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchieveLevel(value.Id)
          local achieveCardShowId = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GroupLvToAchievementId(achieveBaseId, level)
          self.AchievementIcon:InitView(achieveCardShowId or value.Id)
          self.AchievementIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
  if self.Image_Division and self.Image_DivisionLevel and cardInfoShown.stars then
    local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(cardInfoShown.stars)
    self:SetImageByPaperSprite(self.Image_Division, divisionCfg.IconDivisionS)
    local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(divisionCfg.IconDivisionLevelS)
    if "" ~= pathString then
      self:SetImageByPaperSprite(self.Image_DivisionLevel, divisionCfg.IconDivisionLevelS)
      self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self:ShowRankDivision(false)
  end
  local playerLevel = cardInfoShown.playerAttr.level
  local levelBoxPerPhase = self.bp_levelBoxPerPhase
  local arrRows = ConfigMgr:GetPlayerLevelTableRows()
  if arrRows then
    local levelBoxMaxLevelForPlayer = 1
    playerLevelCfg = arrRows:ToLuaTable()
    if playerLevel > levelBoxPerPhase then
      levelBoxMaxLevelForPlayer = playerLevel - playerLevel % levelBoxPerPhase
    elseif playerLevel == levelBoxPerPhase then
      levelBoxMaxLevelForPlayer = levelBoxPerPhase
    end
    if levelBoxMaxLevelForPlayer > 0 and playerLevelCfg[tostring(levelBoxMaxLevelForPlayer)] then
      if self.Image_box_name then
        self:SetImageByPaperSprite(self.Image_box_name, playerLevelCfg[tostring(levelBoxMaxLevelForPlayer)].Levelbox)
      end
    else
      LogInfo("CenterCardPanel UpdateCard", "levelBoxMaxLevelForPlayer:" .. tostring(levelBoxMaxLevelForPlayer))
    end
  else
    LogInfo("CenterCardPanel UpdateCard", "arrRows is nil")
  end
end
function CenterCardPanel:SetBaseCardPrepareOpacity(value)
  if self.CardBG then
    self.CardBG:SetOpacityNotPrepare(value)
  end
end
function CenterCardPanel:SetBaseCardPrepareOffset(value)
  if self.CardBG then
  end
end
function CenterCardPanel:ShowRankDivision(shouldShow)
  if self.BadgeShowUp then
    if shouldShow then
      self:PlayAnimationForward(self.BadgeShowUp)
      self.hasHidden = false
    elseif self.hasHidden == false then
      self:PlayAnimationReverse(self.BadgeShowUp)
      self.hasHidden = true
    end
  end
end
function CenterCardPanel:InitializeLuaEvent()
  LogDebug("CenterCardPanel", "Init lua event")
end
return CenterCardPanel
