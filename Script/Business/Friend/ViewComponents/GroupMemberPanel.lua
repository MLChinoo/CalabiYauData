local GroupMemberPanel = class("GroupMemberPanel", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local maxPlayerCount = 100
function GroupMemberPanel:ListNeededMediators()
  return {}
end
function GroupMemberPanel:InitializeLuaEvent()
  self.actionOnUpdatePlayer = LuaEvent.new(player)
  self.actionOnUncollapsed = LuaEvent.new(panel)
end
function GroupMemberPanel:Construct()
  GroupMemberPanel.super.Construct(self)
  self.players = nil
  self.playerTable = {}
  self.isCollapsed = false
  self.showOnlineStatus = false
  self.friendGroupType = FriendEnum.FriendType.None
  if self.Button_Collapsed then
    self.Button_Collapsed.OnClicked:Add(self, self.ChangeState)
  end
  if self.ListView_PlayerList then
    self.ListView_PlayerList.BP_OnItemClicked:Add(self, self.ChoosePlayer)
    self.ListView_PlayerList.BP_OnItemIsHoveredChanged:Add(self, self.PlayerHoveredChanged)
  end
end
function GroupMemberPanel:Destruct()
  if self.Button_Collapsed then
    self.Button_Collapsed.OnClicked:Remove(self, self.ChangeState)
  end
  if self.ListView_PlayerList then
    self.ListView_PlayerList.BP_OnItemClicked:Remove(self, self.ChoosePlayer)
    self.ListView_PlayerList.BP_OnItemIsHoveredChanged:Remove(self, self.PlayerHoveredChanged)
  end
  if self.players then
    for index = 1, self.players:Length() do
      UnLua.Unref(self.players:Get(index))
    end
    self.players = nil
  end
  GroupMemberPanel.super.Destruct(self)
end
function GroupMemberPanel:InitView(panelTitle, playerList, friendType, groupId)
  LogDebug("GroupMemberPanel", "Init member panel: " .. panelTitle)
  self.showOnlineStatus = (friendType == FriendEnum.FriendType.Friend or friendType == FriendEnum.FriendType.Social) and groupId ~= Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_SHIELD
  self.friendGroupType = friendType
  self.friendGroupId = groupId
  if self.Text_Title then
    self.Text_Title:SetText(panelTitle)
  end
  if self.showOnlineStatus then
    self.onlinePlayers = {}
    self.onlineCount = 0
    self.offlinePlayers = {}
    self.totalCount = 0
    for key, value in pairs(playerList) do
      if value.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_NONE and value.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and value.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
        self.onlinePlayers[key] = value
        self.onlineCount = self.onlineCount + 1
      else
        self.offlinePlayers[key] = value
      end
      self.totalCount = self.totalCount + 1
    end
    if self.ListView_PlayerList then
      self.ListView_PlayerList:ClearListItems()
      for key, value in pairs(self.onlinePlayers) do
        self.ListView_PlayerList:AddItem(self:CreateMemberItemObj(value))
      end
      for key, value in pairs(self.offlinePlayers) do
        self.ListView_PlayerList:AddItem(self:CreateMemberItemObj(value))
      end
      self.players = self.ListView_PlayerList:GetListItems()
      if self.players then
        for index = 1, self.players:Length() do
          UnLua.Ref(self.players:Get(index))
          self.playerTable[self.players:Get(index).data.playerId] = self.players:Get(index)
        end
      end
    end
  elseif self.ListView_PlayerList then
    self.ListView_PlayerList:ClearListItems()
    for key, value in pairsByKeys(playerList, function(a, b)
      return playerList[a].friendTime > playerList[b].friendTime
    end) do
      self.ListView_PlayerList:AddItem(self:CreateMemberItemObj(value))
    end
    self.players = self.ListView_PlayerList:GetListItems()
    if self.players then
      for index = 1, self.players:Length() do
        UnLua.Ref(self.players:Get(index))
        self.playerTable[self.players:Get(index).data.playerId] = self.players:Get(index)
      end
    end
  end
  self:UpdatePlayerCount()
  self:SetPanelCollapsed(true)
  if friendType == FriendEnum.FriendType.Social then
    if self.SizeBox_Platform and self.WidgetSwitcher_Platform then
      self.SizeBox_Platform:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local loginType = UE4.UPMLoginDataCenter.Get(self):GetLoginType()
      if loginType then
        if loginType == UE4.ELoginType.ELT_QQ then
          self.WidgetSwitcher_Platform:SetActiveWidgetIndex(1)
        elseif loginType == UE4.ELoginType.ELT_Wechat then
          self.WidgetSwitcher_Platform:SetActiveWidgetIndex(0)
        else
          self.SizeBox_Platform:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  elseif self.SizeBox_Platform then
    self.SizeBox_Platform:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GroupMemberPanel:SetMaxSize(friendPanelSize, groupNum)
  if self.SizeBox_Title and self.SizeBox_ListSize then
    local titleSize = self.SizeBox_Title.HeightOverride + 5
    self.SizeBox_ListSize:SetMaxDesiredHeight(friendPanelSize - titleSize * groupNum)
  end
end
function GroupMemberPanel:ChangeState()
  self:SetPanelCollapsed(not self.isCollapsed)
end
function GroupMemberPanel:SetPanelCollapsed(isCollapsed)
  self.isCollapsed = isCollapsed
  if self.ListView_PlayerList then
    self.ListView_PlayerList:SetVisibility(self.isCollapsed and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  end
  if self.Image_Arrow then
    local direction = self.isCollapsed and -1 or 1
    self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, direction))
  end
  if self.isCollapsed == false then
    self.actionOnUncollapsed(self)
    if self.ListView_PlayerList then
      self.ListView_PlayerList:RegenerateAllEntries()
      self.ListView_PlayerList:RequestRefresh()
    end
  elseif self.activeItem then
    self.activeItem.isActive = false
    self.actionOnUpdatePlayer(self.activeItem.data)
    self.activeItem = nil
  end
