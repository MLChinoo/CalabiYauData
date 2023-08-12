local InviteInfoPanelMediator = class("InviteInfoPanelMediator", PureMVC.Mediator)
function InviteInfoPanelMediator:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function InviteInfoPanelMediator:ListNotificationInterests()
  return {}
end
function InviteInfoPanelMediator:HandleNotification(notify)
end
function InviteInfoPanelMediator:OnRegister()
  self:OnInit()
end
function InviteInfoPanelMediator:OnInit()
end
return InviteInfoPanelMediator
