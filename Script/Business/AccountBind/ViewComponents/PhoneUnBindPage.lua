local PhoneUnBindPage = class("PhoneUnBindPage", PureMVC.ViewComponentPage)
function PhoneUnBindPage:ListNeededMediators()
  return {}
end
function PhoneUnBindPage:InitializeLuaEvent()
end
function PhoneUnBindPage:OnOpen(luaOpenData, nativeOpenData)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.Button_Cancel.OnClickEvent:Add(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Add(self, self.OnClickConfromBtn)
end
function PhoneUnBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.Button_Cancel.OnClickEvent:Remove(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Remove(self, self.OnClickConfromBtn)
end
function PhoneUnBindPage:OnClickCancelBtn()
  ViewMgr:ClosePage(self)
end
function PhoneUnBindPage:OnClickConfromBtn()
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy then
    AccountBindProxy:ReqBindAccountPhone(1, "", "")
  end
  ViewMgr:ClosePage(self)
end
function PhoneUnBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function PhoneUnBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return PhoneUnBindPage
