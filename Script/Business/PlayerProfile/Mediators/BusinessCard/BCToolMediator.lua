local BCToolMediator = class("BCToolMediator", PureMVC.Mediator)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
function BCToolMediator:ListNotificationInterests()
  return {
    NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeData,
    NotificationDefines.PlayerProfile.BusinessCard.GetCardData,
    NotificationDefines.UpdateItemOperateState,
    NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle,
    NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCard,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function BCToolMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeData then
    self.cardIdUsedTable[notification:GetType()] = notification:GetBody().cardIdUsed
    if self.cardIdSelectedTable[notification:GetType()] and self.cardIdSelectedTable[notification:GetType()] > 0 then
      notification:GetBody().cardIdUsed = self.cardIdSelectedTable[notification:GetType()]
    else
      self.cardIdSelectedTable[notification:GetType()] = notification:GetBody().cardIdUsed
    end
    self:GetViewComponent():UpdateCardTypeList(notification:GetBody(), notification:GetType())
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.GetCardData then
    local cardInfo = notification:GetBody()
    self.cardSelectedUnlock[notification:GetType()] = cardInfo.unlocked or false
    if notification:GetType() == businessCardEnum.cardType.achieve and cardInfo.cardId == nil then
      self.cardSelectedUnlock[notification:GetType()] = true
    end
    self:GetViewComponent():UpdateCardShown(notification:GetType(), cardInfo, table.equal(self.cardIdSelectedTable, self.cardIdUsedTable), self.currenSelectCardType == businessCardEnum.cardType.achieve)
  end
  if notification:GetName() == NotificationDefines.UpdateItemOperateState then
    local cardLockStateData = notification:GetBody()
    if cardLockStateData.itemType == UE4.EItemIdIntervalType.VCardAvatar or cardLockStateData.itemType == UE4.EItemIdIntervalType.VCardBg or cardLockStateData.itemType == UE4.EItemIdIntervalType.Achievement then
      self:GetViewComponent():UpdateCardLockState(cardLockStateData)
    end
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCard then
    self:GetViewComponent():UpdateCenterCard(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle then
    local rebackMsg = notification:GetBody()
    if 0 == rebackMsg.code then
      LogDebug("BCToolMediator", "Adopt scheme succeed")
      self:ChangeStyleFinish()
    else
      ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, rebackMsg.code)
    end
  end
  if notification:GetName() == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed then
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeDataCmd, self.currenSelectCardType)
    self:SelectCard(self.cardIdSelectedTable[self.currenSelectCardType])
    if notification:GetBody().IsSuccessed and notification:GetBody() == UIPageNameDefine.BCSettingPage then
      self:ChangeStyle()
    end
  end
end
function BCToolMediator:ChangeStyleFinish()
  self:GetViewComponent():UpdateCardUsed(self.cardIdUsedTable, self.cardIdSelectedTable)
  for key, value in pairs(self.cardIdSelectedTable) do
    self.cardIdUsedTable[key] = value
  end
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged)
end
function BCToolMediator:OnRegister()
  LogDebug("BCToolMediator", "On register")
  BCToolMediator.super.OnRegister(self)
  self.cardIdUsedTable = {}
  self.cardIdSelectedTable = {}
  self.cardSelectedUnlock = {}
  self:GetViewComponent().InitBCSettingsPanel:Add(self.InitBCSettingsPanel, self)
  self:GetViewComponent().actionOnSelectCardType:Add(self.SelectCardType, self)
  self:GetViewComponent().actionOnSelectCard:Add(self.SelectCard, self)
  self:GetViewComponent().actionOnCancelSelect:Add(self.CancelSelect, self)
  self:GetViewComponent().actionOnChangeStyle:Add(self.ChangeStyle, self)
end
function BCToolMediator:OnRemove()
  self:GetViewComponent().InitBCSettingsPanel:Remove(self.InitBCSettingsPanel, self)
  self:GetViewComponent().actionOnSelectCardType:Remove(self.SelectCardType, self)
  self:GetViewComponent().actionOnSelectCard:Remove(self.SelectCard, self)
  self:GetViewComponent().actionOnCancelSelect:Remove(self.CancelSelect, self)
  self:GetViewComponent().actionOnChangeStyle:Remove(self.ChangeStyle, self)
  BCToolMediator.super.OnRemove(self)
end
function BCToolMediator:InitBCSettingsPanel()
  for key, value in pairs(businessCardEnum.cardType) do
    self.cardIdUsedTable[value] = 0
    self.cardIdSelectedTable[value] = 0
    self.cardSelectedUnlock[value] = true
    self.currenSelectCardType = value
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardTypeDataCmd, value)
  end
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCardCmd, self.cardIdUsedTable, NotificationDefines.PlayerProfile.DataType.Self)
end
function BCToolMediator:SelectCardType(cardType)
  self.currenSelectCardType = cardType
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardDataCmd, self.cardIdSelectedTable[cardType], cardType)
end
function BCToolMediator:SelectCard(cardId)
  if self.cardIdSelectedTable[self.currenSelectCardType] ~= cardId then
    self.cardIdSelectedTable[self.currenSelectCardType] = cardId
    local selectCard = table.clone(self.cardIdSelectedTable)
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.UpdateCenterCardCmd, selectCard, NotificationDefines.PlayerProfile.DataType.Self)
  end
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.GetCardDataCmd, cardId, self.currenSelectCardType)
end
function BCToolMediator:CancelSelect()
  self:SelectCard(0)
end
function BCToolMediator:ChangeStyle()
  for key, value in pairs(self.cardSelectedUnlock) do
    if not value then
      local pageData = {
        contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "DoesRebackCardSelect"),
        source = self,
        cb = self.RebackCardSelect
      }
      ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
      return
    end
  end
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):ReqUpdateCard(self.cardIdSelectedTable)
end
function BCToolMediator:RebackCardSelect(bConfirm)
  if bConfirm then
    local curType = self.currenSelectCardType
    for key, value in pairs(self.cardSelectedUnlock) do
      if not value then
        self:SelectCardType(key)
        self:GetViewComponent():SetCardSelected(key, self.cardIdUsedTable[key])
      end
    end
    self:SelectCardType(curType)
    if not table.equal(self.cardIdSelectedTable, self.cardIdUsedTable) then
      self:ChangeStyle()
    end
  end
end
return BCToolMediator
