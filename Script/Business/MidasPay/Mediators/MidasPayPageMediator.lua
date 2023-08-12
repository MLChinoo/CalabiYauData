local MidasPayPageMediator = class("MidasPayPageMediator", PureMVC.Mediator)
function MidasPayPageMediator:ListNotificationInterests()
  return {}
end
function MidasPayPageMediator:OnRegister()
  self.super:OnRegister()
end
function MidasPayPageMediator:OnRemove()
  self.super:OnRemove()
end
function MidasPayPageMediator:HandleNotification(notification)
end
function MidasPayPageMediator:LuaHandleKeyEvent(key, inputEvent)
end
return MidasPayPageMediator
