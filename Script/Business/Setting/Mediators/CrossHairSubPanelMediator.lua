local CrossHairSubPanelMediator = class("CrossHairSubPanelMediator", PureMVC.Mediator)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
local ItemType = SettingEnum.ItemType
function CrossHairSubPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingValueChangeNtf
  }
end
function CrossHairSubPanelMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingValueChangeNtf then
    if nil == body then
      return
    end
    local oriData = body.oriData
    if nil == oriData then
      return
    end
    local value = body.value
    local indexKey = oriData.indexKey
    self:SetValueByIndexKey(indexKey, value)
  end
end
function CrossHairSubPanelMediator:SetValueByIndexKey(indexKey, value)
  local view = self:GetViewComponent()
  if "CrossHairColor" == indexKey then
    view:SetCrossHairColor(value)
  elseif "Switch_OuterFrame" == indexKey then
    view:SetFrameSwitch(value)
  elseif "OuterFrameOpacity" == indexKey then
    view:SetFrameOpacity(value)
  elseif "OuterFrameThickness" == indexKey then
    view:SetFrameThickness(value)
  elseif "Switch_ShowCrossHair" == indexKey then
    view:SetShowCrossHairByItemList(value, view.CenterItemList)
  elseif "CrossHairCenterOpacity" == indexKey then
    view:SetCrossHairOpacityByItemList(value, view.CenterItemList)
  elseif "CrossHairCenterThickness" == indexKey then
    view:SetCenterCrossHairThickness(value)
  elseif "Switch_InnerCrossHair" == indexKey then
    view:SetShowCrossHairByItemList(value, view.InnerItemList)
  elseif "InnerCrossHairOpacity" == indexKey then
    view:SetCrossHairOpacityByItemList(value, view.InnerItemList)
  elseif "InnerCrossHairLength" == indexKey then
    view:SetCrossHairLengthByItemList(value, view.InnerItemList)
  elseif "InnerCrossHairThickness" == indexKey then
    view:SetCrossHairThicknessByItemList(value, view.InnerItemList)
  elseif "InnerCrossHairOffset" == indexKey then
    view:SetInnerOffset(value)
  elseif "Switch_OuterCrossHair" == indexKey then
    view:SetShowCrossHairByItemList(value, view.OuterItemList)
  elseif "OuterCrossHairOpacity" == indexKey then
    view:SetCrossHairOpacityByItemList(value, view.OuterItemList)
  elseif "OuterCrossHairLength" == indexKey then
    view:SetCrossHairLengthByItemList(value, view.OuterItemList)
  elseif "OuterCrossHairThickness" == indexKey then
    view:SetCrossHairThicknessByItemList(value, view.OuterItemList)
  elseif "OuterCrossHairOffset" == indexKey then
    view:SetOuterOffset(value)
  end
end
function CrossHairSubPanelMediator:OnRegister()
  self.super:OnRegister()
  local view = self:GetViewComponent()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local RefreshInnerViewByIndexKey = function(indexKey)
    local value = SettingSaveDataProxy:GetTemplateValueByKey(indexKey)
    self:SetValueByIndexKey(indexKey, value)
  end
  RefreshInnerViewByIndexKey("CrossHairColor")
  RefreshInnerViewByIndexKey("Switch_OuterFrame")
  RefreshInnerViewByIndexKey("OuterFrameOpacity")
  RefreshInnerViewByIndexKey("OuterFrameThickness")
  RefreshInnerViewByIndexKey("Switch_ShowCrossHair")
  RefreshInnerViewByIndexKey("CrossHairCenterOpacity")
  RefreshInnerViewByIndexKey("CrossHairCenterThickness")
  RefreshInnerViewByIndexKey("Switch_InnerCrossHair")
  RefreshInnerViewByIndexKey("InnerCrossHairOpacity")
  RefreshInnerViewByIndexKey("InnerCrossHairLength")
  RefreshInnerViewByIndexKey("InnerCrossHairThickness")
  RefreshInnerViewByIndexKey("InnerCrossHairOffset")
  RefreshInnerViewByIndexKey("Switch_OuterCrossHair")
  RefreshInnerViewByIndexKey("OuterCrossHairOpacity")
  RefreshInnerViewByIndexKey("OuterCrossHairLength")
  RefreshInnerViewByIndexKey("OuterCrossHairThickness")
  RefreshInnerViewByIndexKey("OuterCrossHairOffset")
end
function CrossHairSubPanelMediator:InitView()
end
function CrossHairSubPanelMediator:OnRemove()
  self.super:OnRemove()
end
return CrossHairSubPanelMediator
