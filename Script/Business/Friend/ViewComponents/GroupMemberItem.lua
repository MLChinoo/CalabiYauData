local GroupMemberItem = class("GroupMemberItem", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local friendShortcutMenu
function GroupMemberItem:ListNeededMediators()
  return {}
end
function GroupMemberItem:InitializeLuaEvent()
end
function GroupMemberItem:Construct()
  GroupMemberItem.super.Construct(self)
  if self.Button_Apply then
    self.Button_Apply.OnClicked:Add(self, self.OnClickAdd)
  end
  if self.Button_Black then
    self.Button_Black.OnClicked:Add(self, self.OnClickBlack)
  end
  if self.Button_Delete then
    self.Button_Delete.OnClicked:Add(self, self.OnClickDelete)
  end
  if self.Content_Remark then
    self.Content_Remark.OnTextCommitted:Add(self, self.CommitRemark)
  end
  if self.Button_ConfirmRemark then
    self.Button_ConfirmRemark.OnClicked:Add(self, self.OnClickConfirmRemark)
  end
end
function GroupMemberItem:Destruct()
  if self.Button_Apply then
    self.Button_Apply.OnClicked:Remove(self, self.OnClickAdd)
  end
  if self.Button_Black then
    self.Button_Black.OnClicked:Remove(self, self.OnClickBlack)
  end
  if self.Button_Delete then
    self.Button_Delete.OnClicked:Remove(self, self.OnClickDelete)
  end
  if self.Content_Remark then
    self.Content_Remark.OnTextCommitted:Remove(self, self.CommitRemark)
  end
  if self.Button_ConfirmRemark then
    self.Button_ConfirmRemark.OnClicked:Remove(self, self.OnClickConfirmRemark)
  end
  self:CollapseFriendMenu()
  GroupMemberItem.super.Destruct(self)
end
function GroupMemberItem:OnListItemObjectSet(itemObj)
  self.itemInfo = itemObj
  if itemObj.parent then
    itemObj.parent.actionOnUpdatePlayer:Add(self.UpdatePlayer, self)
    self.bShowState = self.itemInfo.parent.showOnlineStatus
  end
  self:UpdatePlayer(itemObj.data)
end
function GroupMemberItem:UpdatePlayer(playerInfo)
  if self.itemInfo == nil or nil == self.itemInfo.data then
    return
  end
  if playerInfo and playerInfo.playerId ~= self.itemInfo.data.playerId then
    return
  end
  if playerInfo then
    self.itemInfo.data = playerInfo
    self.isOnline = playerInfo.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and playerInfo.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE
  end
  self:UpdateView()
end
function GroupMemberItem:UpdateView()
  if self.itemInfo and self.itemInfo.data then
    local player = self.itemInfo.data
    if self.itemInfo.bShowPlatform then
      local loginType = UE4.UPMLoginDataCenter.Get(self):GetLoginType()
      if loginType and self.WidgetSwitcher_Platform then
        if loginType == UE4.ELoginType.ELT_QQ then
          self.WidgetSwitcher_Platform:SetActiveWidgetIndex(2)
        elseif loginType == UE4.ELoginType.ELT_Wechat then
          self.WidgetSwitcher_Platform:SetActiveWidgetIndex(1)
        else
          self.WidgetSwitcher_Platform:SetActiveWidgetIndex(0)
        end
      end
    end
    GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Img_PlayerIcon, player.icon, self.Image_BorderIcon, player.vcBorderId)
    if self.Image_Division and self.Image_DivisionLevel then
      local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(player.stars)
      if divisionCfg then
        self:SetImageByPaperSprite(self.Image_Division, divisionCfg.IconDivisionS)
        if GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionSubLevelTexture(divisionCfg) then
          self:SetImageByPaperSprite(self.Image_DivisionLevel, divisionCfg.IconDivisionLevelS)
          self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      else
        LogError("GroupMemberItem", "Division config error")
      end
    end
    if self.Text_Name then
      self.Text_Name:SetText(player.nick)
    end
    if self.Text_Remark then
      if player.remarks and player.remarks ~= "" then
        self.Text_Remark:SetText(player.remarks)
        self.Text_Remark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Text_Remark:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.SizeBox_FriendRemark and not self.itemInfo.isActive then
      self.SizeBox_FriendRemark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.WS_PlayerState then
      if self.bShowState and player.onlineStatus ~= nil and nil ~= player.status then
        self.WS_PlayerState:SetActiveWidgetIndex(self:GetStatusShown(player.onlineStatus, player.status))
        self.WS_PlayerState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.Image_OfflineState then
      local bNotMask = self.isOnline or not self.bShowState
      self.Image_OfflineState:SetVisibility(bNotMask and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Image_Selected then
      self.Image_Selected:SetVisibility(self.itemInfo.isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    if self.WS_ContextType then
      self.WS_ContextType:SetActiveWidgetIndex(0)
    end
    if self.itemInfo.isActive then
      self:SetPlayerManagerMenu(player)
    else
      self:CollapseFriendMenu()
    end
    if self.Image_Hovered then
      self.Image_Hovered:SetVisibility(self.itemInfo.isHovered and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    if self.Text_WinCount then
      self.Text_WinCount:SetText(player.battleInfo.winCount)
    end
    if self.Text_MVPCount then
      self.Text_MVPCount:SetText(player.battleInfo.mvpCount)
    end
  end
end
function GroupMemberItem:SetPlayerManagerMenu(player)
  if self.MenuSlot == nil then
    return
  end
  if (nil == friendShortcutMenu or not friendShortcutMenu:IsValid()) and self.FriendShortcutMenuClass then
    local menuClass = ObjectUtil:LoadClass(self.FriendShortcutMenuClass)
    if menuClass then
      friendShortcutMenu = UE4.UWidgetBlueprintLibrary.Create(self, menuClass)
      if nil == friendShortcutMenu then
        LogError("GroupMemberItem", "Menu create failed")
      end
    else
      LogError("GroupMemberItem", "Menu class load failed")
    end
  end
  if player.friendType == FriendEnum.FriendType.Apply then
    if self.WS_ContextType then
      self.WS_ContextType:SetActiveWidgetIndex(2)
    end
  else
    if friendShortcutMenu then
      self.MenuSlot:AddChild(friendShortcutMenu)
      local menuData = {}
      menuData.playerId = player.playerId
      menuData.playerNick = player.nick
      local friendProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
      local friendType = player.friendType
      local friendStatus = player.onlineStatus
      local playerStatus = player.status
      local socialSecret = player.socialSecret
      menuData.bPlayerInfo = self:CanShowInfo(friendType, socialSecret)
      menuData.bFriend = friendType ~= FriendEnum.FriendType.Blacklist
      menuData.bInviteTeam = friendStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE and friendProxy:IsFriend(player.playerId) and not friendProxy:IsShieldList(player.playerId) and playerStatus ~= Pb_ncmd_cs.EPlayerStatus.PlayerStatus_REPLAY
      menuData.bJoinTeam = friendStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE and friendProxy:IsFriend(player.playerId) and friendProxy:GetFriendCurrentRoomId(player.playerId) and not friendProxy:IsShieldList(player.playerId)
      menuData.bMsg = friendProxy:IsFriend(player.playerId) and self.isOnline and self.bShowState
      menuData.bRemark = friendProxy:IsFriend(player.playerId) or friendType == FriendEnum.FriendType.Blacklist
      menuData.bShield = true
      friendShortcutMenu:Init(menuData)
      if menuData.bInviteTeam and not self.bBindInvite then
        friendShortcutMenu:SetInviteState(player.playerId, player.bInvite)
        friendShortcutMenu.actionOnClickInviteTeam:Add(self.InviteTeam, self)
        self.bBindInvite = true
      end
      if menuData.bJoinTeam and not self.bBindJoin then
        friendShortcutMenu:SetJoinState(player.playerId, player.bReqJoin)
        friendShortcutMenu.actionOnClickJoinTeam:Add(self.JoinTeam, self)
        self.bBindJoin = true
      end
      if menuData.bRemark and not self.bBindRemark then
        friendShortcutMenu.actionOnClickRemark:Add(self.RemarkFriend, self)
        self.bBindRemark = true
      end
    end
    if self.WS_ContextType then
      self.WS_ContextType:SetActiveWidgetIndex(1)
    end
  end
end
function GroupMemberItem:CollapseFriendMenu()
  if friendShortcutMenu then
    if self.bBindInvite then
      friendShortcutMenu.actionOnClickInviteTeam:Remove(self.InviteTeam, self)
      self.bBindInvite = false
    end
    if self.bBindJoin then
      friendShortcutMenu.actionOnClickJoinTeam:Remove(self.JoinTeam, self)
      self.bBindJoin = false
    end
    if self.bBindRemark then
      friendShortcutMenu.actionOnClickRemark:Remove(self.RemarkFriend, self)
      self.bBindRemark = false
    end
  end
end
function GroupMemberItem:CanShowInfo(friendType, socialSecretLevel)
  if nil == socialSecretLevel then
    return true
  end
  if socialSecretLevel == FriendEnum.SocialSecretType.Private then
    return false
  end
  if socialSecretLevel == FriendEnum.SocialSecretType.Public then
    return true
  end
  if socialSecretLevel == FriendEnum.SocialSecretType.Friend then
    return friendProxy:IsFriend(player.playerId)
  end
end
function GroupMemberItem:InviteTeam()
  if self.itemInfo then
    local targetPlayer = self.itemInfo.data
    targetPlayer.bInvite = false
  end
end
function GroupMemberItem:JoinTeam()
  if self.itemInfo then
    local targetPlayer = self.itemInfo.data
    targetPlayer.bReqJoin = false
  end
end
function GroupMemberItem:OnClickAdd()
  if self.itemInfo then
    local targetPlayer = self.itemInfo.data
    local friendReplyInfo = {}
    friendReplyInfo.replyType = FriendEnum.ReplyType.Agree
    friendReplyInfo.playerId = targetPlayer.playerId
    GameFacade:SendNotification(NotificationDefines.FriendReplyCmd, friendReplyInfo)
  end
end
function GroupMemberItem:OnClickBlack()
  if self.itemInfo then
    local targetPlayer = self.itemInfo.data
    local blackFriendData = {}
    blackFriendData.playerId = targetPlayer.playerId
    blackFriendData.nick = targetPlayer.nick
    GameFacade:SendNotification(NotificationDefines.ShieldFriendCmd, blackFriendData)
  end
end
function GroupMemberItem:OnClickDelete()
  if self.itemInfo then
    local targetPlayer = self.itemInfo.data
    local deleteFriendInfo = {}
    deleteFriendInfo.playerId = targetPlayer.playerId
    deleteFriendInfo.friendType = FriendEnum.FriendType.Apply
    deleteFriendInfo.nick = targetPlayer.nick
    GameFacade:SendNotification(NotificationDefines.DeleteFriendCmd, deleteFriendInfo)
  end
end
function GroupMemberItem:RemarkFriend()
  if self.SizeBox_FriendRemark then
    self.SizeBox_FriendRemark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function GroupMemberItem:CommitRemark(text, commitMethod)
  if commitMethod == UE4.ETextCommit.OnEnter then
    if self.MaxRemarkCharacters and UE4.UKismetStringLibrary.Len(text) > self.MaxRemarkCharacters then
      return
    end
    if self.itemInfo then
      local targetPlayer = self.itemInfo.data
      GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):ReqFriendRemarks(targetPlayer.playerId, text)
    end
    self.Content_Remark:SetText("")
    self.SizeBox_FriendRemark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GroupMemberItem:OnClickConfirmRemark()
  if self.Content_Remark then
    self:CommitRemark(self.Content_Remark:GetText(), UE4.ETextCommit.OnEnter)
  end
end
function GroupMemberItem:GetStatusShown(onlineStatus, playerStatus)
  if nil == onlineStatus or nil == playerStatus then
    return FriendEnum.FriendStateType.None
  end
  if onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
    if self.itemInfo and self.itemInfo.data then
      if playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_NONE then
        return FriendEnum.FriendStateType.Online
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_ROOM then
        return FriendEnum.FriendStateType.Room
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_PRACTICE then
        return FriendEnum.FriendStateType.Training
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_MATCH then
        return FriendEnum.FriendStateType.Matching
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_FIGHT then
        return FriendEnum.FriendStateType.Contest
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_WATCH then
        return FriendEnum.FriendStateType.Watch
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_SETTLE then
        return FriendEnum.FriendStateType.Summary
      elseif playerStatus == Pb_ncmd_cs.EPlayerStatus.PlayerStatus_REPLAY then
        return FriendEnum.FriendStateType.Replay
      end
    else
      return FriendEnum.FriendStateType.Online
    end
  elseif onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LOST then
    return FriendEnum.FriendStateType.LostLine
  elseif onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE then
    return FriendEnum.FriendStateType.OffOnline
  elseif onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LEAVE then
    return FriendEnum.FriendStateType.Leave
  elseif onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
    return FriendEnum.FriendStateType.OffOnline
  else
    return FriendEnum.FriendStateType.None
  end
end
return GroupMemberItem
