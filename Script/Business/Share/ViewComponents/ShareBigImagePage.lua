local ShareBigImagePageMediator = require("Business/Share/Mediators/ShareBigImagePageMediator")
local ShareBigImagePage = class("ShareBigImagePage", PureMVC.ViewComponentPage)
function ShareBigImagePage:ListNeededMediators()
  return {ShareBigImagePageMediator}
end
function ShareBigImagePage:InitializeLuaEvent()
end
function ShareBigImagePage:Construct()
  ShareBigImagePage.super.Construct(self)
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
  self.index = -1
end
function ShareBigImagePage:Destruct()
  ShareBigImagePage.super.Destruct(self)
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
  self.index = -1
end
function ShareBigImagePage:OnEscHotKeyClick()
  LogInfo("ShareBigImagePage", "OnEscHotKeyClick")
  ViewMgr:ClosePage(self)
end
function ShareBigImagePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnEscHotKeyClick()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function ShareBigImagePage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ShareBigImagePage", luaOpenData)
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
  self:SetImageByTexture2D(item.HeadImage, avatarIcon)
  item.HeadImage:SetVisibility(UE4.ESlateVisibility.Visible)
  local SaveImageToLocal = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "SaveImageToLocal")
  self.PathText:SetText(SaveImageToLocal .. UE4.UPMShareSubSystem.GetInst(self):GetSavePath())
  local imageURL = ""
  local QRCodeImageUrlIndex = 8402
  local row = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(QRCodeImageUrlIndex)
  if nil ~= row and row.ParaValue ~= nil then
    imageURL = row.ParaValue
  end
  if "" ~= imageURL then
    LogDebug("ShareBigImagePage", imageURL)
    local DownLoadTask
    DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(imageURL)
    if DownLoadTask then
      DownLoadTask.OnSuccess:Add(self, self.LoadImgSuc)
      DownLoadTask.OnFail:Add(self, self.LoadImgError)
    end
  else
    LogDebug("ShareBigImagePage", "imageURL == ''")
    self.QRcodeImage.PC_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if nil == self.CaptureScreenshotTask then
      self.CaptureScreenshotTask = TimerMgr:AddFrameTask(5, 0, 1, function()
        self.CaptureScreenshotTask = nil
        UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
      end)
    end
  end
end
function ShareBigImagePage:LoadImgSuc(InTexture)
  LogDebug("ShareBigImagePage", "LoadImgSuc")
  if -1 == self.index then
    return
  end
  local item = self.WidgetSwitcher:GetWidgetAtIndex(self.index)
  item.QRcodeImage.PC_QRcodeImage:SetBrushFromTextureDynamic(InTexture)
  item.QRcodeImage.PC_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
end
function ShareBigImagePage:LoadImgError()
  LogDebug("ShareBigImagePage", "LoadImgError")
  if -1 == self.index then
    return
  end
  local item = self.WidgetSwitcher:GetWidgetAtIndex(self.index)
  item.QRcodeImage.PC_QRcodeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Root:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  UE4.UPMShareSubSystem.GetInst(self):CaptureScreenshotToShare()
end
function ShareBigImagePage:OnCaptureScreenshotSuccess(texture)
  self.ShareImage:SetBrushFromTexture(texture)
  self:ShowBtn()
end
function ShareBigImagePage:HideBtn()
  self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ShareImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ShareImageRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BG:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.WidgetSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PathRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ShareBigImagePage:ShowBtn()
  self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ShareImageRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ShareImage:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BG:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BG_1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.WidgetSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PathRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function ShareBigImagePage:OnClose()
end
return ShareBigImagePage
