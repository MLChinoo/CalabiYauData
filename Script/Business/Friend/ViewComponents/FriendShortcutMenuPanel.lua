local FriendShortcutMenuPanel = class("FriendShortcutMenuPanel", PureMVC.ViewComponentPanel)
local FriendShortcutMenuPanelMediator = require("Business/Friend/Mediators/FriendShortcutMenuPanelMediator")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendShortcutMenuPanel:ListNeededMediators()
  return {FriendShortcutMenuPanelMediator}
end
function FriendShortcutMenuPanel:InitializeLuaEvent()
  self.actionOnClickRemark = LuaEvent.new()
  self.actionOnClickJoinTeam = LuaEvent.new()
  self.actionOnClickInviteTeam = LuaEvent.new()
  self.actionOnExecute = LuaEvent.new()
end
function FriendShortcutMenuPanel:OnInitialized()
  LogDebug("FriendShortcutMenuPanel", "On init...")
  FriendShortcutMenuPanel.super.OnInitialized(self)
  self.targetPlayerId = 0
  if self.VB_BehaviorList then
    self.behaviorButtonList = self.VB_BehaviorList:GetAllChildren()
    if self.behaviorButtonList:Length() > 0 then
      for i = 1, self.behaviorButtonList:Length() do
        local btn = self.behaviorButtonList:Get(i)
        if btn.actionOnClick then
          btn.actionOnClick:Add(self.ExecuteManager, self)
        end
      end
    end
  end
