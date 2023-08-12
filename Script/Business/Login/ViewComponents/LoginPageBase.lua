local LoginMediator = require("Business/Login/Mediators/LoginMediator")
local LoginPageBase = class("LoginPageBase", PureMVC.ViewComponentPage)
LoginPageBase.LoginChannelType = {
  LCT_Develop = 0,
  LCT_QQ = 1,
  LCT_WeChat = 2,
  LCT_PlatformAuto = 3
}
function LoginPageBase:OnOpen(luaOpenData, nativeOpenData)
  GameFacade:SendNotification(NotificationDefines.Login.NtfInitPage)
end
function LoginPageBase:ListNeededMediators()
  return {LoginMediator}
end
function LoginPageBase:SetWidgetVisibility(widgetName, visibleType)
  if not widgetName or not self[widgetName] then
    return
  end
  self[widgetName]:SetVisibility(visibleType)
end
function LoginPageBase:InitPage(loginInfo)
  self:SetWidgetVisibility("CanvasLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("CanvasPanel_Policy", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("Text_Hint", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("Border_ErrorHint", UE4.ESlateVisibility.Collapsed)
  if BUILD_SHIPPING then
    self:SetWidgetVisibility("CanvasPanel_DirServerSelect", UE4.ESlateVisibility.Collapsed)
  else
    self:SetWidgetVisibility("CanvasPanel_DirServerSelect", UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Swicher_PwdVisible then
    self.Swicher_PwdVisible:SetActiveWidgetIndex(0)
  end
  if type(loginInfo.privacyFlag) == "boolean" and self.CheckBox_Policy then
    self.CheckBox_Policy:SetIsChecked(loginInfo.privacyFlag)
  end
  self.TxtGameVersion:SetText(string.format(loginInfo.verContent, loginInfo.gameVersion, loginInfo.resVersion))
  self:BindEvent()
end
function LoginPageBase:BindEvent()
  self.EnterAfterAuthedEvent = LuaEvent.new()
  if self.Btn_EnterGame then
    self.Btn_EnterGame.OnClicked:Add(self, self.OnClickedLogin)
  end
  if self.Btn_EnterGame_SkipSequence then
    self.Btn_EnterGame_SkipSequence.OnClicked:Add(self, self.OnClickedLoginSkipSequence)
  end
  if self.Btn_RandomNick then
    self.Btn_RandomNick.OnClicked:Add(self, self.OnClickRandomNick)
  end
  if self.Btn_CreatePlayer then
    self.Btn_CreatePlayer.OnClicked:Add(self, self.OnClickCreatePlayer)
  end
  if self.Btn_HidePassword then
    self.Btn_HidePassword.OnClicked:Add(self, self.OnPwdVisible)
  end
  if self.Btn_ShowPassword then
    self.Btn_ShowPassword.OnClicked:Add(self, self.OnPwdVisible)
  end
  if self.Button_AgeTips then
    self.Button_AgeTips.OnClicked:Add(self, self.OnClickAgeTips)
  end
  if self.Button_Known then
    self.Button_Known.OnClicked:Add(self, self.OnClickKnown)
  end
  if self.Btn_SelectDirServer then
    self.Btn_SelectDirServer.OnClicked:Add(self, self.OnClickSelectDirServer)
  end
  if self.Btn_ReLoginDirServer then
    self.Btn_ReLoginDirServer.OnClicked:Add(self, self.OnClickReLoginDirServer)
  end
  if self.CheckBox_Policy then
    self.CheckBox_Policy.OnCheckStateChanged:Add(self, self.OnCheckStateChangedPolicy)
  end
  if self.Button_UserAgreement then
    self.Button_UserAgreement.OnClicked:Add(self, self.OnClickedUserAgreement)
  end
  if self.Button_PrivacyPolicy then
    self.Button_PrivacyPolicy.OnClicked:Add(self, self.OnClickedPrivacyPolicy)
  end
  if self.Button_ChildrenPrivacyPolicy then
    self.Button_ChildrenPrivacyPolicy.OnClicked:Add(self, self.OnClickedChildrenPrivacyPolicy)
  end
  if self.Button_ThirdPartyList then
    self.Button_ThirdPartyList.OnClicked:Add(self, self.OnClickedThirdPartyList)
  end
  if self.BtnReplayCG then
    self.BtnReplayCG.OnClicked:Add(self, self.OnClickPlayPreStoryCG)
    self.BtnReplayCG.OnHovered:Add(self, self.ShowReplayCGTips)
    self.BtnReplayCG.OnUnhovered:Add(self, self.HideReplayCGTips)
  end
  if self.BtnHideQRCode then
    self.BtnHideQRCode.OnClickEvent:Add(self, self.HideCommunityQRCode)
  end
end
function LoginPageBase:OnClose()
  if self.Btn_EnterGame then
    self.Btn_EnterGame.OnClicked:Remove(self, self.OnClickedLogin)
  end
  if self.Btn_EnterGame_SkipSequence then
    self.Btn_EnterGame_SkipSequence.OnClicked:Remove(self, self.OnClickedLoginSkipSequence)
  end
  if self.Btn_RandomNick then
    self.Btn_RandomNick.OnClicked:Remove(self, self.OnClickRandomNick)
  end
  if self.Btn_CreatePlayer then
    self.Btn_CreatePlayer.OnClicked:Remove(self, self.OnClickCreatePlayer)
  end
  if self.Btn_HidePassword then
    self.Btn_HidePassword.OnClicked:Remove(self, self.OnPwdVisible)
  end
  if self.Btn_ShowPassword then
    self.Btn_ShowPassword.OnClicked:Remove(self, self.OnPwdVisible)
  end
  if self.Button_AgeTips then
    self.Button_AgeTips.OnClicked:Remove(self, self.OnClickAgeTips)
  end
  if self.Button_Known then
    self.Button_Known.OnClicked:Remove(self, self.OnClickKnown)
  end
  if self.Btn_SelectDirServer then
    self.Btn_SelectDirServer.OnClicked:Remove(self, self.OnClickSelectDirServer)
  end
  if self.Btn_ReLoginDirServer then
    self.Btn_ReLoginDirServer.OnClicked:Remove(self, self.OnClickReLoginDirServer)
  end
  if self.CheckBox_Policy then
    self.CheckBox_Policy.OnCheckStateChanged:Remove(self, self.OnCheckStateChangedPolicy)
  end
  if self.Button_UserAgreement then
    self.Button_UserAgreement.OnClicked:Remove(self, self.OnClickedUserAgreement)
  end
  if self.Button_PrivacyPolicy then
    self.Button_PrivacyPolicy.OnClicked:Remove(self, self.OnClickedPrivacyPolicy)
  end
  if self.Button_ChildrenPrivacyPolicy then
    self.Button_ChildrenPrivacyPolicy.OnClicked:Remove(self, self.OnClickedChildrenPrivacyPolicy)
  end
  if self.Button_ThirdPartyList then
    self.Button_ThirdPartyList.OnClicked:Remove(self, self.OnClickedThirdPartyList)
  end
  if self.BtnReplayCG then
    self.BtnReplayCG.OnClicked:Remove(self, self.OnClickPlayPreStoryCG)
    self.BtnReplayCG.OnHovered:Remove(self, self.ShowReplayCGTips)
    self.BtnReplayCG.OnUnhovered:Remove(self, self.HideReplayCGTips)
  end
end
function LoginPageBase:PlayBgVideo()
  if not self.BgMediaPlayer or not self.BgVideoPlaylist then
    return
  end
  if self.BgVideoPlaylist then
    self.BgVideoPlaylist:RemoveAt(0)
  end
  self.BgVideoPlaylist:AddFile(self.BgMediaFile.FilePath)
  self.BgMediaPlayer:OpenPlaylist(self.BgVideoPlaylist)
  self.BgMediaPlayer:SetLooping(true)
  self.BgMediaPlayer:Play()
end
function LoginPageBase:CloseMediaPlayer()
  if self.BgMediaPlayer then
    self.BgMediaPlayer:Close()
  end
end
function LoginPageBase:SetHintMsg(msg, errorCode)
  local errCode = errorCode or 0
  if (not msg or UE4.UKismetTextLibrary.TextIsEmpty(msg)) and 0 == errCode then
    return
  end
  local AkUserWidget = self:Cast(UE4.UPMLoginPageWidget)
  if AkUserWidget and AkUserWidget:IsValid() then
    self:K2_StopAkEvent(AkUserWidget.AkHintErrorMsg)
  end
  if errCode > 0 then
    if AkUserWidget and AkUserWidget:IsValid() then
      self:K2_PostAkEvent(AkUserWidget.AkHintErrorMsg, true)
    end
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
    if UE4.UKismetTextLibrary.TextIsEmpty(msg) then
      LogError("LogOnline Error", "Error Code: %d, not in table", errCode)
    end
  end
end
function LoginPageBase:SetPageState(state, param)
  if state == LoginMediator.ViewState.LogoutState then
    self:GotoPageStateLogout(param)
  elseif state == LoginMediator.ViewState.Authed then
    self:GotoPageStateAuthed(param)
  elseif state == LoginMediator.ViewState.PlatformLogout then
    self:GotoPageStatePlatformLogout(param)
  elseif state == LoginMediator.ViewState.PlatformAuthed then
    self:GotoPageStatePlatformAuthed(param)
  elseif state == LoginMediator.ViewState.CreatePlayer then
    self:GotoPageStateCreatePlayer(param)
  end
end
function LoginPageBase:GotoPageStateLogout(publicChannel)
end
function LoginPageBase:GotoPageStateAuthed(param)
end
function LoginPageBase:GotoPageStatePlatformLogout(param)
end
function LoginPageBase:GotoPageStatePlatformAuthed(param)
end
function LoginPageBase:GotoPageStateCreatePlayer(playerName)
  self:SetHintMsg()
end
function LoginPageBase:EnterGameAfterAuthed()
  self.EnterAfterAuthedEvent()
  self:SetWidgetVisibility("BtnLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("TextLoginLobby", UE4.ESlateVisibility.Collapsed)
  self:SetWidgetVisibility("TextEnterLobby", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPageBase:LoginBtnsEnable(isEnable)
  if self.Btn_EnterGame then
    self.Btn_EnterGame:SetIsEnabled(isEnable)
  end
  if self.Btn_EnterGame_SkipSequence then
    self.Btn_EnterGame_SkipSequence:SetIsEnabled(isEnable)
  end
  if self.Btn_QQLogin then
    self.Btn_QQLogin:SetIsEnabled(isEnable)
  end
  if self.Btn_WeChatLogin then
    self.Btn_WeChatLogin:SetIsEnabled(isEnable)
  end
end
function LoginPageBase:PlatformLoginBtnsEnable(isEnable)
  if self.BtnAutoLogin then
    self.BtnAutoLogin:SetIsEnabled(isEnable)
  end
end
function LoginPageBase:ShowRandomName(RandomName)
  self.Txt_NickName:SetText(RandomName)
end
function LoginPageBase:ShowSelectServer(isShow)
end
function LoginPageBase:UpdateServerIpPort(serverIpPort)
  if self.Text_DirServerIpPort then
    self.Text_DirServerIpPort:SetText(serverIpPort)
  end
end
function LoginPageBase:OnPwdVisible()
  local curIsPassword = not self.Txt_Token.IsPassword
  self.Swicher_PwdVisible:SetActiveWidgetIndex(curIsPassword and 0 or 1)
  self.Txt_Token:SetIsPassword(curIsPassword)
end
function LoginPageBase:OnClickedLogin()
  if not self:CheckReadPolicy() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoLogin, self.LoginChannelType.LCT_Develop)
end
function LoginPageBase:OnClickedLoginSkipSequence()
  local gameInstance = UE4.UGameplayStatics.GetGameInstance(LuaGetWorld())
  if gameInstance then
    gameInstance:SetLoginIsSkipSequence(true)
  end
  GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy):SkipLoggingStep()
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoLogin, self.LoginChannelType.LCT_Develop)
end
function LoginPageBase:OnCheckStateChangedPolicy(bIsChecked)
  LogInfo("LoginPageBase:OnCheckStateChangedPolicy", tostring(bIsChecked))
  local LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self)
  LoginSubsystem:SetCheckedPrivacyFlag(bIsChecked)
