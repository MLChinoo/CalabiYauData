local ActivityEntryPanelMediator = class("ActivityEntryPanelMediator", PureMVC.Mediator)
local ActivitiesProxy
function ActivityEntryPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.PreviewUpdate,
    NotificationDefines.Activities.ActivityRedDotUpdate
  }
end
function ActivityEntryPanelMediator:OnRegister()
  self:GetViewComponent().updateViewEvent:Add(self.UpdateViewData, self)
  ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
end
function ActivityEntryPanelMediator:OnRemove()
  self:GetViewComponent().updateViewEvent:Remove(self.UpdateViewData, self)
end
function ActivityEntryPanelMediator:UpdateViewData()
  GameFacade:SendNotification(NotificationDefines.Activities.ReqActivitiesCmd)
end
function ActivityEntryPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.PreviewUpdate then
    if table.count(ActivitiesProxy:GetAllEnableActivities()) > 1 and viewComponent.apartmentVisible then
      viewComponent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetRedDot(self:HasRedDot())
  elseif noteName == NotificationDefines.Activities.ActivityRedDotUpdate then
    self:SetRedDot(self:HasRedDot())
  end
end
function ActivityEntryPanelMediator:HasRedDot()
  local mainActivity = ActivitiesProxy:GetMainActivitie()
  if not mainActivity then
    return 0
  end
  local ActivityRedList = ActivitiesProxy:GetActivityRedList()
  for key, value in pairs(ActivityRedList) do
    if mainActivity.activityId ~= key and value > 0 then
      return value
    end
  end
  return 0
end
function ActivityEntryPanelMediator:SetRedDot(num)
  if self:GetViewComponent().RedDot then
    self:GetViewComponent().RedDot:SetVisibility(num > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return ActivityEntryPanelMediator
