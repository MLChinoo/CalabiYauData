local PhoneBindPageMediator = require("Business/AccountBind/Mediators/PhoneBindPageMediator")
local PhoneBindPage = class("PhoneBindPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function PhoneBindPage:ListNeededMediators()
  return {PhoneBindPageMediator}
end
function PhoneBindPage:InitializeLuaEvent()
end
function PhoneBindPage:OnPressGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(3))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(3))
  end
end
function PhoneBindPage:OnReleasGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneBindPage:OnHoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(2))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(2))
  end
end
function PhoneBindPage:OnUnhoverGetVerificationCodeBtn()
  if self.Button_GetVerificationCode:GetIsEnabled() then
    self.GetCodeText:SetColorAndOpacity(self.TextStyleMap:Get(1))
    self.CountDownText:SetColorAndOpacity(self.TextStyleMap:Get(1))
  end
end
function PhoneBindPage:OnOpen(luaOpenData, nativeOpenData)
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
  self:UpdataReward()
end
function PhoneBindPage:UpdataReward()
  if AccountBindProxy then
    if AccountBindProxy:GetPhoneBingHasReward() then
      local itemID, itemCount = AccountBindProxy:GetPhoneBindReward()
      local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
      if ItemsProxy then
        local ItemInfo = ItemsProxy:GetAnyItemInfoById(itemID)
        local itemQualityCfg = ItemsProxy:GetItemQualityConfig(ItemInfo.quality)
        if self.Image_Qullaty then
          self.Image_Qullaty:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.Color)))
        end
        if self.RewadImage then
          self:SetImageByTexture2D(self.RewadImage, ItemInfo.image)
        end
        if self.NumText then
          self.NumText:SetText(tostring(itemCount))
        end
      end
      self.RewadRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.RewadRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function PhoneBindPage:OnClickGetVerificationCodeBtn()
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
function PhoneBindPage:OnClickCancelBtn()
  ViewMgr:ClosePage(self)
end
function PhoneBindPage:OnClickConfromBtn()
  if AccountBindProxy then
    AccountBindProxy:ReqBindAccountPhone(0, self.VerificationCode, self.PhoneNumber)
  end
end
function PhoneBindPage:OnInputPhoneNumberChanged(Text)
  LogDebug("PhoneBindPage", "OnInputPhoneNumberChanged Text = " .. Text)
  self.PhoneNumber = Text
  self:SetBtnEnable()
end
function PhoneBindPage:SetBtnEnable()
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
function PhoneBindPage:OnInputVerificationCodeChanged(Text)
  LogDebug("PhoneBindPage", "OnInputVerificationCodeChanged Text = " .. Text)
  self.VerificationCode = Text
  self:SetBtnEnable()
end
function PhoneBindPage:OnClose()
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
function PhoneBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function PhoneBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return PhoneBindPage
