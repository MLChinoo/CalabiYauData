local BCToolMediator = require("Business/PlayerProfile/Mediators/BusinessCard/BCToolMediator")
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local BCSettingPageMobile = class("BCSettingPageMobile", PureMVC.ViewComponentPage)
function BCSettingPageMobile:ListNeededMediators()
  return {BCToolMediator}
end
function BCSettingPageMobile:ChangeCardType(cardType)
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
function BCSettingPageMobile:UpdateCardShown(cardType, cardInfo, isUsed, canUnequiped)
  if self.CardDescPanel then
    if cardInfo.name and cardInfo.desc then
      local cardDes = {}
      cardDes.itemName = cardInfo.name
      cardDes.itemDesc = cardInfo.desc
      cardDes.qualityID = cardInfo.qualityID
      self.CardDescPanel:UpdatePanel(cardDes)
      self.CardDescPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
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
    else
      self.CardDescPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
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
function BCSettingPageMobile:UpdateCenterCard(cardInfoShown)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfoShown)
  end
end
function BCSettingPageMobile:UpdateCardUsed(oldUsed, newUsed)
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
function BCSettingPageMobile:UpdateCardLockState(cardStateInfo)
  if self.Button_CardState then
    self.Button_CardState:UpdateOperateState(cardStateInfo)
  end
end
function BCSettingPageMobile:InitBCPage()
  if self.SwtichAnimation then
    self.SwtichAnimation:PlayOpenAnimation()
  end
  self.InitBCSettingsPanel()
  self.Check_Avatar:SetSelectState(true)
  self.Check_Frame:SetSelectState(false)
  self.Check_Achieve:SetSelectState(false)
  self.CheckedTag = self.Check_Avatar
  self:ChangeCardType(businessCardEnum.cardType.avatar)
  self.Button_CardState:SetPageName(UIPageNameDefine.BCSettingPage)
end
function BCSettingPageMobile:UpdateCardTypeList(cardTypeInfo, cardType)
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
function BCSettingPageMobile:SetCardSelected(cardType, cardId)
  if cardType == businessCardEnum.cardType.avatar and self.CardListPanel_Avatar then
    self.CardListPanel_Avatar:SetDefaultSelectItemByItemID(cardId)
  end
  if cardType == businessCardEnum.cardType.frame and self.CardListPanel_Frame then
    self.CardListPanel_Frame:SetDefaultSelectItemByItemID(cardId)
  end
  if cardType == businessCardEnum.cardType.achieve and self.CardListPanel_Achieve then
    if 0 == cardId then
      self.CardListPanel_Achieve:ClearSelectedState()
    else
      self.CardListPanel_Achieve:SetDefaultSelectItemByItemID(cardId)
    end
  end
end
function BCSettingPageMobile:InitializeLuaEvent()
  LogDebug("BCSettingPageMobile", "Init lua event")
  self.InitBCSettingsPanel = LuaEvent.new()
  self.actionOnSelectCardType = LuaEvent.new(cardType)
  self.actionOnSelectCard = LuaEvent.new(cardId)
  self.actionOnCancelSelect = LuaEvent.new()
  self.actionOnChangeStyle = LuaEvent.new()
end
function BCSettingPageMobile:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("BCSettingPageMobile", "Lua open page")
  if self.Check_Avatar and self.Check_Frame and self.Check_Achieve then
    self.Check_Avatar.OnCheckStateChanged:Add(self, self.OnChosenSkin)
    self.Check_Frame.OnCheckStateChanged:Add(self, self.OnChosenCardBg)
    self.Check_Achieve.OnCheckStateChanged:Add(self, self.OnChosenAchievement)
    self.Check_Avatar:SetSelectState(true)
    self.Check_Frame:SetSelectState(false)
    self.Check_Achieve:SetSelectState(false)
  end
  if self.SwtichAnimation then
    self.SwtichAnimation:PlayOpenAnimation()
  end
  if self.CardListPanel_Avatar and self.CardListPanel_Frame and self.CardListPanel_Achieve then
    self.CardListPanel_Avatar.clickItemEvent:Add(self.SelectCard, self)
    self.CardListPanel_Frame.clickItemEvent:Add(self.SelectCard, self)
    self.CardListPanel_Achieve.clickItemEvent:Add(self.SelectCard, self)
  end
  if self.Button_Unequiped then
    self.Button_Unequiped.OnClickEvent:Add(self, self.CancelSelect)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickClose)
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
  self:InitBCPage()