end
function LoginPageBase:CheckReadPolicy()
  local read = true
  if self.CheckBox_Policy and self.CheckBox_Policy:IsChecked() == false then
    read = false
    local readInfo = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PleaseRead")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, readInfo)
  end
  return read
end
function LoginPageBase:OnClickedUserAgreement()
  LogInfo("LoginPageBase:OnClickedUserAgreement", "")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.UserAgreement), 1, 0.7)
end
function LoginPageBase:OnClickedPrivacyPolicy()
  LogInfo("LoginPageBase:OnClickedPrivacyPolicy", "")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.PrivacyPolicy), 1, 0.7)
end
function LoginPageBase:OnClickedChildrenPrivacyPolicy()
  LogInfo("LoginPageBase:OnClickedChildrenPrivacyPolicy", "")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.ChildrenPrivacyPolicy), 1, 0.7)
end
function LoginPageBase:OnClickedThirdPartyList()
  LogInfo("LoginPageBase:OnClickedThirdPartyList", "")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.ThirdPartyList), 1, 0.7)
end
function LoginPageBase:OnClickRandomNick()
  GameFacade:SendNotification(NotificationDefines.Login.NtfReqRandomName)
end
function LoginPageBase:OnClickCreatePlayer()
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoCreatPlayer, self.Txt_NickName:GetText())
end
function LoginPageBase:OnClickRegister()
  GameFacade:SendNotification(NotificationDefines.Login.NtfOpenRegisterPage)
