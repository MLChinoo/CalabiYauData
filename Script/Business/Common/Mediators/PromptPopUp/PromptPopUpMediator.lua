local PromptPopUpMediator = class("PromptPopUpMediator", PureMVC.Mediator)
function PromptPopUpMediator:ListNotificationInterests()
  return {
    NotificationDefines.ShowCommonTip
  }
end
function PromptPopUpMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local body = notification:GetBody()
  if NtfName == NotificationDefines.ShowCommonTip then
    self:GetViewComponent():ShowMsg(body.msg, body.oriData)
  end
end
return PromptPopUpMediator
