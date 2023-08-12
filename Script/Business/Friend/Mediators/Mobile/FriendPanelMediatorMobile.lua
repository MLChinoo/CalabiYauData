local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FriendPanelMediatorMobile = class("FriendPanelMediatorMobile", PureMVC.Mediator)
local roomProxy, firendListDataProxy
function FriendPanelMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.Common,
    NotificationDefines.FriendCmd
  }
end
function FriendPanelMediatorMobile:HandleNotification(notify)
end
function FriendPanelMediatorMobile:OnRegister()
  firendListDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  self:GetViewComponent().actionOnListItemObjectSet:Add(self.OnListItemObjectSet, self)
  self:GetViewComponent().actionOnClickJoinBtn:Add(self.OnClickJoinBtn, self)
  self:GetViewComponent().actionOnClickApplyAdd:Add(self.OnClickApplyAdd, self)
  self:GetViewComponent().actionOnClickChatBtn:Add(self.OnClickChatBtn, self)
  self:GetViewComponent().actionOnClickRejectInviteBtn:Add(self.OnClickRejectInviteBtn, self)
  self:GetViewComponent().actionOnClickPassInviteBtn:Add(self.OnClickPassInviteBtn, self)
  self:GetViewComponent().actionOnClickCancelShieldBtn:Add(self.OnClickCancelShieldBtn, self)
  self:GetViewComponent().actionOnClickHeadBtn:Add(self.OnClickHeadBtn, self)
  self:GetViewComponent().actionOnClickRecentData:Add(self.OnClickRecentData, self)
  self:GetViewComponent().actionOnClickQQInviteSilent:Add(self.OnClickQQInviteSilent, self)
  self:GetViewComponent().actionOnClickWXInviteSingle:Add(self.OnClickWXInviteSingle, self)
  roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
end
function FriendPanelMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnListItemObjectSet:Remove(self.OnListItemObjectSet, self)
  self:GetViewComponent().actionOnClickJoinBtn:Remove(self.OnClickJoinBtn, self)
  self:GetViewComponent().actionOnClickApplyAdd:Remove(self.OnClickApplyAdd, self)
  self:GetViewComponent().actionOnClickChatBtn:Remove(self.OnClickChatBtn, self)
  self:GetViewComponent().actionOnClickRejectInviteBtn:Remove(self.OnClickRejectInviteBtn, self)
  self:GetViewComponent().actionOnClickPassInviteBtn:Remove(self.OnClickPassInviteBtn, self)
  self:GetViewComponent().actionOnClickCancelShieldBtn:Remove(self.OnClickCancelShieldBtn, self)
  self:GetViewComponent().actionOnClickHeadBtn:Remove(self.OnClickHeadBtn, self)
  self:GetViewComponent().actionOnClickRecentData:Remove(self.OnClickRecentData, self)
  self:GetViewComponent().actionOnClickQQInviteSilent:Remove(self.OnClickQQInviteSilent, self)
  self:GetViewComponent().actionOnClickWXInviteSingle:Remove(self.OnClickWXInviteSingle, self)
end
function FriendPanelMediatorMobile:OnListItemObjectSet(listItemObject)
  self.selectType = listItemObject.currentSelect
  self.currentAddFriendPageStatus = listItemObject.currentAddFriendPageStatus
  self:OnInitFriendPanel(listItemObject.data)
