local Facade = puremvc_require("patterns/Facade")
local PureMVCConfig = puremvc_require("PureMVCConfig")
local Notifier = class("Notifier")
function Notifier:ctor()
end
function Notifier:InitializeNotifier(key)
  self.multitonKey = key
  self.facade = self:GetFacade()
end
function Notifier:GetFacade()
  if self.multitonKey == nil then
    PureMVC_Log(PureMVCConfig.LogLevel_Error, "multitonKey for this Notifier not yet initialized!")
  end
  return Facade.GetInstance(self.multitonKey)
end
function Notifier:SendNotification(notificationName, body, noteType)
  local facade = self:GetFacade()
  if nil ~= facade then
    facade:SendNotification(notificationName, body, noteType)
  end
end
return Notifier
