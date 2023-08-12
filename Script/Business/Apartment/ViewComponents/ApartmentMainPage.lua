local ApartmentMainPage = class("ApartmentMainPage", PureMVC.ViewComponentPage)
local ApartmentMainMediator = require("Business/Apartment/Mediators/ApartmentMainMediator")
local EnumClickButton = {
  Promise = 0,
  Information = 1,
  Memory = 2,
  Gift = 3
}
local Valid
function ApartmentMainPage:ListNeededMediators()
  return {ApartmentMainMediator}
end
function ApartmentMainPage:InitializeLuaEvent()
end
function ApartmentMainPage:UpdateRoleInfo(Data)
  if self.NewData == nil then
    self.ProgressLevel, self.TextExpNow, self.TextLevel = Data.ProgressLevel, Data.CurExp, Data.TextLevel
    Valid = self.ProgressBar_Level and self.ProgressBar_Level:SetPercent(Data.ProgressLevel)
    Valid = self.TextBlock_Level and self.TextBlock_Level:SetText(Data.TextLevel)
    Valid = self.TextBlock_LevelName and self.TextBlock_LevelName:SetText(Data.TextLevelName)
  end
  self.NewData = Data
  Valid = self.TextBlock_ExpNow and self.TextBlock_ExpNow:SetText(Data.TextExpNow)
end
function ApartmentMainPage:OnPlayProgressLevelAnim()
  if self.NewData == nil then
    return
  end
  self.CurProgressLevel = self.ProgressLevel
  self.CurLevel = self.TextLevel
  Valid = self.lizi01 and self.lizi01:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.lizi01 and self.lizi01:GetParticleComponent():SetFloatParameter("RenderOpacity", 1)
  LogInfo("ApartmentMainPage:OnPlayProgressLevelAnim", "UpdateRoleInfoTimer")
  if self.UpdateRoleInfoTimer then
    self.UpdateRoleInfoTimer:EndTask()
    self.UpdateRoleInfoTimer = nil
  end
  self.UpdateRoleInfoTimer = TimerMgr:AddFrameTask(0, 1, 0, function()
    self:UpdateRoleLevelInfo()
  end)
end
function ApartmentMainPage:UpdateRoleLevelInfo()
  local Data = self.NewData
  local bIsEnd = false
  if self.CurLevel == Data.TextLevel then
    if self.CurProgressLevel < Data.ProgressLevel then
      self.CurProgressLevel = self.CurProgressLevel + self.UpgradeSpeed
    else
      self.CurProgressLevel = Data.ProgressLevel
      bIsEnd = true
    end
  elseif self.CurLevel < Data.TextLevel then
    if self.CurProgressLevel < 1 then
      self.CurProgressLevel = self.CurProgressLevel + self.UpgradeSpeed
    else
      self.CurLevel = Data.TextLevel
      Valid = self.TextBlock_Level and self.TextBlock_Level:SetText(Data.TextLevel)
      Valid = self.TextBlock_LevelName and self.TextBlock_LevelName:SetText(Data.TextLevelName)
      self.CurProgressLevel = 0
    end
  else
    bIsEnd = true
  end
  if self.ProgressBar_Level and self.ProgressBar_Level:IsValid() then
    self.ProgressBar_Level:SetPercent(self.CurProgressLevel)
    LogInfo("ApartmentMainPage.ProgressBar_Level:Percent", "CurProgressLevel" .. self.CurProgressLevel)
  else
    self:EndUpdateRoleInfoTimer()
  end
  if bIsEnd then
    LogInfo("ApartmentMainPage:EndUpdateRoleInfoTimer()", "EndBySelf")
    self:EndUpdateRoleInfoTimer()
  end
end
function ApartmentMainPage:EndUpdateRoleInfoTimer()
  if self.NewData then
    self.ProgressLevel, self.TextExpNow, self.TextLevel = self.NewData.ProgressLevel, self.NewData.CurExp, self.NewData.TextLevel
  end
  self.CurProgressLevel = 0
  self.CurLevel = 0
  self.CacheOpacity = 1
  self.EndUpdateTimer = TimerMgr:AddFrameTask(0, 1, 0, function()
    self:UpdateEndAnim()
  end)
  if self.UpdateRoleInfoTimer then
    LogInfo("ApartmentMainPage:EndUpdateRoleInfoTimer()", "self.UpdateRoleInfoTimer:EndTask")
    self.UpdateRoleInfoTimer:EndTask()
    self.UpdateRoleInfoTimer = nil
  end
end
function ApartmentMainPage:UpdateEndAnim()
  self.CacheOpacity = math.max(self.CacheOpacity - (self.DisappearSpeed or 0.003), 0)
  Valid = self.lizi01 and self.lizi01:GetParticleComponent():SetFloatParameter("RenderOpacity", self.CacheOpacity)
  if 0 == self.CacheOpacity then
    Valid = self.lizi01 and self.lizi01:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.EndUpdateTimer then
      self.EndUpdateTimer:EndTask()
      self.EndUpdateTimer = nil
    end
  end
