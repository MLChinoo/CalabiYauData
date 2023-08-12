local ResultDisplayPage = class("ResultDisplayPage", PureMVC.ViewComponentPage)
function ResultDisplayPage:ListNeededMediators()
  return {}
end
function ResultDisplayPage:DisplayItem()
  self.resultShown = self.resultShown + 1
  if self.itemsObtained[self.resultShown] then
    local itemInfo = self.itemsObtained[self.resultShown]
    if itemInfo.quality >= UE4.ECyItemQualityType.Orange then
      self:DisplayHighQuality(itemInfo.item_id)
    else
      self:DisplayItem()
    end
  else
    self:OnClickSkip()
  end
end
function ResultDisplayPage:DisplayNormal(itemId)
  if self.ItemDescPanel then
    self.ItemDescPanel:Update(itemId)
  end
  local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
  local is3DModel = false
  if itemType == UE4.EItemIdIntervalType.RoleSkin or itemType == UE4.EItemIdIntervalType.Weapon or itemType == UE4.EItemIdIntervalType.Decal then
    is3DModel = true
  end
  if self.UI3DModel and self.UI2DModel then
    if is3DModel then
      self.Display3DModelResult = self.UI3DModel:DisplayByItemId(itemId, UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeapon, UE4.EItemDisplayType.AcquireItem)
      self:HideMedia(true)
      GameFacade:SendNotification(NotificationDefines.ItemImageDisplay)
      self.UI3DModel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UI3DModel:Display3DEnvBackground()
      if self.itemType == UE4.EItemIdIntervalType.FlyEffect and self.MediaPlayer then
        self:HideMedia(false)
        local filePath = "./Movies/FlyEffect/FlyEffect_" .. itemId .. ".mp4"
        self.MediaPlayer:PlayVideoByFilePath(filePath)
        GameFacade:SendNotification(NotificationDefines.ItemImageDisplay)
      else
        self:HideMedia(true)
        GameFacade:SendNotification(NotificationDefines.ItemImageDisplay, itemId)
        self.UI2DModel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
  if self.WidgetSwitcher_ContentType then
    self.WidgetSwitcher_ContentType:SetActiveWidgetIndex(1)
  end
end
function ResultDisplayPage:HideMedia(isHidden)
  if self.MediaPlayer then
    if isHidden then
      self.MediaPlayer:CloseVideo()
    end
    self.MediaPlayer:SetVisibility(isHidden and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ResultDisplayPage:DisplayHighQuality(itemId)
  if self.HighQualityItemDisplay and self.WidgetSwitcher_ContentType then
    self.bStopHotKey = true
    self.WidgetSwitcher_ContentType:SetActiveWidgetIndex(0)
    self.HighQualityItemDisplay:SetItemDisplayed(itemId)
  end
end
function ResultDisplayPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ResultDisplayPage", "Lua implement OnOpen")
  if self.Btn_Share then
    self.Btn_Share.OnClickEvent:Add(self, self.OnClickShare)
  end
  if self.Button_Continue then
    self.Button_Continue.OnClickEvent:Add(self, self.OnClickContinue)
  end
  if self.Button_ScreenContinue then
    self.Button_ScreenContinue.OnClicked:Add(self, self.OnClickContinue)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnClickSkip)
  end
  if self.HighQualityItemDisplay then
    self.HighQualityItemDisplay.actionOnSkip:Add(self.DisplayItem, self)
  end
  self.resultShown = 0
  if self.ResultList then
    self.resultItemArr = self.ResultList:GetAllChildren()
    local ballTypeArray = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryBallSet()
    self:InitBallView(ballTypeArray)
  end
  self.bStopHotKey = false
  self.itemsObtained = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryObtained()
  if self.itemsObtained == nil or 0 == #self.itemsObtained then
    return
  end
  self.ScreenPrintSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self, "OnScreenPrintSuccess")
  self:DisplayItem()
end
function ResultDisplayPage:OnClose()
  if self.Btn_Share then
    self.Btn_Share.OnClickEvent:Remove(self, self.OnClickShare)
  end
  if self.Button_Continue then
    self.Button_Continue.OnClickEvent:Remove(self, self.OnClickContinue)
  end
  if self.Button_ScreenContinue then
    self.Button_ScreenContinue.OnClicked:Remove(self, self.OnClickContinue)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnClickSkip)
  end
  if self.HighQualityItemDisplay then
    self.HighQualityItemDisplay.actionOnSkip:Remove(self.DisplayItem, self)
  end
  if self.ScreenPrintSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self.ScreenPrintSuccessHandler)
    self.ScreenPrintSuccessHandler = nil
  end
end
function ResultDisplayPage:InitBallView(ballTypeArr)
  if ballTypeArr and self.resultItemArr then
    for i = 1, self.resultItemArr:Length() do
      local item = self.resultItemArr:Get(i)
      if ballTypeArr[i] then
        item:SetItemType(ballTypeArr[i])
        item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        item:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end
function ResultDisplayPage:UpdateResultQuality()
  if self.resultShown then
    local itemsObtained = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryObtained()
    if self.resultShown <= table.count(itemsObtained) and self.resultShown <= self.resultItemArr:Length() then
      self.resultItemArr:Get(self.resultShown):SetItemQuality(itemsObtained[self.resultShown].quality)
    end
  end
end
function ResultDisplayPage:OnClickContinue()
  if self.bStopHotKey then
    return
  end
  self:DisplayItem()
end
function ResultDisplayPage:OnClickSkip()
  ViewMgr:ClosePage(self)
  UE4.UCySequenceManager.Get(self):GoToEndAndStop()
  ViewMgr:OpenPage(self, UIPageNameDefine.LotteryResultPage)
end
function ResultDisplayPage:LuaHandleKeyEvent(key, inputEvent)
  if self.bStopHotKey then
    if self.HighQualityItemDisplay then
      return self.HighQualityItemDisplay:LuaHandleKeyEvent(key, inputEvent)
    end
    return false
  end
  local ret = false
  if self.Button_Continue and not ret then
    ret = self.Button_Continue:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_Esc and not ret then
    ret = self.Button_Esc:MonitorKeyDown(key, inputEvent)
  end
  if self.Btn_Share and not ret then
    ret = self.Btn_Share:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function ResultDisplayPage:OnClickShare()
  if self.HB_ActionBar then
    self.HB_ActionBar:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.Rewards)
end
function ResultDisplayPage:OnScreenPrintSuccess()
  if self.HB_ActionBar then
    self.HB_ActionBar:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
return ResultDisplayPage
