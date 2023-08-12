local FBUnBandOrChangeBindPage = class("FBUnBandOrChangeBindPage", PureMVC.ViewComponentPage)
function FBUnBandOrChangeBindPage:ListNeededMediators()
  return {}
end
function FBUnBandOrChangeBindPage:InitializeLuaEvent()
end
function FBUnBandOrChangeBindPage:OnOpen(luaOpenData, nativeOpenData)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.UnBindBtn.OnClickEvent:Add(self, self.OnClickUnBindBtn)
  self.ChangeBindBtn.OnClickEvent:Add(self, self.OnClickChangeBindBtn)
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy then
    local FBid = AccountBindProxy:GetFBid()
    self.FBIdText:SetText(FBid)
  end
end
function FBUnBandOrChangeBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.UnBindBtn.OnClickEvent:Remove(self, self.OnClickUnBindBtn)
  self.ChangeBindBtn.OnClickEvent:Remove(self, self.OnClickChangeBindBtn)
end
function FBUnBandOrChangeBindPage:OnClickUnBindBtn()
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.UnBindFanBookPage)
end
function FBUnBandOrChangeBindPage:OnClickChangeBindBtn()
  LogDebug("FBUnBandOrChangeBindPage", "OnClickChangeBindBtn")
  local AccountBindWorldSubsystem = UE4.UPMAccountBindWorldSubsystem.Get(LuaGetWorld())
  if AccountBindWorldSubsystem then
    AccountBindWorldSubsystem:StartAccoutBind("fanbook://oauth?client_id=524063210475753472&invite_code=calabiyau&scheme=calabiyau&host=AccountBind")
  end
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.BindFanbookWaitPage)
end
function FBUnBandOrChangeBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function FBUnBandOrChangeBindPage:LuaHandleKeyEvent(key, inputEvent)
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
return FBUnBandOrChangeBindPage
