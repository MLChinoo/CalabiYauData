local AccountBindPageMediator = require("Business/AccountBind/Mediators/AccountBindPageMediator")
local AccountBindPage = class("AccountBindPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function AccountBindPage:ListNeededMediators()
  return {AccountBindPageMediator}
end
function AccountBindPage:InitializeLuaEvent()
end
function AccountBindPage:OnOpen(luaOpenData, nativeOpenData)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self.PhoneBindBtn.OnClicked:Add(self, self.OnClickPhoneBindBtn)
  self.PhoneChangeBindBtn.OnClicked:Add(self, self.OnClickPhoneChangeBindBtn)
  self.FBBindBtn.OnClicked:Add(self, self.OnClickFBBindBtn)
  self.FBChangeBindBtn.OnClicked:Add(self, self.OnClickFBChangeBindBtn)
  self.PlayerIDCopyBtn.OnClicked:Add(self, self.OnClickPlayerIDCopyBtn)
  AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy then
    AccountBindProxy:ReqQueryAccountInfo()
  end
  self:UpdataUI()
end
function AccountBindPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  self.PhoneBindBtn.OnClicked:Remove(self, self.OnClickPhoneBindBtn)
  self.PhoneChangeBindBtn.OnClicked:Remove(self, self.OnClickPhoneChangeBindBtn)
  self.FBBindBtn.OnClicked:Remove(self, self.OnClickFBBindBtn)
  self.FBChangeBindBtn.OnClicked:Remove(self, self.OnClickFBChangeBindBtn)
  self.PlayerIDCopyBtn.OnClicked:Remove(self, self.OnClickPlayerIDCopyBtn)
end
function AccountBindPage:OnClickPhoneBindBtn()
  LogDebug("AccountBindPage", "OnClickPhoneBindBtn")
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.PhoneBindPage)
end
function AccountBindPage:OnClickPhoneChangeBindBtn()
  LogDebug("AccountBindPage", "OnClickPhoneChangeBindBtn")
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.PhoneSafetyVerifiPage)
end
function AccountBindPage:OnClickFBBindBtn()
  LogDebug("AccountBindPage", "OnClickFBBindBtn")
  local AccountBindWorldSubsystem = UE4.UPMAccountBindWorldSubsystem.Get(LuaGetWorld())
  if AccountBindWorldSubsystem then
    if AccountBindWorldSubsystem:CheckFanbookInstalled() then
      AccountBindWorldSubsystem:StartAccoutBind("fanbook://oauth?client_id=524063210475753472&invite_code=calabiyau&scheme=calabiyau&host=AccountBind")
    else
      UE4.UKismetSystemLibrary.LaunchURL("https://fanbook.mobi/calabiyau")
    end
  end
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.BindFanbookWaitPage)
end
function AccountBindPage:OnClickFBChangeBindBtn()
  LogDebug("AccountBindPage", "OnClickFBChangeBindBtn")
  ViewMgr:ClosePage(self)
  ViewMgr:OpenPage(self, UIPageNameDefine.FBUnBandOrChangeBindPage)
end
function AccountBindPage:OnClickPlayerIDCopyBtn()
  LogDebug("AccountBindPage", "OnClickPlayerIDCopyBtn")
  if self.PlayerIDText then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(self.PlayerIDText:GetText())
    local stFriendName = StringTablePath.ST_FriendName
    local showMsg = ConfigMgr:FromStringTable(stFriendName, "Copy_FriendListText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function AccountBindPage:UpdataUI()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    self.PlayerIDText:SetText(friendDataProxy:GetPlayerID())
    self.PlayerName:SetText(friendDataProxy:GetNick())
  end
  self:UpdatePlayerAvatar()
  if AccountBindProxy then
    local PhoneNumber, PhoneNumberStar, PhoneNumberEnd = AccountBindProxy:GetPhoneNumber()
    if nil ~= PhoneNumber and "" ~= PhoneNumber then
      self.PhoneStar:SetText(PhoneNumberStar)
      self.PhoneEnd:SetText(PhoneNumberEnd)
      self.PhoneNumbRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.PhoneNumbRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.FBIdText:SetText(AccountBindProxy:GetFBid())
    if AccountBindProxy:GetPhoneIsBind() then
      self.WidgetSwitcher_Phone:SetActiveWidgetIndex(1)
    else
      self.WidgetSwitcher_Phone:SetActiveWidgetIndex(0)
    end
    if AccountBindProxy:GetFBIsBind() then
      self.WidgetSwitcher_FB:SetActiveWidgetIndex(1)
    else
      self.WidgetSwitcher_FB:SetActiveWidgetIndex(0)
    end
    if AccountBindProxy:GetPhoneBingHasReward() then
      self.PhoneRewadImageRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.PhoneRewadImageRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if AccountBindProxy:GetFBBingHasReward() then
      self.FBRewadImageRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.FBRewadImageRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function AccountBindPage:UpdatePlayerAvatar()
  if self.HeadImage then
    local avatarId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
    if nil == avatarId then
      avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
    end
    if avatarId then
      local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
      if avatarIcon then
        self.HeadImage:SetBrushFromSoftTexture(avatarIcon)
      else
        LogError("FriendListPage", "Player icon or config error")
      end
    end
  end
end
function AccountBindPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function AccountBindPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
return AccountBindPage
