local OperationSettingPanelMB = class("OperationSettingPanelMB", PureMVC.ViewComponentPanel)
local OperationSettingPanelMBMediator = require("Business/Setting/Mediators/Mobile/OperationSettingPanelMBMediator")
function OperationSettingPanelMB:ListNeededMediators()
  return {OperationSettingPanelMBMediator}
end
function OperationSettingPanelMB:InitializeLuaEvent()
  local World = self:GetWorld()
  if self.CanvasPanel_OperationCustom and World then
    local GameState = UE4.UGameplayStatics.GetGameState(World)
    if GameState and GameState.GetModeType then
      local GameModeType = GameState:GetModeType()
      if UE4.EPMGameModeType.NoviceGuide == GameModeType then
        self.CanvasPanel_OperationCustom:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  self.Button_CustomLayout.OnClicked:Add(self, OperationSettingPanelMB.OnClickCustomLayoutButton)
  self.Button_Bg.OnClicked:Add(self, OperationSettingPanelMB.OnClickBg1)
  self.Button_Bg_Second.OnClicked:Add(self, OperationSettingPanelMB.OnClickBg2)
  self.Button_Bg_Third.OnClicked:Add(self, OperationSettingPanelMB.OnClickBg3)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  self.OperationOriData = SettingConfigProxy:GetOriDataByIndexKey("OperationIndex")
  self.LayoutOriData = SettingConfigProxy:GetOriDataByIndexKey("LayoutIndex")
  self.oriData = self.OperationOriData
  self.SelectImgArr = {
    self.Img_First_Select,
    self.Img_Second_Select,
    self.Img_Third_Select
  }
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetCurrentValueByKey("LayoutIndex")
  self.DragPanel:SetAbbrev(value)
  TimerMgr:AddTimeTask(0.1, 0, 0, function()
    local World = self:GetWorld()
    if not World then
      LogInfo("OperationSettingPanelMB:InitializeLuaEvent", "Not World !!!")
      return
    end
    local RootGeometry = UE4.UWidgetLayoutLibrary.GetViewportWidgetGeometry(World)
    if not RootGeometry then
      LogInfo("OperationSettingPanelMB:InitializeLuaEvent", "Not RootGeometry !!!")
      return
    end
    local RootLocalSize = UE4.USlateBlueprintLibrary.GetLocalSize(RootGeometry)
    LogInfo("OperationSettingPanelMB:InitializeLuaEvent", "UIRootLocalSize=[%.2f, %.2f]", RootLocalSize.X, RootLocalSize.Y)
    if RootLocalSize.X < 1 or RootLocalSize.Y < 1 then
      LogInfo("OperationSettingPanelMB:InitializeLuaEvent", "Not Get RootGeometry Size !!!")
      return
    end
    local targetSize = RootLocalSize
    self.PMSafeZone_1.Slot:SetSize(targetSize)
    local sx = targetSize.X / 1920
    local sy = targetSize.Y / 1080
    local bgSize = self.CanvasPanel_1.Slot:GetSize()
    local iniScale = {
      X = 1920 / bgSize.X,
      Y = 1080 / bgSize.Y
    }
    if sx > sy then
      scale = sx
    else
      scale = sy
    end
    local ty = bgSize.Y / scale
    local ty2 = (bgSize.Y - ty) / 2
    self.Image_1.Slot:SetSize(UE4.FVector2D(0, ty2))
    self.Image_1.Slot:SetPosition(UE4.FVector2D(0, ty2))
    self.PMSafeZone_1:SetRenderScale(UE4.FVector2D(1 / scale / iniScale.X, 1 / scale / iniScale.Y))
    self.PMSafeZone_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DragPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end)
end
function OperationSettingPanelMB:InitView()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local value = SettingSaveDataProxy:GetCurrentValueByKey("OperationIndex")
  self:ShowCustomButton(value)
end
function OperationSettingPanelMB:ShowCustomButton(index)
  for i, v in ipairs(self.SelectImgArr) do
    v:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.SelectImgArr[index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  settingSaveDataProxy:UpdateTemplateData(self.OperationOriData, index)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf, {
    oriData = self.OperationOriData,
    value = index
  })
end
function OperationSettingPanelMB:OnClickBg1()
  self:ShowCustomButton(1)
end
function OperationSettingPanelMB:OnClickBg2()
  self:ShowCustomButton(2)
end
function OperationSettingPanelMB:OnClickBg3()
  self:ShowCustomButton(3)
end
function OperationSettingPanelMB:UpdateOperationDragPanel()
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local layoutIndex = SettingOperationProxy:GetLayoutIndex()
  local settingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  settingSaveDataProxy:UpdateTemplateData(self.LayoutOriData, layoutIndex)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf, {
    oriData = self.LayoutOriData,
    value = layoutIndex
  })
  self.DragPanel:SetAbbrev(layoutIndex)
  self.DragPanel:Update()
end
function OperationSettingPanelMB:OnClickCustomLayoutButton()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local value = SettingSaveDataProxy:GetTemplateValueByKey("LayoutIndex")
  SettingOperationProxy:EnterPage(value)
  ViewMgr:OpenPage(self, UIPageNameDefine.SettingOperatePage)
end
function OperationSettingPanelMB:RefreshView(value)
  self:ShowCustomButton(value)
end
return OperationSettingPanelMB
