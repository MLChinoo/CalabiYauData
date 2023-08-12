local LeadboardSubTypeItemPanelMediator = class("LeadboardSubTypeItemPanelMediator", PureMVC.Mediator)
function LeadboardSubTypeItemPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.CareerRank.ClearAllLeadboardSubTypeBtnCheck,
    NotificationDefines.Career.CareerRank.SelectLeadboardSubTypeBtnCheck
  }
end
function LeadboardSubTypeItemPanelMediator:HandleNotification(notify)
  local viewComponent = self:GetViewComponent()
  if notify:GetName() == NotificationDefines.Career.CareerRank.ClearAllLeadboardSubTypeBtnCheck then
    if notify:GetBody() ~= viewComponent.bp_leaderboardType then
      self:GetViewComponent():OnClearBtnStyle()
    end
  elseif notify:GetName() == NotificationDefines.Career.CareerRank.SelectLeadboardSubTypeBtnCheck and notify:GetBody() == viewComponent.bp_leaderboardType then
    self:GetViewComponent():OnCheckStateChanged(true)
  end
end
return LeadboardSubTypeItemPanelMediator
