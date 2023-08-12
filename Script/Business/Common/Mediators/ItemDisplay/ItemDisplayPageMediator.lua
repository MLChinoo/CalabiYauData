local ItemDisplayPageMediator = class("ItemDisplayPageMediator", PureMVC.Mediator)
function ItemDisplayPageMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.Common.OpenItemDisplayPageCmd, luaData)
end
function ItemDisplayPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesGoodsDetailClickItem,
    NotificationDefines.Common.SendItemDisplayDataNtf
  }
end
function ItemDisplayPageMediator:HandleNotification(notification)
  viewComponent = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.Common.SendItemDisplayDataNtf then
    viewComponent:Init(Body)
  elseif Name == NotificationDefines.HermesGoodsDetailClickItem then
    viewComponent:UpdatePanel(Body)
  end
end
function ItemDisplayPageMediator:OnRegister()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
end
function ItemDisplayPageMediator:OnRemove()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
end
return ItemDisplayPageMediator
