local FBUnBindPage = class("FBUnBindPage", PureMVC.ViewComponentPage)
function FBUnBindPage:ListNeededMediators()
  return {}
end
function FBUnBindPage:InitializeLuaEvent()
end
function FBUnBindPage:OnOpen(luaOpenData, nativeOpenData)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.Button_Cancel.OnClickEvent:Add(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Add(self, self.OnClickConfromBtn)
end
function FBUnBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.Button_Cancel.OnClickEvent:Remove(self, self.OnClickCancelBtn)
  self.Button_Confrom.OnClickEvent:Remove(self, self.OnClickConfromBtn)
end
function FBUnBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function FBUnBindPage:OnClickCancelBtn()
  ViewMgr:ClosePage(self)
end
function FBUnBindPage:OnClickConfromBtn()
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy then
    AccountBindProxy:ReqBindAccountFanbook(1, "", "")
  end
  ViewMgr:ClosePage(self)
end
function FBUnBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return FBUnBindPage
