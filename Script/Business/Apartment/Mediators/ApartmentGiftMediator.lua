local ApartmentGiftMediator = class("ApartmentGiftMediator", PureMVC.Mediator)
local ApartmentGiftPage
function ApartmentGiftMediator:OnRegister()
  ApartmentGiftPage = self:GetViewComponent()
end
function ApartmentGiftMediator:OnRemove()
end
function ApartmentGiftMediator:ListNotificationInterests()
  return {
    NotificationDefines.SetApartmentGiftPageData
  }
end
function ApartmentGiftMediator:HandleNotification(notification)
  if not ApartmentGiftPage:GetPageIsActive() then
    return
  end
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.SetApartmentGiftPageData then
    ApartmentGiftPage:Init(Body)
  end
end
return ApartmentGiftMediator
