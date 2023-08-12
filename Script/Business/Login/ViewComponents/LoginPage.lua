local LoginPageBase = require("Business/Login/ViewComponents/LoginPageBase")
local AuthStrategy = {
  None = 0,
  SteamWithQQ = 1,
  SteamWithWeChat = 2
}
local LoginPage = class("LoginPage", LoginPageBase)
function LoginPage:BindEvent()
  self.super.BindEvent(self)
  if self.Btn_Register then
    self.Btn_Register.OnClicked:Add(self, self.OnClickRegister)
  end
  if self.Btn_ResetPwd then
    self.Btn_ResetPwd.OnClicked:Add(self, self.OnClickResetPwd)
  end
  if self.Btn_QQLogin then
    self.Btn_QQLogin.OnClicked:Add(self, self.OnClickQQLogin)
  end
  if self.Btn_WeChatLogin then
    self.Btn_WeChatLogin.OnClicked:Add(self, self.OnClickWeChatLogin)
  end
  if self.BtnAutoLogin then
    self.BtnAutoLogin.OnClicked:Add(self, self.OnPlatformLogoutLogin)
  end
  if self.BtnLoginLobby then
    self.BtnLoginLobby.OnClicked:Add(self, self.EnterGameAfterAuthed)
  end
  if self.ImgWBClick then
    self.ImgWBClick.OnMouseButtonDownEvent:Bind(self, self.OnWBClicked)
  end
  if self.BtnHideBrowser then
    self.BtnHideBrowser.Btn_Item.OnClicked:Add(self, self.OnClickedHideBrowser)
  end
  if self.HotKeyQuitGame then
    self.HotKeyQuitGame.OnClickEvent:Add(self, self.OnClickReturnDesktop)
  end
  if self.WebViewRoot then
    self.WebViewRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.CloseWebBtn then
    self.CloseWebBtn.OnClicked:Add(self, self.CloseWeb)
  end
  if self.BtnRepair then
    self.BtnRepair.OnClicked:Add(self, self.AskForRepair)
    self.BtnRepair.OnHovered:Add(self, self.ShowRepairToolTips)
    self.BtnRepair.OnUnhovered:Add(self, self.HideRepairToolTips)
  end
  if self.NoticeBtn then
    self.NoticeBtn.OnClicked:Add(self, self.OnClickNoticeBtn)
    self.NoticeBtn.OnHovered:Add(self, self.ShowGameNoticeTips)
    self.NoticeBtn.OnUnhovered:Add(self, self.HideGameNoticeTips)
  end
  if self.CheckUseNativeBrowser then
    self.CheckUseNativeBrowser.OnCheckStateChanged:Add(self, self.OnUseNativeBrowserStateChanged)
  end
  if self.WB_TX then
    LogWarn("html5_login", "BindWebUObject:ueobj")
    local LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self)
    self.WB_TX:BindWebUObject("ueobj", LoginSubsystem, true)
  end
  if self.BtnCustomService then
    self.BtnCustomService.OnClicked:Add(self, self.OnClickCustomerServiceBtn)
    self.BtnCustomService.OnHovered:Add(self, self.ShowCustomerServiceTips)
    self.BtnCustomService.OnUnhovered:Add(self, self.HideCustomerServiceTips)
  end
end
function LoginPage:OnClose()
  self.super.OnClose(self)
  self:ClearWBClickCD()
  if self.BtnLoginLobby then
    self.BtnLoginLobby.OnClicked:Remove(self, self.EnterGameAfterAuthed)
  end
end
function LoginPage:InitPage(loginInfo)
  self.super.InitPage(self, loginInfo)
  if loginInfo.useNativeBrowserState and self.CheckUseNativeBrowser then
    self.CheckUseNativeBrowser:SetIsChecked(loginInfo.useNativeBrowserState)
  end
  self:SetWidgetVisibility("CanvasWebBrowser", UE4.ESlateVisibility.Collapsed)
  self.Txt_OpenId:SetText(loginInfo.openId)
  self.Txt_Token:SetText(loginInfo.token)
  self.Txt_Token:SetIsPassword(true)
  self.CanUpdateWB = true
