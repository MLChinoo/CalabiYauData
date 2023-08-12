local LoginMediator = class("LoginMediator", PureMVC.Mediator)
LoginMediator.ViewState = {
  LogoutState = 1,
  Authed = 2,
  PlatformLogout = 3,
  PlatformAuthed = 4,
  CreatePlayer = 5
}
local ServerOverDuration = 5
local AuthInputControlDuration = 15
function LoginMediator:OnRegister()
  self.super:OnRegister()
  self.CanClickLogin = true
  self.CurPageState = -1
  self.ViewPage = self:GetViewComponent()
  self.LoginProxy = GameFacade:RetrieveProxy(ProxyNames.LoginData)
  self:InitModule()
  InitRedDot()
  self.NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    LogDebug("LoginMediator", "is TodayFirstLogin")
    if self.NoticeSubSys then
      self.OnLoadNoticeDataSuccessHandler = DelegateMgr:AddDelegate(self.NoticeSubSys.OnLoadNoticeDataSuccess, self, "InitNotice")
      self.SeverShotDownCheckHandler = DelegateMgr:AddDelegate(self.NoticeSubSys.OnLoadBlockNoticeData, self, "ServerShotDownCheckRlt")
      self.NoticeSubSys:LoadNoticeData("0", "zh-CN", 156)
    end
  end
end
function LoginMediator:InitNotice()
  local LoginBeforeNoticeInfoList = self.NoticeSubSys:GetLoginBeforeNoticeInfoList()
  if LoginBeforeNoticeInfoList:Length() > 0 then
    if self.NoticeSubSys:GetTodayFirstLoginStatus() then
      ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.NoticePage, false, 2)
    else
      LogDebug("LoginMediator", "not is TodayFirstLogin")
    end
    if self.ViewPage.CanvasNotice then
      self.ViewPage.CanvasNotice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.ViewPage.CanvasNotice then
    self.ViewPage.CanvasNotice:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function LoginMediator:InitModule()
  self.LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self.ViewPage)
  if not self.LoginSubsystem then
    LogInfo("LoginMediator", "LoginMediator:InitModule, LoginSubsystem is nil")
    return
  end
  self.LoginSubsystem:Reset()
  self.LoginStateChangedHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.LoginStateChanged, self, LoginMediator.OnLoginStateChanged)
  self.HintMsgDelegatehandler = DelegateMgr:BindDelegate(self.LoginSubsystem.HintMsgDelegate, self, LoginMediator.SetHintMsg)
  self.LoginBtnEnableDelegateHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.LoginBtnEnableDelegate, self, LoginMediator.OnLoginBtnEnable)
  self.UpdateServerIpPortDelegateHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.UpdateServerIpPortDelegate, self, LoginMediator.UpdateServerIpPort)
  self.PendingDelegateHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.PendingDelegate, self, LoginMediator.DoingLogin)
  self.OnLoginLobbyEndHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.OnLoginLobbyEnd, self, LoginMediator.OnLoginLobbyFinished)
  self.ServerNotOpenDelegateHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.ServerNotOpenDelegate, self, LoginMediator.OnServerNotOpenEvent)
  self.NativeBrowserDialogStateHandler = DelegateMgr:BindDelegate(self.LoginSubsystem.UseNativeBrowserDialogStateDelegate, self, LoginMediator.OnUseBrowserDialogStateChange)
