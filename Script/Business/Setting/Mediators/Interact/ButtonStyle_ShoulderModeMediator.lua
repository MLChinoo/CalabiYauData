local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ButtonStyle_ShoulderModeMediator = class("ButtonStyle_ShoulderModeMediator", SuperClass)
function ButtonStyle_ShoulderModeMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingOnlyRefreshNtf
  })
end
function ButtonStyle_ShoulderModeMediator:HandleNotification(notification)
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
function ButtonStyle_ShoulderModeMediator:ChangeValueEvent()
  local view = self:GetViewComponent()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local aimValue = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_OpenAimMode")
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local aimOriData = SettingConfigProxy:GetOriDataByIndexKey("ButtonStyle_OpenAimMode")
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  local shoulderValue = self:GetViewComponent().currentValue
  if SettingKeyMapManagerProxy:CheckAimingAndAdsIsSame() and aimValue == shoulderValue then
    if SettingHelper.CheckLuaValueIsSameAsCPPValue(shoulderValue, UE4.EButtonStyle.EB_Pressed) then
      SettingSaveDataProxy:UpdateTemplateData(aimOriData, SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Clicked))
    elseif SettingHelper.CheckLuaValueIsSameAsCPPValue(shoulderValue, UE4.EButtonStyle.EB_Clicked) then
      SettingSaveDataProxy:UpdateTemplateData(aimOriData, SettingHelper.GetLuaValueByCPPValue(UE4.EButtonStyle.EB_Pressed))
    end
    GameFacade:SendNotification(NotificationDefines.Setting.SettingOnlyRefreshNtf, {
      oriData = aimOriData,
      value = SettingSaveDataProxy:GetTemplateValueByKey("ButtonStyle_OpenAimMode")
    })
  end
  SuperClass.ChangeValueEvent(self)
end
return ButtonStyle_ShoulderModeMediator