end
function LoginPage:GotoPageStateLogout(authSDKType)
  self.AuthSDKType = authSDKType
  if self.AnimEnterLobby then
    self:StopAnimation(self.AnimEnterLobby)
  end
  self.CanvasInfosDisplay:SetRenderOpacity(1)
  self.CanvasLogoutState:SetRenderOpacity(1)
  self.HotKeyQuitGame:SetRenderOpacity(1)
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
  self:SetWidgetVisibility("BtnAutoLogin", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("TextAutoLogin", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("WidgetSwitcher_Login", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.Collapsed)
  self:LoginBtnsEnable(true)
  if self.AuthSDKType == UE4.EPMIdAuthSDK.SteamWithMSDK then
    self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.AuthSDKType == UE4.EPMIdAuthSDK.LD then
    self:SetWidgetVisibility("WidgetSwitcher_Login", UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.Collapsed)
  elseif self.AuthSDKType == UE4.EPMIdAuthSDK.WeGame then
    self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.Collapsed)
  elseif self.AuthSDKType == UE4.EPMIdAuthSDK.GCLOUD then
    self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if not BUILD_SHIPPING then
    self:SetWidgetVisibility("WidgetSwitcher_Login", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LoginPage:GotoPageStateAuthed(isRetry)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("TextLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetEnterLobbyBtnUseable(isRetry)
  if isRetry then
    self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
    self.HotKeyQuitGame:SetRenderOpacity(1)
  else
    self:PlayWidgetAnimationWithCallBack("AnimEnterLobby", FuncSlot(self.AnimEnterLobbyCallback, self))
    self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LoginPage:AnimEnterLobbyCallback()
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Collapsed)
end
function LoginPage:GotoPageStatePlatformLogout(authSDKType)
  self.AuthSDKType = authSDKType
  if self.AnimEnterLobby then
    self:StopAnimation(self.AnimEnterLobby)
  end
  self.CanvasInfosDisplay:SetRenderOpacity(1)
  self.CanvasLogoutState:SetRenderOpacity(1)
  self.HotKeyQuitGame:SetRenderOpacity(1)
  self:SetWidgetVisibility("WidgetSwitcher_Login", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
  self:SetWidgetVisibility("CanvasLoginBtns", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("BtnAutoLogin", UE4.ESlateVisibility.Visible)
  self:SetWidgetVisibility("TextAutoLogin", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:LoginBtnsEnable(true)
  self:PlatformLoginBtnsEnable(true)
  if not BUILD_SHIPPING then
    self:SetWidgetVisibility("WidgetSwitcher_Login", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LoginPage:GotoPageStatePlatformAuthed(isRetry)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("TextLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetEnterLobbyBtnUseable(isRetry)
  if isRetry then
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
    self.HotKeyQuitGame:SetRenderOpacity(1)
  else
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LoginPage:GotoPageStateCreatePlayer(playerName)
end
function LoginPage:SetEnterLobbyBtnUseable(isEnable)
  if not self.BtnLoginLobby then
    return
  end
  self.BtnLoginLobby:SetIsEnabled(isEnable)
  if isEnable then
    self.InLoginProcess = false
    self.BtnLoginLobby:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetWidgetVisibility("TextAutoLogin", UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("TextLoginLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
    if self.HotKeyQuitGame then
      self.HotKeyQuitGame:SetRenderOpacity(1)
    end
  else
    self.InLoginProcess = true
    self.BtnLoginLobby:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("TextAutoLogin", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Collapsed)
  end
end
function LoginPage:OnClickRegister()
  GameFacade:SendNotification(NotificationDefines.Login.NtfOpenRegisterPage)
end
function LoginPage:OnClickResetPwd()
  GameFacade:SendNotification(NotificationDefines.Login.NtfOpenResetPwdPage)
end
function LoginPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "N" == keyName then
    self:HideCommunityQRCode()
    return true
  end
  if "Escape" == keyName and not self.CanvasCommunityQRCode:IsVisible() and not self.InLoginProcess then
    self:OnClickReturnDesktop()
    return true
  end
  return false
end
function LoginPage:OnClickReturnDesktop()
  UE4.UPMWidgetBlueprintLibrary.TryExitGame(self)
end
function LoginPage:OnClickedHideBrowser()
  self:SetWidgetVisibility("CanvasWebBrowser", UE4.ESlateVisibility.Collapsed)
end
function LoginPage:OnPlatformLogoutLogin()
  if not self:CheckReadPolicy() then
    return
  end
  self:PlatformLoginBtnsEnable(false)
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoPlatformLogin, self.LoginChannelType.LCT_PlatformAuto)
end
function LoginPage:OnClickQQLogin()
  if not self:CheckReadPolicy() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoQQLogin, self.LoginChannelType.LCT_QQ)
end
function LoginPage:OnClickWeChatLogin()
  if not self:CheckReadPolicy() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoWeChatLogin, self.LoginChannelType.LCT_WeChat)
end
function LoginPage:ClearWBClickCD()
  if self.WBUpdateCdTimer then
    self.WBUpdateCdTimer:EndTask()
    self.WBUpdateCdTimer = nil
  end
end
function LoginPage:OnWBClicked()
  if self.CanUpdateWB then
    self.CanUpdateWB = false
    if self.LoginStrategy == AuthStrategy.SteamWithQQ then
      self:OnClickQQLogin()
    elseif self.LoginStrategy == AuthStrategy.SteamWithWeChat then
      self:OnClickWeChatLogin()
    end
    self.WBUpdateCdTimer = TimerMgr:AddTimeTask(0.5, 0, 1, function()
      self.CanUpdateWB = true
      self.WBUpdateCdTimer = nil
    end)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function LoginPage:ShowLoginWebPage(loginURL)
  LogWarn("html5_login", "loginURL:%s", loginURL)
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(loginURL, 2, 0.5)
  if self.LoginStrategy == AuthStrategy.SteamWithQQ then
    self.TxtWBTitle:SetText("打开手机QQ扫码登录游戏")
  elseif self.LoginStrategy == AuthStrategy.SteamWithWeChat then
    self.TxtWBTitle:SetText("打开手机微信扫码登录游戏")
  end
end
function LoginPage:OnOpenNativeBrowser()
  GameFacade:SendNotification(NotificationDefines.Login.NtfOpenNativeBrowser)
end
function LoginPage:OnUseNativeBrowserStateChanged(bIsChecked)
  LogInfo("LoginPage:OnUseNativeBrowserStateChanged", tostring(bIsChecked))
  local LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self)
  LoginSubsystem:SetUseNativeBrowserFlag(bIsChecked)
end
function LoginPage:ShowWeb(url)
  self.WebViewRoot:SetVisibility(UE4.ESlateVisibility.Visible)
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(url, 2, 0.5)
end
function LoginPage:CloseWeb()
  self.WebViewRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function LoginPage:OnClickNoticeBtn()
  ViewMgr:OpenPage(self, UIPageNameDefine.NoticePage, false, 2)
end
function LoginPage:AskForRepair()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "AskForRepair")
  pageData.cb = FuncSlot(self.DoWebView2Repair, self)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function LoginPage:DoWebView2Repair(isRepair)
  if not isRepair then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfWebView2Repair)
end
function LoginPage:html5_login(Channel, Code, State)
  LogWarn("html5_login", "Channel:%s Code:%s State:%s", Channel, Code, State)
  local LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self)
  return LoginSubsystem:html5_login(Channel, Code, State)
end
function LoginPage:ShowNativeBrowserOption()
end
function LoginPage:ShowRepairToolTips()
  self:SetWidgetVisibility("CanvasRepairTips", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPage:HideRepairToolTips()
  self:SetWidgetVisibility("CanvasRepairTips", UE4.ESlateVisibility.Collapsed)
end
function LoginPage:ShowGameNoticeTips()
  self:SetWidgetVisibility("CanvasNoticeTips", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPage:HideGameNoticeTips()
  self:SetWidgetVisibility("CanvasNoticeTips", UE4.ESlateVisibility.Collapsed)
end
function LoginPage:OnClickCustomerServiceBtn()
  LogDebug("LoginPageBase", "OnClickCustomerServiceBtn")
  local CustomerServicekUrlIndex = 8411
  local url = ""
  local row = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(CustomerServicekUrlIndex)
  if nil ~= row and nil ~= row.ParaValue then
    url = row.ParaValue
  end
  if "" == url then
    return
  end
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(self:GetWorld())
  GCloudSdk:OpenWebView(url, 1, 1)
end
function LoginPage:ShowCustomerServiceTips()
  self:SetWidgetVisibility("CanvasCustomServiceTip", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPage:HideCustomerServiceTips()
  self:SetWidgetVisibility("CanvasCustomServiceTip", UE4.ESlateVisibility.Collapsed)
end
return LoginPage
