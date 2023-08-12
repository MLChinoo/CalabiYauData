local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local ScalabilityQualityMediator = class("ScalabilityQualityMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local ItemType = SettingEnum.ItemType
function ScalabilityQualityMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.SettingVisualGraphicsChangedNtf,
    NotificationDefines.Setting.SettingScalabilityChangedNtf
  })
end
function ScalabilityQualityMediator:HandleNotification(notification)
  SuperClass.HandleNotification(self, notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingVisualGraphicsChangedNtf then
    local receiveOriData = body.oriData
    local value = body.value
    if receiveOriData.indexKey == "Graphics" then
      if value == SettingEnum.GraphicCustomIndex then
        return
      else
        local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
        local GraphicsQualityArr = SettingVisualProxy:GetGraphicsQualityArr()
        local QualityArr = GraphicsQualityArr[value]
        local view = self:GetViewComponent()
        local oriData = view.oriData
        local indexKey = oriData.indexKey
        local selectValue = QualityArr[indexKey]
        if selectValue then
          self:GetViewComponent():DoSelectCurrentValue(selectValue, true)
        end
        local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
        if oriData.indexKey == "SSAOQuality" or oriData.indexKey == "SSRQuality" then
          if 2 == SettingSaveDataProxy:GetTemplateValueByKey("RenderMode") then
            view:SetEnabled(false)
          else
            view:SetEnabled(true)
          end
        end
        SuperClass.ChangeValueEvent(self)
      end
    end
  elseif name == NotificationDefines.Setting.SettingScalabilityChangedNtf then
    local receiveOriData = body.oriData
    local value = body.value
    local view = self:GetViewComponent()
    local oriData = view.oriData
    if receiveOriData.indexKey == "RenderMode" and (oriData.indexKey == "SSAOQuality" or oriData.indexKey == "SSRQuality") then
      if 2 == value then
        view:SetEnabled(false)
        if 1 ~= view.currentValue then
          view:DoSelectCurrentValue(1)
        end
      else
        view:SetEnabled(true)
      end
    end
  end
end
function ScalabilityQualityMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  if oriData.indexKey == "SSAOQuality" or oriData.indexKey == "SSRQuality" then
    if 2 == SettingSaveDataProxy:GetTemplateValueByKey("RenderMode") then
      view:SetEnabled(false)
    else
      view:SetEnabled(true)
    end
  end
end
function ScalabilityQualityMediator:ChangeValueEvent()
  SuperClass.ChangeValueEvent(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  GameFacade:SendNotification(NotificationDefines.Setting.SettingScalabilityChangedNtf, {
    oriData = oriData,
    value = view.currentValue
  })
end
return ScalabilityQualityMediator
