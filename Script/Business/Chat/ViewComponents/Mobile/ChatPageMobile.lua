local ChatPageMobile = class("ChatPageMobile", PureMVC.ViewComponentPage)
local ChatPageMediator = require("Business/Chat/Mediators/ChatPageMediator")
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function ChatPageMobile:ListNeededMediators()
  return {ChatPageMediator}
end
function ChatPageMobile:InitializeLuaEvent()
  self.actionOnShowReserveMsg = LuaEvent.new()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
  self.actionOnDeleteChat = LuaEvent.new(tabName)
end
function ChatPageMobile:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ChatPageMobile", "Lua implement OnOpen")
  RedDotTree:Bind(RedDotModuleDef.ModuleName.ChatTeam, function(cnt)
    self:UpdateRedDotTeam(cnt)
  end)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.ChatRoom, function(cnt)
    self:UpdateRedDotRoom(cnt)
  end)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.ChatPrivate, function(cnt)
    self:UpdateRedDotPrivate(cnt)
  end)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.ChatPFriend, function(cnt)
    self:UpdateRedDotFriend(cnt)
  end)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.ChatPNearest, function(cnt)
    self:UpdateRedDotNearest(cnt)
  end)
  self:InitView()
  if self.FriendPanel then
    self.FriendPanel.actionOnDeletePlayer:Add(self.DeleteChat, self)
    self.FriendPanel.actionOnChoosePlayer:Add(self.SetActiveChannel, self)
    self.FriendPanel.actionOnUncollapsed:Add(self.SetActivePlayerPanel, self)
  end
  if self.Button_EnterChat then
    self.Button_EnterChat.OnClicked:Add(self, self.OnClickEnter)
  end
  if self.Button_Send then
    self.Button_Send.OnClicked:Add(self, self.SendChatMsg)
  end
  if self.ShareBtn then
    self.ShareBtn.OnClicked:Add(self, self.ShowSharePanel)
  end
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel.OnGetMenuContentEvent:Bind(self, self.OpenSharePanel)
  end
  if self.Button_Search then
    self.Button_Search.OnClicked:Add(self, self.SearchFriend)
  end
  if self.PlayerSearch then
    self.PlayerSearch.OnTextChanged:Add(self, self.SearchContentChange)
  end
  if self.Check_World then
    self.Check_World.OnCheckStateChanged:Add(self, self.SelectWorldTab)
  end
  if self.Check_Team then
    self.Check_Team.OnCheckStateChanged:Add(self, self.SelectTeamTab)
  end
  if self.Check_Room then
    self.Check_Room.OnCheckStateChanged:Add(self, self.SelectRoomTab)
  end
  if self.Check_Friend then
    self.Check_Friend.OnCheckStateChanged:Add(self, self.SelectPrivateTab)
  end
  if self.RedDot_Main then
    self.RedDot_Main:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot_World then
    self.RedDot_World:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot_Team then
    self.RedDot_Team:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot_Room then
    self.RedDot_Room:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.RedDot_Private then
    self.RedDot_Private:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPageMobile:OnClose()
  LogDebug("ChatPageMobile", "Lua implement OnClose")
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.ChatTeam)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.ChatRoom)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.ChatPrivate)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.ChatPFriend)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.ChatPNearest)
  if self.updateHandle then
    self.updateHandle:EndTask()
    self.updateHandle = nil
  end
  if self.sendMsgCancelTask then
    self.sendMsgCancelTask:EndTask()
    self.sendMsgCancelTask = nil
  end
  if self.scrollHandle then
    self.scrollHandle:EndTask()
    self.scrollHandle = nil
  end
  if self.FriendPanel then
    self.FriendPanel.actionOnDeletePlayer:Remove(self.DeleteChat, self)
    self.FriendPanel.actionOnChoosePlayer:Remove(self.SetActiveChannel, self)
    self.FriendPanel.actionOnUncollapsed:Remove(self.SetActivePlayerPanel, self)
  end
  if self.Button_EnterChat then
    self.Button_EnterChat.OnClicked:Remove(self, self.OnClickEnter)
  end
  if self.Button_Send then
    self.Button_Send.OnClicked:Remove(self, self.SendChatMsg)
  end
  if self.Button_Search then
    self.Button_Search.OnClicked:Remove(self, self.SearchFriend)
  end
  if self.PlayerSearch then
    self.PlayerSearch.OnTextChanged:Remove(self, self.SearchContentChange)
  end
  if self.Check_World then
    self.Check_World.OnCheckStateChanged:Remove(self, self.SelectWorldTab)
  end
  if self.Check_Team then
    self.Check_Team.OnCheckStateChanged:Remove(self, self.SelectTeamTab)
  end
  if self.Check_Room then
    self.Check_Room.OnCheckStateChanged:Remove(self, self.SelectRoomTab)
  end
  if self.Check_Friend then
    self.Check_Friend.OnCheckStateChanged:Remove(self, self.SelectPrivateTab)
  end
  if self.ShareBtn then
    self.ShareBtn.OnClicked:Remove(self, self.ShowSharePanel)
  end
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel.OnGetMenuContentEvent:Unbind()
  end
