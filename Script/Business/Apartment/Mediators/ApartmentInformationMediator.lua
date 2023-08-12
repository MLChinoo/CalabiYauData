local ApartmentInformationMediator = class("ApartmentInformationMediator", PureMVC.Mediator)
local ApartmentInformationPage
function ApartmentInformationMediator:OnRegister()
  ApartmentInformationPage = self:GetViewComponent()
end
function ApartmentInformationMediator:OnRemove()
end
function ApartmentInformationMediator:ListNotificationInterests()
  return {
    NotificationDefines.SetApartmentInformationPageData
  }
end
function ApartmentInformationMediator:HandleNotification(notification)
  if not ApartmentInformationPage:GetPageIsActive() then
    return
  end
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.SetApartmentInformationPageData then
    ApartmentInformationPage:Init(Body)
  end
end
return ApartmentInformationMediator
