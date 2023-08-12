local GuideUIGuideMediator = class("GuideUIGuideMediator", PureMVC.Mediator)
local ModuleProxyNames = ProxyNames
local ModuleNotificationDefines = NotificationDefines.Guide
local ESlateVisibility = UE4.ESlateVisibility
local FVector2D = UE4.FVector2D
local ECyGuideUIGuideType = UE4.ECyGuideUIGuideType or {}
function GuideUIGuideMediator:ListNotificationInterests()
  return {
    ModuleNotificationDefines.UIGuide
  }
end
function GuideUIGuideMediator:HandleNotification(notification)
  local notificationType = notification:GetType()
  if ModuleNotificationDefines.UIGuideType.Begin == notificationType then
    self:OnUIGuideBegin(notification:GetBody())
  elseif ModuleNotificationDefines.UIGuideType.End == notificationType then
    self:OnUIGuideEnd(notification:GetBody())
  end
end
function GuideUIGuideMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  local World = viewComponent:GetWorld()
  if not World then
    return
  end
  if viewComponent.CanvasPanel_UIGuide then
    viewComponent.CanvasPanel_UIGuide:ClearChildren()
  end
  viewComponent.OnViewTargetChangedEvent:Add(self.OnViewTargetChangedEvent, self)
  if GameFacade then
    local GuideProxy = GameFacade:RetrieveProxy(ModuleProxyNames.GuideProxy)
    if GuideProxy then
      GuideProxy:TryInitGuideUIGuide(World)
    end
  end
end
function GuideUIGuideMediator:OnUIGuideBegin(InData)
  local World = LuaGetWorld()
  local viewComponent = self.viewComponent
  local OwningPlayer = viewComponent and viewComponent:GetOwningPlayer() or nil
  if not (InData and World and OwningPlayer and viewComponent and viewComponent.CanvasPanel_UIGuide) or not viewComponent.UIGuideTypeAndGuideWidgetMap then
    return
  end
  LogInfo("GuideUIGuideMediator", "OnUIGuideBegin")
  if viewComponent and viewComponent.CanvasPanel_UIGuide then
    viewComponent.CanvasPanel_UIGuide:ClearChildren()
  end
  local WidgetClass, Widget, AnchorData, PredefineLocationUIName, PredefineLocationUI, CanvasPanelSlot
  for _, UIGuideTypeConfig in ipairs(InData) do
    WidgetClass = viewComponent.UIGuideTypeAndGuideWidgetMap:Find(UIGuideTypeConfig.UIGuideType)
    if WidgetClass then
      AnchorData = nil
      if UIGuideTypeConfig.bCustomLayout then
        AnchorData = UIGuideTypeConfig.AnchorData
      elseif viewComponent.GameUIFunctionAndUILocationMap then
        PredefineLocationUIName = viewComponent.GameUIFunctionAndUILocationMap:Find(UIGuideTypeConfig.GameFunctionType)
        if PredefineLocationUIName then
          PredefineLocationUI = viewComponent:K2_GetWidgetFromName(PredefineLocationUIName)
          AnchorData = PredefineLocationUI and PredefineLocationUI.Slot and PredefineLocationUI.Slot.GetLayout and PredefineLocationUI.Slot:GetLayout() or nil
          if AnchorData then
            if ECyGuideUIGuideType.LeftTextInfo == UIGuideTypeConfig.UIGuideType then
              AnchorData.Alignment = FVector2D(0.0, 1.0)
              AnchorData.Offsets.Top = AnchorData.Offsets.Top - AnchorData.Offsets.Bottom / 2.0
              AnchorData.Offsets.Right = 100.0
              AnchorData.Offsets.Bottom = 100.0
            elseif ECyGuideUIGuideType.RightTextInfo == UIGuideTypeConfig.UIGuideType then
              AnchorData.Alignment = FVector2D(1.0, 1.0)
              AnchorData.Offsets.Top = AnchorData.Offsets.Top - AnchorData.Offsets.Bottom / 2.0
              AnchorData.Offsets.Right = 100.0
              AnchorData.Offsets.Bottom = 100.0
            end
            if UIGuideTypeConfig.bCustomLocation then
              if UIGuideTypeConfig.Location then
                AnchorData.Offsets.Left = UIGuideTypeConfig.Location.X
                AnchorData.Offsets.Top = UIGuideTypeConfig.Location.Y
              end
            elseif UIGuideTypeConfig.LocationOffset then
              AnchorData.Offsets.Left = AnchorData.Offsets.Left + UIGuideTypeConfig.LocationOffset.X
              AnchorData.Offsets.Top = AnchorData.Offsets.Top + UIGuideTypeConfig.LocationOffset.Y
            end
            if UIGuideTypeConfig.Size and UIGuideTypeConfig.Size.X > 0.001 and UIGuideTypeConfig.Size.Y > 0.001 then
              AnchorData.Offsets.Right = UIGuideTypeConfig.Size.X
              AnchorData.Offsets.Bottom = UIGuideTypeConfig.Size.Y
            end
          end
        end
      end
      if AnchorData then
        Widget = UE4.UWidgetBlueprintLibrary.Create(World, WidgetClass, OwningPlayer)
        if Widget and Widget.InitPanel then
          CanvasPanelSlot = viewComponent.CanvasPanel_UIGuide:AddChildToCanvas(Widget)
          if CanvasPanelSlot then
            CanvasPanelSlot:SetLayout(AnchorData)
          end
          Widget:InitPanel(UIGuideTypeConfig)
        end
      else
        LogInfo("GuideUIGuideMediator", "Warn: AnchorData not found !!! GameFunctionType=" .. UIGuideTypeConfig.GameFunctionType)
      end
    else
      LogInfo("GuideUIGuideMediator", "Warn: Widget Class not found !!! UIGuideType=" .. UIGuideTypeConfig.UIGuideType)
    end
  end
end
function GuideUIGuideMediator:OnUIGuideEnd(InData)
  LogInfo("GuideUIGuideMediator", "OnUIGuideEnd")
  local viewComponent = self.viewComponent
  if viewComponent and viewComponent.CanvasPanel_UIGuide then
    viewComponent.CanvasPanel_UIGuide:ClearChildren()
  end
end
function GuideUIGuideMediator:OnViewTargetChangedEvent(InViewTarget)
  if self.viewComponent then
    local bPawnControlled = InViewTarget and InViewTarget.IsPawnControlled and InViewTarget:IsPawnControlled() or false
    self.viewComponent:SetVisibility(bPawnControlled and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Collapsed)
  end
end
return GuideUIGuideMediator