end
function ChatPageMobile:InitView()
  self.panelMap = {}
  self.lastMsgTime = 0
  self.isSendingMsg = false
  self.sendMsgCancelTask = nil
  self.updateHandle = nil
  self.scrollHandle = nil
  self.worldMsgTimeLimit = 0
  self.worldMsgQueue = {}
  self.worldChatCoolDown = 0
  self.chatId = 0
  if self.ChannelMsgPanelClass then
    self.msgPanelClass = ObjectUtil:LoadClass(self.ChannelMsgPanelClass)
    if nil == self.msgPanelClass then
      LogDebug("ChatPageMobile", "Chat msg panel class load failed")
    end
  end
  self.msgRecord = {}
  self.msgPanels = {}
  if self.ChatTextPanelClass and self.ScrollBox_OutContent then
    self.ScrollBox_OutContent:ClearChildren()
    self.chatTextClass = ObjectUtil:LoadClass(self.ChatTextPanelClass)
    if self.chatTextClass then
      for i = 1, 10 do
        local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.chatTextClass)
        if panelIns then
          panelIns.actionOnDeleteMsg:Add(self.DeleteMsg, self)
          self.ScrollBox_OutContent:AddChild(panelIns)
          table.insert(self.msgPanels, panelIns)
        end
      end
    else
      LogDebug("ChatPageMobile", "Chat msg panel class load failed")
    end
  end
  self.tabLists = {}
  if self.TabList then
    local tabArray = self.TabList:GetAllChildren()
    for index = 1, tabArray:Length() do
      table.insert(self.tabLists, tabArray:Get(index))
    end
  end
  self.activeTabName = ChatEnum.ChannelName.world
  if self.SendContent then
    self.SendContent:SetText("")
  end
  GameFacade:SendNotification(NotificationDefines.Chat.GetGroupChatListCmd)
  self:SetChatState(ChatEnum.EChatState.deactive)
end
function ChatPageMobile:AddChat(channelType, tabName, chatId, groupMembers, playerId)
  LogDebug("ChatPageMobile", "Add chat: " .. tabName)
  self.chatId = chatId
  local tabIndexToShow = self:GetChatTypeLoc(channelType)
  self.tabLists[tabIndexToShow]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.panelMap[tabName] then
    self.panelMap[tabName].chatId = chatId
    self.panelMap[tabName].msgPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.msgPanelClass and self.WidgetSwitcher_TabContents then
    local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.msgPanelClass)
    if panelIns then
      self.WidgetSwitcher_TabContents:AddChild(panelIns)
      local chatSettings = {
        timeInterval = self.TimeInterval,
        msgReserved = self.MaxMsgReserved:Find(channelType)
      }
      panelIns:InitView(chatSettings, groupMembers, playerId)
      self:UpdatePanelMap(tabName, channelType, chatId, panelIns)
    else
      LogDebug("ChatPageMobile", "Msg panel create failed")
    end
  end
  self:SetActiveChannel(tabName, self.chatId)
