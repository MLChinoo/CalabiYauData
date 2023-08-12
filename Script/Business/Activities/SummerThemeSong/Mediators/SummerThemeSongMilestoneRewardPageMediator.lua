local SummerThemeSongMilestoneRewardPageMediator = class("SummerThemeSongMilestoneRewardPageMediator", PureMVC.Mediator)
function SummerThemeSongMilestoneRewardPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible
  }
end
function SummerThemeSongMilestoneRewardPageMediator:OnRegister()
end
function SummerThemeSongMilestoneRewardPageMediator:OnRemove()
end
function SummerThemeSongMilestoneRewardPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  if noteName == NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible then
    self:SetPageWidgetVisible(noteBody)
  end
end
function SummerThemeSongMilestoneRewardPageMediator:SetPageWidgetVisible(bVisible)
  local visibleEnum = UE4.ESlateVisibility.SelfHitTestInvisible
  if not bVisible then
    visibleEnum = UE4.ESlateVisibility.Collapsed
  end
  local ViewComponent = self:GetViewComponent()
  ViewComponent.Canvas_ButtonArea:SetVisibility(visibleEnum)
  ViewComponent.Text_ClickEmpty:SetVisibility(visibleEnum)
end
return SummerThemeSongMilestoneRewardPageMediator
