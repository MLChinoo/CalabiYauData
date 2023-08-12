local LoginRegisterMediator = require("Business/Login/Mediators/LoginRegisterMediator")
local LoginRegisterPage = class("LoginRegisterPage", PureMVC.ViewComponentPage)
function LoginRegisterPage:OnOpen(luaOpenData, nativeOpenData)
  self.IsRegister = luaOpenData.isRegister
  self.Tips = ""
  self:BindEvent()
  self:SetMode()
  self.Swicher_PwdVisible:SetActiveWidgetIndex(0)
end
function LoginRegisterPage:BindEvent()
  if self.Button_SendCode then
    self.Button_SendCode.OnClicked:Add(self, self.OnClickSendCode)
  end
  if self.Button_Rest then
    self.Button_Rest.OnClicked:Add(self, self.OnClickRestPassword)
  end
  if self.Btn_HidePassword then
    self.Btn_HidePassword.OnClicked:Add(self, self.OnPwdVisible)
  end
  if self.Btn_ShowPassword then
    self.Btn_ShowPassword.OnClicked:Add(self, self.OnPwdVisible)
  end
  if self.Button_Register then
    self.Button_Register.OnClicked:Add(self, self.OnClickRegister)
  end
  if self.Button_Close then
    self.Button_Close.OnClicked:Add(self, self.OnClickClose)
  end
end
function LoginRegisterPage:ListNeededMediators()
  return {LoginRegisterMediator}
end
function LoginRegisterPage:SetMode()
  self.Tips = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "RegisterSuccess")
  self.Tips = UE4.UKismetTextLibrary.Conv_TextToString(self.Tips)
  if self.IsRegister then
    self.Text_Titl:SetText(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "RegisterUser"))
    self.Button_Register:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Button_Rest:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.Text_Titl:SetText(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "ResetPassword"))
    self.Button_Register:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Button_Rest:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Tips = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "ResetPasswordSuccess")
    self.Tips = UE4.UKismetTextLibrary.Conv_TextToString(self.Tips)
  end
end
function LoginRegisterPage:OnClickSendCode()
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoSendCode, {
    number = self.EditableTextBox_Phone:GetText(),
    isRegister = self.IsRegister
  })
end
function LoginRegisterPage:OnClickRestPassword()
  local resetParams = {}
  resetParams.phoneNum = self.EditableTextBox_Phone:GetText()
  resetParams.verifyCode = self.EditableTextBox_PhoneCode:GetText()
  resetParams.pwd = self.EditableTextBox_Password:GetText()
  resetParams.confirmPwd = self.EditableTextBox_ComfirmPassword:GetText()
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoResetPwd, resetParams)
end
function LoginRegisterPage:OnPwdVisible()
  local curIsPassword = not self.EditableTextBox_Password.IsPassword
  self.Swicher_PwdVisible:SetActiveWidgetIndex(curIsPassword and 0 or 1)
  self.EditableTextBox_Password:SetIsPassword(curIsPassword)
  self.EditableTextBox_ComfirmPassword:SetIsPassword(curIsPassword)
end
function LoginRegisterPage:OnClickRegister()
  local registerParams = {}
  registerParams.phoneNum = self.EditableTextBox_Phone:GetText()
  registerParams.verifyCode = self.EditableTextBox_PhoneCode:GetText()
  registerParams.pwd = self.EditableTextBox_Password:GetText()
  registerParams.confirmPwd = self.EditableTextBox_ComfirmPassword:GetText()
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoRegister, registerParams)
end
function LoginRegisterPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    self:OnClickClose()
    return true
  elseif "Y" == keyName then
    if self.IsRegister then
      self:OnClickRegister()
    else
      self:OnClickRestPassword()
    end
    return true
  end
  return false
end
function LoginRegisterPage:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.PMRegisterPagePC)
end
return LoginRegisterPage