end
function ChatPageMobile:DeleteChat(tabNameDelete)
  if self.panelMap[tabNameDelete] == nil then
    return
  end
  self.panelMap[tabNameDelete].msgPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local isPrivateChat = self.panelMap[tabNameDelete].chatType == ChatEnum.EChatChannel.private
  local deleteIndex = self:GetChatTypeLoc(self.panelMap[tabNameDelete].chatType)
  if false == isPrivateChat then
    self.tabLists[deleteIndex]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.panelMap[tabNameDelete].msgPanel:ClearContent()
    self:SetActiveChannel(ChatEnum.ChannelName.world)
  elseif self.activeTabName == tabNameDelete then
    self:SetActiveChannel(ChatEnum.ChannelName.private)
  end
  self.actionOnDeleteChat(tabNameDelete)
end
function ChatPageMobile:SetActiveChannel(tabName, chatId)
  if nil == tabName then
    return
  end
  LogDebug("ChatPageMobile", "Active channel: " .. tabName)
  self.activeTabName = tabName
  if tabName == ChatEnum.ChannelName.world or tabName == ChatEnum.ChannelName.team or tabName == ChatEnum.ChannelName.room then
    self.Overlay_PlayerList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetActiveTab(tabName)
  elseif tabName == ChatEnum.ChannelName.private then
    self.Overlay_PlayerList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetActiveTab(tabName)
    if self.WidgetSwitcher_TabContents then
      self.WidgetSwitcher_TabContents:SetActiveWidgetIndex(0)
    end
    if self.FriendPanel and self.FriendPanel.hasActivePlayer then
      local activePlayer = self.FriendPanel.activeItem.data
      self:SetActiveChannel(activePlayer.nick, activePlayer.playerId)
    end
    return
  else
    self.Overlay_PlayerList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetActiveTab(ChatEnum.ChannelName.private)
    if self.FriendPanel then
      self.FriendPanel:CheckChosen(chatId)
    end
    if nil == self.panelMap[tabName] then
      local playerInfo = {playerId = chatId, playerName = tabName}
      GameFacade:SendNotification(NotificationDefines.Chat.CreatePrivateChat, playerInfo)
    end
  end
  if self.WidgetSwitcher_TabContents then
    if nil == self.panelMap[tabName] then
      return
    end
    local activeMsgPanel = self.panelMap[tabName].msgPanel
    activeMsgPanel:ScrollToBottom()
    self.WidgetSwitcher_TabContents:SetActiveWidget(activeMsgPanel)
  end
end
function ChatPageMobile:SetActiveTab(activeTabName)
  if self.Check_World then
    self.Check_World:SetIsChecked(false)
  end
  if self.Check_Team then
    self.Check_Team:SetIsChecked(false)
  end
  if self.Check_Room then
    self.Check_Room:SetIsChecked(false)
  end
  if self.Check_Friend then
    self.Check_Friend:SetIsChecked(false)
  end
  if activeTabName == ChatEnum.ChannelName.world then
    self.Check_World:SetIsChecked(true)
  elseif activeTabName == ChatEnum.ChannelName.team then
    self.Check_Team:SetIsChecked(true)
  elseif activeTabName == ChatEnum.ChannelName.room then
    self.Check_Room:SetIsChecked(true)
  else
    self.Check_Friend:SetIsChecked(true)
  end
