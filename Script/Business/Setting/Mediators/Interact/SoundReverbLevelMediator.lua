local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SoundReverbLevelMediator = class("SoundReverbLevelMediator", SuperClass)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function SoundReverbLevelMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SpatialAudioTypelChangeNtf
  })
end
function SoundReverbLevelMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SpatialAudioTypelChangeNtf then
    self:RefreshView()
  end
end
function SoundReverbLevelMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  self:RefreshView()
end
function SoundReverbLevelMediator:RefreshView()
  local value = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy):GetTemplateValueByKey("SpatialAudioType")
  local bEnabled = SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Custom)
  self:GetViewComponent():SetEnabled(bEnabled)
  if SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Close) then
    self:GetViewComponent():DoSelectShowCurrentValue(2)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Low) then
    self:GetViewComponent():DoSelectShowCurrentValue(2)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Middle) then
    self:GetViewComponent():DoSelectShowCurrentValue(2)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_High) then
    self:GetViewComponent():DoSelectShowCurrentValue(1)
  end
end
return SoundReverbLevelMediator