end
function ApartmentMainPage:SetChatVisibility(bVisible)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, bVisible)
end
function ApartmentMainPage:OnOpen(luaOpenData, nativeOpenData)
  local CurrentRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  if CurrentRoleId then
    if GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleBiographCfg(CurrentRoleId) == nil then
      self.bShieldBiography = true
    end
    if nil == GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomWindingCorridorProxy):GetWindingCorridorListByRoleID(CurrentRoleId) and nil == GameFacade:RetrieveProxy(ProxyNames.ApartmentPromiseItemProxy):GetRoleAllPromiseItemsCfg(CurrentRoleId) then
      self.bShieldWindingCorridor = true
    end
  end
  Valid = self.ViewSwitchAnimation and self.ViewSwitchAnimation:PlayOpenAnimation()
  Valid = self.Button_Esc and self.Button_Esc.OnClickEvent:Add(self, self.OnClickSkip)
  Valid = self.Button_Promise and self.Button_Promise.OnClicked:Add(self, self.OnClickPromise)
  Valid = self.Button_Gift and self.Button_Gift.OnClicked:Add(self, self.OnClickGift)
  Valid = self.Button_Information and self.Button_Information.OnClicked:Add(self, self.OnClickInformation)
  Valid = self.Button_Memory and self.Button_Memory.OnClicked:Add(self, self.OnClickMemory)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickBackBtn, self)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Add(self, self.OnClickBackBtn)
  if luaOpenData == EnumClickButton.Gift then
    self:OnClickGift()
  else
    self:OnClickPromise()
  end
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseTaskRewards, function(cnt)
    self:UpdateRedDotPromiseTask(cnt)
  end)
  self:UpdateRedDotPromiseTask(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseTaskRewards))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseGift, function(cnt)
    self:UpdateRedDotPromiseGift(cnt)
  end)
  self:UpdateRedDotPromiseGift(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseGift))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseBiography, function(cnt)
    self:UpdateRedDotPromiseBiography(cnt)
  end)
  self:UpdateRedDotPromiseBiography(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseBiography))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseItemAndMemory, function(cnt)
    self:UpdateRedDotPromiseItemAndMemory(cnt)
  end)
  self:UpdateRedDotPromiseItemAndMemory(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseItemAndMemory))
  self:SetIsCanSkipSequence(true)
  self:SetIsNeedListenKey(false)
end
function ApartmentMainPage:OnClose()
  if self.EndUpdateTimer then
    self.EndUpdateTimer:EndTask()
    self.EndUpdateTimer = nil
  end
  if self.UpdateRoleInfoTimer then
    self.UpdateRoleInfoTimer:EndTask()
    self.UpdateRoleInfoTimer = nil
  end
  LogInfo("ApartmentMainPage:EndUpdateRoleInfoTimer()", "EndByPageClose")
  Valid = self.Button_Esc and self.Button_Esc.OnClickEvent:Remove(self, self.OnClickSkip)
  Valid = self.Button_Promise and self.Button_Promise.OnClicked:Remove(self, self.OnClickPromise)
  Valid = self.Button_Gift and self.Button_Gift.OnClicked:Remove(self, self.OnClickGift)
  Valid = self.Button_Information and self.Button_Information.OnClicked:Remove(self, self.OnClickInformation)
  Valid = self.Button_Memory and self.Button_Memory.OnClicked:Remove(self, self.OnClickMemory)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickBackBtn, self)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Remove(self, self.OnClickBackBtn)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseTaskRewards)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseGift)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseBiography)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseItemAndMemory)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseItem)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseMemory)
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):ClearCharacterAllAttachActor()
  self.CurPage = nil
end
function ApartmentMainPage:OnClickSkip()
  if self.bIsNeedListenKey and self.bIsCanSKipSequence then
    GameFacade:SendNotification(NotificationDefines.SkipApartmentCurAnimation)
  end
end
function ApartmentMainPage:OnClickPromise()
  self:ChangeButtonState(EnumClickButton.Promise)
  GameFacade:SendNotification(NotificationDefines.ReqApartmentPromisePageData)
end
function ApartmentMainPage:OnClickGift()
  local TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "NoneGiftTip")
  local BagItemsList = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):GetGiftItemListData()
  if table.count(BagItemsList) > 0 then
    self:ChangeButtonState(EnumClickButton.Gift)
    GameFacade:SendNotification(NotificationDefines.ReqApartmentGiftPageData)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  end
end
function ApartmentMainPage:OnClickInformation()
  if self.bShieldBiography then
    local TipsText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TempTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipsText)
  else
    self:ChangeButtonState(EnumClickButton.Information)
    GameFacade:SendNotification(NotificationDefines.ReqApartmentInformationPageData)
  end
end
function ApartmentMainPage:OnClickMemory()
  if self.bShieldWindingCorridor then
    local TipsText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TempTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipsText)
  else
    self:ChangeButtonState(EnumClickButton.Memory)
    GameFacade:SendNotification(NotificationDefines.ReqApartmentMemoryPageData)
  end
