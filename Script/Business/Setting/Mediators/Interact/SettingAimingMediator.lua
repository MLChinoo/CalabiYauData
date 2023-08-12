local SuperClass = require("Business/Setting/Mediators/Interact/KeyChangeMediator")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingShoulderMediator = class("SettingShoulderMediator", SuperClass)
function SettingShoulderMediator:ChangeValueEvent()
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  settingSaveDataProxy:UpdateTemplateData(oriData, view.currentValue)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local aimValue = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_OpenAimMode")
  local shoulderValue = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_ShoulderMode")
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  if SettingKeyMapManagerProxy:CheckAimingAndAdsIsSame() and aimValue == shoulderValue then
    if SettingHelper.CheckLuaValueIsSameAsCPPValue(aimValue, UE4.EButtonStyle.EB_Pressed) then
      SettingSaveDataProxy:UpdateTemplateData(SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_OpenAimMode"), SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Clicked))
    elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(aimValue, UE4.EButtonStyle.EB_Clicked) then
      SettingSaveDataProxy:UpdateTemplateData(SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_OpenAimMode"), SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Pressed))
    end
  end
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf, {
    oriData = oriData,
    value = view.currentValue
  })
  GameFacade:SendNotification(NotificationDefines.Setting.SettingOnlyRefreshNtf, {
    oriData = SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_OpenAimMode"),
    value = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_OpenAimMode")
  })
  GameFacade:SendNotification(NotificationDefines.Setting.SettingOnlyRefreshNtf, {
    oriData = SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_ShoulderMode"),
    value = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_ShoulderMode")
  })
end
return SettingShoulderMediator
