local Observer = puremvc_require("patterns/Observer")
local PureMVCConfig = puremvc_require("PureMVCConfig")
local View = puremvc_require("core/View")
local Controller = class("Controller")
Controller.instanceMap = {}
function Controller:ctor(key)
  if Controller.instanceMap[key] ~= nil then
    PureMVC_Log(PureMVCConfig.LogLevel_Error, "Controller instance for this Multiton key already constructed!")
  end
  self.multitonKey = key
  Controller.instanceMap[self.multitonKey] = self
  self.commandMap = {}
  self:InitializeController()
end
function Controller:InitializeController()
  self.view = View.GetInstance(self.multitonKey)
end
function Controller.GetInstance(key)
  if nil == key then
    return nil
  end
  if nil == Controller.instanceMap[key] then
    return Controller.new(key)
  else
    return Controller.instanceMap[key]
  end
end
function Controller:ExecuteCommand(note)
  local commandClassRef = self.commandMap[note:GetName()]
  if nil == commandClassRef then
    return
  end
  local commandInstance = commandClassRef.new()
  commandInstance:InitializeNotifier(self.multitonKey)
  commandInstance:Execute(note)
end
function Controller:RegisterCommand(notificationName, commandClassRef)
  if self.commandMap[notificationName] == nil then
    self.view:RegisterObserver(notificationName, Observer.new(self.ExecuteCommand, self))
  end
  self.commandMap[notificationName] = commandClassRef
end
function Controller:HasCommand(notificationName)
  return self.commandMap[notificationName] ~= nil
end
function Controller:RemoveCommand(notificationName)
  if self:HasCommand(notificationName) then
    self.view:RemoveObserver(notificationName, self)
    self.commandMap[notificationName] = nil
  end
end
function Controller.RemoveController(key)
  Controller.instanceMap[key] = nil
end
return Controller
