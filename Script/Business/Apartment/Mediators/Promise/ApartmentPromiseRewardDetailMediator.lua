local ApartmentPromiseRewardDetailMediator = class("ApartmentPromiseRewardDetailMediator", PureMVC.Mediator)
local ApartmentPromiseRewardDetailPage
function ApartmentPromiseRewardDetailMediator:OnRegister()
  ApartmentPromiseRewardDetailPage = self:GetViewComponent()
end
function ApartmentPromiseRewardDetailMediator:ListNotificationInterests()
  return {
    NotificationDefines.PromiseRewardClickItem
  }
end
function ApartmentPromiseRewardDetailMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.PromiseRewardClickItem then
    ApartmentPromiseRewardDetailPage:UpdatePanel(Body)
  end
end
return ApartmentPromiseRewardDetailMediator
