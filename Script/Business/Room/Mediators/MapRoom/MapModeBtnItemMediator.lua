local MapModeBtnItemMediator = class("MapModeBtnItemMediator", PureMVC.Mediator)
function MapModeBtnItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.MapRoom.ClearAllMapModeBtnCheck
  }
end
function MapModeBtnItemMediator:HandleNotification(notify)
  local viewComponent = self:GetViewComponent()
  if notify:GetName() == NotificationDefines.MapRoom.ClearAllMapModeBtnCheck and notify:GetBody() ~= viewComponent.bp_mapPlayModeType then
    self:GetViewComponent():OnClearBtnStyle()
  end
end
return MapModeBtnItemMediator
