local SummerThemeSongDailyFlipTaskItemMediator = class("SummerThemeSongDailyFlipTaskItemMediator", PureMVC.Mediator)
function SummerThemeSongDailyFlipTaskItemMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask,
    NotificationDefines.BattlePass.TaskUpdate
  }
end
function SummerThemeSongDailyFlipTaskItemMediator:OnRegister()
end
function SummerThemeSongDailyFlipTaskItemMediator:OnRemove()
end
function SummerThemeSongDailyFlipTaskItemMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask then
    if noteBody and viewComponent.bp_taskId and noteBody == viewComponent.bp_taskId then
      viewComponent:SetTaskFinishedState(5)
    end
  elseif noteName == NotificationDefines.BattlePass.TaskUpdate then
    viewComponent:InitTaskItemData()
  end
end
return SummerThemeSongDailyFlipTaskItemMediator
