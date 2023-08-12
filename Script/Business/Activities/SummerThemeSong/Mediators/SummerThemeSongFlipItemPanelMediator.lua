local SummerThemeSongFlipFunctionPanelMediator = class("SummerThemeSongFlipFunctionPanelMediator", PureMVC.Mediator)
function SummerThemeSongFlipFunctionPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateData,
    NotificationDefines.Activities.SummerThemeSong.UpdateOpenCard,
    NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask
  }
end
function SummerThemeSongFlipFunctionPanelMediator:OnRegister()
end
function SummerThemeSongFlipFunctionPanelMediator:OnRemove()
end
function SummerThemeSongFlipFunctionPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateData then
    viewComponent:SetFlipItemParticleVisible()
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateOpenCard then
    viewComponent:SetFlipItemParticleVisible()
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask then
    viewComponent:SetFlipItemParticleVisible()
  end
end
return SummerThemeSongFlipFunctionPanelMediator
