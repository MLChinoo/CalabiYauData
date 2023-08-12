local InviteInfoPanel = class("InviteInfoPanel", PureMVC.ViewComponentPanel)
function InviteInfoPanel:ListNeededMediators()
  return {}
end
function InviteInfoPanel:InitializeLuaEvent()
  self.actionOnClickSelect = LuaEvent.new()
  self.actionOnClickSelectBorder = LuaEvent.new()
end
function InviteInfoPanel:Construct()
  InviteInfoPanel.super.Construct(self)
  self.Image_Icon.OnMouseButtonDownEvent:Bind(self, self.OnClickIcon)
  if self.bChecked then
    self:SetIsChecked(self.bChecked)
  end
  self.duration = 15
end
function InviteInfoPanel:Destruct()
  InviteInfoPanel.super.Construct(self)
  self.Image_Icon.OnMouseButtonDownEvent:Unbind()
end
function InviteInfoPanel:ShowPanel()
  self.TimerHandle_Countdown = TimerMgr:AddTimeTask(0, 1, 0, self.TimerFuncCountdown)
end
function InviteInfoPanel:OnClickIcon(inGeometry, inMouseEvent)
  if UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(inMouseEvent).KeyName == "LeftMouseButton" then
    self:SetIsChecked(true)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.OnCheckSwitchInfo, self)
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function InviteInfoPanel:TimerFuncCountdown()
  if self.duration <= 0 and self.TimerHandle_Countdown then
    self.TimerHandle_Countdown:EndTask()
  end
  self.duration = self.duration - 1
end
function InviteInfoPanel:SetIsChecked(bCheck)
  self.bChecked = bChecked
  if bCheck then
    self.Image_Line:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function InviteInfoPanel:GetSwitchInfo()
  return self.switchInfo
end
function InviteInfoPanel:SetRoomPlayerInfo(inVal)
  self.switchInfo = inVal
  self:LoadingHeadIcon(inVal.icon)
end
function InviteInfoPanel:LoadingHeadIcon(iconId)
  local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  local cardAvatarId = iconId
  if 0 == cardAvatarId then
    cardAvatarId = cardDataProxy:GetDefaultAvatarId()
  end
  local idCardTableRow = cardDataProxy:GetCardResourceTableFromId(cardAvatarId)
  if idCardTableRow then
    self:SetImageByTexture2D(self.Image_Icon, idCardTableRow.IconItem)
  end
end
function InviteInfoPanel:Remove()
  if self.TimerHandle_Countdown then
    self.TimerHandle_Countdown:EndTask()
  end
  ViewMgr:ClosePage(self)
end
return InviteInfoPanel
