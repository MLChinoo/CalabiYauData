local RoomContextMenuPanelMobile = class("RoomContextMenuPanelMobile", PureMVC.ViewComponentPanel)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
function RoomContextMenuPanelMobile:ListNeededMediators()
  return {}
end
function RoomContextMenuPanelMobile:InitializeLuaEvent()
  self.rankCard = nil
end
function RoomContextMenuPanelMobile:Construct()
  RoomContextMenuPanelMobile.super.Construct(self)
  local bShowPlayerInfo = false
  if self.ContextButton_PlayerInfo then
    self.ContextButton_PlayerInfo.OnClicked:Add(self, function()
      self:OnClickPlayerInfo()
    end)
    self.ContextButton_PlayerInfo.OnHovered:Add(self, function()
      self:OnHoveredContextPlayerInfo()
    end)
    self.ContextButton_PlayerInfo.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextPlayerInfo()
    end)
  end
  if self.ContextButton_SendMsg then
    self.ContextButton_SendMsg.OnClicked:Add(self, function()
      self:OnClickSendMsg()
    end)
    self.ContextButton_SendMsg.OnHovered:Add(self, function()
      self:OnHoveredContextSendMsg()
    end)
    self.ContextButton_SendMsg.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextSendMsg()
    end)
  end
  if self.ContextButton_AddFriend then
    self.ContextButton_AddFriend.OnClicked:Add(self, function()
      self:OnClickAddFriend()
    end)
    self.ContextButton_AddFriend.OnHovered:Add(self, function()
      self:OnHoveredContextAddFriend()
    end)
    self.ContextButton_AddFriend.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextAddFriend()
    end)
  end
  if self.ContextButton_Switch then
    self.ContextButton_Switch.OnClicked:Add(self, function()
      self:OnClickSwitch()
    end)
    self.ContextButton_Switch.OnHovered:Add(self, function()
      self:OnHoveredContextSwitch()
    end)
    self.ContextButton_Switch.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextSwitch()
    end)
  end
  if self.ContextButton_Kick then
    self.ContextButton_Kick.OnClicked:Add(self, function()
      self:OnClickKick()
    end)
    self.ContextButton_Kick.OnHovered:Add(self, function()
      self:OnHoveredContextKick()
    end)
    self.ContextButton_Kick.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextKick()
    end)
  end
  if self.ContextButton_TransLeader then
    self.ContextButton_TransLeader.OnClicked:Add(self, function()
      self:OnClickTransLeader()
    end)
    self.ContextButton_TransLeader.OnHovered:Add(self, function()
      self:OnHoveredContextTransLeader()
    end)
    self.ContextButton_TransLeader.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextTransLeader()
    end)
  end
  if self.ContextButton_Black then
    self.ContextButton_Black.OnClicked:Add(self, function()
      self:OnClickBlack()
    end)
    self.ContextButton_Black.OnHovered:Add(self, function()
      self:OnHoveredContextBlack()
    end)
    self.ContextButton_Black.OnUnhovered:Add(self, function()
      self:OnUnhoveredContextBlack()
    end)
  end
