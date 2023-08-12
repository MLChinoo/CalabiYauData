local NavigationBarMediatorMobile = class("NavigationBarMediatorMobile", PureMVC.Mediator)
function NavigationBarMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.OnResPlayerAttrSync,
    NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged,
    NotificationDefines.NavigationBar.LiveApartmentPage,
    NotificationDefines.NavigationBar.SwitchDisplayNavBar
  }
end
function NavigationBarMediatorMobile:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.OnResPlayerAttrSync then
    viewComponent:InitPlayerInfo()
    self:UpdatePlayerAvatar()
  elseif noteName == NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged then
    self:UpdatePlayerAvatar()
  elseif noteName == NotificationDefines.NavigationBar.LiveApartmentPage then
    viewComponent:SetCloseApartmentPage(false)
  elseif noteName == NotificationDefines.NavigationBar.SwitchDisplayNavBar then
    viewComponent:SetVisibility(notification:GetBody() and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarMediatorMobile:OnRegister()
  NavigationBarMediatorMobile.super.OnRegister(self)
  self:UpdatePlayerAvatar()
  self:GetViewComponent():InitPlayerInfo()
end
function NavigationBarMediatorMobile:UpdatePlayerAvatar()
  local avatarId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  if avatarId then
    local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
    if avatarIcon then
      self:GetViewComponent():InitPlayerAvatar(avatarIcon)
    else
      LogError("NavigationBarMediatorMobile", "Player icon or config error")
    end
  end
end
return NavigationBarMediatorMobile