end
function LoginPageBase:OnClickResetPwd()
  GameFacade:SendNotification(NotificationDefines.Login.NtfOpenResetPwdPage)
end
function LoginPageBase:OnClickAgeTips()
  self:SetWidgetVisibility("CanvasPanel_Policy", UE4.ESlateVisibility.Visible)
end
function LoginPageBase:OnClickKnown()
  self:SetWidgetVisibility("CanvasPanel_Policy", UE4.ESlateVisibility.Hidden)
end
function LoginPageBase:OnClickSelectDirServer()
  GameFacade:SendNotification(NotificationDefines.Login.NtfShowSelectServerPage)
end
function LoginPageBase:OnClickReLoginDirServer()
  if not self.Text_DirServerIpPort then
    return
  end
  GameFacade:SendNotification(NotificationDefines.Login.NtfReLoginServer, self.Text_DirServerIpPort:GetText())
end
function LoginPageBase:OnClickRealIdAuth()
  ViewMgr:OpenPage(self, UIPageNameDefine.AuthPage)
end
function LoginPageBase:OnClickPlayPreStoryCG(isFirstPlay)
  self:PreReplayCG()
  ViewMgr:OpenPage(self, UIPageNameDefine.PrefaceStoryPage, nil, {
    IsReplay = not isFirstPlay
  })
end
function LoginPageBase:ShowReplayCGTips()
  self:SetWidgetVisibility("CanvasReplayTips", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPageBase:HideReplayCGTips()
  self:SetWidgetVisibility("CanvasReplayTips", UE4.ESlateVisibility.Collapsed)
end
function LoginPageBase:PreReplayCG()
  if self.AkEventEmpty and self.AkEventEmpty:IsValid() then
    self:K2_PostAkEvent(self.AkEventEmpty)
  end
  self:CloseMediaPlayer()
end
function LoginPageBase:AfterReplayCG()
  if self.AkEventBGM and self.AkEventBGM:IsValid() then
    self:K2_PostAkEvent(self.AkEventBGM)
  end
  self:PlayBgVideo()
end
function LoginPageBase:ShowCommunityQRCode()
  self:SetWidgetVisibility("CanvasCommunityQRCode", UE4.ESlateVisibility.SelfHitTestInvisible)
end
function LoginPageBase:HideCommunityQRCode()
  self:SetWidgetVisibility("CanvasCommunityQRCode", UE4.ESlateVisibility.Collapsed)
end
return LoginPageBase
