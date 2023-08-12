local FriendSetupPanelMobile = class("FriendSetupPanelMobile", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
function FriendSetupPanelMobile:OnInitialized()
  FriendSetupPanelMobile.super.OnInitialized(self)
end
function FriendSetupPanelMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSetupPanelMobile:ListNeededMediators()
  return {}
end
function FriendSetupPanelMobile:InitializeLuaEvent()
end
function FriendSetupPanelMobile:Construct()
  FriendSetupPanelMobile.super.Construct(self)
  self.Btn_Online.OnClicked:Add(self, self.OnCheckOnline)
  self.Btn_Offline.OnClicked:Add(self, self.OnCheckOffline)
  self.Btn_TeamToPublic.OnClicked:Add(self, self.OnCheckTeamToPublic)
  self.Btn_TeamToFriend.OnClicked:Add(self, self.OnCheckTeamToFriend)
  self.Btn_TeamToPrivate.OnClicked:Add(self, self.OnCheckTeamToPrivate)
  self:InitSetupState()
end
function FriendSetupPanelMobile:Destruct()
  FriendSetupPanelMobile.super.Destruct(self)
  self.Btn_Online.OnClicked:Remove(self, self.OnCheckOnline)
  self.Btn_Offline.OnClicked:Remove(self, self.OnCheckOffline)
  self.Btn_TeamToPublic.OnClicked:Remove(self, self.OnCheckTeamToPublic)
  self.Btn_TeamToFriend.OnClicked:Remove(self, self.OnCheckTeamToFriend)
  self.Btn_TeamToPrivate.OnClicked:Remove(self, self.OnCheckTeamToPrivate)
end
function FriendSetupPanelMobile:OnCheckOnline()
  self.Txt_OnlineState:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "FriendOnlineStatus"))
  self.Imgback_checkOnline:SetColorAndOpacity(self.bp_checkColor)
  self.Canvas_checkOnline:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Txt_checkOnline:SetColorAndOpacity(self.bp_textCheckColor)
  self.Imgback_checkOffline:SetColorAndOpacity(self.bp_uncheckColor)
  self.Canvas_checkOffline:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Txt_checkOffline:SetColorAndOpacity(self.bp_textUncheckColor)
  if friendDataProxy and friendDataProxy.currentStateType ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.OnlineState, Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE)
  end
end
function FriendSetupPanelMobile:OnCheckOffline()
  self.Txt_OnlineState:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "FriendOfflineStatus"))
  self.Imgback_checkOffline:SetColorAndOpacity(self.bp_checkColor)
  self.Canvas_checkOffline:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Txt_checkOffline:SetColorAndOpacity(self.bp_textCheckColor)
  self.Imgback_checkOnline:SetColorAndOpacity(self.bp_uncheckColor)
  self.Canvas_checkOnline:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Txt_checkOnline:SetColorAndOpacity(self.bp_textUncheckColor)
  if friendDataProxy and friendDataProxy.currentStateType ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.OnlineState, Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE)
  end
end
function FriendSetupPanelMobile:OnCheckTeamToPublic()
  self.Txt_TeamPrivacy:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "TeamPrivacyPublicStatus"))
  self:ClearAllTeamCheck()
  self.Imgback_checkTeamToPublic:SetColorAndOpacity(self.bp_checkColor)
  self.Canvas_checkTeamToPublic:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Txt_checkTeamToPublic:SetColorAndOpacity(self.bp_textCheckColor)
  if friendDataProxy and friendDataProxy.currentStateType ~= FriendEnum.SocialSecretType.Public then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Public)
  end
end
function FriendSetupPanelMobile:OnCheckTeamToFriend()
  self.Txt_TeamPrivacy:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "TeamPrivacyOnlyFriendStatus"))
  self:ClearAllTeamCheck()
  self.Imgback_checkTeamToFriend:SetColorAndOpacity(self.bp_checkColor)
  self.Canvas_checkTeamToFriend:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Txt_checkTeamToFriend:SetColorAndOpacity(self.bp_textCheckColor)
  if friendDataProxy and friendDataProxy.currentStateType ~= FriendEnum.SocialSecretType.Friend then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Friend)
  end
end
function FriendSetupPanelMobile:OnCheckTeamToPrivate()
  self.Txt_TeamPrivacy:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "TeamPrivacyPrivateStatus"))
  self:ClearAllTeamCheck()
  self.Imgback_checkTeamToPrivate:SetColorAndOpacity(self.bp_checkColor)
  self.Canvas_checkTeamToPrivate:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Txt_checkTeamToPrivate:SetColorAndOpacity(self.bp_textCheckColor)
  if friendDataProxy and friendDataProxy.currentStateType ~= FriendEnum.SocialSecretType.Private then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Private)
  end
end
function FriendSetupPanelMobile:ClearAllTeamCheck()
  self.Imgback_checkTeamToPublic:SetColorAndOpacity(self.bp_uncheckColor)
  self.Canvas_checkTeamToPublic:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Txt_checkTeamToPublic:SetColorAndOpacity(self.bp_textUncheckColor)
  self.Imgback_checkTeamToFriend:SetColorAndOpacity(self.bp_uncheckColor)
  self.Canvas_checkTeamToFriend:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Txt_checkTeamToFriend:SetColorAndOpacity(self.bp_textUncheckColor)
  self.Imgback_checkTeamToPrivate:SetColorAndOpacity(self.bp_uncheckColor)
  self.Canvas_checkTeamToPrivate:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Txt_checkTeamToPrivate:SetColorAndOpacity(self.bp_textUncheckColor)
end
function FriendSetupPanelMobile:InitSetupState()
  if friendDataProxy then
    local currentStateType = friendDataProxy.currentStateType
    if currentStateType == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
      self:OnCheckOnline()
    elseif currentStateType == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LEAVE then
      self:OnCheckOffline()
    else
      self:OnCheckOffline()
    end
    local currentSocialType = friendDataProxy.currentSocialType
    if currentSocialType == FriendEnum.SocialSecretType.Public then
      self:OnCheckTeamToPublic()
    elseif currentSocialType == FriendEnum.SocialSecretType.Friend then
      self:OnCheckTeamToFriend()
    elseif currentSocialType == FriendEnum.SocialSecretType.Private then
      self:OnCheckTeamToPrivate()
    else
      self:OnCheckTeamToPublic()
    end
  end
end
return FriendSetupPanelMobile
