local LoginPageBase = require("Business/Login/ViewComponents/LoginPageBase")
local LoginMobilePage = class("LoginMobilePage", LoginPageBase)
function LoginMobilePage:BindEvent()
  self.super.BindEvent(self)
  if self.Btn_QQLogin then
    self.Btn_QQLogin.OnClicked:Add(self, self.OnClickQQLogin)
  end
  if self.Btn_WeChatLogin then
    self.Btn_WeChatLogin.OnClicked:Add(self, self.OnClickWeChatLogin)
  end
  if self.Btn_EnterLobby then
    self.Btn_EnterLobby.OnClicked:Add(self, self.EnterGameAfterAuthed)
  end
  if self.CheckReadPermissionBtn then
    self.CheckReadPermissionBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CheckReadPermissionBtn.OnClicked:Add(self, self.OnClickCheckReadPermissionBtn)
  end
  if self.CheckWritePermissionBtn then
    self.CheckWritePermissionBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CheckWritePermissionBtn.OnClicked:Add(self, self.OnClickCheckWritePermissionBtn)
  end
end
function LoginMobilePage:SetEnterLobbyBtnUseable(isEnable)
  if not self.Btn_EnterLobby then
    return
  end
  self.Btn_EnterLobby:SetIsEnabled(isEnable)
  if isEnable then
    self.InLoginProcess = false
    self.Btn_EnterLobby:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Visible)
    if self.HotKeyQuitGame then
      self.HotKeyQuitGame:SetRenderOpacity(1)
    end
  else
    self.InLoginProcess = true
    self.Btn_EnterLobby:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetWidgetVisibility("HotKeyQuitGame", UE4.ESlateVisibility.Collapsed)
  end
end
function LoginMobilePage:OnClickCheckReadPermissionBtn()
  LogDebug("LoginMobilePage", "OnClickCheckReadPermissionBtn")
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  if GCloudSdk:CheckReadPermission() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "has Read Permission")
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "none Read Permission")
  end
end
function LoginMobilePage:OnClickCheckWritePermissionBtn()
  LogDebug("LoginMobilePage", "OnClickCheckWritePermissionBtn")
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  if GCloudSdk:CheckWritePermission() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "has Write Permission")
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "none Write Permission")
  end
end
function LoginMobilePage:InitPage(loginInfo)
  self.super.InitPage(self, loginInfo)
  self.LoginInfo = loginInfo
  self:SetWidgetVisibility("Panel_CreatePlayer", UE4.ESlateVisibility.Collapsed)
end
function LoginMobilePage:GotoPageStateLogout()
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.Collapsed)
  if BUILD_SHIPPING then
    self:SetWidgetVisibility("Panel_DevLogin", UE4.ESlateVisibility.Collapsed)
  else
    self:SetWidgetVisibility("Panel_DevLogin", UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_OpenId:SetText(self.LoginInfo.openId)
    self.Txt_Token:SetText(self.LoginInfo.token)
    self.Txt_Token:SetIsPassword(true)
  end
end
function LoginMobilePage:GotoPageStateAuthed()
  self:SetWidgetVisibility("CanvasInfosDisplay", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasLogoutState", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Btn_EnterLobby:SetIsEnabled(false)
  self:SetWidgetVisibility("Btn_EnterLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
  self:LoginBtnsEnable(true)
end
function LoginMobilePage:GotoPageStatePlatformAuthed()
  self:GotoPageStateAuthed()
end
function LoginMobilePage:GotoPageStateCreatePlayer(playerName)
end
function LoginMobilePage:ShowRandomName(RandomName)
  self.Txt_NickName:SetText(RandomName)
end
function LoginMobilePage:OnClickQQLogin()
  if not self:CheckReadPolicy() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoQQLogin)
end
function LoginMobilePage:OnClickWeChatLogin()
  if not self:CheckReadPolicy() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoWeChatLogin)
end
return LoginMobilePage
