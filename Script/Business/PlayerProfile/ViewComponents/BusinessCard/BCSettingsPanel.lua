local BCToolMediator = require("Business/PlayerProfile/Mediators/BusinessCard/BCToolMediator")
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local BCSettingsPanel = class("BCSettingsPanel", PureMVC.ViewComponentPanel)
function BCSettingsPanel:ListNeededMediators()
  return {BCToolMediator}
end
function BCSettingsPanel:ChangeCardType(cardType)
  if self.WidgetSwitcher_CardListSelect then
    if cardType == businessCardEnum.cardType.avatar then
      self.WidgetSwitcher_CardListSelect:SetActiveWidgetIndex(0)
    end
    if cardType == businessCardEnum.cardType.frame then
      self.WidgetSwitcher_CardListSelect:SetActiveWidgetIndex(1)
    end
    if cardType == businessCardEnum.cardType.achieve then
      self.WidgetSwitcher_CardListSelect:SetActiveWidgetIndex(2)
    end
  end
  self.actionOnSelectCardType(cardType)
end
function BCSettingsPanel:UpdateCardShown(cardType, cardInfo, isUsed, canUnequiped)
  if self.CardDescPanel then
    if cardInfo.name and cardInfo.desc then
      local cardDes = {}
      cardDes.itemName = cardInfo.name
      cardDes.itemDesc = cardInfo.desc
      cardDes.qualityID = cardInfo.qualityID
      self.CardDescPanel:UpdatePanel(cardDes)
      self.CardDescPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.CardDescPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local lockPanel, text_Name
  if cardType == businessCardEnum.cardType.avatar then
    lockPanel = self.Overlay_Avatar
    text_Name = self.Text_AvatarName
  end
  if cardType == businessCardEnum.cardType.frame then
    lockPanel = self.Overlay_Frame
    text_Name = self.Text_FrameName
  end
  if cardType == businessCardEnum.cardType.achieve then
    lockPanel = self.Overlay_Achieve
    text_Name = self.Text_AchieveName
  end
  if lockPanel and text_Name then
    if cardInfo.unlocked == nil or cardInfo.unlocked then
      lockPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      lockPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.Button_CardState then
    if cardInfo.unlocked == nil or cardInfo.unlocked then
      self.Button_CardState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Button_CardState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.Button_Apply then
    if isUsed then
      self.Button_Apply:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "IsUsing"))
      self.Button_Apply:SetButtonIsEnabled(false)
    else
      self.Button_Apply:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "UseSetting"))
      self.Button_Apply:SetButtonIsEnabled(true)
    end
  end
  if self.Button_Unequiped then
    if canUnequiped and cardInfo.unlocked ~= nil and cardInfo.unlocked == true then
      self.Button_Unequiped:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Button_Unequiped:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function BCSettingsPanel:UpdateCenterCard(cardInfoShown)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfoShown)
  end
end
function BCSettingsPanel:UpdateCardUsed(oldUsed, newUsed)
  if self.CardListPanel_Avatar and self.CardListPanel_Frame and self.CardListPanel_Achieve then
    self.CardListPanel_Avatar:GetSingleItemByItemID(oldUsed[businessCardEnum.cardType.avatar]):SetEquipState(false)
    self.CardListPanel_Avatar:GetSingleItemByItemID(newUsed[businessCardEnum.cardType.avatar]):SetEquipState(true)
    self.CardListPanel_Frame:GetSingleItemByItemID(oldUsed[businessCardEnum.cardType.frame]):SetEquipState(false)
    self.CardListPanel_Frame:GetSingleItemByItemID(newUsed[businessCardEnum.cardType.frame]):SetEquipState(true)
    if 0 ~= oldUsed[businessCardEnum.cardType.achieve] then
      self.CardListPanel_Achieve:GetSingleItemByItemID(oldUsed[businessCardEnum.cardType.achieve]):SetEquipState(false)
    end
    if 0 ~= newUsed[businessCardEnum.cardType.achieve] then
      self.CardListPanel_Achieve:GetSingleItemByItemID(newUsed[businessCardEnum.cardType.achieve]):SetEquipState(true)
    end
  end
  if self.Button_Apply then
    self.Button_Apply:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "IsUsing"))
    self.Button_Apply:SetButtonIsEnabled(false)
  end
end
function BCSettingsPanel:UpdateCardLockState(cardStateInfo)
  if self.Button_CardState then
    self.Button_CardState:UpdateOperateState(cardStateInfo)
  end
end
function BCSettingsPanel:InitBCPage()
  if self.SwtichAnimation then
    self.SwtichAnimation:PlayOpenAnimation()
  end
  self.InitBCSettingsPanel()
  self.Check_Skin:SetChecked(true, nil, true)
  self.Check_Frame:SetChecked(false)
  self.Check_Achieve:SetChecked(false)
  self.CheckedTag = self.Check_Skin
  self:ChangeCardType(businessCardEnum.cardType.avatar)
  if self.Button_CardState then
    self.Button_CardState:SetPageName(UIPageNameDefine.BCSettingPage)
  end
