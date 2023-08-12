local ApartmentPromiseGridItemMediator = class("ApartmentPromiseGridItemMediator", PureMVC.Mediator)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function ApartmentPromiseGridItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.ShowPlayerGuideCurrentIndex
  }
end
function ApartmentPromiseGridItemMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local data = notification:GetBody()
end
return ApartmentPromiseGridItemMediator
