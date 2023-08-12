local DefaultCommonMediator = class("DefaultCommonMediator", PureMVC.Mediator)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function DefaultCommonMediator:PackNotificationInterests(packlist)
  local list = self.super:ListNotificationInterests()
  local ret = {}
  for i, v in ipairs(packlist) do
    ret[#ret + 1] = v
  end
  for i, v in ipairs(list) do
    ret[#ret + 1] = v
  end
  return ret
end
function DefaultCommonMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingDefaultApplyNtf
  })
end
function DefaultCommonMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingDefaultApplyNtf then
    self:ApplyDefaultConfig()
  end
end
function DefaultCommonMediator:OnRegister()
  self:GetViewComponent().ChangeValueEvent = LuaEvent.new()
  self:GetViewComponent().ChangeValueEvent:Add(self.ChangeValueEvent, self)
  self:FixedRelationView()
end
function DefaultCommonMediator:OnRemove()
  self:GetViewComponent().ChangeValueEvent:Remove(self.ChangeValueEvent, self)
end
function DefaultCommonMediator:FixedRelationView()
end
function DefaultCommonMediator:ChangeValueEvent(func)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  settingSaveDataProxy:UpdateTemplateData(oriData, view.currentValue)
  if type(func) == "function" then
    func()
  end
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf, {
    oriData = oriData,
    value = view.currentValue
  })
end
function DefaultCommonMediator:ApplyDefaultConfig()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  local oriData = self:GetViewComponent().oriData
  local panelStr = SettingManagerProxy:GetCurPanelTypeStr()
  if panelStr and oriData.Type == panelStr then
    local value = SettingSaveDataProxy:GetDefaultValueByKey(oriData.Indexkey)
    self:GetViewComponent():SetCurrentValue(value)
    self:GetViewComponent():RefreshView()
    if panelStr == SettingEnum.PanelTypeStr.CrossHair and self.ChangeValueEvent then
      self:ChangeValueEvent()
    end
  end
end
return DefaultCommonMediator
