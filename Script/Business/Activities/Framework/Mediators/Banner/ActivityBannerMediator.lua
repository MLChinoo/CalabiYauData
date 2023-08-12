local ActivityBannerMediator = class("ActivityBannerMediator", PureMVC.Mediator)
function ActivityBannerMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.PreviewUpdate,
    NotificationDefines.Activities.ActivityRedDotUpdate
  }
end
function ActivityBannerMediator:OnRegister()
  self:GetViewComponent().updateViewEvent:Add(self.UpdateViewData, self)
end
function ActivityBannerMediator:OnRemove()
  self:GetViewComponent().updateViewEvent:Remove(self.UpdateViewData, self)
end
function ActivityBannerMediator:UpdateViewData()
  GameFacade:SendNotification(NotificationDefines.Activities.ReqActivitiesCmd)
end
function ActivityBannerMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.PreviewUpdate then
    local proxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
    if proxy then
      local activities = proxy:GetMainActivitie()
      if activities then
        LogDebug("ActivityBannerMediator", "activities.activityId = " .. tostring(activities.activityId) .. "    activities.cfg.sort = " .. tostring(activities.cfg.sort))
        viewComponent:UpdateView({activities})
      else
        viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  elseif noteName == NotificationDefines.Activities.ActivityRedDotUpdate then
    local noteBody = notification:GetBody()
    viewComponent:UpdateRedDot(noteBody.activityId, noteBody.reddotNum)
  end
end
return ActivityBannerMediator
