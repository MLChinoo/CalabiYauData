local HermesTopUpMediator = class("HermesTopUpMediator", PureMVC.Mediator)
local HermesTopUpPage
function HermesTopUpMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
end
function HermesTopUpMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.Hermes.TopUp.MainPage.Update)
end
function HermesTopUpMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesTopUpMainPageNtf
  }
end
function HermesTopUpMediator:HandleNotification(notification)
  HermesTopUpPage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesTopUpMainPageNtf then
    HermesTopUpPage:Update(Body)
  end
end
function HermesTopUpMediator:OnRegister()
end
function HermesTopUpMediator:OnRemove()
end
return HermesTopUpMediator
