local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local VoiceEffectMediator = class("VoiceEffectMediator", SuperClass)
function VoiceEffectMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  GameFacade:SendNotification(NotificationDefines.Setting.VoiceEffectChanged, {
    value = view.currentValue
  })
end
return VoiceEffectMediator