end
function GroupMemberPanel:CheckChosen(inPlayerId)
  if self.playerTable[inPlayerId] then
    if self.activeItem then
      if self.activeItem == self.playerTable[inPlayerId] then
        return
      end
      self.activeItem.isActive = false
      self.actionOnUpdatePlayer(self.activeItem.data)
    end
    self.activeItem = self.playerTable[inPlayerId]
    self.activeItem.isActive = true
    self.actionOnUpdatePlayer(self.activeItem.data)
    self.ListView_PlayerList:BP_ScrollItemIntoView(self.activeItem)
  else
    if self.activeItem then
      self.activeItem.isActive = false
      self.actionOnUpdatePlayer(self.activeItem.data)
    end
    self.activeItem = nil
  end
end
function GroupMemberPanel:ChoosePlayer(item)
  if item then
    LogDebug("GroupMemberPanel", "Choose player: " .. item.data.nick)
    item.isActive = not item.isActive
    self.actionOnUpdatePlayer(item.data)
    if item.isActive then
      if self.activeItem then
        self.activeItem.isActive = false
        self.actionOnUpdatePlayer(self.activeItem.data)
      end
      self.activeItem = item
    else
      self.activeItem = nil
    end
    self.ListView_PlayerList:RequestRefresh()
  end
end
function GroupMemberPanel:PlayerHoveredChanged(item, isHovered)
  if item then
    item.isHovered = isHovered
    self.actionOnUpdatePlayer(item.data)
  end
end
function GroupMemberPanel:UpdatePlayerInfo(inPlayer)
  local isOnline = inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE
  if isOnline and self.offlinePlayers[inPlayer.playerId] then
    self.offlinePlayers[inPlayer.playerId] = nil
    self.onlinePlayers[inPlayer.playerId] = inPlayer
    self.onlineCount = self.onlineCount + 1
    if self.playerTable[inPlayer.playerId] then
      self.playerTable[inPlayer.playerId].data = inPlayer
      self:UpdatePlayerLoc(inPlayer.playerId, self.onlineCount)
    end
    self:UpdatePlayerCount()
    return
  end
  if false == isOnline and self.onlinePlayers[inPlayer.playerId] then
    self.onlinePlayers[inPlayer.playerId] = nil
    self.offlinePlayers[inPlayer.playerId] = inPlayer
    self.onlineCount = self.onlineCount - 1
    if self.playerTable[inPlayer.playerId] then
      self.playerTable[inPlayer.playerId].data = inPlayer
      self:UpdatePlayerLoc(inPlayer.playerId, self.onlineCount + 1)
    end
    self:UpdatePlayerCount()
    return
  end
  self.actionOnUpdatePlayer(inPlayer)
end
function GroupMemberPanel:UpdatePlayerLoc(inPlayerId, locationAtList)
  if self.ListView_PlayerList then
    for index = 1, self.players:Length() do
      if self.players:Get(index).data.playerId == inPlayerId then
        if index == locationAtList then
          return
        end
        local item = self.players:Get(index)
        self.players:RemoveItem(item)
        if 0 == locationAtList then
          self.players:Add(item)
        else
          self.players:Insert(item, locationAtList)
        end
        self.ListView_PlayerList:BP_SetListItems(self.players)
        break
      end
    end
    self.actionOnUpdatePlayer()
    self.ListView_PlayerList:RegenerateAllEntries()
  end
end
function GroupMemberPanel:ChangePlayer(player)
  local isAdd = false
  if player.friendType == FriendEnum.FriendType.Friend and player.groupId == self.friendGroupId then
    isAdd = true
  end
  if player.friendType ~= FriendEnum.FriendType.Friend and player.friendType == self.friendGroupType then
    isAdd = true
  end
  if isAdd then
    self:AddPlayer(player)
  else
    self:DeletePlayer(player.playerId)
  end