end
function FriendShortcutMenuPanel:Init(data)
  if nil == data or nil == data.playerId or nil == self.VB_BehaviorList then
    self.VB_BehaviorList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.targetPlayerId = data.playerId
  self.targetPlayerNick = data.playerNick
  self.bIsBattleInfo = data.bIsBattleInfo
  self.reportContent = data.reportContent
  local isFriend = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsFriend(self.targetPlayerId)
  self.VB_BehaviorList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if nil == self.behaviorButtonList or self.behaviorButtonList:Length() <= 0 then
    return
  end
  for i = 1, self.behaviorButtonList:Length() do
    self.behaviorButtonList:Get(i):SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if data.bPlayerInfo then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.PlayerInfo):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if data.bFriend then
    if isFriend then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.DeleteFriend):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.AddFriend):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if data.bInviteTeam then
    local ownTeamInfo = GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetTeamInfo()
    local targetPlayerRoomId = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetFriendCurrentRoomId(self.targetPlayerId)
    if ownTeamInfo and ownTeamInfo.teamId and ownTeamInfo.teamId == targetPlayerRoomId or not isFriend then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.InviteTeam):SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.InviteTeam):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if data.bJoinTeam then
    local ownTeamInfo = GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetTeamInfo()
    local targetPlayerInfo = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetFriendInfoFromPlayerID(self.targetPlayerId)
    if ownTeamInfo and targetPlayerInfo and ownTeamInfo.teamId and ownTeamInfo.teamId == targetPlayerInfo.teamId then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.JoinTeam):SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.JoinTeam):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if targetPlayerInfo.socialType == FriendEnum.SocialSecretType.Private then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.JoinTeam):SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if data.bMsg then
    if isFriend then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.SendMsg):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.SendMsg):SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if data.bRemark then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.Remark):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if data.bMove then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.Move):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if data.bShield then
    if GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsShieldList(self.targetPlayerId) then
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.CancelShield):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.Shield):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if data.bReport then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.Report):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function FriendShortcutMenuPanel:ExecuteManager(behaviorIndex)
  if nil == behaviorIndex then
    return
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.PlayerInfo then
    LogDebug("FriendShortcutMenuPanel", "Look player info, playerID: %s", self.targetPlayerId)
    ViewMgr:ClosePage(self, UIPageNameDefine.FriendList)
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd, self.targetPlayerId)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.AddFriend then
    LogDebug("FriendShortcutMenuPanel", "Add friend, playerID: %s", self.targetPlayerId)
    local playerInfo = {
      playerId = self.targetPlayerId,
      nick = self.targetPlayerNick
    }
    GameFacade:SendNotification(NotificationDefines.AddFriendCmd, playerInfo)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.InviteTeam then
    LogDebug("FriendShortcutMenuPanel", "Invite player:%s to team", self.targetPlayerId)
    self.actionOnClickInviteTeam()
    GameFacade:SendNotification(NotificationDefines.InviteFriendCountdownCmd, self.targetPlayerId)
    self:SetInviteState(self.targetPlayerId, false)
    local targetPlayerInfo = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetFriendInfoFromPlayerID(self.targetPlayerId)
    if targetPlayerInfo and targetPlayerInfo.socialType and targetPlayerInfo.socialType ~= FriendEnum.SocialSecretType.Private then
      GameFacade:SendNotification(NotificationDefines.InviteFriendCmd, self.targetPlayerId)
    end
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.JoinTeam then
    LogDebug("FriendShortcutMenuPanel", "Apply to join team, targetPlayerID: %s", self.targetPlayerId)
    local targetPlayerRoomId = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetFriendCurrentRoomId(self.targetPlayerId)
    self.actionOnClickJoinTeam()
    GameFacade:RetrieveProxy(ProxyNames.RoomProxy):ReqTeamApply(targetPlayerRoomId, self.targetPlayerId)
    GameFacade:SendNotification(NotificationDefines.ReqJoinFriendCountdownCmd, self.targetPlayerId)
    self:SetJoinState(self.targetPlayerId, false)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.SendMsg then
    LogDebug("FriendShortcutMenuPanel", "Send msg to player: %s", self.targetPlayerId)
    ViewMgr:ClosePage(self, UIPageNameDefine.FriendList)
    local playerInfo = {
      playerId = self.targetPlayerId,
      playerName = self.targetPlayerNick
    }
    GameFacade:SendNotification(NotificationDefines.Chat.CreatePrivateChat, playerInfo)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.Remark then
    LogDebug("FriendShortcutMenuPanel", "Add friend remark, playerID: %s", self.targetPlayerId)
    self.actionOnClickRemark()
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.Move then
    LogDebug("FriendShortcutMenuPanel", "Move player group, playerID: %s", self.targetPlayerId)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.DeleteFriend then
    LogDebug("FriendShortcutMenuPanel", "Delete friend, playerID: %s", self.targetPlayerId)
    local deleteFriendInfo = {
      playerId = self.targetPlayerId,
      friendType = FriendEnum.FriendType.Friend,
      nick = self.targetPlayerNick
    }
    GameFacade:SendNotification(NotificationDefines.DeleteFriendCmd, deleteFriendInfo)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.Shield then
    if GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):IsFriend(self.targetPlayerId) then
      LogDebug("FriendShortcutMenuPanel", "Add shield list, playerID: %s", self.targetPlayerId)
      local shieldFriendData = {
        playerId = self.targetPlayerId,
        nick = self.targetPlayerNick
      }
      GameFacade:SendNotification(NotificationDefines.ShieldFriendCmd, shieldFriendData)
    else
      GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):AddToBlacklist(self.targetPlayerId)
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ShieldChatMsg")
      local stringMap = {
        [0] = self.targetPlayerNick
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
    end
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.CancelShield then
    LogDebug("FriendShortcutMenuPanel", "Cancel shield, playerID: %s", self.targetPlayerId)
    local unshieldData = {
      playerId = self.targetPlayerId
    }
    GameFacade:SendNotification(NotificationDefines.UnShieldFriendCmd, unshieldData)
  end
  if behaviorIndex == FriendEnum.FriendBehaviorEnum.Report then
    LogDebug("FriendShortcutMenuPanel", "Report playerID: %s", self.targetPlayerId)
    local TipoffPageParam
    if self.bIsBattleInfo then
      TipoffPageParam = {
        TargetUID = self.targetPlayerId,
        TargetName = self.targetPlayerNick,
        EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME,
        SceneType = UE4.ECyTipoffSceneType.IN_GAME
      }
    else
      TipoffPageParam = {
        TargetUID = self.targetPlayerId,
        TargetName = self.targetPlayerNick,
        EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_CHAT,
        SceneType = UE4.ECyTipoffSceneType.CHAT,
        Content = self.reportContent
      }
    end
    GameFacade:RetrieveProxy(ProxyNames.CreditProxy):OpenReportPage(TipoffPageParam)
  end
  self.actionOnExecute()
end
function FriendShortcutMenuPanel:SetInviteState(targetPlayerId, bCanInvite)
  if self.targetPlayerId and self.targetPlayerId == targetPlayerId then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.InviteTeam):SetInviteState(bCanInvite)
  end
end
function FriendShortcutMenuPanel:SetJoinState(targetPlayerId, bCanJoin)
  if self.targetPlayerId and self.targetPlayerId == targetPlayerId then
    self.behaviorButtonList:Get(FriendEnum.FriendBehaviorEnum.JoinTeam):SetJoinState(bCanJoin)
  end
end
return FriendShortcutMenuPanel
