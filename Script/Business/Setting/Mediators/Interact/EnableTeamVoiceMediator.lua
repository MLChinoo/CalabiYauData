local SuperClass = require("Business/Setting/Mediators/Interact/KeyChangeMediator")
local EnableTeamVoiceMediator = class("EnableTeamVoiceMediator", SuperClass)
function EnableTeamVoiceMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SettingTeamVoiceKeyChanged)
end
return EnableTeamVoiceMediator