end
function GroupMemberPanel:AddPlayer(inPlayer)
  LogDebug("GroupMemberPanel", "Add player: " .. inPlayer.playerId)
  if self.ListView_PlayerList then
    if self.playerTable and self.playerTable[inPlayer.playerId] then
      if not self.showOnlineStatus then
        self:UpdatePlayerLoc(inPlayer.playerId, 1)
      else
        self.actionOnUpdatePlayer(inPlayer)
      end
      return
    end
    local itemObj = self:CreateMemberItemObj(inPlayer)
    self.playerTable[inPlayer.playerId] = itemObj
    if self.showOnlineStatus then
      UnLua.Ref(itemObj)
      self.players:Insert(itemObj, self.onlineCount + 1)
      if inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
        self.onlinePlayers[inPlayer.playerId] = inPlayer
        self.onlineCount = self.onlineCount + 1
      else
        self.offlinePlayers[inPlayer.playerId] = inPlayer
      end
      self.ListView_PlayerList:BP_SetListItems(self.players)
      self.totalCount = self.totalCount + 1
      self:UpdatePlayerCount()
    else
      self.players:Insert(itemObj, 1)
      if table.count(self.playerTable) > maxPlayerCount then
        local bottomItem = self.players:Get(table.count(self.playerTable))
        local bottomPlayerId = bottomItem.data.playerId
        self.players:removeItem(bottomItem)
        UnLua.Unref(bottomItem)
        if self.playerTable[bottomPlayerId] then
          self.playerTable[bottomPlayerId] = nil
        end
      end
      self.ListView_PlayerList:BP_SetListItems(self.players)
    end
    self.actionOnUpdatePlayer()
  end
  self:UpdatePlayerCount()
end
function GroupMemberPanel:DeletePlayer(inPlayerId)
  LogDebug("GroupMemberPanel", "Delete player: " .. inPlayerId)
  if self.ListView_PlayerList then
    local playerName = ""
    if self.playerTable and self.playerTable[inPlayerId] then
      playerName = self.playerTable[inPlayerId].data.nick
      self.players:RemoveItem(self.playerTable[inPlayerId])
      self.playerTable[inPlayerId] = nil
      self.ListView_PlayerList:BP_SetListItems(self.players)
      if self.onlinePlayers and self.onlinePlayers[inPlayerId] then
        self.onlinePlayers[inPlayerId] = nil
        self.onlineCount = self.onlineCount - 1
      end
      if self.offlinePlayers and self.offlinePlayers[inPlayerId] then
        self.offlinePlayers[inPlayerId] = nil
      end
      if self.showOnlineStatus then
        self.totalCount = self.totalCount - 1
      end
      self:UpdatePlayerCount()
      self.actionOnUpdatePlayer()
      if self.friendGroupType == FriendEnum.FriendType.Blacklist then
        local arg1 = UE4.FFormatArgumentData()
        arg1.ArgumentName = "0"
        arg1.ArgumentValue = playerName
        arg1.ArgumentValueType = 4
        local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
        inArgsTarry:Add(arg1)
        local textAddNtf = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "PlayerRemoveFromBlackList")
        textAddNtf = UE4.UKismetTextLibrary.Format(textAddNtf, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, textAddNtf)
      end
    end
  end
end
function GroupMemberPanel:UpdatePlayerCount()
  if self.showOnlineStatus then
    LogDebug("GroupMemberPanel", "Player count: %d, online: %d", self.totalCount, self.onlineCount)
    if self.Text_PlayerCount then
      self.Text_PlayerCount:SetText(string.format("(%d/%d)", self.onlineCount, self.totalCount))
    end
  elseif self.Text_PlayerCount then
    self.Text_PlayerCount:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ListView_PlayerList then
    self.ListView_PlayerList:RegenerateAllEntries()
  end
  if self.RedDot_New then
    if self.friendGroupType == FriendEnum.FriendType.Apply and table.count(self.playerTable) > 0 then
      self.RedDot_New:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.RedDot_New:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GroupMemberPanel:SearchPlayer(inText)
  if self.ListView_PlayerList and self.players and self.TempItems then
    if nil == inText or "" == inText then
      self.ListView_PlayerList:BP_SetListItems(self.players)
    else
      self.TempItems:Clear()
      for i = 1, self.players:Length() do
        if self.players:Get(i).data then
          local playerName = self.players:Get(i).data.nick
          if UE4.UKismetStringLibrary.Contains(playerName, inText, false, false) then
            self.TempItems:Add(self.players:Get(i))
          end
        end
      end
      self.ListView_PlayerList:BP_SetListItems(self.TempItems)
    end
    self.ListView_PlayerList:RequestRefresh()
  end
end
function GroupMemberPanel:CreateMemberItemObj(player)
  local itemObj = ObjectUtil:CreateLuaUObject(self)
  itemObj.data = player
  itemObj.isActive = false
  itemObj.isHovered = false
  itemObj.bShowPlatform = self.friendGroupType == FriendEnum.FriendType.Friend and player.friendType == FriendEnum.FriendType.Social and GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy).bShowPlatformFriend
  itemObj.parent = self
  return itemObj
end
return GroupMemberPanel