end
function BCSettingsPanel:UpdateCardTypeList(cardTypeInfo, cardType)
  if cardType == businessCardEnum.cardType.avatar and self.CardListPanel_Avatar then
    self.CardListPanel_Avatar:UpdatePanel(cardTypeInfo.itemsData)
    self.CardListPanel_Avatar:UpdateItemNumStr(cardTypeInfo.itemsData)
    self.CardListPanel_Avatar:SetDefaultSelectItemByItemID(cardTypeInfo.cardIdUsed)
    self:DecreaseRedDotCnt(cardTypeInfo.cardIdUsed)
  end
  if cardType == businessCardEnum.cardType.frame and self.CardListPanel_Frame then
    self.CardListPanel_Frame:UpdatePanel(cardTypeInfo.itemsData)
    self.CardListPanel_Frame:UpdateItemNumStr(cardTypeInfo.itemsData)
    self.CardListPanel_Frame:SetDefaultSelectItemByItemID(cardTypeInfo.cardIdUsed)
    self:DecreaseRedDotCnt(cardTypeInfo.cardIdUsed)
  end
  if cardType == businessCardEnum.cardType.achieve and self.CardListPanel_Achieve then
    self.CardListPanel_Achieve:UpdatePanel(cardTypeInfo.itemsData)
    self.CardListPanel_Achieve:UpdateItemNumStr(cardTypeInfo.itemsData)
    if 0 == cardTypeInfo.cardIdUsed then
      self.CardListPanel_Achieve:ClearSelectedState()
    else
      self.CardListPanel_Achieve:SetDefaultSelectItemByItemID(cardTypeInfo.cardIdUsed)
    end
  end
end
function BCSettingsPanel:SetCardSelected(cardType, cardId)
  if cardType == businessCardEnum.cardType.avatar and self.CardListPanel_Avatar then
    self.CardListPanel_Avatar:SetDefaultSelectItemByItemID(cardId)
  end
  if cardType == businessCardEnum.cardType.frame and self.CardListPanel_Frame then
    self.CardListPanel_Frame:SetDefaultSelectItemByItemID(cardId)
  end
  if cardType == businessCardEnum.cardType.achieve and self.CardListPanel_Achieve then
    if 0 == cardId then
      self:CancelSelect()
    else
      self.CardListPanel_Achieve:SetDefaultSelectItemByItemID(cardId)
    end
  end
end
function BCSettingsPanel:InitializeLuaEvent()
  LogDebug("BCSettingsPanel", "Init lua event")
  self.InitBCSettingsPanel = LuaEvent.new()
  self.actionOnSelectCardType = LuaEvent.new(cardType)
  self.actionOnSelectCard = LuaEvent.new(cardId)
  self.actionOnCancelSelect = LuaEvent.new()
  self.actionOnChangeStyle = LuaEvent.new()
  self.actionOnJumpPage = LuaEvent.new()
end
function BCSettingsPanel:Construct()
  LogDebug("BCSettingsPanel", "Lua construct")
  BCSettingsPanel.super.Construct(self)
  if self.Check_Skin and self.Check_Frame and self.Check_Achieve then
    self.Check_Skin:InitInfo("left", ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "Skin"), nil, 1, self)
    self.Check_Frame:InitInfo("middle", ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "Frame"), nil, 2, self)
    self.Check_Achieve:InitInfo("right", ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "Achieve"), nil, 3, self)
    self.Check_Skin:SetChecked(true, nil, true)
    self.Check_Frame:SetChecked(false)
    self.Check_Achieve:SetChecked(false)
  end
  if self.CardListPanel_Avatar and self.CardListPanel_Frame and self.CardListPanel_Achieve then
    self.CardListPanel_Avatar.clickItemEvent:Add(self.SelectCard, self)
    self.CardListPanel_Frame.clickItemEvent:Add(self.SelectCard, self)
    self.CardListPanel_Achieve.clickItemEvent:Add(self.SelectCard, self)
  end
  if self.Button_Unequiped then
    self.Button_Unequiped.OnClickEvent:Add(self, self.CancelSelect)
  end
  if self.Button_CardState then
    self.Button_CardState.onJumpSceenEvent:Add(self.OnJumpSceenButtonClick, self)
  end
  if self.Button_Apply then
    self.Button_Apply.OnClickEvent:Add(self, self.OnClickApply)
  end
  RedDotTree:Bind(RedDotModuleDef.ModuleName.BCAvatar, function(cnt)
    self:UpdateRedDotAvatar(cnt)
  end)
  self:UpdateRedDotAvatar(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.BCAvatar))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.BCFrame, function(cnt)
    self:UpdateRedDotFrame(cnt)
  end)
  self:UpdateRedDotFrame(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.BCFrame))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.BCAchieve, function(cnt)
    self:UpdateRedDotAchieve(cnt)
  end)
  self:UpdateRedDotAchieve(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.BCAchieve))
