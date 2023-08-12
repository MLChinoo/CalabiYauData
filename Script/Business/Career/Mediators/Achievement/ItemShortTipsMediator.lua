local ItemShortTipsMediator = class("ItemShortTipsMediator", PureMVC.Mediator)
function ItemShortTipsMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.Achievement.ShowAchievementShortTip
  }
end
function ItemShortTipsMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowAchievementShortTip then
    local achievementCfg = notification:GetBody()
  end
end
return ItemShortTipsMediator
