local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SoundDiffractionLevelMediator = class("SoundDiffractionLevelMediator", SuperClass)
function SoundDiffractionLevelMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SpatialAudioTypelChangeNtf
  })
end
function SoundDiffractionLevelMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SpatialAudioTypelChangeNtf then
    self:RefreshView()
  end
end
function SoundDiffractionLevelMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  self:RefreshView()
end
function SoundDiffractionLevelMediator:RefreshView()
  local value = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy):GetTemplateValueByKey("SpatialAudioType")
  local bEnabled = SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Custom)
  self:GetViewComponent():SetEnabled(bEnabled)
  if SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Close) then
    self:GetViewComponent():DoSelectShowCurrentValue(1)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Low) then
    self:GetViewComponent():DoSelectShowCurrentValue(1)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_Middle) then
    self:GetViewComponent():DoSelectShowCurrentValue(2)
  elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESpatialAudioType.EV_High) then
    self:GetViewComponent():DoSelectShowCurrentValue(3)
  end
end
return SoundDiffractionLevelMediator
