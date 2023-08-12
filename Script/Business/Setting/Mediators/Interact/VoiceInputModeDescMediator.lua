local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local VoiceInputModeDescMediator = class("VoiceInputModeDescMediator", SuperClass)
function VoiceInputModeDescMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingRoomVoiceKeyChanged
  })
end
function VoiceInputModeDescMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingRoomVoiceKeyChanged then
    self:FixedRelationView()
  end
end
function VoiceInputModeDescMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  self:GetViewComponent().TextBlock_Desc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().TextBlock_ShortCut:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("EnableRoomVoice")
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
  local keyStr1 = SettingInputUtilProxy:GetKeyName(inputChordArr[1])
  local keyStr2 = SettingInputUtilProxy:GetKeyName(inputChordArr[2])
  local text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "29")
  if "" ~= keyStr1 and "" ~= keyStr2 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "30") .. keyStr1 .. ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "8") .. keyStr2
  elseif "" ~= keyStr1 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "30") .. keyStr1
  elseif "" ~= keyStr2 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "30") .. keyStr2
  end
  self:GetViewComponent().TextBlock_ShortCut:SetText(text)
end
return VoiceInputModeDescMediator