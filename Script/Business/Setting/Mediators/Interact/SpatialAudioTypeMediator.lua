local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SpatialAudioTypeMediator = class("SpatialAudioTypeMediator", SuperClass)
function SpatialAudioTypeMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self, function()
    GameFacade:SendNotification(NotificationDefines.Setting.SpatialAudioTypelChangeNtf)
  end)
end
return SpatialAudioTypeMediator
