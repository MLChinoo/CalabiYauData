local RankContextMenuPanel = class("RankContextMenuPanel", PureMVC.ViewComponentPanel)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
function RankContextMenuPanel:ListNeededMediators()
  return {}
end
function RankContextMenuPanel:InitializeLuaEvent()
  self.rankCard = nil
end
function RankContextMenuPanel:Construct()
  RankContextMenuPanel.super.Construct(self)
  self.ContextButton_PlayerInfo.OnClicked:Add(self, function()
    self:OnClickPlayerInfo()
  end)
  self.ContextButton_SendMsg.OnClicked:Add(self, function()
    self:OnClickSendMsg()
  end)
  self.ContextButton_AddFriend.OnClicked:Add(self, function()
    self:OnClickAddFriend()
  end)
  self.ContextButton_Switch.OnClicked:Add(self, function()
    self:OnClickSwitch()
  end)
  self.ContextButton_Kick.OnClicked:Add(self, function()
    self:OnClickKick()
  end)
  self.ContextButton_TransLeader.OnClicked:Add(self, function()
    self:OnClickTransLeader()
  end)
  self.ContextButton_Black.OnClicked:Add(self, function()
    self:OnClickBlack()
  end)
end
function RankContextMenuPanel:Destruct()
  RankContextMenuPanel.super.Destruct(self)
  self.ContextButton_PlayerInfo.OnClicked:Remove(self, self.OnClickPlayerInfo)
  self.ContextButton_SendMsg.OnClicked:Remove(self, self.OnClickSendMsg)
  self.ContextButton_AddFriend.OnClicked:Remove(self, self.OnClickAddFriend)
  self.ContextButton_Switch.OnClicked:Remove(self, self.OnClickSwitch)
  self.ContextButton_Kick.OnClicked:Remove(self, self.OnClickKick)
  self.ContextButton_TransLeader.OnClicked:Remove(self, self.OnClickTransLeader)
  self.ContextButton_Black.OnClicked:Remove(self, self.OnClickBlack)
