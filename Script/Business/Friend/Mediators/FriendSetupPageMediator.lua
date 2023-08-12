local FriendSetupPageMediator = class("FriendSetupPageMediator", PureMVC.Mediator)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendSetupPageMediator:ListNotificationInterests()
  return {}
end
function FriendSetupPageMediator:HandleNotification(notify)
end
function FriendSetupPageMediator:OnRegister()
  self:GetViewComponent().actionOnClickOnlineState:Add(self.OnClickOnlineState, self)
  self:GetViewComponent().actionOnClickTeamSecret:Add(self.OnClickTeamSecret, self)
  self:GetViewComponent().actionOnCheckOnline:Add(self.OnCheckOnline, self)
  self:GetViewComponent().actionOnCheckLeave:Add(self.OnCheckLeave, self)
  self:GetViewComponent().actionOnCheckPublic:Add(self.OnCheckPublic, self)
  self:GetViewComponent().actionOnCheckFriendOnly:Add(self.OnCheckFriendOnly, self)
  self:GetViewComponent().actionOnCheckPrivate:Add(self.OnCheckPrivate, self)
  self.checkBoxArr1 = {}
  self.checkBoxArr2 = {}
  self.imageArr1 = {}
  self.imageArr2 = {}
  self.curStatusType = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetOnlineStatus()
  self.curSocialType = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetSocialType()
  table.insert(self.checkBoxArr1, self:GetViewComponent().CheckBox_Online)
  table.insert(self.checkBoxArr1, self:GetViewComponent().CheckBox_Leave)
  table.insert(self.imageArr1, self:GetViewComponent().Img_C1)
  table.insert(self.imageArr1, self:GetViewComponent().Img_C2)
  table.insert(self.checkBoxArr2, self:GetViewComponent().CheckBox_Public)
  table.insert(self.checkBoxArr2, self:GetViewComponent().CheckBox_FriendOnly)
  table.insert(self.checkBoxArr2, self:GetViewComponent().CheckBox_Private)
  table.insert(self.imageArr2, self:GetViewComponent().Img_C3)
  table.insert(self.imageArr2, self:GetViewComponent().Img_C4)
  table.insert(self.imageArr2, self:GetViewComponent().Img_C5)
  self:InitCheckState()
end
function FriendSetupPageMediator:OnRemove()
  self:GetViewComponent().actionOnClickOnlineState:Remove(self.OnClickOnlineState, self)
  self:GetViewComponent().actionOnClickTeamSecret:Remove(self.OnClickTeamSecret, self)
  self:GetViewComponent().actionOnCheckOnline:Remove(self.OnCheckOnline, self)
  self:GetViewComponent().actionOnCheckLeave:Remove(self.OnCheckLeave, self)
  self:GetViewComponent().actionOnCheckPublic:Remove(self.OnCheckPublic, self)
  self:GetViewComponent().actionOnCheckFriendOnly:Remove(self.OnCheckFriendOnly, self)
  self:GetViewComponent().actionOnCheckPrivate:Remove(self.OnCheckPrivate, self)
  self:UpdateSetup()
end
function FriendSetupPageMediator:InitCheckState()
  if self.curStatusType == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
    self:OnCheckOnline(true)
  elseif self.curStatusType == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
    self:OnCheckLeave(true)
  else
    self:OnCheckOnline(true)
  end
  if self.curSocialType == FriendEnum.SocialSecretType.Public then
    self:OnCheckPublic(true)
  elseif self.curSocialType == FriendEnum.SocialSecretType.Friend then
    self:OnCheckFriendOnly(true)
  elseif self.curSocialType == FriendEnum.SocialSecretType.Private then
    self:OnCheckPrivate(true)
  else
    self:OnCheckPublic(true)
  end
end
function FriendSetupPageMediator:OnClickOnlineState()
  if self:GetViewComponent().VB_OnlineState then
    if self:GetViewComponent().VB_OnlineState:IsVisible() then
      self:GetViewComponent().VB_OnlineState:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if self:GetViewComponent().Img_ArrowOnline then
        self:GetViewComponent().Img_ArrowOnline:SetRenderScale(UE4.FVector2D(1, -1))
      end
    else
      self:GetViewComponent().VB_OnlineState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self:GetViewComponent().Img_ArrowOnline then
        self:GetViewComponent().Img_ArrowOnline:SetRenderScale(UE4.FVector2D(1, 1))
      end
    end
  end
end
function FriendSetupPageMediator:OnClickTeamSecret()
  if self:GetViewComponent().VB_TeamSecret then
    if self:GetViewComponent().VB_TeamSecret:IsVisible() then
      self:GetViewComponent().VB_TeamSecret:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if self:GetViewComponent().Img_ArrowSecret then
        self:GetViewComponent().Img_ArrowSecret:SetRenderScale(UE4.FVector2D(1, -1))
      end
    else
      self:GetViewComponent().VB_TeamSecret:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self:GetViewComponent().Img_ArrowSecret then
        self:GetViewComponent().Img_ArrowSecret:SetRenderScale(UE4.FVector2D(1, 1))
      end
    end
  end
