local RankPreparePageMediator = class("RankPreparePageMediator", PureMVC.Mediator)
function RankPreparePageMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnQuitBattle
  }
end
function RankPreparePageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.TeamRoom.OnQuitBattle then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
  end
end
return RankPreparePageMediator
