local ShareBigImagePageMediator = class("ShareBigImagePageMediator", PureMVC.Mediator)
function ShareBigImagePageMediator:ListNotificationInterests()
  return {}
end
function ShareBigImagePageMediator:OnRegister()
end
function ShareBigImagePageMediator:OnRemove()
end
function ShareBigImagePageMediator:HandleNotification(notification)
end
return ShareBigImagePageMediator
