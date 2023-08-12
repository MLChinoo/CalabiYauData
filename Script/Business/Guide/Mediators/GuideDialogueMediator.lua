local GuideDialogueMediator = class("GuideDialogueMediator", PureMVC.Mediator)
local ModuleProxyNames = ProxyNames
local ModuleNotificationDefines = NotificationDefines.Guide
local UKismetSystemLibrary = UE4.UKismetSystemLibrary
function GuideDialogueMediator:ListNotificationInterests()
  return {
    ModuleNotificationDefines.GuideDialogue
  }
end
function GuideDialogueMediator:HandleNotification(notification)
  local notificationType = notification:GetType()
  if ModuleNotificationDefines.GuideDialogueType.Begin == notificationType then
    self:OnGuideDialogBegin(notification:GetBody())
  elseif ModuleNotificationDefines.GuideDialogueType.End == notificationType then
    self:OnGuideDialogEnd(notification:GetBody())
  end
end
function GuideDialogueMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  local World = viewComponent:GetWorld()
  if not World then
    return
  end
  if viewComponent then
    viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if GameFacade then
    local GuideProxy = GameFacade:RetrieveProxy(ModuleProxyNames.GuideProxy)
    if GuideProxy then
      GuideProxy:TryInitGuideDialogue(World)
    end
  end
end
function GuideDialogueMediator:OnGuideDialogBegin(InData)
  local viewComponent = self.viewComponent
  if not InData or not viewComponent then
    return
  end
  local DialogueData = InData
  self.DialogueData = nil
  viewComponent:StopAllAnimations()
  viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if DialogueData.DialogueId <= 0 then
    return
  end
  LogInfo("GuideDialogueMediator", "OnGuideDialogBegin")
  self.DialogueData = DialogueData
  viewComponent:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if viewComponent.WidgetSwitcher_Head then
    viewComponent.WidgetSwitcher_Head:SetActiveWidgetIndex(DialogueData.bFlickerHead and 1 or 0)
  end
  if DialogueData.RoleHead then
    if DialogueData.bFlickerHead then
      if viewComponent.Image_Head_Flicker and viewComponent.SetImageMatParamByTexture2D then
        viewComponent:SetImageMatParamByTexture2D(viewComponent.Image_Head_Flicker, "Map", DialogueData.RoleHead)
      end
    elseif viewComponent.Image_Head_Normal then
      viewComponent.Image_Head_Normal:SetBrushFromSoftTexture(DialogueData.RoleHead)
    end
  end
  if viewComponent.TextBlock_RoleName then
    viewComponent.TextBlock_RoleName:SetText(DialogueData.RoleName)
    viewComponent.TextBlock_RoleName:SetColorAndOpacity(DialogueData.RoleNameColor)
  end
  if viewComponent.FlowTextBlock_Text then
    if viewComponent.FlowTextBlock_Text.ClearShowText then
      viewComponent.FlowTextBlock_Text:ClearShowText()
    end
    viewComponent.FlowTextBlock_Text:SetText(DialogueData.Text)
  end
  if viewComponent.Anim_Begin then
    viewComponent:PlayAnimation(viewComponent.Anim_Begin, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end
function GuideDialogueMediator:OnGuideDialogEnd(InData)
  local viewComponent = self.viewComponent
  if not (InData and self.DialogueData) or not viewComponent then
    return
  end
  if self.DialogueData.DialogueId <= 0 then
    return
  end
  LogInfo("GuideDialogueMediator", "OnGuideDialogEnd")
  viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if viewComponent.Anim_End then
    viewComponent:PlayAnimation(viewComponent.Anim_End, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end
return GuideDialogueMediator
