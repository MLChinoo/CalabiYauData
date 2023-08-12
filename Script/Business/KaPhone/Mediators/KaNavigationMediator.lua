local KaNavigationMediator = class("KaNavigationMediator", PureMVC.Mediator)
local NavigationPanel
function KaNavigationMediator:OnRegister()
  NavigationPanel = self:GetViewComponent()
end
function KaNavigationMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfKaNavigation
  }
end
function KaNavigationMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  local Type = notification:GetType()
  if NavigationPanel:GetIsActive() and Name == NotificationDefines.NtfKaNavigation then
    NavigationPanel:Update(Body)
  end
end
return KaNavigationMediator
