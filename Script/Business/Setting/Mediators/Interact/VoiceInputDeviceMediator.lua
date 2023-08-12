local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local VoiceInputDeviceMediator = class("VoiceInputDeviceMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function VoiceInputDeviceMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingDeviceChangeNtf,
    NotificationDefines.Setting.SettingListScrolled
  }
end
function VoiceInputDeviceMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingDeviceChangeNtf then
    local view = self:GetViewComponent()
    local oriData = view.oriData
    view:InitView(oriData)
    local textArr = self:GetViewComponent().displayTextArr
    view:SetEnabled(textArr[1] ~= SettingEnum.NoDevice)
  elseif name == NotificationDefines.Setting.SettingListScrolled then
    local view = self:GetViewComponent()
    if view.WBP_SettingScrollTextItem_PC then
      view.WBP_SettingScrollTextItem_PC:BeginScroll()
    end
  end
end
function VoiceInputDeviceMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  self:DelayBeginScroll()
end
function VoiceInputDeviceMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  local view = self:GetViewComponent()
  view.WBP_SettingScrollTextItem_PC:SetScrollText(view.TextBlock_Display)
  self:DelayBeginScroll()
end
function VoiceInputDeviceMediator:DelayBeginScroll()
  local view = self:GetViewComponent()
  if view.WBP_SettingScrollTextItem_PC then
    TimerMgr:AddTimeTask(0.1, 0, 1, function()
      view.WBP_SettingScrollTextItem_PC:BeginScroll()
    end)
  end
end
return VoiceInputDeviceMediator
