local MemberPanelMobile = class("MemberPanelMobile", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local maxPlayerCount = 100
function MemberPanelMobile:ListNeededMediators()
  return {}
end
function MemberPanelMobile:InitializeLuaEvent()
  self.actionOnUpdatePlayer = LuaEvent.new(player)
  self.actionOnDeletePlayer = LuaEvent.new(chatName)
  self.actionOnChoosePlayer = LuaEvent.new(chatName)
  self.actionOnSearchPlayer = LuaEvent.new(text)
  self.actionOnUncollapsed = LuaEvent.new(panel)
end
function MemberPanelMobile:Construct()
  MemberPanelMobile.super.Construct(self)
  self.playerTable = {}
  self.hasActivePlayer = false
  self.isCollapsed = false
  self.newMsgPlayerCnt = 0
  if self.Button_Collapsed then
    self.Button_Collapsed.OnClicked:Add(self, self.ChangeState)
  end
end
function MemberPanelMobile:Destruct()
  if self.Button_Collapsed then
    self.Button_Collapsed.OnClicked:Remove(self, self.ChangeState)
  end
  MemberPanelMobile.super.Destruct(self)
end
function MemberPanelMobile:InitView(panelTitle, playerList, isFriend)
  LogDebug("MemberPanelMobile", "Init member panel: " .. panelTitle)
  self.showOnlineStatus = isFriend
  if self.Text_Title then
    self.Text_Title:SetText(panelTitle)
  end
  if self.RedDot_NewMsg then
    self.RedDot_NewMsg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if isFriend then
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
      self.ListView_PlayerList.BP_OnItemClicked:Add(self, self.ChoosePlayer)
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
          self.playerTable[self.players:Get(index).data.playerId] = self.players:Get(index)
        end
      end
    end
  elseif self.ListView_PlayerList then
    self.ListView_PlayerList.BP_OnItemClicked:Add(self, self.ChoosePlayer)
    self.ListView_PlayerList:ClearListItems()
    for key, value in pairs(playerList) do
      self.ListView_PlayerList:AddItem(self:CreateMemberItemObj(value))
    end
    self.players = self.ListView_PlayerList:GetListItems()
    if self.players then
      for index = 1, self.players:Length() do
        self.playerTable[self.players:Get(index).data.playerId] = self.players:Get(index)
      end
    end
  end
  self:UpdatePlayerCount()
end
function MemberPanelMobile:ChangeState()
  self:SetPanelCollapsed(not self.isCollapsed)
end
function MemberPanelMobile:SetPanelCollapsed(isCollapsed)
  self.isCollapsed = isCollapsed
  if self.ListView_PlayerList then
    self.ListView_PlayerList:SetVisibility(self.isCollapsed and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  end
  if self.Image_Arrow then
    local direction = self.isCollapsed and 1 or -1
    self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, direction))
  end
  if self.isCollapsed == false then
    self.actionOnUncollapsed(self)
  end
end
function MemberPanelMobile:CheckChosen(inPlayerId)
  if self.playerTable[inPlayerId] then
    if self.activeItem then
      if self.activeItem == self.playerTable[inPlayerId] then
        return
      end
      self.activeItem.isActive = false
      self.actionOnUpdatePlayer(self.activeItem.data)
    end
    self.activeItem = self.playerTable[inPlayerId]
    self.hasActivePlayer = true
    self.activeItem.isActive = true
    self.actionOnUpdatePlayer(self.activeItem.data)
    self.ListView_PlayerList:BP_ScrollItemIntoView(self.activeItem)
  else
    if self.activeItem then
      self.activeItem.isActive = false
      self.actionOnUpdatePlayer(self.activeItem.data)
    end
    self.activeItem = nil
    self.hasActivePlayer = false
  end
end
function MemberPanelMobile:ChoosePlayer(item)
  if item then
    LogDebug("MemberPanelMobile", "Choose player: " .. item.data.nick)
    item.isActive = true
    if item.hasMsg then
      item.hasMsg = false
      self:ChangeNewMsgPlayerCnt(-1)
    end
    self.actionOnUpdatePlayer(item.data)
    self.actionOnChoosePlayer(item.data.nick, item.data.playerId)
  end
