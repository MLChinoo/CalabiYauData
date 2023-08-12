local TemplateMediator = class("TemplateMediator", PureMVC.Mediator)
function TemplateMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.Unlock
  }
end
function TemplateMediator:OnRegister()
  LogDebug("TemplateMediator", "OnRegister %s", self:GetMediatorName())
  self:GetViewComponent().actionOnClose:Add(function()
    LogDebug("TemplateMediator", "Action on Esc")
    ViewMgr:ClosePage(self:GetViewComponent())
    LogDebug("TemplateMediator", "Action After Close page")
  end)
end
function TemplateMediator:OnViewComponentPreOpen(luaData, originOpenData)
end
function TemplateMediator:OnViewComponentPostOpen(luaData, originOpenData)
end
return TemplateMediator
