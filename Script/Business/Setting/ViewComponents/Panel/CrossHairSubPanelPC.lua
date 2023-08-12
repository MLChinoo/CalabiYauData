local CrossHairSubPanel = class("CrossHairSubPanel", PureMVC.ViewComponentPanel)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local CrossHairSubPanelMediator = require("Business/Setting/Mediators/CrossHairSubPanelMediator")
function CrossHairSubPanel:ListNeededMediators()
  return {CrossHairSubPanelMediator}
end
function CrossHairSubPanel:InitializeLuaEvent()
  self.InnerItemList = {
    self.Item_Inner_Left,
    self.Item_Inner_Up,
    self.Item_Inner_Right,
    self.Item_Inner_Down
  }
  self.OuterItemList = {
    self.Item_Outer_Left,
    self.Item_Outer_Up,
    self.Item_Outer_Right,
    self.Item_Outer_Down
  }
  self.CenterItemList = {
    self.Item_Center
  }
  self.Item_Center:SetIsCenter(true)
  for i, v in pairs(self.InnerItemList) do
    v.bInner = true
  end
  self.InnerOffsetValue = 4
  self.InnerOffsetValueDf = 1
  self.OutterOffsetValue = 3
  self.OutterOffsetValueDf = 0
  if self.ButtonTest then
    self.ButtonTest.OnClicked:Add(self, self.OnClickTest)
  end
end
function CrossHairSubPanel:RefreshView()
end
function CrossHairSubPanel:TraverseAllItemListByFunc(func)
  self:TraverseItemListByFunc(self.InnerItemList, func)
  self:TraverseItemListByFunc(self.OuterItemList, func)
  self:TraverseItemListByFunc(self.CenterItemList, func)
end
function CrossHairSubPanel:TraverseItemListByFunc(itemlist, func)
  for i, v in ipairs(itemlist) do
    func(v)
  end
end
function CrossHairSubPanel:SetCrossHairColor(value)
  local hairColor = UE4.UPMSettingDataCenter.GetCrossHairColor(value - 1)
  local color = {
    hairColor.R,
    hairColor.G,
    hairColor.B
  }
  self:TraverseAllItemListByFunc(function(item)
    item:SetColor(color)
  end)
end
function CrossHairSubPanel:SetFrameOpacity(opacity)
  opacity = opacity / SettingEnum.Multipler
  self:TraverseAllItemListByFunc(function(item)
    item:SetBorderOpacity(opacity)
  end)
end
function CrossHairSubPanel:SetFrameSwitch(value)
  local bSwitch = SettingHelper.CheckSwitchIsOn(value)
  self:TraverseAllItemListByFunc(function(item)
    item:SetBorderSwitch(bSwitch)
  end)
end
function CrossHairSubPanel:SetFrameThickness(thickness)
  thickness = thickness / SettingEnum.Multipler
  self:TraverseAllItemListByFunc(function(item)
    item:SetBorderThickness(thickness)
  end)
end
function CrossHairSubPanel:SetShowCrossHairByItemList(value, itemlist)
  local bShow = SettingHelper.CheckSwitchIsOn(value)
  self:TraverseItemListByFunc(itemlist, function(item)
    item:SetVisible(bShow)
  end)
end
function CrossHairSubPanel:SetCrossHairOpacityByItemList(value, itemlist)
  value = value / SettingEnum.Multipler
  self:TraverseItemListByFunc(itemlist, function(item)
    item:SetContentOpacity(value)
  end)
end
function CrossHairSubPanel:SetCrossHairLengthByItemList(value, itemlist)
  print("value >>>>>>>>>>>>", value)
  value = value / SettingEnum.Multipler
  self:TraverseItemListByFunc(itemlist, function(item)
    item:SetContentLength(value)
  end)
end
function CrossHairSubPanel:SetCrossHairThicknessByItemList(value, itemlist)
  value = value / SettingEnum.Multipler
  self:TraverseItemListByFunc(itemlist, function(item)
    item:SetContentWidth(value)
  end)
end
function CrossHairSubPanel:SetCenterCrossHairThickness(value)
  value = value / SettingEnum.Multipler
  self.Item_Center:SetContentLength(value)
  self.Item_Center:SetContentWidth(value)
  self:RefreshOutOffset()
  self:RefreshInnerOffset()
end
function CrossHairSubPanel:SetInnerOffset(value)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local switch = SettingSaveDataProxy:GetTemplateValueByKey("Switch_InnerCrossHairShootOffset")
  self:RefreshInnerOffset(value, switch)
