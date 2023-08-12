local RoleWarmUpGoodsPanelMediator = class("RoleWarmUpGoodsPanelMediator", PureMVC.Mediator)
function RoleWarmUpGoodsPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesPurchaseGoodsNtf
  }
end
function RoleWarmUpGoodsPanelMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.HermesPurchaseGoodsUpdate, luaData)
end
function RoleWarmUpGoodsPanelMediator:OnRegister()
end
function RoleWarmUpGoodsPanelMediator:OnRemove()
end
function RoleWarmUpGoodsPanelMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesPurchaseGoodsNtf then
    self:GetViewComponent():Init(Body)
  end
end
return RoleWarmUpGoodsPanelMediator
