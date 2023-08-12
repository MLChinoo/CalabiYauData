local NavigationMenuPageMediator = require("Business/NavigationBar/Mediators/NavigationMenuPageMediator")
local NavigationMenuPage = class("NavigationMenuPage", PureMVC.ViewComponentPage)
local FunctionOpenEnum = require("Business/Common/Proxies/FunctionOpenEnum")
function NavigationMenuPage:ListNeededMediators()
  return {NavigationMenuPageMediator}
end
function NavigationMenuPage:UpdataRedDot()
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy:GetPhoneBingHasReward() or AccountBindProxy:GetFBBingHasReward() then
    self.AccountBindRedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.AccountBindRedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationMenuPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Img_BackgroundBlur then
    self.Img_BackgroundBlur.OnMouseButtonDownEvent:Bind(self, self.OnClickBackground)
  end
  if self.PMButton_Setting then
    self.PMButton_Setting.OnPMButtonClicked:Add(self, self.OnClickSetting)
  end
  if self.NetworkStatePanel then
    self.NetworkStatePanel:OnOpen()
  end
  if self.PMButton_Notice then
    self.PMButton_Notice.OnPMButtonClicked:Add(self, self.OnClickNotice)
  end
  if self.PMButton_AccountBind then
    self.PMButton_AccountBind.OnPMButtonClicked:Add(self, self.OnClickAccountBind)
  end
  if self.PMButton_CustomerService then
    self.PMButton_CustomerService.OnPMButtonClicked:Add(self, self.OnClickCustomerServiceBtn)
  end
  if self.PMButton_FeedBack then
    self.PMButton_FeedBack.OnPMButtonClicked:Add(self, self.OnClickFeedBack)
  end
  if self.PMButton_LogOut then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.PC then
      self.PMButton_LogOut:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.PMButton_LogOut.OnPMButtonClicked:Add(self, self.OnClickLogOut)
    end
  end
  if self.PMButton_Exit then
    self.PMButton_Exit.OnPMButtonClicked:Add(self, self.OnClickExit)
  end
  if self.PMButton_PersonalPrivacy then
    self.PMButton_PersonalPrivacy.OnPMButtonClicked:Add(self, self.OnClickPersonalPrivacy)
  end
  if self.PMButton_ServiceAgreement then
    self.PMButton_ServiceAgreement.OnPMButtonClicked:Add(self, self.OnClickServiceAgreement)
  end
  if self.PMButton_Default then
    self.PMButton_Default.OnPMButtonClicked:Add(self, self.OnClickDefault)
  end
  if self.PMButton_ActiveCode then
    self.PMButton_ActiveCode.OnPMButtonClicked:Add(self, self.OnClickActiveCode)
  end
  if self.SizeBox_PersonalPrivacy then
    self.SizeBox_PersonalPrivacy:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.SizeBox_ServiceAgreement then
    self.SizeBox_ServiceAgreement:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.SizeBox_Default then
    self.SizeBox_Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PMButton_PersonalPrivacy then
    self.PMButton_PersonalPrivacy:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PMButton_ServiceAgreement then
    self.PMButton_ServiceAgreement:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PMButton_Default then
    self.PMButton_Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local FunctionOpenProxy = GameFacade:RetrieveProxy(ProxyNames.FunctionOpenProxy)
  if self.SizeBox_FeedBack then
    if nil ~= FunctionOpenProxy and FunctionOpenProxy:GetFunctionOpenByType(FunctionOpenEnum.FeedBack) then
      self.SizeBox_FeedBack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SizeBox_FeedBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.SizeBox_Notice then
    if nil ~= FunctionOpenProxy and FunctionOpenProxy:GetFunctionOpenByType(FunctionOpenEnum.Notice) then
      self.SizeBox_Notice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SizeBox_Notice:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.SizeBox_CustomerService then
    if nil ~= FunctionOpenProxy and FunctionOpenProxy:GetFunctionOpenByType(FunctionOpenEnum.CustomerService) then
      self.SizeBox_CustomerService:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SizeBox_CustomerService:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.SizeBox_ActiveCode then
    self.SizeBox_ActiveCode:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:UpdataRedDot()
end
function NavigationMenuPage:OnShow(luaOpenData, nativeOpenData)
  if self.NetworkStatePanel then
    self.NetworkStatePanel:OnShow()
  end
