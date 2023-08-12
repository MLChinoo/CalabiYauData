local AccountBindPageMediator = class("AccountBindPageMediator", PureMVC.Mediator)
function AccountBindPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.AccountBind.UpdataAccountInfo
  }
end
function AccountBindPageMediator:OnRegister()
  self.super:OnRegister()
  local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  if NoticeSubSys then
    NoticeSubSys:SetPageNameIsTouch("AccountBindPage", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
  end
  GameFacade:SendNotification(NotificationDefines.AccountBind.OpenAccountBindPage)
end
function AccountBindPageMediator:OnRemove()
  self.super:OnRemove()
end
function AccountBindPageMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.AccountBind.UpdataAccountInfo then
    self:GetViewComponent():UpdataUI()
  end
end
return AccountBindPageMediator
