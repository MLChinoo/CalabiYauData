local PhoneUnBandOrChangeBindPage = class("PhoneUnBandOrChangeBindPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function PhoneUnBandOrChangeBindPage:ListNeededMediators()
  return {}
end
function PhoneUnBandOrChangeBindPage:InitializeLuaEvent()
end
function PhoneUnBandOrChangeBindPage:OnOpen(luaOpenData, nativeOpenData)
  AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.UnBindBtn.OnClickEvent:Add(self, self.OnClickUnBindBtn)
  self.ChangeBindBtn.OnClickEvent:Add(self, self.OnClickChangeBindBtn)
  if AccountBindProxy then
    local PhoneNumber, PhoneNumberStar, PhoneNumberEnd = AccountBindProxy:GetPhoneNumber()
    self.PhoneStar:SetText(PhoneNumberStar)
    self.PhoneEnd:SetText(PhoneNumberEnd)
  end
end
function PhoneUnBandOrChangeBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.UnBindBtn.OnClickEvent:Remove(self, self.OnClickUnBindBtn)
  self.ChangeBindBtn.OnClickEvent:Remove(self, self.OnClickChangeBindBtn)
end
function PhoneUnBandOrChangeBindPage:OnClickChangeBindBtn()
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.PhoneChangeBindPage)
end
function PhoneUnBandOrChangeBindPage:OnClickUnBindBtn()
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.UnBindPhonePage)
end
function PhoneUnBandOrChangeBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function PhoneUnBandOrChangeBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return PhoneUnBandOrChangeBindPage