end
function LoginMediator:OnRemove()
  self.super:OnRemove()
  self:ShowPending(false)
  if self.ParamsCheckTimer then
    self.ParamsCheckTimer:EndTask()
    self.ParamsCheckTimer = nil
  end
  if self.ReqRandomNameTimer then
    self.ReqRandomNameTimer:EndTask()
    self.ReqRandomNameTimer = nil
  end
  self:ClearUnTouchLoginBtnsTimer()
  if self.ViewPage.EnterAfterAuthedEvent then
    self.ViewPage.EnterAfterAuthedEvent:Remove(LoginMediator.DoEnterGame, self)
  end
  if self.LoginStateChangedHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.LoginStateChanged, self.LoginStateChangedHandler)
    self.LoginStateChangedHandler = nil
  end
  if self.HintMsgDelegatehandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.HintMsgDelegate, self.HintMsgDelegatehandler)
    self.HintMsgDelegatehandler = nil
  end
  if self.UpdateServerIpPortDelegateHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.UpdateServerIpPortDelegate, self.UpdateServerIpPortDelegateHandler)
    self.UpdateServerIpPortDelegateHandler = nil
  end
  if self.PendingDelegateHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.PendingDelegate, self.PendingDelegateHandler)
    self.PendingDelegateHandler = nil
  end
  if self.OnLoginLobbyEndHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.OnLoginLobbyEnd, self.OnLoginLobbyEndHandler)
    self.OnLoginLobbyEndHandler = nil
  end
  if self.LoginBtnEnableDelegateHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.LoginBtnEnableDelegate, self.LoginBtnEnableDelegateHandler)
    self.LoginBtnEnableDelegateHandler = nil
  end
  if self.OnLoadNoticeDataSuccessHandler then
    DelegateMgr:RemoveDelegate(self.NoticeSubSys.OnLoadNoticeDataSuccess, self.OnLoadNoticeDataSuccessHandler)
    self.OnLoadNoticeDataSuccessHandler = nil
  end
  if self.SeverShotDownCheckHandler then
    DelegateMgr:RemoveDelegate(self.NoticeSubSys.OnLoadBlockNoticeData, self.SeverShotDownCheckHandler)
    self.SeverShotDownCheckHandler = nil
  end
  if self.ServerNotOpenDelegateHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.ServerNotOpenDelegate, self.ServerNotOpenDelegateHandler)
    self.ServerNotOpenDelegateHandler = nil
  end
  if self.NativeBrowserDialogStateHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.UseNativeBrowserDialogStateDelegate, self.NativeBrowserDialogStateHandler)
    self.NativeBrowserDialogStateHandler = nil
  end
  if self.ShowUseBrowserOptionHandler then
    DelegateMgr:UnbindDelegate(self.LoginSubsystem.ShowUseNativeBrowserOption, self.ShowUseBrowserOptionHandler)
    self.ShowUseBrowserOptionHandler = nil
  end
end
function LoginMediator:ListNotificationInterests()
  return {
    NotificationDefines.Login.NtfInitPage,
    NotificationDefines.Login.NtfDoLogin,
    NotificationDefines.Login.NtfDoQQLogin,
    NotificationDefines.Login.NtfDoWeChatLogin,
    NotificationDefines.Login.NtfDoPlatformLogin,
    NotificationDefines.Login.NtfOpenRegisterPage,
    NotificationDefines.Login.NtfOpenResetPwdPage,
    NotificationDefines.Login.NtfShowSelectServerPage,
    NotificationDefines.Login.NtfReLoginServer,
    NotificationDefines.Login.NtfClearHint,
    NotificationDefines.Login.NtfOpenNativeBrowser,
    NotificationDefines.Login.NotePrefaceStoryPageClose,
    NotificationDefines.Login.NtfWebView2Repair,
    NotificationDefines.Login.NtfPlayerCloseLoginQueuePage,
    NotificationDefines.Login.NtfCloseUseBrowserPage
  }
