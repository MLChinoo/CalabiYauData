local LoginRegisterMediator = class("LoginRegisterMediator", PureMVC.Mediator)
function LoginRegisterMediator:OnRegister()
  self.super:OnRegister()
  self.ViewPage = self:GetViewComponent()
  self.LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self.ViewPage)
  DelegateMgr:BindDelegate(self.LoginSubsystem.RegisterResultDelegate, self, LoginRegisterMediator.GetRegisterDelegate)
end
function LoginRegisterMediator:OnRemove()
  self.super:OnRemove()
end
function LoginRegisterMediator:ListNotificationInterests()
  return {
    NotificationDefines.Login.NtfDoSendCode,
    NotificationDefines.Login.NtfDoRegister,
    NotificationDefines.Login.NtfDoResetPwd
  }
end
function LoginRegisterMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  if NtfName == NotificationDefines.Login.NtfDoSendCode then
    self:DoSendCode(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfDoRegister then
    self:OnClickRegister(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfDoResetPwd then
    self:OnClickResetPwd(notification:GetBody())
  end
end
function LoginRegisterMediator:DoSendCode(params)
  self.LoginSubsystem:OnClickSendCode(params.number, params.isRegister)
end
function LoginRegisterMediator:OnClickRegister(registerParams)
  self.LoginSubsystem:OnClickRegister(registerParams.phoneNum, registerParams.verifyCode, registerParams.pwd, registerParams.confirmPwd)
end
function LoginRegisterMediator:OnClickResetPwd(registerParams)
  self.LoginSubsystem:OnClickRestPassword(registerParams.phoneNum, registerParams.verifyCode, registerParams.pwd, registerParams.confirmPwd)
end
function LoginRegisterMediator:GetRegisterDelegate(isSuc, msg)
  local MSSDKSubSystem = UE4.UPMMSSDKSubSystem.GetInst(self.ViewPage)
  if isSuc then
    MSSDKSubSystem:ShowTips(self.ViewPage.Tips)
    ViewMgr:ClosePage(self.ViewPage, UIPageNameDefine.PMRegisterPagePC)
  else
    MSSDKSubSystem:ShowTips(msg)
  end
end
return LoginRegisterMediator
