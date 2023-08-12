local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local WindowVoiceConfigDescMediator = class("WindowVoiceConfigDescMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
function WindowVoiceConfigDescMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.VoiceEffectChanged,
    NotificationDefines.Setting.ToggleVoiceEffectChanged
  }
end
local checkSystem = function(value)
  return value - 1 == UE4.EVoiceEffect.EV_SYSTEM
end
function WindowVoiceConfigDescMediator:OnRegister()
  self.surroundText = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "37")
  self.systemText = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "36")
  SuperClass.OnRegister(self)
end
function WindowVoiceConfigDescMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.VoiceEffectChanged then
    local value = body.value
    self:RefreshView(value)
  elseif name == NotificationDefines.Setting.ToggleVoiceEffectChanged then
    self:RefreshContent()
  end
end
function WindowVoiceConfigDescMediator:FixedRelationView()
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = settingSaveDataProxy:GetTemplateValueByKey("VoiceEffect")
  self:RefreshView(value)
end
function WindowVoiceConfigDescMediator:RefreshView(value)
  if checkSystem(value) then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshContent()
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function WindowVoiceConfigDescMediator:RefreshContent()
  local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
  local showvalue = SettingProxy:GetValueByKey("VoiceEffect_SHOW")
  if showvalue == UE4.EVoiceEffect.EV_HEADPHONE then
    self:GetViewComponent().showTxt:SetText(self.systemText)
  elseif showvalue == UE4.EVoiceEffect.EV_SURROUND then
    self:GetViewComponent().showTxt:SetText(self.surroundText)
  end
end
return WindowVoiceConfigDescMediator
