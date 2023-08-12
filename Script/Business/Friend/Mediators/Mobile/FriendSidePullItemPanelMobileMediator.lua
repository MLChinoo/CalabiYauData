local FriendSidePullItemPanelMobileMediator = class("FriendSidePullItemPanelMobileMediator", PureMVC.Mediator)
function FriendSidePullItemPanelMobileMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendInfoChange
  }
end
function FriendSidePullItemPanelMobileMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendInviteStateChange then
    if notify:GetBody() == self:GetViewComponent().panelData.playerId then
      self:GetViewComponent().WS_operateState:SetActiveWidgetIndex(0)
    end
  elseif notify:GetName() == NotificationDefines.FriendInfoChange and notify:GetBody().playerId == self:GetViewComponent().panelData.playerId then
    self:GetViewComponent().panelData = notify:GetBody()
    self:GetViewComponent():ShowPanelInfo()
  end
end
function FriendSidePullItemPanelMobileMediator:OnRegister()
end
function FriendSidePullItemPanelMobileMediator:OnRemove()
end
return FriendSidePullItemPanelMobileMediator
