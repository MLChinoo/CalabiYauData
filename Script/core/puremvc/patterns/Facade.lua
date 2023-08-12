local Controller = puremvc_require("core/Controller")
local Model = puremvc_require("core/Model")
local View = puremvc_require("core/View")
local Notification = puremvc_require("patterns/Notification")
local PureMVCConfig = puremvc_require("PureMVCConfig")
local Facade = class("Facade")
Facade.instanceMap = {}
function Facade:ctor(key)
  if Facade.instanceMap[key] ~= nil then
    PureMVC_Log(PureMVCConfig.LogLevel_Error, "Facade instance for this Multiton key already constructed!")
  end
  self:InitializeNotifier(key)
  self:InitializeFacade()
  Facade.instanceMap[key] = self
end
function Facade:InitializeFacade()
  self:InitializeModel()
  self:InitializeController()
  self:InitializeView()
end
function Facade.GetInstance(key)
  if nil == key then
    return nil
  end
  if nil == Facade.instanceMap[key] then
    Facade.instanceMap[key] = Facade.new(key)
  end
  return Facade.instanceMap[key]
end
function Facade:InitializeController()
  if self.controller ~= nil then
    return
  end
  self.controller = Controller.GetInstance(self.multitonKey)
end
function Facade:InitializeModel()
  if self.model ~= nil then
    return
  end
  self.model = Model.GetInstance(self.multitonKey)
end
function Facade:InitializeView()
  if self.view ~= nil then
    return
  end
  self.view = View.GetInstance(self.multitonKey)
end
function Facade:RegisterCommand(notificationName, commandClassRef)
  self.controller:RegisterCommand(notificationName, commandClassRef)
end
function Facade:RemoveCommand(notificationName)
  self.controller:RemoveCommand(notificationName)
end
function Facade:HasCommand(notificationName)
  return self.controller:HasCommand(notificationName)
end
function Facade:RegisterProxy(proxy)
  self.model:RegisterProxy(proxy)
end
function Facade:RetrieveProxy(proxyName)
  return self.model:RetrieveProxy(proxyName)
end
function Facade:RemoveProxy(proxyName)
  local proxy
  if self.model ~= nil then
    proxy = self.model:RemoveProxy(proxyName)
  end
  return proxy
end
function Facade:HasProxy(proxyName)
  return self.model:HasProxy(proxyName)
end
function Facade:RegisterMediator(mediator)
  if self.view ~= nil then
    self.view:RegisterMediator(mediator)
  end
end
function Facade:RetrieveMediator(mediatorName)
  return self.view:RetrieveMediator(mediatorName)
end
function Facade:RemoveMediator(mediatorName)
  local mediator
  if self.view ~= nil then
    mediator = self.view:RemoveMediator(mediatorName)
  end
  return mediator
end
function Facade:HasMediator(mediatorName)
  return self.view:HasMediator(mediatorName)
end
function Facade:SendNotification(notificationName, body, type)
  if nil == notificationName then
    LogError("Facade:SendNotification", "notificationName is nil")
  end
  self:NotifyObservers(Notification.new(notificationName, body, type))
end
function Facade:NotifyObservers(notification)
  if self.view ~= nil then
    self.view:NotifyObservers(notification)
  end
end
function Facade:InitializeNotifier(key)
  self.multitonKey = key
end
function Facade.HasCore(key)
  return Facade.instanceMap[key] ~= nil
end
function Facade.RemoveCore(key)
  if Facade.instanceMap[key] == nil then
    return
  end
  Model.RemoveModel(key)
  View.RemoveView(key)
  Controller.RemoveController(key)
  Facade.instanceMap[key] = nil
end
return Facade