end
function LoginMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  if NtfName == NotificationDefines.Login.NtfInitPage then
    self:InitPage()
  elseif NtfName == NotificationDefines.Login.NtfDoLogin then
    self:CheckServerState(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfDoQQLogin then
    self:CheckServerState(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfDoWeChatLogin then
    self:CheckServerState(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfDoPlatformLogin then
    self:CheckServerState(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfReqRandomName then
    self:ReqRandomName()
  elseif NtfName == NotificationDefines.Login.NtfDoCreatPlayer then
    self:DoCreatePlayer(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfOpenRegisterPage then
    self:OpenRegisterPage()
  elseif NtfName == NotificationDefines.Login.NtfOpenResetPwdPage then
    self:OpenResetPwdPage()
  elseif NtfName == NotificationDefines.Login.NtfShowSelectServerPage then
    self:ShowSelectServerPage()
  elseif NtfName == NotificationDefines.Login.NtfReLoginServer then
    self:ReLoginDirServer(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfClearHint then
    self:SetHintMsg("", 0)
  elseif NtfName == NotificationDefines.Login.NtfOpenNativeBrowser then
    self:OpenNativeBrowser()
  elseif NtfName == NotificationDefines.Login.NotePrefaceStoryPageClose then
    self:AfterPlayCG(notification:GetBody())
  elseif NtfName == NotificationDefines.Login.NtfWebView2Repair then
    self:DoRepairWebView()
  elseif NtfName == NotificationDefines.Login.NtfPlayerCloseLoginQueuePage then
    self:PlayerCanelLoginQueue()
  elseif NtfName == NotificationDefines.Login.NtfCloseUseBrowserPage then
    self:OnUseBrowserDialogStateChange(nil, UE4.EPMUseNativeBrowserState.CloseBrowser)
  end
end
function LoginMediator:InitPage()
  local loginPageInfo = {}
  self.AuthSDKType = self.LoginSubsystem:GetAuthSDKType()
  self.ModuleState = self.LoginSubsystem.LoginState
  loginPageInfo.openId = self.LoginSubsystem:GetLoginOpenId()
  loginPageInfo.token = self.LoginSubsystem:GetLoginToken()
  local openIdLen = string.len(loginPageInfo.token)
  if openIdLen > self.ViewPage.Txt_OpenId.MaxCharactersNum or openIdLen < self.ViewPage.Txt_OpenId.MinCharactersNum then
    loginPageInfo.openId = ""
    loginPageInfo.token = ""
  end
  loginPageInfo.privacyFlag = self.LoginSubsystem:GetCheckedPrivacyFlag()
  loginPageInfo.useNativeBrowserState = self.LoginSubsystem:GetUseNativeBrowserFlag()
  loginPageInfo.gameVersion = self.LoginSubsystem:GetGameVersion()
  loginPageInfo.resVersion = self.LoginSubsystem:GetResVersion()
  loginPageInfo.verContent = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "GameAndResVersion")
  self.ViewPage:InitPage(loginPageInfo)
  if self.ViewPage.EnterAfterAuthedEvent then
    self.ViewPage.EnterAfterAuthedEvent:Add(LoginMediator.DoEnterGame, self)
  end
  self:OnLoginStateChanged(self.ModuleState)
  self.LoginSubsystem:UpdateDirServerIpPortText()
  if self.LoginSubsystem:NeedPlayPrefadeStory() then
    LogInfo("Login Log", "LoginMediator: Play Preface Story")
    self.ViewPage:OnClickPlayPreStoryCG(true)
  else
    self:ReallyShowPage()
  end
end
function LoginMediator:ReallyShowPage()
  local welcomeVoiceId = self.LoginProxy:RandomRoleWelcomeVoiceId()
  if welcomeVoiceId then
    local voiceRows = ConfigMgr:GetRoleVoiceTableRows()
    voiceRows = voiceRows:ToLuaTable()
    local voiceCfg = voiceRows[tostring(welcomeVoiceId)]
    if voiceCfg and voiceCfg.AkEvent then
      LogInfo("Login Log", "Login welcome voice id : %d", welcomeVoiceId)
      local AudioPlayer = UE4.UPMLuaAudioBlueprintLibrary
      AudioPlayer.PostEvent(AudioPlayer.GetID(voiceCfg.AkEvent))
    else
      LogWarn("Login Log", "Login welcome voice config missing! Voice id : %d", welcomeVoiceId)
    end
  end
  if self.ViewPage.AkEventBGM and self.ViewPage.AkEventBGM:IsValid() then
    self.ViewPage:K2_PostAkEvent(self.ViewPage.AkEventBGM)
  end
  self.ViewPage:PlayBgVideo()
end
function LoginMediator:OnLoginLobbyFinished()
  self.ViewPage:CloseMediaPlayer()
end
function LoginMediator:OnLoginStateChanged(newState, ctrlOpt)
  if not newState then
    return
  end
  LogInfo("Login Log", "OnLoginStateChanged : %d", newState)
  self.ModuleState = newState
  if newState == UE4.EPMLoginState.Logout then
    self:OnLoginStateLogout()
  elseif newState == UE4.EPMLoginState.Authed then
    self:OnLoginStateAuthed(ctrlOpt)
  elseif newState == UE4.EPMLoginState.PlatformLogout then
    self:OnLoginStatePlatformLogout()
  elseif newState == UE4.EPMLoginState.PlatformAuthed then
    self:OnLoginStatePlatformAuthed(ctrlOpt)
  elseif newState == UE4.EPMLoginState.LoginLobby then
    self:OnLoginStateLoginLobby(ctrlOpt)
  elseif newState == UE4.EPMLoginState.CreatePlayer then
  elseif newState == UE4.EPMLoginState.Logined then
    local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
    FlapFaceProxy:SetLoginFlag(true)
  end
end
function LoginMediator:GotoViewState(state, param)
  if not state then
    return
  end
  self.CurPageState = state
  self.ViewPage:SetPageState(state, param)
end
function LoginMediator:OnLoginStateLogout()
  self:GotoViewState(LoginMediator.ViewState.LogoutState, self.AuthSDKType)
end
function LoginMediator:OnLoginStateAuthed(ctrlOpt)
  self:GotoViewState(LoginMediator.ViewState.Authed, ctrlOpt)
end
function LoginMediator:OnLoginStatePlatformLogout(ctrlOpt)
  self:GotoViewState(LoginMediator.ViewState.PlatformLogout, ctrlOpt)
end
function LoginMediator:OnLoginStatePlatformAuthed(ctrlOpt)
  self:GotoViewState(LoginMediator.ViewState.PlatformAuthed, ctrlOpt)
end
function LoginMediator:OnLoginStateLoginLobby(ctrlOpt)
  self:GotoViewState(LoginMediator.ViewState.PlatformAuthed, ctrlOpt)
end
function LoginMediator:SetHintMsg(msg, errorCode)
  self.ViewPage:SetHintMsg(msg, errorCode)
end
function LoginMediator:CheckServerState(loginChannelType)
  self.LoginChannelType = loginChannelType
  if BUILD_SHIPPING then
    self.NoticeSubSys:LoadBlockNoticeData()
  else
    self:ServerShotDownCheckRlt(false)
  end
end
function LoginMediator:ServerShotDownCheckRlt(isShutDown)
  if isShutDown then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.NoticePage, false, 1)
  else
    local channelTypeEnum = self.ViewPage.LoginChannelType
    if self.LoginChannelType == channelTypeEnum.LCT_Develop then
      self:LoginProcess()
    elseif self.LoginChannelType == channelTypeEnum.LCT_QQ then
      self:QQLoginProcess()
    elseif self.LoginChannelType == channelTypeEnum.LCT_WeChat then
      self:WechatLoginProcess()
    elseif self.LoginChannelType == channelTypeEnum.LCT_PlatformAuto then
      self:PlatformLoginProcess()
    end
  end
end
function LoginMediator:CheckCanLogin()
  self.CanClickLogin = false
  self.ParamsCheckTimer = TimerMgr:AddTimeTask(AuthInputControlDuration, 0.0, 0, function()
    self.CanClickLogin = true
    self.ParamsCheckTimer = nil
  end)
end
function LoginMediator:LoginProcess()
  local openId, accessToken
  if self.ViewPage.Txt_OpenId then
    openId = self.ViewPage.Txt_OpenId:GetText()
    if UE4.UKismetTextLibrary.TextIsEmpty(openId) then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "OpenIdEmpty"), 1)
      return
    end
    if self.ViewPage.Txt_OpenId:HasChinese() and self.ViewPage.Txt_OpenId:HasSpace() then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "OpenIdInputError"), 1)
      return
    end
    if not self.ViewPage.Txt_OpenId:IsMatchLimit() then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "OpenIdLenError"), 1)
      return
    end
  end
  if self.ViewPage.Txt_Token then
    accessToken = self.ViewPage.Txt_Token:GetText()
    if UE4.UKismetTextLibrary.TextIsEmpty(accessToken) then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "AccessTokenEmpty"), 1)
      return
    end
    if self.ViewPage.Txt_Token:HasChinese() and self.ViewPage.Txt_Token:HasSpace() then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "AccessTokenInputError"), 1)
      return
    end
    if not self.ViewPage.Txt_Token:IsMatchLimit() then
      self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "AccessTokenLenError"), 1)
      return
    end
  end
  self:OnLoginBtnEnable(false)
  self:SetHintMsg(UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "Logining"))
  self.LoginSubsystem:OnClickLogin(openId, accessToken)