end
function ApartmentMainPage:ChangeButtonState(ClickButton)
  self.CurPage = ClickButton
  Valid = self.PromisePage and self.PromisePage:SetPageActive(ClickButton == EnumClickButton.Promise)
  Valid = self.GiftsPage and self.GiftsPage:SetPageActive(ClickButton == EnumClickButton.Gift)
  Valid = self.InformationPage and self.InformationPage:SetPageActive(ClickButton == EnumClickButton.Information)
  Valid = self.MemoryPage and self.MemoryPage:SetPageActive(ClickButton == EnumClickButton.Memory)
  Valid = self.Button_Promise and self.Button_Promise:SetIsEnabled(ClickButton ~= EnumClickButton.Promise)
  Valid = self.Button_Gift and self.Button_Gift:SetIsEnabled(ClickButton ~= EnumClickButton.Gift)
  Valid = self.Button_Information and self.Button_Information:SetIsEnabled(ClickButton ~= EnumClickButton.Information)
  Valid = self.Button_Memory and self.Button_Memory:SetIsEnabled(ClickButton ~= EnumClickButton.Memory)
  Valid = self.Button_Promise and self.Button_Promise.Slot:SetPadding(ClickButton == EnumClickButton.Promise and self.ButtonClickedPadding or self.DefaultPadding)
  Valid = self.Button_Gift and self.Button_Gift.Slot:SetPadding(ClickButton == EnumClickButton.Gift and self.ButtonClickedPadding or self.DefaultPadding)
  Valid = self.Button_Information and self.Button_Information.Slot:SetPadding(ClickButton == EnumClickButton.Information and self.ButtonClickedPadding or self.DefaultPadding)
  Valid = self.Button_Memory and self.Button_Memory.Slot:SetPadding(ClickButton == EnumClickButton.Memory and self.ButtonClickedPadding or self.DefaultPadding)
  Valid = self.WidgetSwitcher_BtnPromise and self.WidgetSwitcher_BtnPromise:SetActiveWidgetIndex(ClickButton == EnumClickButton.Promise and 1 or 0)
  Valid = self.WidgetSwitcher_BtnGift and self.WidgetSwitcher_BtnGift:SetActiveWidgetIndex(ClickButton == EnumClickButton.Gift and 1 or 0)
  Valid = self.WidgetSwitcher_BtnInformation and self.WidgetSwitcher_BtnInformation:SetActiveWidgetIndex(ClickButton == EnumClickButton.Information and 1 or 0)
  Valid = self.WidgetSwitcher_BtnMemory and self.WidgetSwitcher_BtnMemory:SetActiveWidgetIndex(ClickButton == EnumClickButton.Memory and 1 or 0)
  Valid = self.WidgetSwitcher_Page and self.WidgetSwitcher_Page:SetActiveWidgetIndex(ClickButton)
end
function ApartmentMainPage:OnClickBackBtn()
  if self.bIsClosing then
    return
  end
  self.bIsClosing = true
  Valid = self.ViewSwitchAnimation and self.ViewSwitchAnimation:PlayCloseAnimation({
    self,
    self.AnimClosed
  })
end
function ApartmentMainPage:AnimClosed()
  self.bIsClosing = false
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if NewPlayerGuideProxy:IsAllGuideComplete() then
    GameFacade:SendNotification(NotificationDefines.ApartmentMainPageClose)
    GameFacade:SendNotification(NotificationDefines.GivePageClose)
  else
    GameFacade:SendNotification(NotificationDefines.GivePageClose)
  end
end
function ApartmentMainPage:LuaHandleKeyEvent(key, inputEvent)
  if self.bIsNeedListenKey and self.bIsCanSKipSequence and inputEvent == UE4.EInputEvent.IE_Released then
    Valid = self.Button_Esc and self.Button_Esc:MonitorKeyDown(key, inputEvent)
    return false
  else
    if self.OnlyCheckLeftClick then
      return key ~= self.ClickGiftKey
    end
    Valid = self.GiftsPage and self.GiftsPage:LuaHandleKeyEvent(key, inputEvent)
    Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
    return false
  end
end
function ApartmentMainPage:UpdateRedDotPromiseTask(cnt)
  Valid = self.RedDot_Task and self.RedDot_Task:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMainPage:UpdateRedDotPromiseGift(cnt)
  Valid = self.RedDot_Gift and self.RedDot_Gift:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMainPage:UpdateRedDotPromiseBiography(cnt)
  Valid = self.RedDot_Information and self.RedDot_Information:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMainPage:UpdateRedDotPromiseItemAndMemory(cnt)
  if not self.RedDot_Memory then
    return
  end
  self.RedDot_Memory:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMainPage:SetIsNeedListenKey(bEnable)
  self.bIsNeedListenKey = bEnable
end
function ApartmentMainPage:SetIsCanSkipSequence(bEnable)
  self.bIsCanSKipSequence = bEnable
  if not bEnable then
    Valid = self.Button_Esc and self.Button_Esc:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.Button_Esc and self.Button_Esc:SetIsEnabled(false)
  end
end
function ApartmentMainPage:SetIsOnlyCheckLeftClick(bEnable)
  self.OnlyCheckLeftClick = bEnable
end
return ApartmentMainPage
