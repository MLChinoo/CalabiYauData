local HermesHotListSingleProductMediator = class("HermesHotListSingleProductMediator", PureMVC.Mediator)
local HermesHotListSingleProductPanel
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
function HermesHotListSingleProductMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesHotListRefreshPriceState
  }
end
function HermesHotListSingleProductMediator:HandleNotification(notification)
  HermesHotListSingleProductPanel = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesHotListRefreshPriceState then
    HermesHotListSingleProductPanel:UpdateButton()
  end
end
return HermesHotListSingleProductMediator