end
function ChatPageMobile:UpdatePanelMap(inTabName, inChatType, inChatId, inMsgPanel)
  if self.panelMap[inTabName] == nil then
    self.panelMap[inTabName] = {}
  end
  self.panelMap[inTabName].chatType = inChatType
  if inChatId then
    self.panelMap[inTabName].chatId = inChatId
  end
  if inMsgPanel then
    self.panelMap[inTabName].msgPanel = inMsgPanel
  end
end
function ChatPageMobile:OnClickEnter()
  if self.chatState == ChatEnum.EChatState.deactive then
    self:SetChatState(ChatEnum.EChatState.active)
  end
end
function ChatPageMobile:SendChatMsg()
  if self.activeTabName == ChatEnum.ChannelName.private then
    return
  end
  if self.SendContent then
    local text = self.SendContent:GetText()
    if UE4.UKismetTextLibrary.TextIsEmpty(text) == false and not self.isSendingMsg then
      local textString = UE4.UKismetTextLibrary.Conv_TextToString(text)
      if self:CheckCanSendContent(textString) then
        textString = UE4.UKismetStringLibrary.Left(textString, self.MaxMsgCharacters)
        local msgInfo = {}
        msgInfo.channelType = self.panelMap[self.activeTabName].chatType
        msgInfo.chatId = self.panelMap[self.activeTabName].chatId
        msgInfo.msgSend = textString
        msgInfo.chatName = self.activeTabName
        self:SendMsg(true)
        self.actionOnSendMsg(msgInfo)
      end
    end
  end
end
function ChatPageMobile:CheckCanSendContent(contentText)
  if self.MaxMsgCharacters and UE4.UKismetStringLibrary.Len(contentText) > self.MaxMsgCharacters then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20305)
    return false
  end
  if self.WorldChatLevelLimit and self.activeTabName and self.activeTabName == ChatEnum.ChannelName.world then
    local playerLevel = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
    if playerLevel < self.WorldChatLevelLimit then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "WorldChatLevelLimit")
      local stringMap = {
        [0] = self.WorldChatLevelLimit
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self:AddSystemMsg(text)
      return false
    end
    if os.time() < self.worldMsgTimeLimit then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20303)
      return false
    end
    if self.worldChatCoolDown > 0 then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20303)
      return false
    end
  end
  return true
end
function ChatPageMobile:SetChatState(newChatState)
  if self.chatState == newChatState then
    return
  end
  if self.WidgetSwitcher_Content then
    self.WidgetSwitcher_Content:SetActiveWidgetIndex(newChatState)
  end
  self.chatState = newChatState
  if self.chatState == ChatEnum.EChatState.active and self.SendContent then
    self.SendContent:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    self:StopMsgDisappear()
  else
    if self.RedDot_Main then
      local msgCnt = RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Chat)
      self.RedDot_Main:SetVisibility(msgCnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    self:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    self:StartMsgDisappear()
  end
end
function ChatPageMobile:SetChatInvalidation(isInvalid)
end
function ChatPageMobile:SendMsgSucceed()
  if self.SendContent then
    self.SendContent:SetText("")
  end
  self:SendMsg(false)
end
function ChatPageMobile:SendMsg(isSending)
  self.isSendingMsg = isSending
  if self.SendContent then
    if isSending then
      self.SendContent:SetIsEnabled(false)
      self:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
      self.sendMsgCancelTask = TimerMgr:AddTimeTask(5, 0, 1, function()
        self:SendMsg(false)
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1)
      end)
    else
      if self.sendMsgCancelTask then
        self.sendMsgCancelTask:EndTask()
        self.sendMsgCancelTask = nil
      end
      self.SendContent:SetIsEnabled(true)
      self.SendContent:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    end
  end
end
function ChatPageMobile:AddSystemMsg(msgContent)
  local msgInfo = {
    chatId = 0,
    chatNick = "",
    chatMsg = msgContent,
    isOwnMsg = true
  }
  self:NotifyRecvMsg(ChatEnum.ChannelName.system, msgInfo)
