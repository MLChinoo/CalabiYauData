local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SwitchTeamChatDescMediator = class("SwitchTeamChatDescMediator", SuperClass)
function SwitchTeamChatDescMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingTeamVoiceKeyChanged
  })
end
function SwitchTeamChatDescMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingTeamVoiceKeyChanged then
    self:FixedRelationView()
  end
end
function SwitchTeamChatDescMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  self:GetViewComponent().TextBlock_Desc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().TextBlock_ShortCut:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local SettingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("EnableTeamVoice")
  local inputChordArr = SettingInputUtilProxy:GetInputChordByValue(value)
  local keyStr1 = SettingInputUtilProxy:GetKeyName(inputChordArr[1])
  local keyStr2 = SettingInputUtilProxy:GetKeyName(inputChordArr[2])
  local text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "6")
  if "" ~= keyStr1 and "" ~= keyStr2 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "7") .. keyStr1 .. ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "8") .. keyStr2
  elseif "" ~= keyStr1 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "7") .. keyStr1
  elseif "" ~= keyStr2 then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "7") .. keyStr2
  end
  self:GetViewComponent().TextBlock_ShortCut:SetText(text)
  self:GetViewComponent().TextBlock_Desc:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "9"))
end
return SwitchTeamChatDescMediator
