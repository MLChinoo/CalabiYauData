local ShareBigImagePageMediatorMobile = require("Business/Share/Mediators/Mobile/ShareBigImagePageMediatorMobile")
local ShareBigImagePageMobile = class("ShareBigImagePageMobile", PureMVC.ViewComponentPage)
function ShareBigImagePageMobile:ListNeededMediators()
  return {ShareBigImagePageMediatorMobile}
end
function ShareBigImagePageMobile:InitializeLuaEvent()
end
function ShareBigImagePageMobile:Construct()
  ShareBigImagePageMobile.super.Construct(self)
  self.WBP_CommonReturnButton_Mobile.OnClickEvent:Add(self, self.OnClickBackBtn)
  self.ShareToQQBtn.OnClicked:Add(self, self.OnShareToQQBtnClick)
  self.ShareToWechatBtn.OnClicked:Add(self, self.OnShareToWechatBtnClick)
  self.ShareToWechatSpaceBtn.OnClicked:Add(self, self.OnShareToWechatSpaceBtnClick)
  self.ShareToQQSpaceBtn.OnClicked:Add(self, self.OnShareToQQSpaceBtnClick)
  if self.SaveImageBtn then
    self.SaveImageBtn.OnClicked:Add(self, self.OnSaveImageBtnClick)
  end
  self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
  self.index = -1
end
function ShareBigImagePageMobile:Destruct()
  ShareBigImagePageMobile.super.Destruct(self)
  self.WBP_CommonReturnButton_Mobile.OnClickEvent:Remove(self, self.OnClickBackBtn)
  self.ShareToQQBtn.OnClicked:Remove(self, self.OnShareToQQBtnClick)
  self.ShareToWechatBtn.OnClicked:Remove(self, self.OnShareToWechatBtnClick)
  self.ShareToWechatSpaceBtn.OnClicked:Remove(self, self.OnShareToWechatSpaceBtnClick)
  self.ShareToQQSpaceBtn.OnClicked:Remove(self, self.OnShareToQQSpaceBtnClick)
  if self.SaveImageBtn then
    self.SaveImageBtn.OnClicked:Remove(self, self.OnSaveImageBtnClick)
  end
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
  self.index = -1
end
function ShareBigImagePageMobile:OnSaveImageBtnClick()
  LogInfo("ShareBigImagePageMobile", "OnSaveImageBtnClick")
  UE4.UPMShareSubSystem.GetInst(self):SavePhoto()
  ViewMgr:ClosePage(self)
end
function ShareBigImagePageMobile:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ShareBigImagePageMobile", luaOpenData)
  self.index = luaOpenData
  self.Root:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:HideBtn()
  self.WidgetSwitcher:SetActiveWidgetIndex(luaOpenData)
  local item = self.WidgetSwitcher:GetWidgetAtIndex(luaOpenData)
  local PlayerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  item.PlayerName:SetText(PlayerProxy:GetPlayerNick())
  item.PlayerID:SetText(PlayerProxy:GetPlayerId())
  local GloryTextIndex = 8500
  local gloryText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(GloryTextIndex + luaOpenData).ParaValue
  item.GloryText:SetText(gloryText)
  local avatarIcon
  local avatarId = tonumber(PlayerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  if avatarId then
    avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
  end
  if avatarIcon then
    self:SetImageByTexture2D(item.HeadImage, avatarIcon)
    item.HeadImage:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local imageURL = ""
  local QRCodeImageUrlIndex = 0
  local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
    QRCodeImageUrlIndex = 8402
  else
    QRCodeImageUrlIndex = 8403
  end
  local row = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(QRCodeImageUrlIndex)
  if nil ~= row and row.ParaValue ~= nil then
    imageURL = row.ParaValue
  end
  if "" ~= imageURL then
    LogDebug("ShareBigImagePageMobile", imageURL)
    local DownLoadTask
    DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(imageURL)
    if DownLoadTask then
      DownLoadTask.OnSuccess:Add(self, self.LoadImgSuc)
      DownLoadTask.OnFail:Add(self, self.LoadImgError)
    end
  else
    LogDebug("ShareBigImagePageMobile", "imageURL == ''")
    self.QRcodeImage.MB_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if nil == self.CaptureScreenshotTask then
      self.CaptureScreenshotTask = TimerMgr:AddFrameTask(5, 0, 1, function()
        self.CaptureScreenshotTask = nil
        UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
      end)
    end
  end
end
function ShareBigImagePageMobile:LoadImgSuc(InTexture)
  LogDebug("ShareBigImagePageMobile", "LoadImgSuc")
  if -1 == self.index then
    return
  end
  local item = self.WidgetSwitcher:GetWidgetAtIndex(self.index)
  item.QRcodeImage.MB_QRcodeImage:SetBrushFromTextureDynamic(InTexture)
  item.QRcodeImage.MB_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
end
function ShareBigImagePageMobile:LoadImgError()
  LogDebug("ShareBigImagePageMobile", "LoadImgError")
  if -1 == self.index then
    return
  end
  local item = self.WidgetSwitcher:GetWidgetAtIndex(self.index)
  item.QRcodeImage.MB_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
end
function ShareBigImagePageMobile:OnCaptureScreenshotSuccess(texture)
  self.ShareImage:SetBrushFromTexture(texture)
  self:ShowBtn()
end
function ShareBigImagePageMobile:HideBtn()
  self.WBP_CommonReturnButton_Mobile:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ShareImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ShareImageRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.WidgetSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BG:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ShareBigImagePageMobile:ShowBtn()
  self.WBP_CommonReturnButton_Mobile:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BtnRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ShareImage:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ShareImageRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BG:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BG_1:SetVisibility(UE4.ESlateVisibility.Visible)
end
function ShareBigImagePageMobile:OnShareToQQBtnClick()
  LogDebug("ShareBigImagePageMobile", "OnShareToQQBtnClick")
  if not UE4.UPMShareSubSystem.GetInst(self):IsQQInstall() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "NoInstallQQ"))
    return
  end
  UE4.UPMShareSubSystem.GetInst(self):SendBigImageToQQ()
  ViewMgr:ClosePage(self)
end
function ShareBigImagePageMobile:OnShareToWechatBtnClick()
  LogDebug("ShareBigImagePageMobile", "OnShareToWechatBtnClick")
  if not UE4.UPMShareSubSystem.GetInst(self):IsWeChatInstall() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "NoInstallWeChat"))
    return
  end
  UE4.UPMShareSubSystem.GetInst(self):SendBigImageToWeChat()
  ViewMgr:ClosePage(self)
end
function ShareBigImagePageMobile:OnShareToWechatSpaceBtnClick()
  LogDebug("ShareBigImagePageMobile", "OnShareToWechatSpaceBtnClick")
  if not UE4.UPMShareSubSystem.GetInst(self):IsWeChatInstall() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "NoInstallWeChat"))
    return
  end
  UE4.UPMShareSubSystem.GetInst(self):ShareBigImageToWeChat()
  ViewMgr:ClosePage(self)
end
function ShareBigImagePageMobile:OnShareToQQSpaceBtnClick()
  LogDebug("ShareBigImagePageMobile", "OnShareToQQSpaceBtnClick")
  if not UE4.UPMShareSubSystem.GetInst(self):IsQQInstall() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "NoInstallQQ"))
    return
  end
  UE4.UPMShareSubSystem.GetInst(self):ShareBigImageToQQ()
  ViewMgr:ClosePage(self)
end
function ShareBigImagePageMobile:OnClose()
end
function ShareBigImagePageMobile:OnClickBackBtn()
  ViewMgr:ClosePage(self)
end
return ShareBigImagePageMobile