end
function RoomContextMenuPanelMobile:Destruct()
  RoomContextMenuPanelMobile.super.Destruct(self)
  if self.ContextButton_PlayerInfo then
    self.ContextButton_PlayerInfo.OnClicked:Remove(self, self.OnClickPlayerInfo)
    self.ContextButton_PlayerInfo.OnHovered:Remove(self, self.OnHoveredContextPlayerInfo)
    self.ContextButton_PlayerInfo.OnUnhovered:Remove(self, self.OnUnhoveredContextPlayerInfo)
  end
  if self.ContextButton_SendMsg then
    self.ContextButton_SendMsg.OnClicked:Remove(self, self.OnClickSendMsg)
    self.ContextButton_SendMsg.OnHovered:Remove(self, self.OnHoveredContextSendMsg)
    self.ContextButton_SendMsg.OnUnhovered:Remove(self, self.OnUnhoveredContextSendMsg)
  end
  if self.ContextButton_AddFriend then
    self.ContextButton_AddFriend.OnClicked:Remove(self, self.OnClickAddFriend)
    self.ContextButton_AddFriend.OnHovered:Remove(self, self.OnHoveredContextAddFriend)
    self.ContextButton_AddFriend.OnUnhovered:Remove(self, self.OnUnhoveredContextAddFriend)
  end
  if self.ContextButton_Switch then
    self.ContextButton_Switch.OnClicked:Remove(self, self.OnClickSwitch)
    self.ContextButton_Switch.OnHovered:Remove(self, self.OnHoveredContextSwitch)
    self.ContextButton_Switch.OnUnhovered:Remove(self, self.OnUnhoveredContextSwitch)
  end
  if self.ContextButton_Kick then
    self.ContextButton_Kick.OnClicked:Remove(self, self.OnClickKick)
    self.ContextButton_Kick.OnHovered:Remove(self, self.OnHoveredContextKick)
    self.ContextButton_Kick.OnUnhovered:Remove(self, self.OnUnhoveredContextKick)
  end
  if self.ContextButton_TransLeader then
    self.ContextButton_TransLeader.OnClicked:Remove(self, self.OnClickTransLeader)
    self.ContextButton_TransLeader.OnHovered:Remove(self, self.OnHoveredContextTransLeader)
    self.ContextButton_TransLeader.OnUnhovered:Remove(self, self.OnUnhoveredContextTransLeader)
  end
  if self.ContextButton_Black then
    self.ContextButton_Black.OnClicked:Remove(self, self.OnClickBlack)
    self.ContextButton_Black.OnHovered:Remove(self, self.OnHoveredContextBlack)
    self.ContextButton_Black.OnUnhovered:Remove(self, self.OnUnhoveredContextBlack)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextPlayerInfo()
  if self.Text_1 then
    self.Text_1:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextPlayerInfo()
  if self.Text_1 then
    self.Text_1:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextSendMsg()
  if self.Text_2 then
    self.Text_2:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextSendMsg()
  if self.Text_2 then
    self.Text_2:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextAddFriend()
  if self.Text_3 then
    self.Text_3:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextAddFriend()
  if self.Text_3 then
    self.Text_3:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextSwitch()
  if self.Text_7 then
    self.Text_7:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextSwitch()
  if self.Text_7 then
    self.Text_7:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextKick()
  if self.Text_4 then
    self.Text_4:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextKick()
  if self.Text_4 then
    self.Text_4:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextTransLeader()
  if self.Text_5 then
    self.Text_5:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextTransLeader()
  if self.Text_5 then
    self.Text_5:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnHoveredContextBlack()
  if self.Text_6 then
    self.Text_6:SetColorAndOpacity(self.bp_hoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnUnhoveredContextBlack()
  if self.Text_6 then
    self.Text_6:SetColorAndOpacity(self.bp_unHoverTextSlatColor)
  end
end
function RoomContextMenuPanelMobile:OnClickSendMsg()
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
function RoomContextMenuPanelMobile:OnClickPlayerInfo()
  if self.ContextMenuData and self.ContextMenuData.playerInfo then
    local playerId = self.ContextMenuData.playerInfo.playerId
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendProfilePage, false, playerId)
  else
    LogInfo("ContextMenuPanel playerInfo is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RoomContextMenuPanelMobile:OnClickBlack()
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
function RoomContextMenuPanelMobile:OnClickTransLeader()
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
function RoomContextMenuPanelMobile:OnTransLeaderReturn(bFirstBtn)
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
function RoomContextMenuPanelMobile:OnClickKick()
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
function RoomContextMenuPanelMobile:OnClickSwitch()
  if roomDataProxy then
    if self.ContextMenuData and self.ContextMenuData.playerInfo then
      local playerId = self.ContextMenuData.playerInfo.playerId
      local position = self.ContextMenuData.playerInfo.position
      local roomId = self.ContextMenuData.playerInfo.roomId
      if playerId and position and roomId then
        if roomDataProxy:GetPlayerID() then
          if roomDataProxy:GetPlayerID() ~= playerId then
            roomDataProxy:ReqRoomSwitch(roomId, position, 0, 0)
          else
            LogInfo("ContextMenuPanel switch target is self.")
          end
        else
          LogInfo("ContextMenuPanel roomDataProxy:getPlayerID() is invalid.")
        end
      else
        LogInfo("ContextMenuPanel playerId is invalid.")
      end
    else
      LogInfo("ContextMenuPanel playerInfo is invalid.")
    end
  else
    LogInfo("roomDataProxy is invalid.")
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RoomContextMenuPanelMobile:OnClickAddFriend()
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
function RoomContextMenuPanelMobile:SetContextMenuType(inType, initData)
  self.SizeBox_All:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if initData then
    self.ContextMenuData = initData
    if self.SizeBox_All then
      self.SizeBox_All:SetWidthOverride(155)
    end
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
    LogInfo("ContextMenuPanel initData is invalid.")
  end
end
function RoomContextMenuPanelMobile:InitContextMenuButton(inType)
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
  self.Border_Background:SetVisibility(UE4.ESlateVisibility.Visible)
  self:ShowPlayerInfo()
  local collapseSizeBoxArr = {}
  if self.ContextButton_PlayerInfo and not self.bShowPlayerInfo then
    table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
  end
  if inType == CardEnum.RankContextType.LeaderSelf then
    if self.ContextButton_PlayerInfo then
      table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
    end
    if self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
    if self.ContextButton_AddFriend then
      table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
    end
    if self.ContextButton_Kick then
      table.insert(collapseSizeBoxArr, self.ContextButton_Kick:GetParent())
    end
    if self.ContextButton_TransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if self.ContextButton_Black then
      table.insert(collapseSizeBoxArr, self.ContextButton_Black:GetParent())
    end
    if self.ContextButton_Switch then
      table.insert(collapseSizeBoxArr, self.ContextButton_Switch:GetParent())
    end
  elseif inType == CardEnum.RankContextType.LeaderOther then
    if bIsFriend then
      if self.ContextButton_AddFriend then
        table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
      end
    elseif self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
  elseif inType == CardEnum.RankContextType.MemberSelf then
    if self.ContextButton_PlayerInfo then
      table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
    end
    if self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
    if self.ContextButton_AddFriend then
      table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
    end
    if self.ContextButton_Kick then
      table.insert(collapseSizeBoxArr, self.ContextButton_Kick:GetParent())
    end
    if self.ContextButton_TransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if self.ContextButton_Black then
      table.insert(collapseSizeBoxArr, self.ContextButton_Black:GetParent())
    end
    if self.ContextButton_Switch then
      table.insert(collapseSizeBoxArr, self.ContextButton_Switch:GetParent())
    end
  elseif inType == CardEnum.RankContextType.MemberOther then
    if self.ContextButton_Kick then
      table.insert(collapseSizeBoxArr, self.ContextButton_Kick:GetParent())
    end
    if self.ContextButton_TransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if bIsFriend then
      if self.ContextButton_AddFriend then
        table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
      end
    elseif self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
  elseif inType == CardEnum.RankContextType.LeaderRobot then
    if self.ContextButton_PlayerInfo then
      table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
    end
    if self.ContextButton_TransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if self.ContextButton_AddFriend then
      table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
    end
    if self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
    if self.ContextButton_Black then
      table.insert(collapseSizeBoxArr, self.ContextButton_Black:GetParent())
    end
  elseif inType == CardEnum.RankContextType.MemberRobot then
    if self.ContextButton_PlayerInfo then
      table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
    end
    if self.ContextButton_TransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if self.ContextButton_AddFriend then
      table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
    end
    if self.ContextButton_SendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
    if self.ContextButton_Black then
      table.insert(collapseSizeBoxArr, self.ContextButton_Black:GetParent())
    end
    if self.ContextButton_Kick then
      table.insert(collapseSizeBoxArr, self.ContextButton_Kick:GetParent())
    end
  end
  if self.ContextMenuData.cardType and self.ContextMenuData.cardType == CardEnum.GameModeType.Matching and self.ContextButton_Switch then
    table.insert(collapseSizeBoxArr, self.ContextButton_Switch:GetParent())
  end
  for key, value in pairs(collapseSizeBoxArr) do
    if value then
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RoomContextMenuPanelMobile:InitContextMenu(initData)
  if initData then
    self.ContextMenuData = initData
    local collapseSizeBoxArr = {}
    if initData.bShowPlayerInfo then
      table.insert(collapseSizeBoxArr, self.ContextButton_PlayerInfo:GetParent())
    end
    if initData.bSendMsg then
      table.insert(collapseSizeBoxArr, self.ContextButton_SendMsg:GetParent())
    end
    if initData.bAddFriend then
      table.insert(collapseSizeBoxArr, self.ContextButton_AddFriend:GetParent())
    end
    if initData.bKick then
      table.insert(collapseSizeBoxArr, self.ContextButton_Kick:GetParent())
    end
    if initData.bTransLeader then
      table.insert(collapseSizeBoxArr, self.ContextButton_TransLeader:GetParent())
    end
    if initData.bBlack then
      table.insert(collapseSizeBoxArr, self.ContextButton_Black:GetParent())
    end
    if initData.bSwitch then
      table.insert(collapseSizeBoxArr, self.ContextButton_Switch:GetParent())
    end
    for key, value in pairs(collapseSizeBoxArr) do
      if value then
        value:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    LogInfo("ContextMenuPanel initData is invalid.")
  end
end
function RoomContextMenuPanelMobile:ShowPlayerInfo()
  local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(self.ContextMenuData.playerInfo.stars)
  local rankLevelName = divisionCfg.Name
  self.Txt_playerName:SetText(self.ContextMenuData.playerInfo.nick)
  self.Txt_playerLevel:SetText(rankLevelName)
  self:SetImageByPaperSprite(self.Img_playerLevel, divisionCfg.IconDivisions)
end
return RoomContextMenuPanelMobile