end
function ChatPageMobile:NotifyRecvMsg(channelName, msgInfo)
  if self.chatState == ChatEnum.EChatState.deactive and not msgInfo.msgTime and channelName ~= ChatEnum.ChannelName.world and channelName ~= ChatEnum.ChannelName.system and self.RedDot_Main then
    self.RedDot_Main:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.ScrollBox_OutContent then
    local showTime = true
    local currentTime = msgInfo.msgTime or os.time()
    if 0 ~= self.lastMsgTime then
      showTime = currentTime - self.lastMsgTime > self.TimeInterval * 60
    end
    self.lastMsgTime = currentTime
    local msgProp = {}
    msgProp.title = channelName
    msgProp.time = currentTime
    msgProp.showTime = false
    local shouldDisapper = true
    if self.chatState == ChatEnum.EChatState.active then
      shouldDisapper = false
    end
    local msg = {
      info = msgInfo,
      prop = msgProp,
      disapper = shouldDisapper
    }
    table.insert(self.msgRecord, msg)
    if #self.msgRecord > #self.msgPanels then
      table.remove(self.msgRecord, 1)
    end
    self:UpdateViewTask()
  end
  if channelName == ChatEnum.ChannelName.system then
    for key, value in pairs(self.panelMap) do
      value.msgPanel:AddMsg(msgInfo, channelName)
    end
    return
  end
  if self.panelMap[channelName] == nil then
    self:AddChat(ChatEnum.EChatChannel.private, channelName, msgInfo.chatId)
  end
  if channelName ~= self.activeTabName then
    self:UpdateRedDotState(self.panelMap[channelName].chatType)
  end
  if self.panelMap[channelName].chatType == ChatEnum.EChatChannel.private then
    local allFriends = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetAllFriends()
    if allFriends[self.panelMap[channelName].chatId] and self.FriendPanel then
      self.FriendPanel:ReceiveNewMsg(self.panelMap[channelName].chatId, msgInfo)
    end
  end
  self.panelMap[channelName].msgPanel:AddMsg(msgInfo)
  if channelName == ChatEnum.ChannelName.world and msgInfo.isOwnMsg then
    if self.WorldMsgTimeInterval then
      self.worldMsgTimeLimit = os.time() + self.WorldMsgTimeInterval
    end
    if self.WorldChatTimeCount and self.WorldChatMsgLimit and self.WorldChatExLimitCoolDown then
      if self.worldMsgQueue[1] then
        if os.time() - self.worldMsgQueue[1] >= self.WorldChatTimeCount then
          self.worldMsgQueue = {}
        elseif self.worldMsgQueue[self.WorldChatMsgLimit - 1] then
          self.worldChatCoolDown = self.WorldChatExLimitCoolDown
          TimerMgr:AddTimeTask(self.WorldChatExLimitCoolDown, 0, 1, function()
            self.worldChatCoolDown = 0
          end)
        end
      end
      table.insert(self.worldMsgQueue, os.time())
    end
  end