end
function RankContextMenuPanel:OnClickSendMsg()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    local nick = self.ContextMenuData.playerInfo.nick
    if playerId and nick then
      local privateChatMsg = {}
      privateChatMsg.playerId = playerId
      privateChatMsg.playerName = nick
      GameFacade:SendNotification(NotificationDefines.Chat.CreatePrivateChat, privateChatMsg)
    else
      LogInfo("ContextMenuPanel playerId or nick is invalid.")
    end
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickPlayerInfo()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd, playerId)
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickBlack()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    local nick = self.ContextMenuData.playerInfo.nick
    if playerId and nick then
      local blackFriendData = {}
      blackFriendData.playerId = playerId
      blackFriendData.nick = nick
      GameFacade:SendNotification(NotificationDefines.ShieldFriendCmd, blackFriendData)
    else
      LogInfo("ContextMenuPanel playerId or nick is invalid.")
    end
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickTransLeader()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local bIsRobot = self.ContextMenuData.playerInfo.bIsRobot
    local nick = self.ContextMenuData.playerInfo.nick
    if not bIsRobot then
      local infoString = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TransLeader_Card")
      local arg1 = UE4.FFormatArgumentData()
      arg1.ArgumentName = "PlayerName"
      arg1.ArgumentValue = nick
      arg1.ArgumentValueType = 4
      local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
      inArgsTarry:Add(arg1)
      local tempText = UE4.UKismetTextLibrary.Format(infoString, inArgsTarry)
      local pageData = {}
      pageData.contentTxt = tempText
      pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsConfirmText")
      pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsBackText")
      pageData.source = self
      pageData.cb = self.OnTransLeaderReturn
      ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
    else
      LogInfo("ContextMenuPanel cant transleader to robot.")
    end
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnTransLeaderReturn(bFirstBtn)
  if bFirstBtn then
    if self.ContextMenuData and self.ContextMenuData.playerInfo then
      local playerId = self.ContextMenuData.playerInfo.playerId
      local roomId = self.ContextMenuData.playerInfo.roomId
      local contextMenuType = self.ContextMenuData.playerInfo.contextMenuType
      if playerId and roomId and contextMenuType then
        if roomDataProxy then
          if 0 == contextMenuType then
            roomDataProxy:ReqTeamTransLeader(roomId, playerId)
          elseif 1 == contextMenuType then
            roomDataProxy:ReqTransLeader(roomId, playerId)
          end
        else
          LogInfo("roomDataProxy is invalid.")
        end
      else
        LogInfo("ContextMenuPanel playerId is invalid.")
      end
    else
      LogInfo("ContextMenuPanel playerInfo is invalid.")
    end
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickKick()
  if roomDataProxy and not roomDataProxy.bLockEditRoomInfo then
    if self.ContextMenuData and self.ContextMenuData.playerInfo then
      local playerId = self.ContextMenuData.playerInfo.playerId
      local roomId = self.ContextMenuData.playerInfo.roomId
      local contextMenuType = self.ContextMenuData.playerInfo.contextMenuType
      if playerId and roomId and contextMenuType then
        if 0 == contextMenuType then
          roomDataProxy:ReqTeamKick(roomId, playerId)
        elseif 1 == contextMenuType then
          roomDataProxy:ReqRoomKick(roomId, playerId)
        end
      else
        LogInfo("ContextMenuPanel playerId is invalid.")
      end
    else
      LogInfo("ContextMenuPanel playerInfo is invalid.")
    end
  else
    LogInfo("roomDataProxy bLockEditRoomInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickSwitch()
  if roomDataProxy then
    if self.ContextMenuData and self.ContextMenuData.playerInfo then
      local position = self.ContextMenuData.playerInfo.position
      local roomId = self.ContextMenuData.playerInfo.roomId
      if position and roomId then
        roomDataProxy:ReqRoomSwitch(roomId, position, 0, 0)
      else
        LogInfo("ContextMenuPanel position or roomId is invalid.")
      end
    else
      LogInfo("ContextMenuPanel playerInfo is invalid.")
    end
  else
    LogInfo("roomDataProxy is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:OnClickAddFriend()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    local nick = self.ContextMenuData.playerInfo.nick
    if playerId and nick then
      local addFriendData = {}
      addFriendData.playerId = playerId
      addFriendData.nick = nick
      GameFacade:SendNotification(NotificationDefines.AddFriendCmd, addFriendData)
    else
      LogInfo("ContextMenuPanel playerId or nick is invalid.")
    end
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankContextMenuPanel:SetContextMenuType(inType, initData)
  self.SizeBox_All:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if initData then
    self.ContextMenuData = initData
    if self.SizeBox_All then
      self.SizeBox_All:SetWidthOverride(155)
    end
    if self.ContextMenuData.playerInfo.playerId then
      local playerId = self.ContextMenuData.playerInfo.playerId
      local SettingCacheProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCacheProxy)
      SettingCacheProxy:GetValueByPlayerId(playerId, function()
        local cache = SettingCacheProxy:GetCacheByPlayerId(playerId)
        local value = cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_SECRET]
        if value then
          if 2 == value then
            self.bShowPlayerInfo = true
          else
            self.bShowPlayerInfo = false
          end
        else
          self.bShowPlayerInfo = false
        end
        TimerMgr:AddTimeTask(0.05, 0, 1, function()
          self:InitContextMenuButton(inType)
        end)
      end)
    else
      self:InitContextMenuButton(inType)
    end
  else
    LogInfo("ContextMenuPanel initData is invalid.")
  end
end
function RankContextMenuPanel:InitContextMenuButton(inType)
  self.SizeBox_All:SetVisibility(UE4.ESlateVisibility.Visible)
  local bIsFriend = false
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    if friendDataProxy and playerId and friendDataProxy.allFriendMap[playerId] then
      bIsFriend = true
    else
      LogInfo("friendDataProxy data is invalid.")
    end
  end
  if self.ContextButton_PlayerInfo and self.bShowPlayerInfo then
    self.ContextButton_PlayerInfo:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.ContextButton_Switch:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
  if inType == CardEnum.RankContextType.None then
  elseif inType == CardEnum.RankContextType.LeaderSelf then
    self.ContextButton_Switch:GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif inType == CardEnum.RankContextType.LeaderOther then
    if bIsFriend then
      self.ContextButton_SendMsg:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.ContextButton_AddFriend:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.ContextButton_Kick:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    self.ContextButton_TransLeader:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    self.ContextButton_Black:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
  elseif inType == CardEnum.RankContextType.MemberSelf then
    self.ContextButton_Switch:GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif inType == CardEnum.RankContextType.MemberOther then
    if bIsFriend then
      self.ContextButton_SendMsg:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.ContextButton_AddFriend:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif inType == CardEnum.RankContextType.LeaderRobot then
    self.ContextButton_PlayerInfo:GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ContextButton_Kick:GetParent():SetVisibility(UE4.ESlateVisibility.Visible)
  elseif inType == CardEnum.RankContextType.MemberRobot then
    self.ContextButton_PlayerInfo:GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return RankContextMenuPanel
