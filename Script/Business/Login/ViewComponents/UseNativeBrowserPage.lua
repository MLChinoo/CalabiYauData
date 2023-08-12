local UseNativeBrowserPage = class("UseNativeBrowserPage", PureMVC.ViewComponentPage)
local UseNativeBrowserMediator = require("Business/Login/Mediators/UseNativeBrowserMediator")
function UseNativeBrowserPage:ListNeededMediators()
  return {UseNativeBrowserMediator}
end
function UseNativeBrowserPage:InitializeLuaEvent()
  self.Button_Confirm_one.OnClickEvent:Add(self, self.OnConfirmOneBtnClicked)
end
function UseNativeBrowserPage:OnOpen(luaOpenData, nativeOpenData)
  self:GetLoginWithBrowserSubSys()
  self.WS_Button:SetActiveWidgetIndex(0)
  self:SetPageState(luaOpenData.loginType, luaOpenData.newState)
end
function UseNativeBrowserPage:OnClose()
end
function UseNativeBrowserPage:GetLoginWithBrowserSubSys()
  if not self.LoginWithBrowserSubSys then
    self.LoginWithBrowserSubSys = UE4.UPMLoginWithBrowserWorldSubsystem.Get(LuaGetWorld())
  end
end
function UseNativeBrowserPage:SetPageState(loginType, newState)
  self.LoginType = loginType
  self.CurState = newState
  if newState == UE4.EPMUseNativeBrowserState.ShowBrowser then
    local browserLoginingTips = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "UseNativeBrowserLogining")
    self.TxtTips:SetText(browserLoginingTips)
    self.Button_Confirm_one.Tex_NameCN:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel"))
  elseif newState == UE4.EPMUseNativeBrowserState.CloseBrowser then
    GameFacade:SendNotification(NotificationDefines.Login.NtfCloseUseBrowserPage)
  elseif newState == UE4.EPMUseNativeBrowserState.FixRegisteTable then
    local needFixTips = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "FixBrowserLogin")
    self.TxtTips:SetText(needFixTips)
    self.Button_Confirm_one.Tex_NameCN:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Login, "ConfirmFix"))
  end
end
function UseNativeBrowserPage:OnConfirmOneBtnClicked()
  if self.CurState == UE4.EPMUseNativeBrowserState.ShowBrowser then
    self:CancelNativeBrowserLogin()
    GameFacade:SendNotification(NotificationDefines.Login.NtfCloseUseBrowserPage)
  elseif self.CurState == UE4.EPMUseNativeBrowserState.FixRegisteTable then
    self:DoFixRegisteTable()
  end
end
function UseNativeBrowserPage:DoFixRegisteTable()
  self:GetLoginWithBrowserSubSys()
  if self.LoginWithBrowserSubSys then
    self.LoginWithBrowserSubSys:TryRepaireRegistry()
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfCloseUseBrowserPage)
end
function UseNativeBrowserPage:CancelNativeBrowserLogin()
  self:GetLoginWithBrowserSubSys()
  if self.LoginWithBrowserSubSys then
    if self.LoginType == "QQ" then
      self.LoginWithBrowserSubSys:EndBrowserLoginQQ()
    elseif self.LoginType == "WX" then
      self.LoginWithBrowserSubSys:EndBrowserLoginWX()
    end
  end
  return self.LoginWithBrowserSubSys
end
return UseNativeBrowserPage