end
function FriendPanelMediatorMobile:OnInitFriendPanel(panelData)
  self.friendPanelData = panelData
  if self.friendPanelData then
    if self:GetViewComponent().PalyerName then
      local nick = ""
      if FunctionUtil:getByteCount(self.friendPanelData.nick) > 9 then
        nick = FunctionUtil:getSubStringByCount(self.friendPanelData.nick, 1, 8) .. "..."
      else
        nick = self.friendPanelData.nick
      end
      self:GetViewComponent().PalyerName:SetText(nick)
    end
    if self:GetViewComponent().RemarksText then
      if "" ~= self.friendPanelData.remarks and self.friendPanelData.remarks ~= nil then
        self:GetViewComponent().RemarksText:SetText("(" .. self.friendPanelData.remarks .. ")")
      else
        self:GetViewComponent().RemarksText:SetText("")
      end
    end
    if self:GetViewComponent().LevelText then
      self:GetViewComponent().LevelText:SetText("LV. " .. self.friendPanelData.level)
    end
    if self:GetViewComponent().SexIconMan and self:GetViewComponent().SexIconWoman then
      if 0 == self.friendPanelData.sex then
        self:GetViewComponent().SexIconMan:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self:GetViewComponent().SexIconWoman:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self:GetViewComponent().SexIconWoman:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self:GetViewComponent().SexIconMan:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    local division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(self.friendPanelData.rank)
    if division and self:GetViewComponent().Image_Division and self:GetViewComponent().Image_DivisionLevel then
      self:GetViewComponent():SetImageByPaperSprite(self:GetViewComponent().Image_Division, division.IconDivisions)
      local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(division.IconDivisionLevelS)
      if "" ~= pathString then
        self:GetViewComponent():SetImageByPaperSprite(self:GetViewComponent().Image_DivisionLevel, division.IconDivisionLevelS)
        self:GetViewComponent().Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self:GetViewComponent().Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self:GetViewComponent().HeadIcon then
      if nil ~= firendListDataProxy.PlatformFriendList[panelData.playerId] then
        local picture_url = firendListDataProxy.PlatformFriendList[panelData.playerId].picture_url
        if picture_url then
          print("DownloadImage HeadIcon", picture_url)
          local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
          local DownLoadTask
          if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
            DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(picture_url .. "100")
          elseif dataCenter:GetLoginType() == UE4.ELoginType.ELT_Wechat then
            DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(picture_url .. "132")
          else
            self:LoadImgError()
          end
          if DownLoadTask then
            DownLoadTask.OnSuccess:Add(self:GetViewComponent(), self.LoadImgSuc)
            DownLoadTask.OnFail:Add(self:GetViewComponent(), self.LoadImgError)
          end
        end
      else
        local avatarId = tonumber(panelData.icon)
        if nil == avatarId then
          avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
        end
        if avatarId then
          local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
          if avatarIcon then
            self:GetViewComponent().HeadIcon:SetBrushFromSoftTexture(avatarIcon)
            self:GetViewComponent().HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
          else
            LogError("FriendPanelMediatorMobile", "Player icon or config error")
          end
        end
      end
    end
    self:ShowBtnByStatu()
    if self:GetViewComponent().WS_PlayerState then
      if self.selectType == FriendEnum.SelectCheckStatus.PlatformFriend or self.selectType == FriendEnum.SelectCheckStatus.GameFriend then
        if self.friendPanelData.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
          local bInRoom = false
          if 0 == self.friendPanelData.roomId and 0 ~= self.friendPanelData.teamId or 0 ~= self.friendPanelData.roomId and self.friendPanelData.roomStatus == FriendEnum.RoomStatus.Ready then
            bInRoom = true
          end
          self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.Online)
          if bInRoom then
            self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.Room)
            self:GetViewComponent().JoinTeamBtn:SetVisibility(UE4.ESlateVisibility.Visible)
          elseif self.friendPanelData.roomStatus == FriendEnum.RoomStatus.Waiting then
            self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.Ready)
          else
            if self.friendPanelData.roomStatus == FriendEnum.RoomStatus.Running then
              self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.Contest)
            else
            end
          end
          local widgetPrivilegeInfo = self:GetViewComponent().PrivilegeInfo
          if widgetPrivilegeInfo then
            widgetPrivilegeInfo:UpdateDisplay(panelData, 2)
          end
        else
          self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.OffOnline)
          local timeText = ""
          local time = FunctionUtil:FormatTime(os.time() - self.friendPanelData.lastTime)
          local daysAgoText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "DaysAgoText")
          if time.Day > 7 then
            timeText = string.format(daysAgoText, 7)
          elseif time.Day > 0 then
            timeText = string.format(daysAgoText, time.Day)
          elseif time.Hour > 0 then
            local hourAndMinuteAgoText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "HourAndMinuteAgoText")
            timeText = string.format(hourAndMinuteAgoText, time.Hour, time.Minute)
          else
            local minuteAgoText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "MinuteAgoText")
            if time.Minute > 0 then
              timeText = string.format(minuteAgoText, time.Minute)
            else
              timeText = string.format(minuteAgoText, 1)
            end
          end
          self:GetViewComponent().PlayerStateText_OffLine:SetText(timeText)
          if self.selectType == FriendEnum.SelectCheckStatus.PlatformFriend then
            local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
            if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
              self:GetViewComponent().QQInviteSilent:SetVisibility(UE4.ESlateVisibility.Visible)
            elseif dataCenter:GetLoginType() == UE4.ELoginType.ELT_Wechat then
              self:GetViewComponent().WXInviteSingle:SetVisibility(UE4.ESlateVisibility.Visible)
            else
              LogDebug("FriendPanelMediatorMobile", "Not QQLogin and Not WXLogin")
            end
          end
        end
      elseif self.selectType == FriendEnum.SelectCheckStatus.ViewReq then
        self:GetViewComponent().WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateMobileType.OffOnline)
        local reqSuffixText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "ReqSuffixText")
        local timeText = os.date("%Y-%m-%d ", self.friendPanelData.friend_time)
        timeText = string.format(reqSuffixText, timeText)
        self:GetViewComponent().PlayerStateText_OffLine:SetText(timeText)
      end
    end
  end
