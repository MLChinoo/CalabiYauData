local SuperClass = require("Business/Setting/Mediators/Interact/KeyChangeMediator")
local EnableRoomVoiceMediator = class("EnableRoomVoiceMediator", SuperClass)
function EnableRoomVoiceMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SettingRoomVoiceKeyChanged)
end
return EnableRoomVoiceMediator
