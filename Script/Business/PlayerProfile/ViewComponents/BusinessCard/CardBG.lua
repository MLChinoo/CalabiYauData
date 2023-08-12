local CardBG = class("CardBG", PureMVC.ViewComponentPanel)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local cardDataProxy
function CardBG:ListNeededMediators()
  return {}
end
function CardBG:SetPlayerData(avatarId, frameId)
  if cardDataProxy then
    local pAvatarId = avatarId
    if 0 == avatarId then
      pAvatarId = cardDataProxy:GetDefaultAvatarId()
    end
    local avatarIdTableRow = cardDataProxy:GetCardResourceTableFromId(pAvatarId)
    if avatarIdTableRow then
      self:SetCardAvatar(avatarIdTableRow)
    end
    local pFrameId = frameId
    if 0 == frameId then
      pFrameId = cardDataProxy:GetDefaultFrameId()
    end
    local frameIdTableRow = cardDataProxy:GetCardResourceTableFromId(pFrameId)
    if frameIdTableRow then
      self:SetCardBorder(frameIdTableRow)
    end
  end
end
function CardBG:SetCardAvatar(avatarCfg)
  if self.Image_RoleSkin == nil then
    return
  end
  self:SetSkinTexture(avatarCfg.IconIdcardL)
  local bShowDynamic = false
  if avatarCfg.AnimBlueprint and self.Slot_Avatar then
    local dynamicIconBP = ObjectUtil:LoadClass(avatarCfg.AnimBlueprint)
    if dynamicIconBP and self.Slot_Avatar then
      self.Slot_Avatar:ClearChildren()
      local dynamicIconIns = UE4.UWidgetBlueprintLibrary.Create(self, dynamicIconBP)
      self.Slot_Avatar:AddChild(dynamicIconIns)
      self.Image_RoleSkin:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Slot_Avatar:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      bShowDynamic = true
    end
  end
  if not bShowDynamic then
    self.Image_RoleSkin:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    if self.Slot_Avatar then
      self.Slot_Avatar:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function CardBG:SetCardBorder(borderCfg)
  if self.Image_Border == nil then
    return
  end
  local bShowDynamic = false
  if borderCfg.AnimBlueprint and self.Slot_Border then
    local dynamicIconBP = ObjectUtil:LoadClass(borderCfg.AnimBlueprint)
    if dynamicIconBP and self.Slot_Border then
      self.Slot_Border:ClearChildren()
      local dynamicIconIns = UE4.UWidgetBlueprintLibrary.Create(self, dynamicIconBP)
      self.Slot_Border:AddChild(dynamicIconIns)
      self.Image_Border:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Slot_Border:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      bShowDynamic = true
    end
  end
  if not bShowDynamic then
    self:SetBorderTexture(borderCfg.IconIdcardL, borderCfg.IconIdcardFrame)
    self.Image_Border:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    if self.Slot_Border then
      self.Slot_Border:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function CardBG:SetSkinTexture(texture)
  if texture and self.Image_RoleSkin then
    self:SetImageMatParamByTexture2D(self.Image_RoleSkin, "RoleSkin", texture)
  end
end
function CardBG:SetBorderTexture(itemTexture, borderTexture)
  if itemTexture and borderTexture and self.Image_Border then
    self:SetImageMatParamByTexture2D(self.Image_Border, "RoleSkin", borderTexture)
  end
end
function CardBG:ChangeCardAppearance(cardType, cardConfig)
  if nil == cardConfig then
    LogDebug("CardBG", "Can't find card config")
  end
  if cardType == businessCardEnum.cardType.avatar then
    self:SetCardAvatar(cardConfig)
  end
  if cardType == businessCardEnum.cardType.frame then
    self:SetCardBorder(cardConfig)
  end
end
function CardBG:InitializeLuaEvent()
  LogDebug("CardBG", "Init lua event")
  cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
end
return CardBG
