local Observer = class("Observer")
function Observer:ctor(notifyMethod, notifyContext)
  self:SetNotifyMethod(notifyMethod)
  self:SetNotifyContext(notifyContext)
end
function Observer:SetNotifyMethod(value)
  self.notifyMethod = value
end
function Observer:GetNotifyMethod()
  return self.notifyMethod
end
function Observer:SetNotifyContext(value)
  self.notifyContext = value
end
function Observer:GetNotifyContext()
  return self.notifyContext
end
function Observer:NotifyObserver(notification)
  self.notifyMethod(self.notifyContext, notification)
end
function Observer:CompareNotifyContext(obj)
  return self.notifyContext == obj
end
return Observer