end
function LoginMediator:QQLoginProcess()
  self:ShowPending(true)
  self.LoginSubsystem:OnClickQQLogin()
end
function LoginMediator:WechatLoginProcess()
  self:ShowPending(true)
  self.LoginSubsystem:OnClickWeChatLogin()
end
function LoginMediator:PlatformLoginProcess()
  self.LoginSubsystem:HandleLoginPageInitEnd()
end
function LoginMediator:DoEnterGame()
  self.LoginSubsystem:EnterGameAfterAuthed()
end
function LoginMediator:OpenNativeBrowser()
  self.LoginSubsystem:OpenLoginUrlInNativeBrowser()
end
function LoginMediator:OnLoginBtnEnable(isEnable)
  if self.ModuleState == UE4.EPMLoginState.Logout then
    self.ViewPage:LoginBtnsEnable(isEnable)
  elseif self.ModuleState == UE4.EPMLoginState.PlatformLogout then
    self.ViewPage:PlatformLoginBtnsEnable(isEnable)
  else
    self.ViewPage:SetEnterLobbyBtnUseable(isEnable)
  end
end
function LoginMediator:UnTouchLoginBtns()
  if self.ViewPage.Btn_EnterGame then
    self.ViewPage.Btn_EnterGame:SetIsEnabled(false)
  end
  if self.ViewPage.Btn_QQLogin then
    self.ViewPage.Btn_QQLogin:SetIsEnabled(false)
  end
  if self.ViewPage.Btn_WeChatLogin then
    self.ViewPage.Btn_WeChatLogin:SetIsEnabled(false)
  end
  self.UnTouchLoginBtnsTimer = TimerMgr:AddTimeTask(ServerOverDuration, 0.0, 0, function()
    self.ViewPage:LoginBtnsEnable(true)
    self.UnTouchLoginBtnsTimer = nil
  end)
