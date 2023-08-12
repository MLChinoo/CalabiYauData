local ApartmentGiftSharePage = class("ApartmentGiftSharePage", PureMVC.ViewComponentPage)
local Valid
function ApartmentGiftSharePage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.Show_Page and self:PlayAnimationForward(self.Show_Page, 1, false)
  local avatarIcon
  local avatarId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  if avatarId then
    avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
  end
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RedSkinTexture = luaOpenData and RoleProxy:GetRoleSkin(luaOpenData).IconRedskin
  local PlayerId = friendDataProxy:GetPlayerID()
  local PlayerNick = friendDataProxy:GetNick()
  local PlayerIdText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "PlayerId")
  local PlayerIdTextParam = ObjectUtil:GetTextFromFormat(PlayerIdText, {
    [0] = PlayerId
  })
  Valid = self.TextBlock_PlayerId and self.TextBlock_PlayerId:SetText(PlayerIdTextParam)
  Valid = self.TextBlock_PlayerName and self.TextBlock_PlayerName:SetText(PlayerNick)
  Valid = self.Image_Avatar and self:SetImageByTexture2D(self.Image_Avatar, avatarIcon)
  Valid = self.Image_RoleShare and self:SetImageByTexture2D(self.Image_RoleShare, RedSkinTexture)
  Valid = self.Image_TakePhone and self.Image_TakePhone:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ApartmentGiftSharePage:OnClose()
  self:ClearTimer()
end
function ApartmentGiftSharePage:InitializeLuaEvent()
end
function ApartmentGiftSharePage:Construct()
  ApartmentGiftSharePage.super.Construct(self)
  Valid = self.Button_Download and self.Button_Download.OnClicked:Add(self, self.OnClickDownload)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Add(self, self.OnClickClose)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickClose, self)
end
function ApartmentGiftSharePage:Destruct()
  Valid = self.Button_Download and self.Button_Download.OnClicked:Remove(self, self.OnClickDownload)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Remove(self, self.OnClickClose)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickClose, self)
  GameFacade:SendNotification(NotificationDefines.ReqApartmentPromisePageData)
  ApartmentGiftSharePage.super.Destruct(self)
end
function ApartmentGiftSharePage:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.ApartmentGiftSharePage)
end
function ApartmentGiftSharePage:OnClickDownload()
  self:ClearTimer()
  Valid = self.Button_Download and self.Button_Download:SetVisibility(UE4.ESlateVisibility.Collapsed)
  Valid = self.Button_Close and self.Button_Close:SetVisibility(UE4.ESlateVisibility.Collapsed)
  Valid = self.Button_Download and self.Button_Download:SetIsEnabled(false)
  Valid = self.Button_Close and self.Button_Close:SetIsEnabled(false)
  local g_LuaBridgeSubsystem = _G.g_LuaBridgeSubsystem
  g_LuaBridgeSubsystem:CaptureScreenshot()
  local TipText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "DownloadTip")
  self.TimerHandle_ShowTips = TimerMgr:AddTimeTask(0.5, 0, 0, function()
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
    Valid = self.Button_Download and self.Button_Download:SetIsEnabled(true)
    Valid = self.Button_Close and self.Button_Close:SetIsEnabled(true)
    Valid = self.Button_Download and self.Button_Download:SetVisibility(UE4.ESlateVisibility.Visible)
    Valid = self.Button_Close and self.Button_Close:SetVisibility(UE4.ESlateVisibility.Visible)
    Valid = self.Image_TakePhone and self.Image_TakePhone:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.Show_Page and self:PlayAnimationForward(self.Take_Photo, 1, false)
  end)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentTLogProxy):NightgownDownloadsFrequency()
end
function ApartmentGiftSharePage:ClearTimer()
  if self.TimerHandle_ShowTips then
    self.TimerHandle_ShowTips:EndTask()
    self.TimerHandle_ShowTips = nil
  end
end
function ApartmentGiftSharePage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
return ApartmentGiftSharePage