end
function FriendPanelMediatorMobile:LoadImgSuc(InTexture)
  self.HeadIcon:SetBrushFromTextureDynamic(InTexture)
  self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
end
function FriendPanelMediatorMobile:LoadImgError()
  local avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  if avatarId then
    local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
    if avatarIcon then
      self.HeadIcon:SetBrushFromSoftTexture(avatarIcon)
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      LogError("FriendPanelMediatorMobile", "Player icon or config error")
    end
  end
end
function FriendPanelMediatorMobile:ShowBtnByStatu()
  self:HideAllBtn()
  if self.selectType == FriendEnum.SelectCheckStatus.PlatformFriend then
    self:GetViewComponent().AddPlayerBtn_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().ChatBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.selectType == FriendEnum.SelectCheckStatus.GameFriend then
    self:GetViewComponent().ChatBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.selectType == FriendEnum.SelectCheckStatus.ShieldedFriend then
    self:GetViewComponent().CancelShieldBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.selectType == FriendEnum.SelectCheckStatus.AddFriend then
    self:GetViewComponent().AddPlayerBtn_2:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.RecentPlayers then
      self:GetViewComponent().RecentDataBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif self.selectType == FriendEnum.SelectCheckStatus.ViewReq then
    self:GetViewComponent().RejectInviteBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().PassInviteBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function FriendPanelMediatorMobile:HideAllBtn()
  self:GetViewComponent().JoinTeamBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().AddPlayerBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().AddPlayerBtn_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().ChatBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().RejectInviteBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().PassInviteBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().CancelShieldBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().RecentDataBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().QQInviteSilent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WXInviteSingle:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function FriendPanelMediatorMobile:OnClickJoinBtn()
  self:GetViewComponent().JoinTeamBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if roomProxy then
    local teamInfo = roomProxy:GetTeamInfo()
    if self.friendPanelData and 0 ~= self.friendPanelData.teamId then
      if teamInfo and teamInfo.teamId and teamInfo.teamId == self.friendPanelData.teamId and 0 ~= self.friendPanelData.teamId then
        local alreadyInTeamText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "AlreadyInTeamText")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, alreadyInTeamText)
        return
      else
        local alreadyReqJoinTeamText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "AlreadyReqJoinTeamText")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, alreadyReqJoinTeamText)
        roomProxy:ReqTeamApply(self.friendPanelData.teamId, self.friendPanelData.playerId)
      end
    end
  end
end
function FriendPanelMediatorMobile:OnClickApplyAdd()
  local addFriendData = {}
  addFriendData.playerId = self.friendPanelData.playerId
  addFriendData.nick = self.friendPanelData.nick
  GameFacade:SendNotification(NotificationDefines.AddFriendCmd, addFriendData)
