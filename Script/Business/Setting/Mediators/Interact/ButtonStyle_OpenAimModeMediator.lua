local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ButtonStyle_OpenAimModeMediator = class("ButtonStyle_OpenAimModeMediator", SuperClass)
function ButtonStyle_OpenAimModeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingOnlyRefreshNtf
  })
end
function ButtonStyle_OpenAimModeMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingOnlyRefreshNtf then
    local view = self:GetViewComponent()
    if body.oriData.indexKey == view.oriData.indexKey then
      self:GetViewComponent():OnlyRefreshView()
    end
  end
end
function ButtonStyle_OpenAimModeMediator:ChangeValueEvent()
  local view = self:GetViewComponent()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local aimValue = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_ShoulderMode")
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local aimOriData = SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_ShoulderMode")
  local shoulderValue = self:GetViewComponent().currentValue
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  if SettingKeyMapManagerProxy:CheckAimingAndAdsIsSame() and aimValue == shoulderValue then
    if SettingHelper.CheckLuaValueIsSameAsCPPValue(shoulderValue, UE4.EButtonStyle.EB_Pressed) then
      SettingSaveDataProxy:UpdateTemplateData(aimOriData, SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Clicked))
    elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(shoulderValue, UE4.EButtonStyle.EB_Clicked) then
      SettingSaveDataProxy:UpdateTemplateData(aimOriData, SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Pressed))
    end
    GameFacade:SendNotification(NotificationDefines.Setting.SettingOnlyRefreshNtf, {
      oriData = aimOriData,
      value = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_ShoulderMode")
    })
  end
  SuperClass.ChangeValueEvent(self)
end
return ButtonStyle_OpenAimModeMediator
