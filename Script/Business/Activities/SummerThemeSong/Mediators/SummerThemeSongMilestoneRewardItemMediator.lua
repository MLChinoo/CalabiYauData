local SummerThemeSongMilestoneRewardItemMediator = class("SummerThemeSongMilestoneRewardItemMediator", PureMVC.Mediator)
function SummerThemeSongMilestoneRewardItemMediator:ListNotificationInterests()
  return {}
end
function SummerThemeSongMilestoneRewardItemMediator:OnRegister()
end
function SummerThemeSongMilestoneRewardItemMediator:OnRemove()
end
function SummerThemeSongMilestoneRewardItemMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase then
    self:GetViewComponent():InitMilestoneRewardItem(2)
  end
end
return SummerThemeSongMilestoneRewardItemMediator
