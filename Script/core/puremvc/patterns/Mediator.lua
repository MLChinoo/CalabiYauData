local Notifier = puremvc_require("patterns/Notifier")
local Mediator = class("Mediators", Notifier)
function Mediator:ctor(mediatorName, viewComponent)
  Mediator.super.ctor(self)
  self.mediatorName = mediatorName
  self.viewComponent = viewComponent
end
function Mediator:GetMediatorName()
  return self.mediatorName
end
function Mediator:SetViewComponent(viewComponent)
  self.viewComponent = viewComponent
end
function Mediator:GetViewComponent()
  return self.viewComponent
end
function Mediator:ListNotificationInterests()
  return {}
end
function Mediator:HandleNotification(notification)
end
function Mediator:OnRegister()
end
function Mediator:OnRemove()
end
return Mediator