end
function FriendSetupPageMediator:OnCheckOnline(bIsChecked)
  for key, value in pairs(self.checkBoxArr1) do
    if value then
      value:SetIsChecked(false)
    end
  end
  for key, value in pairs(self.imageArr1) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().CheckBox_Online then
    self:GetViewComponent().CheckBox_Online:SetIsChecked(true)
  end
  if self:GetViewComponent().Img_C1 then
    self:GetViewComponent().Img_C1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().Text_C1 then
    self:GetViewComponent().Text_C1:SetOpacity(1)
  end
  if self:GetViewComponent().Text_C2 then
    self:GetViewComponent().Text_C2:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_OnlineState then
    self:GetViewComponent().Text_OnlineState:SetText(self:GetViewComponent().Text_C1:GetText())
  end
  self:SetStatusType(Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE)
end
function FriendSetupPageMediator:OnCheckLeave(bIsChecked)
  for key, value in pairs(self.checkBoxArr1) do
    if value then
      value:SetIsChecked(false)
    end
  end
  for key, value in pairs(self.imageArr1) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().CheckBox_Leave then
    self:GetViewComponent().CheckBox_Leave:SetIsChecked(true)
  end
  if self:GetViewComponent().Img_C2 then
    self:GetViewComponent().Img_C2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().Text_C1 then
    self:GetViewComponent().Text_C1:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_C2 then
    self:GetViewComponent().Text_C2:SetOpacity(1)
  end
  if self:GetViewComponent().Text_OnlineState then
    self:GetViewComponent().Text_OnlineState:SetText(self:GetViewComponent().Text_C2:GetText())
  end
  self:SetStatusType(Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE)
end
function FriendSetupPageMediator:OnCheckPublic(bIsChecked)
  for key, value in pairs(self.checkBoxArr2) do
    if value then
      value:SetIsChecked(false)
    end
  end
  for key, value in pairs(self.imageArr2) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().CheckBox_Public then
    self:GetViewComponent().CheckBox_Public:SetIsChecked(true)
  end
  if self:GetViewComponent().Img_C3 then
    self:GetViewComponent().Img_C3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().Text_C3 then
    self:GetViewComponent().Text_C3:SetOpacity(1)
  end
  if self:GetViewComponent().Text_C4 then
    self:GetViewComponent().Text_C4:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_C5 then
    self:GetViewComponent().Text_C5:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_TeamSecret then
    self:GetViewComponent().Text_TeamSecret:SetText(self:GetViewComponent().Text_C3:GetText())
  end
  self:SetSocialType(FriendEnum.SocialSecretType.Public)
end
function FriendSetupPageMediator:OnCheckFriendOnly(bIsChecked)
  for key, value in pairs(self.checkBoxArr2) do
    if value then
      value:SetIsChecked(false)
    end
  end
  for key, value in pairs(self.imageArr2) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().CheckBox_FriendOnly then
    self:GetViewComponent().CheckBox_FriendOnly:SetIsChecked(true)
  end
  if self:GetViewComponent().Img_C4 then
    self:GetViewComponent().Img_C4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().Text_C3 then
    self:GetViewComponent().Text_C3:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_C4 then
    self:GetViewComponent().Text_C4:SetOpacity(1)
  end
  if self:GetViewComponent().Text_C5 then
    self:GetViewComponent().Text_C5:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_TeamSecret then
    self:GetViewComponent().Text_TeamSecret:SetText(self:GetViewComponent().Text_C4:GetText())
  end
  self:SetSocialType(FriendEnum.SocialSecretType.Friend)
end
function FriendSetupPageMediator:OnCheckPrivate(bIsChecked)
  for key, value in pairs(self.checkBoxArr2) do
    if value then
      value:SetIsChecked(false)
    end
  end
  for key, value in pairs(self.imageArr2) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().CheckBox_Private then
    self:GetViewComponent().CheckBox_Private:SetIsChecked(true)
  end
  if self:GetViewComponent().Img_C5 then
    self:GetViewComponent().Img_C5:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().Text_C3 then
    self:GetViewComponent().Text_C3:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_C4 then
    self:GetViewComponent().Text_C4:SetOpacity(0.5)
  end
  if self:GetViewComponent().Text_C5 then
    self:GetViewComponent().Text_C5:SetOpacity(1)
  end
  if self:GetViewComponent().Text_TeamSecret then
    self:GetViewComponent().Text_TeamSecret:SetText(self:GetViewComponent().Text_C5:GetText())
  end
  self:SetSocialType(FriendEnum.SocialSecretType.Private)
end
function FriendSetupPageMediator:SetStatusType(newStatus)
  self.curStatusType = newStatus
  if self:GetViewComponent().ButtonCD and self.updateStatusTask == nil then
    self.updateStatusTask = TimerMgr:AddTimeTask(self:GetViewComponent().ButtonCD, 0, 1, function()
      self:UpdateSetup()
    end)
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, self.curStatusType, NotificationDefines.FriendCmdType.OnlineStatusSetup)
end
function FriendSetupPageMediator:SetSocialType(newSocial)
  self.curSocialType = newSocial
  if self:GetViewComponent().ButtonCD and self.updateStatusTask == nil then
    self.updateStatusTask = TimerMgr:AddTimeTask(self:GetViewComponent().ButtonCD, 0, 1, function()
      self:UpdateSetup()
    end)
  end
end
function FriendSetupPageMediator:UpdateSetup()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    if friendDataProxy.currentStateType ~= self.curStatusType then
      friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.OnlineState, self.curStatusType)
    end
    if friendDataProxy.currentSocialType ~= self.curSocialType then
      friendDataProxy:ReqFriendSetup(FriendEnum.FriendSetupType.TeamLimit, self.curSocialType)
    end
  end
  if self.updateStatusTask then
    self.updateStatusTask:EndTask()
    self.updateStatusTask = nil
  end
end
return FriendSetupPageMediator
