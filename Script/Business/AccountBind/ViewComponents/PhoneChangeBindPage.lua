local PhoneChangeBindPageMediator = require("Business/AccountBind/Mediators/PhoneChangeBindPageMediator")
local PhoneChangeBindPage = class("PhoneChangeBindPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function PhoneChangeBindPage:ListNeededMediators()
  return {PhoneChangeBindPageMediator}
end
function PhoneChangeBindPage:InitializeLuaEvent()
end
function PhoneChangeBindPage:OnPressGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(3))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(3))
  end
end
function PhoneChangeBindPage:OnReleasGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneChangeBindPage:OnHoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(2))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(2))
  end
end
function PhoneChangeBindPage:OnUnhoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneChangeBindPage:OnOpen(luaOpenData, nativeOpenData)
  AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.Button_GetVerificationCode.OnClicked:Add(self, self.OnClickGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnPressed:Add(self, self.OnPressGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnReleased:Add(self, self.OnReleasGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnHovered:Add(self, self.OnHoverGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnUnhovered:Add(self, self.OnUnhoverGetVerificationCodeBtn)
  self.Button_Cancel.OnClickEvent:Add(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Add(self, self.OnClickConfromBtn)
  self.EditableTextBox_PhoneNumber.OnTextChanged:Add(self, self.OnInputPhoneNumberChanged)
  self.EditableTextBox_VerificationCode.OnTextChanged:Add(self, self.OnInputVerificationCodeChanged)
  self.EditableTextBox_PhoneNumber:SetText("")
  self.EditableTextBox_VerificationCode:SetText("")
  self.Button_GetVerificationCode:SetIsEnabled(false)
  self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(4))
  self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(4))
  self.Button_Confrom:SetButtonIsEnabled(false)
end
function PhoneChangeBindPage:OnClickGetVerificationCodeBtn()
  if AccountBindProxy then
    local PhoneNumber, PhoneNumberStar, PhoneNumberEnd = AccountBindProxy:GetPhoneNumber()
    if PhoneNumber == self.PhoneNumber then
      local tipsMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "SamePhoneTip")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
      return
    end
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
function PhoneChangeBindPage:OnClickCancelBtn()
  ViewMgr:ClosePage(self)
end
function PhoneChangeBindPage:OnClickConfromBtn()
  if AccountBindProxy then
    AccountBindProxy:ReqBindAccountPhone(0, self.VerificationCode, self.PhoneNumber)
  end
end
function PhoneChangeBindPage:OnInputPhoneNumberChanged(Text)
  LogDebug("PhoneChangeBindPage", "OnInputPhoneNumberChanged Text = " .. Text)
  self.PhoneNumber = Text
  self:SetBtnEnable()
end
function PhoneChangeBindPage:SetBtnEnable()
  if AccountBindProxy then
    if AccountBindProxy:CheckIsMobile(self.PhoneNumber) then
      if self.taskTime == nil then
        self.Button_GetVerificationCode:SetIsEnabled(true)
        self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
        self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
      end
      if AccountBindProxy:CheckIsMobile(self.PhoneNumber) and AccountBindProxy:CheckIsVerificationCode(self.VerificationCode) then
        self.Button_Confrom:SetButtonIsEnabled(true)
      else
        self.Button_Confrom:SetButtonIsEnabled(false)
      end
    else
      self.Button_Confrom:SetButtonIsEnabled(false)
      self.Button_GetVerificationCode:SetIsEnabled(false)
      self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(4))
      self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(4))
    end
  end
end
function PhoneChangeBindPage:OnInputVerificationCodeChanged(Text)
  LogDebug("PhoneChangeBindPage", "OnInputVerificationCodeChanged Text = " .. Text)
  self.VerificationCode = Text
  self:SetBtnEnable()
end
function PhoneChangeBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.Button_GetVerificationCode.OnClicked:Remove(self, self.OnClickGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnPressed:Remove(self, self.OnPressGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnReleased:Remove(self, self.OnReleasGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnHovered:Remove(self, self.OnHoverGetVerificationCodeBtn)
  self.Button_GetVerificationCode.OnUnhovered:Remove(self, self.OnUnhoverGetVerificationCodeBtn)
  self.Button_Cancel.OnClickEvent:Remove(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Remove(self, self.OnClickConfromBtn)
  self.EditableTextBox_PhoneNumber.OnTextChanged:Remove(self, self.OnInputPhoneNumberChanged)
  self.EditableTextBox_VerificationCode.OnTextChanged:Remove(self, self.OnInputVerificationCodeChanged)
  if self.taskTime then
    self.taskTime:EndTask()
    self.taskTime = nil
  end
end
function PhoneChangeBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function PhoneChangeBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return PhoneChangeBindPage
