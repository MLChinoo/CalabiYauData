local FriendSearchStrangeItem = class("FriendSearchStrangeItem", PureMVC.ViewComponentPanel)
function FriendSearchStrangeItem:InitializeLuaEvent()
  self.SelectButton.OnClicked:Add(self, self.OnSelectFunc)
end
function FriendSearchStrangeItem:InitView(playerInfo, parent, index)
  if nil == playerInfo then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text_PlayerName:SetText(playerInfo.nick)
  self.WS_PlayerState:SetActiveWidgetIndex(playerInfo.onlineStatus)
  local avatarId = tonumber(playerInfo.icon)
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Img_Player, avatarId, self.Image_BorderIcon, playerInfo.vcBorderId)
  self.currentPlayerInfo = playerInfo
  self.parent = parent
  self.index = index
end
function FriendSearchStrangeItem:GetPlayerInfo()
  return self.currentPlayerInfo
end
function FriendSearchStrangeItem:DoSelectFunc()
  self:OnSelectFunc()
end
function FriendSearchStrangeItem:OnSelectFunc()
  if self.parent then
    self.parent:SelectItem(self.currentPlayerInfo, self.index)
  end
end
function FriendSearchStrangeItem:SetSelect(bSelect)
  if bSelect then
    self.SelectPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SelectPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return FriendSearchStrangeItem
