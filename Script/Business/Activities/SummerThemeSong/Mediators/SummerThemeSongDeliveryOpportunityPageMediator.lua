local SummerThemeSongDeliveryOpportunityPageMediator = class("SummerThemeSongDeliveryOpportunityPageMediator", PureMVC.Mediator)
function SummerThemeSongDeliveryOpportunityPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes
  }
end
function SummerThemeSongDeliveryOpportunityPageMediator:OnRegister()
end
function SummerThemeSongDeliveryOpportunityPageMediator:OnRemove()
end
function SummerThemeSongDeliveryOpportunityPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local ViewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes then
    ViewComponent:UpdateRemainingFlipTimes()
  end
end
return SummerThemeSongDeliveryOpportunityPageMediator
