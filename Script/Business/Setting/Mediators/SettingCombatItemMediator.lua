local SettingCombatItemMediator = class("SettingCombatItemMediator", PureMVC.Mediator)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function SettingCombatItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingChangeCompleteNtf
  }
end
function SettingCombatItemMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
end
function SettingCombatItemMediator:OnRegister()
end
function SettingCombatItemMediator:OnRemove()
end
return SettingCombatItemMediator