end
function MemberPanelMobile:ReceiveNewMsg(playerID, msgInfo)
  if self.ListView_PlayerList then
    if self.playerTable[playerID] == nil then
      local newPlayer = {
        playerId = msgInfo.chatId,
        nick = msgInfo.chatNick,
        icon = msgInfo.chatIcon
      }
      self:AddPlayer(newPlayer)
    end
    if self.playerTable[playerID].hasMsg == false and false == self.playerTable[playerID].isActive and not msgInfo.msgTime then
      self.playerTable[playerID].hasMsg = true
      self:ChangeNewMsgPlayerCnt(1)
    end
    if self.offlinePlayers and self.offlinePlayers[playerID] then
      self:UpdatePlayerLoc(playerID, self.onlineCount + 1)
    else
      self:UpdatePlayerLoc(playerID, 1)
    end
    self.actionOnUpdatePlayer()
  end
end
function MemberPanelMobile:UpdatePlayerInfo(inPlayer)
  local isOnline = inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_NONE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE
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
function MemberPanelMobile:UpdatePlayerLoc(inPlayerId, locationAtList)
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
  end
end
function MemberPanelMobile:AddPlayer(inPlayer)
  LogDebug("MemberPanelMobile", "Add player: " .. inPlayer.playerId)
  if self.ListView_PlayerList then
    if self.playerTable and self.playerTable[inPlayer.playerId] then
      self:UpdatePlayerLoc(inPlayer.playerId, 1)
      return
    end
    local itemObj = self:CreateMemberItemObj(inPlayer)
    self.playerTable[inPlayer.playerId] = itemObj
    if self.showOnlineStatus then
      self.players:Insert(itemObj, self.onlineCount + 1)
      if inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_NONE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and inPlayer.onlineStatus ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
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
        self.actionOnDeletePlayer(bottomItem.data.nick)
        self.players:removeItem(bottomItem)
        if self.playerTable[bottomPlayerId] then
          self.playerTable[bottomPlayerId] = nil
        end
      end
      self.ListView_PlayerList:BP_SetListItems(self.players)
    end
    self.actionOnUpdatePlayer()
  end
end
function MemberPanelMobile:DeletePlayer(inPlayerId)
  LogDebug("MemberPanelMobile", "Delete player: " .. inPlayerId)
  if self.ListView_PlayerList then
    local playerName = ""
    if self.playerTable and self.playerTable[inPlayerId] then
      playerName = self.playerTable[inPlayerId].data.nick
      self.players:RemoveItem(self.playerTable[inPlayerId])
      if self.playerTable[inPlayerId].isActive == true then
        self.playerTable[inPlayerId] = nil
        self.actionOnChoosePlayer()
      end
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
      self.actionOnDeletePlayer(playerName)
    end
  end
end
function MemberPanelMobile:UpdatePlayerCount()
  if self.showOnlineStatus then
    LogDebug("MemberPanelMobile", "Player count: %d, online: %d", self.totalCount, self.onlineCount)
    if self.Text_PlayerCount then
      self.Text_PlayerCount:SetText(string.format("（%d/%d）", self.onlineCount, self.totalCount))
    end
  elseif self.Text_PlayerCount then
    self.Text_PlayerCount:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function MemberPanelMobile:SearchPlayer(inText)
  self.actionOnSearchPlayer(inText)
end
function MemberPanelMobile:CreateMemberItemObj(player)
  local playerInfoNeed = {
    playerId = player.playerId,
    nick = player.nick,
    icon = player.icon,
    rank = player.rank,
    status = self.showOnlineStatus and player.onlineStatus or nil
  }
  local itemObj = ObjectUtil:CreateLuaUObject(self)
  itemObj.data = playerInfoNeed
  itemObj.hasMsg = false
  itemObj.isActive = false
  itemObj.parent = self
  return itemObj
end
function MemberPanelMobile:UpdateRedDotPlayerList(visibility)
  if self.RedDot_NewMsg then
    self.RedDot_NewMsg:SetVisibility(visibility)
  end
end
function MemberPanelMobile:ChangeNewMsgPlayerCnt(cnt)
  if self.showOnlineStatus then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.ChatPFriend, cnt)
  else
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.ChatPNearest, cnt)
  end
end
return MemberPanelMobile
