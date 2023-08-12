local MapPopUpInfoItemMediator = class("MapPopUpInfoItemMediator", PureMVC.Mediator)
function MapPopUpInfoItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.SetMapInfoSelect
  }
end
function MapPopUpInfoItemMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.TeamRoom.SetMapInfoSelect then
    if notify:GetBody().mapId == self:GetViewComponent().mapId and notify:GetBody().mapType == self:GetViewComponent().mapType then
      self:SetSelected(notify:GetBody().bSelected)
    else
      self:SetSelected(false)
    end
  end
end
function MapPopUpInfoItemMediator:OnRegister()
  self:GetViewComponent().actionOnClickMap:Add(self.OnClickMap, self)
  self:GetViewComponent().actionOnHoverMap:Add(self.OnHoverMap, self)
  self:GetViewComponent().actionSetSelected:Add(self.SetSelected, self)
end
function MapPopUpInfoItemMediator:OnRemove()
  self:GetViewComponent().actionOnClickMap:Remove(self.OnClickMap, self)
  self:GetViewComponent().actionOnHoverMap:Remove(self.OnHoverMap, self)
  self:GetViewComponent().actionSetSelected:Remove(self.SetSelected, self)
end
function MapPopUpInfoItemMediator:OnClickMap()
  self:GetViewComponent().parentMediator:SetMapID(self:GetViewComponent().mapId)
end
function MapPopUpInfoItemMediator:OnHoverMap()
  local vis = self:GetViewComponent().Button_Map:IsHovered() and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed
  self:GetViewComponent().Image_Hover:SetVisibility(vis)
end
function MapPopUpInfoItemMediator:SetSelected(bSelected)
  self:GetViewComponent().Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().Image_Select:SetVisibility(bSelected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if bSelected then
    self:GetViewComponent().WS_MapName:SetActiveWidgetIndex(1)
  else
    self:GetViewComponent().WS_MapName:SetActiveWidgetIndex(0)
  end
end
return MapPopUpInfoItemMediator