end
function FriendPanelMediatorMobile:OnClickChatBtn()
  local privateChatMsg = {}
  privateChatMsg.playerId = self.friendPanelData.playerId
  privateChatMsg.playerName = self.friendPanelData.nick
  GameFacade:SendNotification(NotificationDefines.Chat.CreatePrivateChat, privateChatMsg)
end
function FriendPanelMediatorMobile:OnClickRejectInviteBtn()
  if self.friendPanelData then
    local deleteInfo = {}
    deleteInfo.playerId = self.friendPanelData.playerId
    deleteInfo.friendType = self.friendPanelData.friendType
    deleteInfo.nick = self.friendPanelData.nick
    GameFacade:SendNotification(NotificationDefines.DeleteFriendCmd, deleteInfo)
  end
end
function FriendPanelMediatorMobile:OnClickPassInviteBtn()
  if firendListDataProxy and self.friendPanelData then
    firendListDataProxy:ReqFriendReply(FriendEnum.ReplyType.Agree, self.friendPanelData.playerId)
  end
end
function FriendPanelMediatorMobile:OnClickCancelShieldBtn()
  if self.friendPanelData then
    local deleteInfo = {}
    deleteInfo.playerId = self.friendPanelData.playerId
    deleteInfo.friendType = self.friendPanelData.friendType
    GameFacade:SendNotification(NotificationDefines.DeleteFriendCmd, deleteInfo)
  end
end
function FriendPanelMediatorMobile:OnClickHeadBtn()
  self:GetViewComponent().MenuAnchor_ShowInfo:Open(true)
end
function FriendPanelMediatorMobile:OnClickRecentData()
  if self.friendPanelData and self.friendPanelData.playerId then
    GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):GetRecentBattleRecord(self.friendPanelData.playerId)
  end
end
function FriendPanelMediatorMobile:OnClickQQInviteSilent()
  LogDebug("FriendPanelMediatorMobile", "OnClickQQInviteSilent")
  if self.friendPanelData.openid == nil or self.friendPanelData.openid == "" or 0 == self.friendPanelData.openid then
    LogDebug("FriendPanelMediatorMobile", "self.friendPanelData.openid ='' or nil or 0")
    return
  else
    LogDebug("FriendPanelMediatorMobile", "self.friendPanelData.openid = " .. self.friendPanelData.openid)
  end
  local Link = "https://speed.gamecenter.qq.com/pushgame/v1/detail?appid=1112190766&_wv=2164260896&_wwv=448&autodownload=1&autolaunch=1&autosubscribe=1&__test__"
  local ThumbPath = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png"
  UE4.UPMShareSubSystem.GetInst(LuaGetWorld()):SendInviteSilenceToQQ(tostring(self.friendPanelData.openid), "分享邀请的标题", "分享邀请的内容", Link, ThumbPath, "")
end
function FriendPanelMediatorMobile:OnClickWXInviteSingle()
  LogDebug("FriendPanelMediatorMobile", "OnClickWXInviteSingle")
  if self.friendPanelData.openid == nil or self.friendPanelData.openid == "" or 0 == self.friendPanelData.openid then
    LogDebug("FriendPanelMediatorMobile", "self.friendPanelData.openid ='' or nil or 0")
    return
  else
    LogDebug("FriendPanelMediatorMobile", "self.friendPanelData.openid = " .. self.friendPanelData.openid)
  end
  LogDebug("FriendPanelMediatorMobile", "OnClickWXInviteSingle")
  local Link = "https://speed.gamecenter.qq.com/pushgame/v1/detail?appid=1112190766&_wv=2164260896&_wwv=448&autodownload=1&autolaunch=1&autosubscribe=1&__test__"
  local ThumbPath = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png"
  UE4.UPMShareSubSystem.GetInst(LuaGetWorld()):SendInviteSingleToWeChat(tostring(self.friendPanelData.openid), "分享邀请的标题", "分享邀请的内容", Link, ThumbPath, "")
end
return FriendPanelMediatorMobile
