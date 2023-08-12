local FriendSetupPageMediatorMobile = class("FriendSetupPageMediatorMobile", PureMVC.Mediator)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendSetupPageMediatorMobile:ListNotificationInterests()
  return {}
end
function FriendSetupPageMediatorMobile:HandleNotification(notify)
end
function FriendSetupPageMediatorMobile:OnRegister()
  self:GetViewComponent().actionOnCheckOnlineCheck:Add(self.OnCheckOnlineCheck, self)
  self:GetViewComponent().actionOnCheckOffLineCheck:Add(self.OnCheckOffLineCheck, self)
  self:GetViewComponent().actionOnCheckPublicCheck:Add(self.OnCheckPublicCheck, self)
  self:GetViewComponent().actionOnCheckOnlyFriendCheck:Add(self.OnCheckOnlyFriendCheck, self)
  self:GetViewComponent().actionOnCheckPrivateCheck:Add(self.OnCheckPrivateCheck, self)
  self.currentSeleclStateCheck = nil
  self.currentSelectSocialSecretCheck = nil
  self:InitCheckState()
end
function FriendSetupPageMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnCheckOnlineCheck:Remove(self.OnCheckOnlineCheck, self)
  self:GetViewComponent().actionOnCheckOffLineCheck:Remove(self.OnCheckOffLineCheck, self)
  self:GetViewComponent().actionOnCheckPublicCheck:Remove(self.OnCheckPublicCheck, self)
  self:GetViewComponent().actionOnCheckOnlyFriendCheck:Remove(self.OnCheckOnlyFriendCheck, self)
  self:GetViewComponent().actionOnCheckPrivateCheck:Remove(self.OnCheckPrivateCheck, self)
end
function FriendSetupPageMediatorMobile:InitCheckState()
  self:ClearOnCheckState()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    local currentStateType = friendDataProxy.currentStateType
    if currentStateType == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
      self:OnCheckOnlineCheck(true)
    else
      self:OnCheckOffLineCheck(true)
    end
    local currentSocialType = friendDataProxy.currentSocialType
    if currentSocialType == FriendEnum.SocialSecretType.Public then
      self:OnCheckPublicCheck(true)
    elseif currentSocialType == FriendEnum.SocialSecretType.Friend then
      self:OnCheckOnlyFriendCheck(true)
    elseif currentSocialType == FriendEnum.SocialSecretType.Private then
      self:OnCheckPrivateCheck(true)
    else
      self:OnCheckPublicCheck(true)
    end
  end
end
function FriendSetupPageMediatorMobile:ClearOnCheckState()
  self:GetViewComponent().OnlineCheck:SetIsChecked(false)
  self:GetViewComponent().OffLineCheck:SetIsChecked(false)
  self:GetViewComponent().PublicCheck:SetIsChecked(false)
  self:GetViewComponent().OnlyFriendCheck:SetIsChecked(false)
  self:GetViewComponent().PrivateCheck:SetIsChecked(false)
end
function FriendSetupPageMediatorMobile:OnCheckOnlineCheck(bIsChecked)
  self:GetViewComponent().OnlineCheckImage:SetVisibility(bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().OffLineCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:SetStateCheck(self:GetViewComponent().OnlineCheck)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and friendDataProxy.currentStateType ~= FriendEnum.FriendStateType.Online then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.OnlineState, Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE)
  end
end
function FriendSetupPageMediatorMobile:OnCheckOffLineCheck(bIsChecked)
  self:GetViewComponent().OnlineCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().OffLineCheckImage:SetVisibility(bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:SetStateCheck(self:GetViewComponent().OffLineCheck)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
  end
end
function FriendSetupPageMediatorMobile:OnCheckPublicCheck(bIsChecked)
  self:GetViewComponent().PublicCheckImage:SetVisibility(bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().OnlyFriendCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().PrivateCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:SetSocialSecretCheck(self:GetViewComponent().PublicCheck)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and friendDataProxy.currentSocialType ~= FriendEnum.SocialSecretType.Public then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Public)
  end
end
function FriendSetupPageMediatorMobile:OnCheckOnlyFriendCheck(bIsChecked)
  self:GetViewComponent().PublicCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().OnlyFriendCheckImage:SetVisibility(bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().PrivateCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:SetSocialSecretCheck(self:GetViewComponent().OnlyFriendCheck)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and friendDataProxy.currentSocialType ~= FriendEnum.SocialSecretType.Friend then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Friend)
  end
end
function FriendSetupPageMediatorMobile:OnCheckPrivateCheck(bIsChecked)
  self:GetViewComponent().PublicCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().OnlyFriendCheckImage:SetVisibility(not bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().PrivateCheckImage:SetVisibility(bIsChecked and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:SetSocialSecretCheck(self:GetViewComponent().PrivateCheck)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and friendDataProxy.currentSocialType ~= FriendEnum.SocialSecretType.Private then
    friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, FriendEnum.SocialSecretType.Private)
  end
end
function FriendSetupPageMediatorMobile:SetStateCheck(inscheck)
  if self.currentSeleclStateCheck ~= nil then
    self.currentSeleclStateCheck:SetIsChecked(false)
    self.currentSeleclStateCheck:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.currentSeleclStateCheck = inscheck
  self.currentSeleclStateCheck:SetIsChecked(true)
  self.currentSeleclStateCheck:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end
function FriendSetupPageMediatorMobile:SetSocialSecretCheck(inscheck)
  if self.currentSelectSocialSecretCheck ~= nil then
    self.currentSelectSocialSecretCheck:SetIsChecked(false)
    self.currentSelectSocialSecretCheck:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.currentSelectSocialSecretCheck = inscheck
  self.currentSelectSocialSecretCheck:SetIsChecked(true)
  self.currentSelectSocialSecretCheck:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end
return FriendSetupPageMediatorMobile