end
function ChatPageMobile:UpdateOutMsgShown()
  if self.ScrollBox_OutContent and #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        local msg = self.msgRecord[i]
        self.msgPanels[i]:InitMsg(msg.info, msg.prop, msg.disapper)
        self.msgPanels[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      else
        self.msgPanels[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.ScrollBox_OutContent:SetVisibility(#self.msgRecord <= 0 and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.HitTestInvisible)
    if self.scrollHandle == nil then
      self.scrollHandle = TimerMgr:AddFrameTask(3, 0, 1, function()
        self:ScrollToEnd()
      end)
    end
  end
end
function ChatPageMobile:ScrollToEnd()
  if self.ScrollBox_OutContent then
    self.ScrollBox_OutContent:ScrollToEnd()
    self.scrollHandle = nil
  end
end
function ChatPageMobile:StopMsgDisappear()
  if #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        self.msgPanels[i]:ClearTimer()
      end
    end
  end
end
function ChatPageMobile:StartMsgDisappear()
  if #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        self.msgPanels[i]:StartTimer()
      end
    end
  end
end
function ChatPageMobile:DeleteMsg(msgTimestamp)
  for key, value in pairs(self.msgRecord) do
    if msgTimestamp and value.prop.time == msgTimestamp then
      for i = 1, key do
        table.remove(self.msgRecord, 1)
      end
    end
  end
  self:UpdateViewTask()
end
function ChatPageMobile:UpdateViewTask()
  if self.updateHandle == nil then
    self.updateHandle = TimerMgr:RunNextFrame(function()
      self:UpdateOutMsgShown()
      self.updateHandle = nil
    end)
  end
end
function ChatPageMobile:GetChatTypeLoc(chatType)
  if chatType == ChatEnum.EChatChannel.world then
    return 1
  elseif chatType == ChatEnum.EChatChannel.team then
    return 2
  elseif chatType == ChatEnum.EChatChannel.room then
    return 3
  elseif chatType == ChatEnum.EChatChannel.private then
    return 4
  end
end
function ChatPageMobile:SelectWorldTab(isChecked)
  if isChecked then
    self:SetActiveChannel(ChatEnum.ChannelName.world)
  else
    self.Check_World:SetIsChecked(true)
  end
end
function ChatPageMobile:SelectTeamTab(isChecked)
  if isChecked then
    self:SetActiveChannel(ChatEnum.ChannelName.team)
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.ChatTeam, 0)
  else
    self.Check_Team:SetIsChecked(true)
  end
end
function ChatPageMobile:SelectRoomTab(isChecked)
  if isChecked then
    self:SetActiveChannel(ChatEnum.ChannelName.room)
    RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.ChatRoom, 0)
  else
    self.Check_Room:SetIsChecked(true)
  end
end
function ChatPageMobile:SelectPrivateTab(isChecked)
  if isChecked then
    self:SetActiveChannel(ChatEnum.ChannelName.private)
  else
    self.Check_Private:SetIsChecked(true)
  end
end
function ChatPageMobile:AddMember(tabName, playerIn)
end
function ChatPageMobile:DeleteMember(tabName, playerId)
end
function ChatPageMobile:OnRemovedFromFocusPath(inFocusEvent)
  if self.WidgetSwitcher_Content then
    local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if self.WidgetSwitcher_Content:HasUserFocus(playerController) == false then
      self:SetChatState(ChatEnum.EChatState.deactive)
    end
  end
end
function ChatPageMobile:ClearTeamMsgs()
  if self.panelMap[ChatEnum.ChannelName.team] then
    self.panelMap[ChatEnum.ChannelName.team].msgPanel:ClearContent()
  end
end
function ChatPageMobile:InitFriendList()
  if self.hasInit or self.panelMap == nil then
    return
  end
  if GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):HasInitFriendList() then
    if self.FriendPanel then
      local allFriends = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetAllFriends()
      local friendTitle = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "Friend")
      self.FriendPanel:InitView(friendTitle, allFriends, true)
      self:SetActivePlayerPanel(self.FriendPanel)
    end
    self.hasInit = true
    self.actionOnShowReserveMsg()
  end
end
function ChatPageMobile:SetActivePlayerPanel(activePanel)
  if self.FriendPanel and self.FriendPanel ~= activePanel then
    self.FriendPanel:SetPanelCollapsed(true)
  end
end
function ChatPageMobile:AddFriend(player)
  if self.FriendPanel then
    self.FriendPanel:AddPlayer(player)
  end
end
function ChatPageMobile:AddNearPlayer(player)
end
function ChatPageMobile:DeleteFriend(playerId)
  if self.FriendPanel then
    self.FriendPanel:DeletePlayer(playerId)
  end
