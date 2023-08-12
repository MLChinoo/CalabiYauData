local HermesHotListMediator = class("HermesHotListMediator", PureMVC.Mediator)
local HermesHotListPage
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
function HermesHotListMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.HermesHotListUpdate)
end
function HermesHotListMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
end
function HermesHotListMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesHotListNtf,
    NotificationDefines.HermesHotListVisibility
  }
end
function HermesHotListMediator:HandleNotification(notification)
  HermesHotListPage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesHotListNtf then
    HermesHotListPage:Update(Body)
  end
  if Name == NotificationDefines.HermesHotListVisibility then
    if Body then
      HermesHotListPage:SetVisibility(Visible)
      HermesHotListPage:SetScrollBarPause(false)
    else
      HermesHotListPage:SetVisibility(Collapsed)
      HermesHotListPage:SetScrollBarPause(true)
    end
  end
end
function HermesHotListMediator:OnRegister()
end
function HermesHotListMediator:OnRemove()
end
return HermesHotListMediator
