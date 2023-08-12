local Observer = puremvc_require("patterns/Observer")
local PureMVCConfig = puremvc_require("PureMVCConfig")
local View = class("View")
View.instanceMap = {}
function View:ctor(key)
  if View.instanceMap[key] ~= nil then
    PureMVC_Log(PureMVCConfig.LogLevel_Error, "View instance for this Multiton key already constructed!")
  end
  self.multitonKey = key
  View.instanceMap[self.multitonKey] = self
  self.mediatorMap = {}
  self.observerMap = {}
  self:InitializeView()
end
function View:InitializeView()
end
function View.GetInstance(key)
  if nil == key then
    return nil
  end
  if nil == View.instanceMap[key] then
    return View.new(key)
  else
    return View.instanceMap[key]
  end
end
function View:RegisterObserver(notificationName, observer)
  if self.observerMap[notificationName] ~= nil then
    table.insert(self.observerMap[notificationName], observer)
  else
    self.observerMap[notificationName] = {observer}
  end
end
function View:NotifyObservers(notification)
  if self.observerMap[notification:GetName()] ~= nil then
    local observers_ref = self.observerMap[notification:GetName()]
    for _, o in pairs(observers_ref) do
      o:NotifyObserver(notification)
    end
  end
end
function View:RemoveObserver(notificationName, notifyContext)
  local observers = self.observerMap[notificationName]
  for _, o in pairs(observers) do
    if o:CompareNotifyContext(notifyContext) then
      table.remove(observers, _)
      break
    end
  end
  if 0 == #observers then
    self.observerMap[notificationName] = nil
  end
end
function View:RegisterMediator(mediator)
  if self.mediatorMap[mediator:GetMediatorName()] ~= nil then
    return
  end
  mediator:InitializeNotifier(self.multitonKey)
  self.mediatorMap[mediator:GetMediatorName()] = mediator
  local interests = mediator:ListNotificationInterests()
  if #interests > 0 then
    local observer = Observer.new(mediator.HandleNotification, mediator)
    for _, i in pairs(interests) do
      self:RegisterObserver(i, observer)
    end
  end
  mediator:OnRegister()
end
function View:RetrieveMediator(mediatorName)
  return self.mediatorMap[mediatorName]
end
function View:RemoveMediator(mediatorName)
  local mediator = self.mediatorMap[mediatorName]
  if nil ~= mediator then
    local interests = mediator:ListNotificationInterests()
    for _, i in pairs(interests) do
      self:RemoveObserver(i, mediator)
    end
    self.mediatorMap[mediatorName] = nil
    mediator:OnRemove()
  end
  return mediator
end
function View:HasMediator(mediatorName)
  return self.mediatorMap[mediatorName] ~= nil
end
function View.removeView(key)
  View.instanceMap[key] = nil
end
return View
