local KaPhoneMediator = class("KaPhoneMediator", PureMVC.Mediator)
local KaPhonePage
function KaPhoneMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfKaPoneClose,
    NotificationDefines.NtfKaPhoneShowParticleSystem,
    NotificationDefines.NtfKaPhoneOpenMail,
    NotificationDefines.NtfKaPhoneOpenNavigation
  }
end
function KaPhoneMediator:HandleNotification(notification)
  KaPhonePage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.NtfKaPoneClose then
    ViewMgr:ClosePage(KaPhonePage)
  elseif Name == NotificationDefines.NtfKaPhoneShowParticleSystem then
    KaPhonePage:ActiveParticle()
  elseif Name == NotificationDefines.NtfKaPhoneOpenMail then
    KaPhonePage:OnClickMail()
  elseif Name == NotificationDefines.NtfKaPhoneOpenNavigation then
    KaPhonePage:OnClickNavigation()
  end
end
function KaPhoneMediator:OnRegister()
end
function KaPhoneMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
end
function KaPhoneMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
end
return KaPhoneMediator
