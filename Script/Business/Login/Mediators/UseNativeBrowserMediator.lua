local UseNativeBrowserMediator = class("UseNativeBrowserMediator", PureMVC.Mediator)
function UseNativeBrowserMediator:OnRegister()
  self.ViewPage = self:GetViewComponent()
end
function UseNativeBrowserMediator:OnRemove()
end
function UseNativeBrowserMediator:ListNotificationInterests()
  return {
    NotificationDefines.Login.NtfUseBrowserStateChange
  }
end
function UseNativeBrowserMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local NtfBody = notification:GetBody()
  if NtfName == NotificationDefines.Login.NtfUseBrowserStateChange then
    self.ViewPage:SetPageState(NtfBody.loginType, NtfBody.newState)
  end
end
return UseNativeBrowserMediator
