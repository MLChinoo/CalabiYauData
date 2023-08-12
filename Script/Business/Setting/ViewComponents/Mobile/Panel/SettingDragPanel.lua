local SettingDragPanel = class("SettingDragPanel", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingCustomLayoutMap = require("Business/Setting/Proxies/Map/SettingCustomLayoutMap")
local SettingDragPanelMediator = require("Business/Setting/Mediators/Mobile/SettingDragPanelMediator")
local CustomeKeyList = SettingCustomLayoutMap.KeyList
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function SettingDragPanel:ListNeededMediators()
  return {SettingDragPanelMediator}
end
function SettingDragPanel:InitializeLuaEvent()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local Config = SettingConfigProxy:GetCommonConfigMap()
  self.minScaleValue = Config.scaleRange.min
  self.maxScaleValue = Config.scaleRange.max
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("SpecialShapedAdaption")
  self.adaptionValue = value / SettingEnum.Multipler
  self.ScaleSpeed = self.ScaleSpeed or 2
end
function SettingDragPanel:RestoreLayoutAndBindFunc()
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local traversFunc = function(func)
    for indexName, tbl in pairs(CustomeKeyList) do
      local buttonName = tbl[1]
      if self[buttonName] then
        func(self[buttonName], indexName)
      else
        LogInfo("buttonName error", "buttonName is " .. tostring(buttonName))
      end
    end
  end
  traversFunc(function(button, indexName)
    button:BindDelegate(indexName, self)
  end)
  traversFunc(function(button, indexName)
    button:PostInit()
  end)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("Switch_LeftMarkPoint")
  local bSwitch = SettingHelper.CheckSwitchIsOn(value)
  if self.LeftMarkPointDragItem then
    if bSwitch then
      self.LeftMarkPointDragItem:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.LeftMarkPointDragItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if SettingSaveDataProxy:GetTemplateValueByKey("SmartAutoInWall") == UE4.ESmartAutoInWall.LeftJoyStick + 1 then
    self.bOpenLeftJoyStick = true
    self.SprintDragItem:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.bOpenLeftJoyStick = false
    self.SprintDragItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if SettingSaveDataProxy:GetTemplateValueByKey("Switch_ShowQuickSwitchWeapon") == UE4.ESwitch.ES_ON + 1 then
    self.SwitchExpectedWeaponDragItem:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.SwitchExpectedWeaponDragItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SettingDragPanel:InitView(parent)
  self:RestoreLayoutAndBindFunc()
  self.parent = parent
  self.bFirstTouchMoved = false
end
function SettingDragPanel:GetDragItemByIndex(indexName)
  local tbl = CustomeKeyList[indexName]
  if tbl and tbl[1] and self[tbl[1]] then
    return self[tbl[1]]
  else
    LogInfo("GetDragItemByIndex", "indexName : " .. tostring(indexName) .. "is not valid")
  end
end
function SettingDragPanel:SetDragItem(dragItem)
  if nil == dragItem then
    return
  end
  if nil == self.LastDragItem then
    self.LastDragItem = self.DragItem
  end
  if self.LastDragItem then
    self.LastDragItem:SetSelected(false)
    self.LastDragItem = nil
  end
  self.DragItem = dragItem
  self.DragItem:SetSelected(true)
end
function SettingDragPanel:OnTouchStarted(MyGeometry, InTouchEvent)
  local PointerIndex = UE4.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
  print("onTouchStarted PointerIndex", PointerIndex)
  print("dragItem", self.DragItem)
  self.m_LastPosTable = self.m_LastPosTable or {}
  self.m_FigureCnt = self.m_FigureCnt or 0
  self.m_MoveFlag = true
  if self.m_FigureCnt < 2 then
    local ScreenSpacePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
    local thisPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, ScreenSpacePosition)
    self.m_LastPosTable[PointerIndex + 1] = thisPos
    local cnt = 0
    for k, v in pairs(self.m_LastPosTable) do
      cnt = cnt + 1
    end
    self.m_FigureCnt = cnt
    if 1 == self.m_FigureCnt then
      local screenSpacePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
      local startTouchPosition = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, screenSpacePosition)
      local geometry = self.DragItem:GetCachedGeometry()
      if UE4.USlateBlueprintLibrary.IsUnderLocation(geometry, screenSpacePosition) == false then
        return UE4.UWidgetBlueprintLibrary.Unhandled()
      else
        self.lastTouchPosition = startTouchPosition
      end
    elseif 2 == self.m_FigureCnt then
      local otherPos
      for _pointerIndex, v in pairs(self.m_LastPosTable) do
        if _pointerIndex ~= PointerIndex + 1 then
          otherPos = v
        end
      end
      if self.DragItem.currentData.scale ~= nil then
        self.m_ZoomStartLength = UE4.UKismetMathLibrary.Distance2D(thisPos, otherPos)
        print("m_ZoomStartLength", self.m_ZoomStartLength)
        self.m_ZoomStartScaleValue = self.DragItem.currentData.scale * 100
        print("m_ZoomStartScaleValue", self.m_ZoomStartScaleValue)
      else
        self.m_ZoomStartLength = nil
        self.m_ZoomStartScaleValue = nil
      end
    end
    local Handled = UE4.UWidgetBlueprintLibrary.Handled()
    return UE4.UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingDragPanel:OnTouchMoved(MyGeometry, InTouchEvent)
  if self.m_MoveFlag then
    self.m_MoveFlag = false
    local PointerIndex = UE4.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
    self.m_LastPosTable = self.m_LastPosTable or {}
    self.m_FigureCnt = self.m_FigureCnt or 0
    print("OnTouchMoved PointerIndex", PointerIndex)
    if self.m_LastPosTable[PointerIndex + 1] ~= nil then
      local ScreenSpacePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
      local localPosition = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, ScreenSpacePosition)
      self.m_LastPosTable[PointerIndex + 1] = localPosition
      if 1 == self.m_FigureCnt then
        if self.DragItem and self.lastTouchPosition then
          local localsize = UE4.USlateBlueprintLibrary.GetLocalSize(MyGeometry)
          local dx, dy = self.DragItem:CorrectMoveOffset(localPosition.X - self.lastTouchPosition.X, localPosition.Y - self.lastTouchPosition.Y)
          self.lastTouchPosition = localPosition
          self.DragItem:MoveByOffset(dx, dy)
          if false == self.bFirstTouchMoved then
            self.bFirstTouchMoved = true
            self.parent.WBP_OperationControllerSetting_MB:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
          end
        end
      elseif 2 == self.m_FigureCnt then
        local otherPos
        for _pointerIndex, v in pairs(self.m_LastPosTable) do
          if _pointerIndex ~= PointerIndex + 1 then
            otherPos = v
          end
        end
        if nil ~= self.m_ZoomStartScaleValue then
          local MoveDist = UE4.UKismetMathLibrary.Distance2D(localPosition, otherPos)
          local ZoomStartScaleValue = self.m_ZoomStartScaleValue
          print("movedist", MoveDist - self.m_ZoomStartLength)
          ZoomStartScaleValue = ZoomStartScaleValue + (MoveDist - self.m_ZoomStartLength) / self.ScaleSpeed
          if ZoomStartScaleValue <= self.minScaleValue then
            ZoomStartScaleValue = self.minScaleValue
          end
          if ZoomStartScaleValue >= self.maxScaleValue then
            ZoomStartScaleValue = self.maxScaleValue
          end
          print("ZoomStartScaleValue >>>>", ZoomStartScaleValue)
          if self.scaleBar then
            self.scaleBar:SetCurrentValue(ZoomStartScaleValue)
          end
        end
      end
      self.m_MoveFlag = true
      local Handled = UE4.UWidgetBlueprintLibrary.Handled()
      return Handled
    end
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingDragPanel:OnTouchEnded(MyGeometry, InTouchEvent)
  local PointerIndex = UE4.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
  print("OnTouchEnded PointerIndex", PointerIndex)
  self.LastDragItem = self.DragItem
  if self.bFirstTouchMoved == true then
    self.parent.WBP_OperationControllerSetting_MB:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.bFirstTouchMoved = false
  end
  self.m_LastPosTable = self.m_LastPosTable or {}
  if self.m_LastPosTable[PointerIndex + 1] ~= nil then
    self.m_LastPosTable[PointerIndex + 1] = nil
    self.m_FigureCnt = self.m_FigureCnt - 1
    if 1 == self.m_FigureCnt then
      local otherPos
      for _pointerIndex, v in pairs(self.m_LastPosTable) do
        otherPos = v
      end
      self.lastTouchPosition = otherPos
    elseif 0 == self.m_FigureCnt then
      self.lastTouchPosition = nil
    end
    local Handled = UE4.UWidgetBlueprintLibrary.Handled()
    return UE4.UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
  end
  print("---------------begin-------------------")
  for k, v in pairs(self.m_LastPosTable) do
    print("k>>>v", k, v)
  end
  print("---------------  end-------------------")
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingDragPanel:SetAbbrev(index)
  self.abbrevIndex = index
  self:RestoreLayoutAndBindFunc()
end
function SettingDragPanel:Update()
  self:RestoreLayoutAndBindFunc()
end
function SettingDragPanel:RecordIndex()
  if self.m_LastPosTable then
    for k, v in pairs(self.m_LastPosTable) do
      self.figurePosition = v
    end
  end
end
function SettingDragPanel:SetFigureIndex()
  if self.m_LastPosTable then
    self.m_LastPosTable[3] = self.figurePosition
    self.m_FigureCnt = 1
  end
end
function SettingDragPanel:SetScaleProgressBar(bar)
  self.scaleBar = bar
end
function SettingDragPanel:SetAdaptionValue(value)
  self.adaptionValue = value
end
function SettingDragPanel:SetLayout(pageIndex)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  SettingOperationProxy:EnterPage(pageIndex)
  self:RestoreLayoutAndBindFunc()
end
return SettingDragPanel