end
function CrossHairSubPanel:SetOuterOffset(value)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local switch = SettingSaveDataProxy:GetTemplateValueByKey("Switch_OuterCrossHairShootOffset")
  self:RefreshOutOffset(value, switch)
end
function CrossHairSubPanel:SetInnerCrossHairShootOffset(bSwitch)
  print("bSwitch SetInnerCrossHairShootOffset >>>>>", bSwitch)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("InnerCrossHairOffset")
  self:RefreshInnerOffset(value, bSwitch)
end
function CrossHairSubPanel:SetOuterCrossHairShootOffset(bSwitch)
  print("bSwitch SetOuterCrossHairShootOffset >>>>>", bSwitch)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("OuterCrossHairOffset")
  self:RefreshOutOffset(value, bSwitch)
end
function CrossHairSubPanel:RefreshOutOffset(offset, switch)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  if nil == switch then
    switch = SettingSaveDataProxy:GetTemplateValueByKey("Switch_OuterCrossHairShootOffset")
  end
  if nil == offset then
    offset = SettingSaveDataProxy:GetTemplateValueByKey("OuterCrossHairOffset")
  end
  local offsetValue = offset / SettingEnum.Multipler
  if SettingHelper.CheckSwitchIsOn(switch) then
    offsetValue = offsetValue + self.OutterOffsetValue - self.OutterOffsetValueDf
  else
    offsetValue = offsetValue - self.OutterOffsetValueDf
  end
  self.Item_Outer_Left.Slot:SetPosition(UE4.FVector2D(offsetValue * -1, 0))
  self.Item_Outer_Down.Slot:SetPosition(UE4.FVector2D(0, offsetValue))
  local dy = 1
  if self.Item_Center.curContentLength then
    if 1 == self.Item_Center.curContentLength % 2 then
      dy = 1
    else
      dy = 0
    end
  end
  self.Item_Outer_Up.Slot:SetPosition(UE4.FVector2D(0, offsetValue * -1 + dy))
  self.Item_Outer_Right.Slot:SetPosition(UE4.FVector2D(offsetValue - dy, 0))
end
function CrossHairSubPanel:RefreshInnerOffset(offset, switch)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  if nil == switch then
    switch = SettingSaveDataProxy:GetTemplateValueByKey("Switch_InnerCrossHairShootOffset")
  end
  if nil == offset then
    offset = SettingSaveDataProxy:GetTemplateValueByKey("InnerCrossHairOffset")
  end
  local offsetValue = offset / SettingEnum.Multipler
  if SettingHelper.CheckSwitchIsOn(switch) then
    offsetValue = offsetValue + self.InnerOffsetValue - self.InnerOffsetValueDf
  else
    offsetValue = offsetValue - self.InnerOffsetValueDf
  end
  local dy = 1
  if self.Item_Center.curContentLength then
    if 1 == self.Item_Center.curContentLength % 2 then
      dy = 1
    else
      dy = 0
    end
  end
  self.Item_Inner_Left.Slot:SetPosition(UE4.FVector2D(offsetValue * -1, 0))
  self.Item_Inner_Down.Slot:SetPosition(UE4.FVector2D(0, offsetValue))
  self.Item_Inner_Right.Slot:SetPosition(UE4.FVector2D(offsetValue - dy, 0))
  self.Item_Inner_Up.Slot:SetPosition(UE4.FVector2D(0, offsetValue * -1 + dy))
end
function CrossHairSubPanel:OnClickTest()
  local scale = self.CanvasPanel_Inner.RenderTransform.Scale
  local sscale
  if 1 == scale.X then
    sscale = 5
  else
    sscale = 1
  end
  local World = self:GetWorld()
  local RootGeometry = UE4.UWidgetLayoutLibrary.GetViewportWidgetGeometry(World)
  local RootLocalSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(RootGeometry)
  local sx = 1920 / RootLocalSize.X
  local sy = 1080 / RootLocalSize.Y
  self.CanvasPanel_Inner:SetRenderScale(UE4.FVector2D(sx, sy))
  self.Item_Center:SetRenderScale(UE4.FVector2D(sx, sy))
  self.CanvasPanel_Outer:SetRenderScale(UE4.FVector2D(sx, sy))
end
function CrossHairSubPanel:Refresh()
end
return CrossHairSubPanel