end
function ChatPageMobile:UpdateFriendInfo(player)
  if self.FriendPanel then
    self.FriendPanel:UpdatePlayerInfo(player)
  end
end
function ChatPageMobile:SearchFriend()
  if self.PlayerSearch then
    local searchText = self.PlayerSearch:GetText()
    if "" == searchText then
      return
    end
    if self.FriendPanel then
      self.FriendPanel:SearchPlayer(searchText)
    end
  end
end
function ChatPageMobile:SearchContentChange(text)
  if "" == text and self.FriendPanel then
    self.FriendPanel:SearchPlayer()
  end
end
function ChatPageMobile:ShowSharePanel()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Open(true)
  end
end
function ChatPageMobile:OpenSharePanel()
  local sharePanelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_SharePanel.MenuClass)
  if sharePanelIns then
    sharePanelIns.actionOnSharePlayerInfo:Add(self.SharePlayerInfo, self)
    sharePanelIns.actionOnShareTeam:Add(self.ShareTeam, self)
  end
  return sharePanelIns
end
function ChatPageMobile:SharePlayerInfo()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Close()
  end
  if self.activeTabName ~= ChatEnum.ChannelName.world and self.activeTabName ~= ChatEnum.ChannelName.team and self.activeTabName ~= ChatEnum.ChannelName.room then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20312)
    return
  end
  if self:CheckCanSendContent() then
    local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
    if playerProxy:GetPlayerId() > 0 then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatPlayerInfoHyper_MB")
      local stringMap = {
        [0] = playerProxy:GetPlayerId(),
        [1] = playerProxy:GetPlayerNick(),
        [2] = playerProxy:GetPlayerNick()
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      local msgInfo = {}
      msgInfo.channelType = self.panelMap[self.activeTabName].chatType
      msgInfo.chatId = self.panelMap[self.activeTabName].chatId
      msgInfo.msgSend = text
      msgInfo.chatName = self.activeTabName
      self:SendMsg(true)
      self.actionOnSendMsg(msgInfo)
    end
  end
end
function ChatPageMobile:ShareTeam()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Close()
  end
  if self.activeTabName == ChatEnum.ChannelName.team or self.activeTabName == ChatEnum.ChannelName.room then
    self:SetActiveChannel(ChatEnum.ChannelName.world)
  end
  if self:CheckCanSendContent() then
    local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
    if roomProxy:GetTeamInfo() and roomProxy:GetTeamInfo().teamId then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTeamHyper_MB")
      local stringMap = {
        [0] = roomProxy:GetTeamInfo().teamId,
        [1] = roomProxy:GetPlayerID()
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      local msgInfo = {}
      msgInfo.channelType = self.panelMap[self.activeTabName].chatType
      msgInfo.chatId = self.panelMap[self.activeTabName].chatId
      msgInfo.msgSend = text
      msgInfo.chatName = self.activeTabName
      self:SendMsg(true)
      self.actionOnSendMsg(msgInfo)
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20310)
    end
  end
end
function ChatPageMobile:UpdateRedDotTeam(cnt)
  if self.RedDot_Team then
    self.RedDot_Team:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPageMobile:UpdateRedDotRoom(cnt)
  if self.RedDot_Room then
    self.RedDot_Room:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPageMobile:UpdateRedDotPrivate(cnt)
  if self.RedDot_Private then
    self.RedDot_Private:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPageMobile:UpdateRedDotFriend(cnt)
  if self.FriendPanel then
    self.FriendPanel:UpdateRedDotPlayerList(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPageMobile:UpdateRedDotNearest(cnt)
end
function ChatPageMobile:UpdateRedDotState(chatType)
  if chatType == ChatEnum.EChatChannel.team then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.ChatTeam, 1)
  end
  if chatType == ChatEnum.EChatChannel.room then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.ChatRoom, 1)
  end
end
function ChatPageMobile:SetChatInvalidation(isInvalid)
end
return ChatPageMobile
