local NavigationBarMediator = class("NavigationBarMediator", PureMVC.Mediator)
function NavigationBarMediator:ListNotificationInterests()
  return {
    NotificationDefines.NavigationBar.SwitchDisplayNavBar,
    NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar,
    NotificationDefines.NavigationBar.SwitchIgnoreEsc,
    NotificationDefines.NavigationBar.SwitchDisplayPage,
    NotificationDefines.NavigationBar.SwitchPageVisibility,
    NotificationDefines.NavigationBar.SetAllPageLstVisibility,
    NotificationDefines.OnResPlayerAttrSync,
    NotificationDefines.NavigationBar.SwitchRightSideWidget,
    NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged,
    NotificationDefines.Common.PlayVoice,
    NotificationDefines.NavigationBar.HideKaPhoneRedDot,
    NotificationDefines.FriendCmd,
    NotificationDefines.FriendInfoChange,
    NotificationDefines.Activities.BuffShowVis,
    NotificationDefines.AccountBind.OpenAccountBindPage,
    NotificationDefines.AccountBind.UpdataAccountInfo
  }
end
function NavigationBarMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local noteType = notification:GetType()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.OnResPlayerAttrSync then
    viewComponent:InitPlayerInfo()
    self:UpdatePlayerAvatar()
    GameFacade:SendNotification(NotificationDefines.Common.UpdateCurrency)
  elseif noteName == NotificationDefines.NavigationBar.SwitchDisplayNavBar then
    viewComponent:SetDisplayNavBar(noteBody)
  elseif noteName == NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar then
    viewComponent:SetDisplaySecondNavBar(noteBody)
  elseif noteName == NotificationDefines.NavigationBar.SwitchIgnoreEsc then
    viewComponent:SetIgnoreEsc(noteBody)
  elseif noteName == NotificationDefines.NavigationBar.SwitchPageVisibility then
    viewComponent:SetPageVisibility(noteBody)
  elseif noteName == NotificationDefines.NavigationBar.SwitchRightSideWidget then
    local body = noteBody
    if body.target == UIPageNameDefine.FriendList then
      viewComponent:OnClickFriend()
    elseif body.target == UIPageNameDefine.KaPhonePage then
      if noteType then
        viewComponent:OnClickChat()
      else
        viewComponent:JumpToChat()
      end
    elseif body.target == UIPageNameDefine.NavigationMenuPage then
      viewComponent:OnClickMenu()
    end
  elseif noteName == NotificationDefines.NavigationBar.SwitchDisplayPage then
    local noteBody = noteBody
    if noteBody then
      if noteBody.pageType then
        viewComponent:NavigationBarChange(noteBody.pageType, noteBody.secondIndex, noteBody.exData)
      end
    else
      viewComponent:NavigationBarChange(UE4.EPMFunctionTypes.Apartment)
    end
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetInLottery(false)
  elseif noteName == NotificationDefines.Common.PlayVoice then
    local view = self:GetViewComponent()
    if noteBody.voiceType == "Success" and view.SuccessAudioEvent then
      view:K2_PostAkEvent(view.SuccessAudioEvent)
    elseif noteBody.voiceType == "Failure" and view.FailureAudioEvent then
      view:K2_PostAkEvent(view.FailureAudioEvent)
    end
  elseif noteName == NotificationDefines.NavigationBar.HideKaPhoneRedDot then
  elseif noteName == NotificationDefines.Activities.BuffShowVis then
    local view = self:GetViewComponent()
    if noteBody.bVis then
      view.BuffPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      view.BuffPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif noteName == NotificationDefines.NavigationBar.SetAllPageLstVisibility then
    ViewMgr:SetAllPageLstVisibility(viewComponent, noteBody)
  elseif noteName == NotificationDefines.AccountBind.OpenAccountBindPage or noteName == NotificationDefines.AccountBind.UpdataAccountInfo then
    viewComponent:UpdateRedDotMenu()
  end
  if noteName == NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged then
    self:UpdatePlayerAvatar()
  end
  if noteName == NotificationDefines.FriendCmd and (noteType == NotificationDefines.FriendCmdType.FriendListNtf or noteType == NotificationDefines.FriendCmdType.FriendDelNtf or noteType == NotificationDefines.FriendCmdType.FriendInfoUpdate or noteType == NotificationDefines.FriendCmdType.FriendChangeNtf) then
    self:InitFriendCount()
  end
  if noteName == NotificationDefines.FriendInfoChange then
    self:InitFriendCount()
  end
end
function NavigationBarMediator:OnRegister()
  NavigationBarMediator.super.OnRegister(self)
  self:UpdatePlayerAvatar()
end
function NavigationBarMediator:OnViewComponentPagePostOpen()
  self:InitFriendCount()
end
function NavigationBarMediator:UpdatePlayerAvatar()
  local avatarId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  local frameId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId))
  self:GetViewComponent():InitPlayerAvatar(avatarId, frameId)
end
function NavigationBarMediator:InitFriendCount()
  local allFriends = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetAllFriends()
  local onlineCnt = 0
  local totalCnt = 0
  for key, value in pairs(allFriends) do
    if value.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and value.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
      onlineCnt = onlineCnt + 1
    end
    totalCnt = totalCnt + 1
  end
  LogDebug("NavigationBarMediator", "Update friend count: %d / %d", onlineCnt, totalCnt)
  self:GetViewComponent():UpdateFriendCount(onlineCnt, totalCnt)
end
return NavigationBarMediator