end
function NavigationMenuPage:OnClose()
  if self.Img_BackgroundBlur then
    self.Img_BackgroundBlur.OnMouseButtonDownEvent:Unbind()
  end
  if self.PMButton_Setting then
    self.PMButton_Setting.OnPMButtonClicked:Remove(self, self.OnClickSetting)
  end
  if self.NetworkStatePanel then
    self.NetworkStatePanel:OnClose()
  end
  if self.PMButton_Notice then
    self.PMButton_Notice.OnPMButtonClicked:Remove(self, self.OnClickNotice)
  end
  if self.PMButton_AccountBind then
    self.PMButton_AccountBind.OnPMButtonClicked:Remove(self, self.OnClickAccountBind)
  end
  if self.PMButton_CustomerService then
    self.PMButton_CustomerService.OnPMButtonClicked:Remove(self, self.OnClickCustomerServiceBtn)
  end
  if self.PMButton_FeedBack then
    self.PMButton_FeedBack.OnPMButtonClicked:Remove(self, self.OnClickFeedBack)
  end
  if self.PMButton_LogOut then
    self.PMButton_LogOut.OnPMButtonClicked:Remove(self, self.OnClickLogOut)
  end
  if self.PMButton_Exit then
    self.PMButton_Exit.OnPMButtonClicked:Remove(self, self.OnClickExit)
  end
  if self.PMButton_PersonalPrivacy then
    self.PMButton_PersonalPrivacy.OnPMButtonClicked:Remove(self, self.OnClickPersonalPrivacy)
  end
  if self.PMButton_ServiceAgreement then
    self.PMButton_ServiceAgreement.OnPMButtonClicked:Remove(self, self.OnClickServiceAgreement)
  end
  if self.PMButton_Default then
    self.PMButton_Default.OnPMButtonClicked:Remove(self, self.OnClickDefault)
  end
end
function NavigationMenuPage:OnClickSetting()
  ViewMgr:OpenPage(self, UIPageNameDefine.SettingPage)
end
function NavigationMenuPage:OnClickAccountBind()
  ViewMgr:OpenPage(self, UIPageNameDefine.AccountBindPage)
end
function NavigationMenuPage:OnClickNotice()
  ViewMgr:OpenPage(self, UIPageNameDefine.NoticePage, 3)
end
function NavigationMenuPage:OnClickCustomerServiceBtn()
  LogDebug("NavigationMenuPage", "OnClickCustomerServiceBtn")
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
function NavigationMenuPage:OnClickFeedBack()
  LogInfo("NavigationMenuPage", "OnClickFeedBack")
  local url = "https://wj.qq.com/s2/11440549/ea1d/"
  local FeedBackUrlIndex = 8108
  local row = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(FeedBackUrlIndex)
  if nil ~= row and nil ~= row.ParaValue then
    url = row.ParaValue
  end
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(self:GetWorld())
  GCloudSdk:OpenWebView(url, 2, 1)
end
function NavigationMenuPage:OnClickLogOut()
  local WeGameSubSystem = UE4.UPMWeGameSDKSubSystem.GetInst(LuaGetWorld())
  if WeGameSubSystem and WeGameSubSystem.IsWeGame() then
    self:OnClickExit()
  else
    UE4.UPMWidgetBlueprintLibrary.LogoutGame(self)
  end
end
function NavigationMenuPage:OnClickExit()
  UE4.UPMWidgetBlueprintLibrary.ExitGameWithWorld(self)
end
function NavigationMenuPage:OnClickBackground()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:ClosePage(self, UIPageNameDefine.NavigationMenuPage)
  else
    GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
      target = UIPageNameDefine.NavigationMenuPage
    })
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function NavigationMenuPage:OnClickPersonalPrivacy()
  LogInfo("NavigationMenuPage", "OnClickPersonalPrivacy")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.UserAgreement), 1, 0.7)
end
function NavigationMenuPage:OnClickServiceAgreement()
  LogInfo("NavigationMenuPage", "OnClickServiceAgreement")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.PrivacyPolicy), 1, 0.7)
end
function NavigationMenuPage:OnClickDefault()
  LogInfo("NavigationMenuPage", "OnClickDefault")
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.ChildrenPrivacyPolicy), 1, 0.7)
end
function NavigationMenuPage:OnClickActiveCode()
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.ExchangeUrl), 1, 0.7)
end
return NavigationMenuPage