end
function BCSettingPageMobile:OnClose()
  if self.Check_Avatar and self.Check_Frame and self.Check_Achieve then
    self.Check_Avatar.OnCheckStateChanged:Remove(self, self.OnChosenSkin)
    self.Check_Frame.OnCheckStateChanged:Remove(self, self.OnChosenCardBg)
    self.Check_Achieve.OnCheckStateChanged:Remove(self, self.OnChosenAchievement)
  end
  if self.CardListPanel_Avatar and self.CardListPanel_Frame and self.CardListPanel_Achieve then
    self.CardListPanel_Avatar.clickItemEvent:Remove(self.SelectCard, self)
    self.CardListPanel_Frame.clickItemEvent:Remove(self.SelectCard, self)
    self.CardListPanel_Achieve.clickItemEvent:Remove(self.SelectCard, self)
  end
  if self.Button_Unequiped then
    self.Button_Unequiped.OnClickEvent:Remove(self, self.CancelSelect)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.OnClickClose)
  end
  if self.Button_Apply then
    self.Button_Apply.OnClickEvent:Remove(self, self.OnClickApply)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCAvatar)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCFrame)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BCAchieve)
end
function BCSettingPageMobile:OnChosenSkin(item)
  if self.CheckedTag ~= self.Check_Avatar then
    LogDebug("BCSettingPageMobile", "Choose skin to modify")
    self:ChoosePanelType(self.Check_Avatar, businessCardEnum.cardType.avatar)
  end
end
function BCSettingPageMobile:OnChosenCardBg(item)
  if self.CheckedTag ~= self.Check_Frame then
    LogDebug("BCSettingPageMobile", "Choose card background to modify")
    self:ChoosePanelType(self.Check_Frame, businessCardEnum.cardType.frame)
  end
end
function BCSettingPageMobile:OnChosenAchievement(item)
  if self.CheckedTag ~= self.Check_Achieve then
    LogDebug("BCSettingPageMobile", "Choose achievement to modify")
    self:ChoosePanelType(self.Check_Achieve, businessCardEnum.cardType.achieve)
  end
end
function BCSettingPageMobile:ChoosePanelType(checkBoxChosen, cardType)
  self.CheckedTag:SetSelectState(false)
  self.CheckedTag = checkBoxChosen
  self.CheckedTag:SetSelectState(true)
  self:ChangeCardType(cardType)
end
function BCSettingPageMobile:SelectCard(cardId)
  self.actionOnSelectCard(tonumber(cardId))
  self:DecreaseRedDotCnt(tonumber(cardId))
end
function BCSettingPageMobile:CancelSelect()
  if self.CardListPanel_Achieve then
    self.CardListPanel_Achieve:ClearSelectedState()
  end
  self.actionOnCancelSelect()
end
function BCSettingPageMobile:OnClickApply()
  self.actionOnChangeStyle()
end
function BCSettingPageMobile:OnClickClose()
  ViewMgr:ClosePage(self)
end
function BCSettingPageMobile:DecreaseRedDotCnt(cardId)
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
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
    cardList:SetSelectItemRedDotID(0)
    RedDotTree:ChangeRedDotCnt(redDotName, -1)
  end
end
function BCSettingPageMobile:UpdateRedDotAvatar(cnt)
  if self.Check_Avatar then
    self.Check_Avatar:SetRedDot(cnt)
  end
end
function BCSettingPageMobile:UpdateRedDotFrame(cnt)
  if self.Check_Frame then
    self.Check_Frame:SetRedDot(cnt)
  end
end
function BCSettingPageMobile:UpdateRedDotAchieve(cnt)
  if self.Check_Achieve then
    self.Check_Achieve:SetRedDot(cnt)
  end
end
return BCSettingPageMobile