end
function BCSettingsPanel:Destruct()
  if self.CardListPanel_Avatar and self.CardListPanel_Frame and self.CardListPanel_Achieve then
    self.CardListPanel_Avatar.clickItemEvent:Remove(self.SelectCard, self)
    self.CardListPanel_Frame.clickItemEvent:Remove(self.SelectCard, self)
    self.CardListPanel_Achieve.clickItemEvent:Remove(self.SelectCard, self)
  end
  if self.Button_Unequiped then
    self.Button_Unequiped.OnClickEvent:Remove(self, self.CancelSelect)
  end
  if self.Button_Apply then
    self.Button_Apply.OnClickEvent:Remove(self, self.OnClickApply)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCAvatar)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCFrame)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCAchieve)
  BCSettingsPanel.super.Destruct(self)
end
function BCSettingsPanel:OnChosenSkin(isChecked)
  if isChecked then
    LogDebug("BCSettingsPanel", "Choose skin to modify")
    self:ChoosePanelType(self.CheckBox_Skin, businessCardEnum.cardType.avatar)
  end
end
function BCSettingsPanel:OnChosenCardBg(isChecked)
  if isChecked then
    LogDebug("BCSettingsPanel", "Choose card background to modify")
    self:ChoosePanelType(self.CheckBox_CardBg, businessCardEnum.cardType.frame)
  end
end
function BCSettingsPanel:OnChosenAchievement(isChecked)
  if isChecked then
    LogDebug("BCSettingsPanel", "Choose achievement to modify")
    self:ChoosePanelType(self.CheckBox_Achievement, businessCardEnum.cardType.achieve)
  end
end
function BCSettingsPanel:NotifyActiveButton(buttonIndex)
  if 1 == buttonIndex then
    LogDebug("BCSettingsPanel", "Choose skin to modify")
    self:ChoosePanelType(self.Check_Skin, businessCardEnum.cardType.avatar)
  elseif 2 == buttonIndex then
    LogDebug("BCSettingsPanel", "Choose card background to modify")
    self:ChoosePanelType(self.Check_Frame, businessCardEnum.cardType.frame)
  elseif 3 == buttonIndex then
    LogDebug("BCSettingsPanel", "Choose achievement to modify")
    self:ChoosePanelType(self.Check_Achieve, businessCardEnum.cardType.achieve)
  end
end
function BCSettingsPanel:ChoosePanelType(checkBoxChosen, cardType)
  if self.CheckedTag then
    self.CheckedTag:SetChecked(false)
    self.CheckedTag = checkBoxChosen
    self:ChangeCardType(cardType)
  end
end
function BCSettingsPanel:SelectCard(cardId)
  self.actionOnSelectCard(tonumber(cardId))
  self:DecreaseRedDotCnt(tonumber(cardId))
end
function BCSettingsPanel:CancelSelect()
  if self.CardListPanel_Achieve then
    self.CardListPanel_Achieve:ClearSelectedState()
  end
  self.actionOnCancelSelect()
end
function BCSettingsPanel:OnJumpSceenButtonClick()
  self.actionOnJumpPage()
end
function BCSettingsPanel:OnClickApply()
  self.actionOnChangeStyle()
end
function BCSettingsPanel:DecreaseRedDotCnt(cardId)
  local redDotName = ""
  local cardList
  local cardType = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardType(cardId)
  if cardType == businessCardEnum.cardType.avatar and self.CardListPanel_Avatar then
    cardList = self.CardListPanel_Avatar
    redDotName = RedDotModuleDef.ModuleName.BCAvatar
  end
  if cardType == businessCardEnum.cardType.frame and self.CardListPanel_Frame then
    cardList = self.CardListPanel_Frame
    redDotName = RedDotModuleDef.ModuleName.BCFrame
  end
  if cardType == businessCardEnum.cardType.achieve and self.CardListPanel_Achieve then
    cardList = self.CardListPanel_Achieve
    redDotName = RedDotModuleDef.ModuleName.BCAchieve
  end
  local redDotId = cardList:GetSelectItemRedDotID()
  if redDotId and 0 ~= redDotId then
    local redDotProxy = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy)
    redDotProxy:ReadRedDot(redDotId)
    cardList:SetSelectItemRedDotID(0)
    if redDotProxy:GetRedDotPass(redDotId) then
      RedDotTree:ChangeRedDotCnt(redDotName, -1)
    end
  end
end
function BCSettingsPanel:UpdateRedDotAvatar(cnt)
  if self.Check_Skin then
    self.Check_Skin:SetRedDot(cnt)
  end
end
function BCSettingsPanel:UpdateRedDotFrame(cnt)
  if self.Check_Frame then
    self.Check_Frame:SetRedDot(cnt)
  end
end
function BCSettingsPanel:UpdateRedDotAchieve(cnt)
  if self.Check_Achieve then
    self.Check_Achieve:SetRedDot(cnt)
  end
end
return BCSettingsPanel
