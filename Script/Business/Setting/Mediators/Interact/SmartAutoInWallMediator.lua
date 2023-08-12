local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SmartAutoInWallMediator = class("AutoInWallDelayTimeMediator", SuperClass)
function SmartAutoInWallMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SmartInWallChangeNtf, {
    oriData = oriData,
    value = view.currentValue
  })
end
return SmartAutoInWallMediator