end
function LoginMediator:ClearUnTouchLoginBtnsTimer()
  if self.UnTouchLoginBtnsTimer then
    self.UnTouchLoginBtnsTimer:EndTask()
    self.UnTouchLoginBtnsTimer = nil
  end
end
function LoginMediator:PlayerCanelLoginQueue()
  self.LoginSubsystem:PlayerCancelLoginQueue()
end
function LoginMediator:OnCreatePlayer(playerName)
  self:ShowPending(false)
  self:GotoViewState(self.ViewState.CreatePlayer, playerName)
end
function LoginMediator:ReqRandomName()
  if self.ReqRandomNameTimer then
    return
  end
  self.ReqRandomNameTimer = TimerMgr:AddTimeTask(0.4, 0.0, 1, function()
    self.ReqRandomNameTimer = nil
  end)
  self.LoginSubsystem:OnClickRandomNick()
end
function LoginMediator:GetRandomName(RandomName)
  self.ViewPage:ShowRandomName(RandomName)
end
function LoginMediator:DoCreatePlayer(curName)
  self.LoginSubsystem:OnClickCreatePlayer(curName)
end
function LoginMediator:OpenRegisterPage()
  ViewMgr:OpenPage(self.ViewPage, UIPageNameDefine.PMRegisterPagePC, nil, {isRegister = true})
end
function LoginMediator:OpenResetPwdPage()
  ViewMgr:OpenPage(self.ViewPage, UIPageNameDefine.PMRegisterPagePC, nil, {isRegister = false})
end
function LoginMediator:GetLoginURL(loginURL)
  self.ViewPage:ShowLoginWebPage(loginURL)
  self:ShowPending(false)
end
function LoginMediator:ShowSelectServerPage()
  self.LoginSubsystem:OnClickSelectDirServer()
end
function LoginMediator:ReLoginDirServer(serverIpPort)
  self.LoginSubsystem:OnClickReLoginDirServer(serverIpPort)
end
function LoginMediator:UpdateServerIpPort(serverIpPort)
  self.ViewPage:UpdateServerIpPort(serverIpPort)
end
function LoginMediator:DoingLogin(authing)
  self:ShowPending(authing)
end
function LoginMediator:ShowPending(isPending, NoOverTimeTips)
  if isPending then
    local params = {MsgCode = 102, Time = AuthInputControlDuration}
    if NoOverTimeTips then
      params.MsgCode = nil
    end
    ViewMgr:OpenPage(self.ViewPage, UIPageNameDefine.PendingPage, nil, params)
  else
    ViewMgr:ClosePage(self.ViewPage, UIPageNameDefine.PendingPage)
  end
end
function LoginMediator:AfterPlayCG(isReplay)
  if isReplay then
    self.ViewPage:AfterReplayCG()
  else
    self:ReallyShowPage()
  end
end
function LoginMediator:OnServerNotOpenEvent(msg)
  local pageData = {}
  pageData.bIsOneBtn = "three"
  pageData.contentTxt = msg
  pageData.btnTxtList = {
    "确认",
    "前往官网",
    "前往社区"
  }
  pageData.source = self
  pageData.cb = self.GotoCommunityCallback
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function LoginMediator:GotoCommunityCallback(select)
  if 2 == select then
    UE4.UKismetSystemLibrary.LaunchURL("https://klbq.qq.com/web202305/index.html?nav=home")
  elseif 3 == select then
    self.ViewPage:ShowCommunityQRCode()
  end
end
function LoginMediator:DoRepairWebView()
  self.LoginSubsystem:DoRepairWebView2Com()
end
function LoginMediator:OnShowUseBrowserOption(isShow)
  if isShow and self.ViewPage.ShowNativeBrowserOption then
    self.ViewPage:ShowNativeBrowserOption()
  end
end
function LoginMediator:OnUseBrowserDialogStateChange(loginType, newState)
  if newState == UE4.EPMUseNativeBrowserState.ShowBrowser then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.UseNativeBrowserPage, nil, {loginType = loginType, newState = newState})
  elseif newState == UE4.EPMUseNativeBrowserState.CloseBrowser then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.UseNativeBrowserPage)
  elseif newState == UE4.EPMUseNativeBrowserState.FixRegisteTable then
    GameFacade:SendNotification(NotificationDefines.Login.NtfUseBrowserStateChange, {loginType = loginType, newState = newState})
  end
end
return LoginMediator
