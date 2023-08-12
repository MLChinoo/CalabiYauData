local HermesGoodsDetailMediator = class("HermesGoodsDetailMediator", PureMVC.Mediator)
local HermesGoodsDetailPage
function HermesGoodsDetailMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.HermesGoodsDetailUpdate, luaData)
end
function HermesGoodsDetailMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesGoodsDetailNtf,
    NotificationDefines.HermesGoodsDetailClickItem,
    NotificationDefines.HermesHotListRefreshPriceState,
    NotificationDefines.HermesJumpToBuyCrystal
  }
end
function HermesGoodsDetailMediator:HandleNotification(notification)
  HermesGoodsDetailPage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesGoodsDetailNtf then
    HermesGoodsDetailPage:Init(Body)
  elseif Name == NotificationDefines.HermesGoodsDetailClickItem then
    HermesGoodsDetailPage:UpdatePanel(Body)
  elseif Name == NotificationDefines.HermesHotListRefreshPriceState then
    HermesGoodsDetailPage:UpdateButton()
  elseif Name == NotificationDefines.HermesJumpToBuyCrystal then
    HermesGoodsDetailPage:ClosePage()
  end
end
function HermesGoodsDetailMediator:OnRegister()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.HermesHotListVisibility, false)
end
function HermesGoodsDetailMediator:OnRemove()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.HermesHotListVisibility, true)
end
return HermesGoodsDetailMediator
