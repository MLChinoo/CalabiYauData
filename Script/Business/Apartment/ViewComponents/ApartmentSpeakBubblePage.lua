local ApartmentSpeakBubblePage = class("ApartmentSpeakBubblePage", PureMVC.ViewComponentPage)
function ApartmentSpeakBubblePage:ListNeededMediators()
  return {}
end
function ApartmentSpeakBubblePage:Construct()
  ApartmentSpeakBubblePage.super.Construct(self)
  local StatusTypeFixPosition = {}
  StatusTypeFixPosition[UE4.EPMApartmentRoleStatusType.Stand] = {
    position = UE4.FVector2D(100, 0)
  }
  StatusTypeFixPosition[UE4.EPMApartmentRoleStatusType.Sit] = {
    position = UE4.FVector2D(100, -100)
  }
  StatusTypeFixPosition[UE4.EPMApartmentRoleStatusType.Lie] = {
    position = UE4.FVector2D(0, 0)
  }
  self.StatusTypeFixPosition = StatusTypeFixPosition
  local StateMachineProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self.StateMachineProxy = StateMachineProxy
  if self.ImgBubble then
    self.ImgBubble.OnMouseButtonDownEvent:Bind(self, self.OnImgBubble)
  end
end
function ApartmentSpeakBubblePage:Destruct()
  ApartmentSpeakBubblePage.super.Destruct(self)
  if self.ImgBubble then
    self.ImgBubble.OnMouseButtonDownEvent:Unbind()
  end
end
function ApartmentSpeakBubblePage:OnOpen(luaOpenData, nativeOpenData)
  self:SetCharacterBubbleWidget(self)
  self.BubbleSlot = self.SpeakBubblePanel.Slot
  self:PlayAnimation(self.Edition_Pop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function ApartmentSpeakBubblePage:OnClose()
  self:SetCharacterBubbleWidget(nil)
end
function ApartmentSpeakBubblePage:AdjustPos(ScreenPos)
  if self.BubbleSlot then
    local ViewportPos = UE.FVector2D(0, 0)
    UE4.USlateBlueprintLibrary.ScreenToViewport(self, ScreenPos, ViewportPos)
    local FixPos = self:GetFixPosition()
    if FixPos then
      ViewportPos.X = ViewportPos.X + FixPos.X
      ViewportPos.Y = ViewportPos.Y + FixPos.Y
    end
    self.BubbleSlot:SetPosition(ViewportPos)
  end
end
function ApartmentSpeakBubblePage:GetFixPosition()
  local roleState = self.StateMachineProxy:GetApartmnetRoleState()
  return UE4.FVector2D(200, -150)
end
function ApartmentSpeakBubblePage:SetCharacterBubbleWidget(widget)
  local system = UE4.UPMApartmentSubsystem.Get(self)
  local character = system:GetApartmentCharacter()
  if character then
    character:SetBubbleWidget(widget)
  end
end
function ApartmentSpeakBubblePage:OnImgBubble()
  GameFacade:SendNotification(NotificationDefines.ApartmentSpeakBubbleClicked)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return ApartmentSpeakBubblePage
