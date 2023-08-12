local PhoneSafetyVerifiPageMediator = require("Business/AccountBind/Mediators/PhoneSafetyVerifiPageMediator")
local PhoneSafetyVerifiPage = class("PhoneSafetyVerifiPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function PhoneSafetyVerifiPage:ListNeededMediators()
  return {PhoneSafetyVerifiPageMediator}
end
function PhoneSafetyVerifiPage:InitializeLuaEvent()
end
function PhoneSafetyVerifiPage:OnPressGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(3))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(3))
  end
end
function PhoneSafetyVerifiPage:OnReleasGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneSafetyVerifiPage:OnHoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(2))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(2))
  end
end
function PhoneSafetyVerifiPage:OnUnhoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneSafetyVerifiPage:OnOpen(luaOpenData, nativeOpenData)
  AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.Button_GetVerificationCode.OnClicked:Add(self, self.OnClickGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnPressed:Add(self, self.OnPressGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnReleased:Add(self, self.OnReleasGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnHovered:Add(self, self.OnHoverGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnUnhovered:Add(self, self.OnUnhoverGetVerificationCodeBtn)
  self.Button_Cancel.OnClickEvent:Add(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Add(self, self.OnClickConfromBtn)
  self.EditableTextBox_VerificationCode.OnTextChanged:Add(self, self.OnInputVerificationCodeChanged)
  self.EditableTextBox_VerificationCode:SetText("")
  self.Button_Confrom:SetButtonIsEnabled(false)
  if AccountBindProxy then
    self.PhoneNumber, self.PhoneNumberStar, self.PhoneNumberEnd = AccountBindProxy:GetPhoneNumber()
    self.PhoneStar:SetText(self.PhoneNumberStar)
    self.PhoneEnd:SetText(self.PhoneNumberEnd)
  end
end
function PhoneSafetyVerifiPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.Button_GetVerificationCode.OnClicked:Remove(self, self.OnClickGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnPressed:Remove(self, self.OnPressGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnReleased:Remove(self, self.OnReleasGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnHovered:Remove(self, self.OnHoverGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnUnhovered:Remove(self, self.OnUnhoverGetVerificationCodeBtn)
  self.Button_Cancel.OnClickEvent:Remove(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Remove(self, self.OnClickConfromBtn)
  self.EditableTextBox_VerificationCode.OnTextChanged:Remove(self, self.OnInputVerificationCodeChanged)
  if self.taskTime then
    self.taskTime:EndTask()
    self.taskTime = nil
  end
end
function PhoneSafetyVerifiPage:OnInputVerificationCodeChanged(Text)
  LogDebug("PhoneSafetyVerifiPage", "OnInputVerificationCodeChanged Text = " .. Text)
  self.VerificationCode = Text
  self:SetBtnEnable()
end
function PhoneSafetyVerifiPage:SetBtnEnable()
  if AccountBindProxy then
    if AccountBindProxy:CheckIsVerificationCode(self.VerificationCode) then
      self.Button_Confrom:SetButtonIsEnabled(true)
    else
      self.Button_Confrom:SetButtonIsEnabled(false)
    end
  end
end
function PhoneSafetyVerifiPage:OnClickGetVerificationCodeBtn()
  if AccountBindProxy then
    AccountBindProxy:ReqSendPhoneMsg(self.PhoneNumber, 1)
  end
  self.WidgetSwitcher_GetCodeText:SetActiveWidgetIndex(1)
  self.Button_GetVerificationCode:SetIsEnabled(false)
  self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(4))
  self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(4))
  local index = 60
  self.taskTime = TimerMgr:AddTimeTask(0, 1, 0, function()
    index = index - 1
    local countDownText = tostring(index) .. " s"
    self.CountDownText:SetText(countDownText)
    if 0 == index then
      self.Button_GetVerificationCode:SetIsEnabled(true)
      self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
      self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
      self.WidgetSwitcher_GetCodeText:SetActiveWidgetIndex(0)
      if self.taskTime then
        self.taskTime:EndTask()
        self.taskTime = nil
      end
    end
  end)
end
function PhoneSafetyVerifiPage:OnClickCancelBtn()
  ViewMgr:ClosePage(self)
end
function PhoneSafetyVerifiPage:OnPhoneCheckSuccess()
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.PhoneUnBandOrChangeBindPage)
end
function PhoneSafetyVerifiPage:OnClickConfromBtn()
  if AccountBindProxy then
    AccountBindProxy:ReqCheckPhoneCode(self.PhoneNumber, self.VerificationCode, 1)
  end
end
function PhoneSafetyVerifiPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function PhoneSafetyVerifiPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
return PhoneSafetyVerifiPage
