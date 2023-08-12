local ChatPage = class("ChatPage", PureMVC.ViewComponentPage)
local ChatPageMediator = require("Business/Chat/Mediators/ChatPageMediator")
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local ChatEmotionFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatEmotionFormat")
function ChatPage:ListNeededMediators()
  return {ChatPageMediator}
end
function ChatPage:InitializeLuaEvent()
  self.actionOnShowReserveMsg = LuaEvent.new()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
  self.actionOnDeleteChat = LuaEvent.new(tabName)
end
function ChatPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("ChatPage", "Lua implement OnOpen")
  self:InitView()
  if self.Button_Collapse then
    self.bIsCollapse = true
    self.Button_Collapse.OnClicked:Add(self, self.OnClickCollapse)
  end
  if self.Button_EnterChat then
    self.Button_EnterChat.OnClickEvent:Add(self, self.OnClickEnter)
  end
  if self.Button_CollapseMsg then
    self.Button_CollapseMsg.OnClicked:Add(self, self.OnClickCollapseMsg)
  end
  if self.Button_EllapseMsg then
    self.Button_EllapseMsg.OnClicked:Add(self, self.OnClickEllapseMsg)
  end
  if self.EmojiBtn then
    self.EmojiBtn.OnClicked:Add(self, self.ShowEmotionPanel)
  end
  if self.ShareBtn then
    self.ShareBtn.OnClicked:Add(self, self.ShowSharePanel)
  end
  if self.MenuAnchor_EmotionPanel then
    self.MenuAnchor_EmotionPanel.OnGetMenuContentEvent:Bind(self, self.OpenEmotionPanel)
  end
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel.OnGetMenuContentEvent:Bind(self, self.OpenSharePanel)
  end
end
function ChatPage:InitView()
  self.panelMap = {}
  self.chatCount = 0
  self.privateChatCount = 0
  self.lastMsgTime = 0
  self.isSendingMsg = false
  self.worldMsgUpdateInterval = 0
  self.isActive = true
  self.shieldHotKey = false
  if GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetShowChatMsg() then
    self:OnClickEllapseMsg()
  else
    self:OnClickCollapseMsg()
  end
  self.sendMsgCancelTask = nil
  self.updateHandle = nil
  self.scrollHandle = nil
  self.worldMsgTimeLimit = 0
  self.worldMsgQueue = {}
  self.worldChatCoolDown = 0
  if self.ChannelMsgPanelClass then
    self.msgPanelClass = ObjectUtil:LoadClass(self.ChannelMsgPanelClass)
    if nil == self.msgPanelClass then
      LogDebug("ChatPage", "Chat msg panel class load failed")
    end
  end
  self.msgRecord = {}
  self.msgPanels = {}
  if self.ChatTextPanelClass and self.ScrollBox_OutContent then
    self.ScrollBox_OutContent:ClearChildren()
    self.chatTextClass = ObjectUtil:LoadClass(self.ChatTextPanelClass)
    if self.chatTextClass then
      for i = 1, 15 do
        local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.chatTextClass)
        if panelIns then
          panelIns.actionOnDeleteMsg:Add(self.DeleteMsg, self)
          self.ScrollBox_OutContent:AddChild(panelIns)
          table.insert(self.msgPanels, panelIns)
        end
      end
    else
      LogDebug("ChatPage", "Chat msg panel class load failed")
    end
  end
  self.tabLists = {}
  if self.TabList and self.TabPanelClass then
    local tabArray = self.TabList:GetAllChildren()
    self.maxChatNum = tabArray:Length() - 2
    if tabArray:Length() >= 1 then
      for i = 1, tabArray:Length() do
        local panelIns = tabArray:Get(i)
        panelIns.actionOnSelectChannel:Add(self.SetActiveChannel, self)
        panelIns.actionOnCloseChannel:Add(self.DeleteChat, self)
        panelIns:SetVisibility(UE4.ESlateVisibility.Collapsed)
        table.insert(self.tabLists, panelIns)
      end
    end
  end
  self.activeTabPanel = self.tabLists[1]
  if self.WidgetSwitcher_TabContents then
    self.WidgetSwitcher_TabContents:ClearChildren()
  end
  if self.SendContent then
    self.SendContent:SetText("")
    self.SendContent.OnTextCommitted:Add(self, self.CommitSendContent)
  end
  self:SetChatState(ChatEnum.EChatState.deactive)
  GameFacade:SendNotification(NotificationDefines.Chat.GetGroupChatListCmd)
  if nil == self.worldMsgUpdateTask and self.worldMsgUpdateInterval > 0 then
    self.worldMsgUpdateTask = TimerMgr:AddTimeTask(self.worldMsgUpdateInterval, 0, 1, function()
      self:UpdateWorldMsg()
    end)
  end
end
function ChatPage:OnClose()
  LogDebug("ChatPage", "Page closed")
  self.shieldHotKey = false
  UE4.UPMLuaBridgeBlueprintLibrary.SetAllowTooltips(self, false)
  GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):ClearReservedMsg()
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
  if self.worldMsgUpdateTask then
    self.worldMsgUpdateTask:EndTask()
    self.worldMsgUpdateTask = nil
  end
  if self.Button_Collapse then
    self.Button_Collapse.OnClicked:Remove(self, self.OnClickCollapse)
  end
  if self.Button_EnterChat then
    self.Button_EnterChat.OnClickEvent:Remove(self, self.OnClickEnter)
  end
  if self.Button_CollapseMsg then
    self.Button_CollapseMsg.OnClicked:Remove(self, self.OnClickCollapseMsg)
  end
  if self.Button_EllapseMsg then
    self.Button_EllapseMsg.OnClicked:Remove(self, self.OnClickEllapseMsg)
  end
  if self.EmojiBtn then
    self.EmojiBtn.OnClicked:Remove(self, self.ShowEmotionPanel)
  end
  if self.ShareBtn then
    self.ShareBtn.OnClicked:Remove(self, self.ShowSharePanel)
  end
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel.OnGetMenuContentEvent:Unbind()
  end
end
function ChatPage:AddChat(channelType, tabName, chatId, groupMembers, playerId)
  LogDebug("ChatPage", "Add chat: " .. tabName)
  if self.panelMap[tabName] and self.panelMap[tabName].tabIndex > 0 then
    local tabIndex = self.panelMap[tabName].tabIndex
    self.tabLists[tabIndex]:InitProps(tabName, channelType, chatId)
    self:SetActiveChannel(tabName)
    return
  end
  if self.chatCount >= self.maxChatNum then
    local deleteIndex = self.maxChatNum + 2
    if self.activeTabPanel == self.tabLists[deleteIndex] then
      deleteIndex = deleteIndex - 1
    end
    local tabNameDelete = self.tabLists[deleteIndex].channelTabName
    self:DeleteChat(tabNameDelete)
  end
  local tabIndexToShow = 1
  if channelType == ChatEnum.EChatChannel.team then
    tabIndexToShow = 2
  elseif channelType == ChatEnum.EChatChannel.room then
    tabIndexToShow = 3
  elseif channelType ~= ChatEnum.EChatChannel.world then
    tabIndexToShow = self.maxChatNum + 2 - self.privateChatCount
    self.privateChatCount = self.privateChatCount + 1
  end
  self.tabLists[tabIndexToShow]:InitProps(tabName, channelType, chatId)
  self.tabLists[tabIndexToShow]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.panelMap[tabName] then
    self.panelMap[tabName].tabIndex = tabIndexToShow
    self.panelMap[tabName].msgPanel:ClearContent()
  else
    if self.msgPanelClass and self.WidgetSwitcher_TabContents then
      local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.msgPanelClass)
      if panelIns then
        self.WidgetSwitcher_TabContents:AddChild(panelIns)
        local chatSettings = {
          timeInterval = self.TimeInterval,
          msgReserved = self.MaxMsgReserved:Find(channelType)
        }
        panelIns:InitView(chatSettings, groupMembers, playerId)
        self:UpdatePanelMap(tabName, tabIndexToShow, panelIns)
      else
        LogDebug("ChatPage", "Msg panel create failed")
      end
    end
    if channelType == ChatEnum.EChatChannel.world then
      self.actionOnShowReserveMsg()
    end
  end
  self.chatCount = self.chatCount + 1
  self:SetActiveChannel(tabName)
end
function ChatPage:DeleteChat(tabNameDelete)
  if self.panelMap[tabNameDelete] == nil then
    return
  end
  LogWarn("ChatPage", "Delete chat name: " .. tabNameDelete)
  local isDeleteActive = false
  local deleteIndex = self.panelMap[tabNameDelete].tabIndex
  if self.tabLists[deleteIndex] == self.activeTabPanel then
    isDeleteActive = true
  end
  self.panelMap[tabNameDelete].tabIndex = 0
  if deleteIndex <= 3 then
    self.tabLists[deleteIndex]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.privateChatCount = self.privateChatCount - 1
    self.tabLists[self.maxChatNum + 2 - self.privateChatCount]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    for key, value in pairs(self.panelMap) do
      if value.tabIndex > 3 and deleteIndex > value.tabIndex then
        self:UpdatePanelMap(key, value.tabIndex + 1)
      end
    end
    for index = deleteIndex, self.maxChatNum + 2 - self.privateChatCount + 1, -1 do
      self.tabLists[index]:CopyTabProps(self.tabLists[index - 1])
    end
  end
  if isDeleteActive then
    if deleteIndex <= 3 then
      self:SetActiveChannel(ChatEnum.ChannelName.world)
    else
      for index = deleteIndex, 1, -1 do
        if self.tabLists[index]:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
          self:SetActiveChannel(self.tabLists[index].channelTabName)
          break
        end
      end
    end
  end
  self.chatCount = self.chatCount - 1
  self.actionOnDeleteChat(tabNameDelete)
end
function ChatPage:SetActiveChannel(tabName)
  if nil == tabName then
    return
  end
  LogDebug("ChatPage", "Active channel: " .. tabName)
  local activeIndex = self.panelMap[tabName].tabIndex
  self.activeTabPanel:SetTabState(ChatEnum.EChatState.deactive)
  self.activeTabPanel = self.tabLists[activeIndex]
  if nil == self.activeTabPanel then
    return
  end
  self.activeTabPanel:SetTabState(ChatEnum.EChatState.active)
  if self.WidgetSwitcher_TabContents then
    local activeMsgPanel = self.panelMap[tabName].msgPanel
    activeMsgPanel:ScrollToBottom()
    self.WidgetSwitcher_TabContents:SetActiveWidget(activeMsgPanel)
  end
  if self.TextBlock_Channel then
    local nameShow = ""
    if self.activeTabPanel.channelType == ChatEnum.EChatChannel.world then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "WorldChatChannel")
      local stringMap = {
        [0] = self.activeTabPanel.chatId
      }
      nameShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    elseif self.activeTabPanel.channelType ~= ChatEnum.EChatChannel.private then
      nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, tabName)
    else
      nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.private)
    end
    self.TextBlock_Channel:SetText(nameShow)
  end
  if self.SendContent and self.chatState == ChatEnum.EChatState.active then
    self.SendContent:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
  end
end
function ChatPage:UpdatePanelMap(inTabName, inTabIndex, inMsgPanel)
  if self.panelMap[inTabName] == nil then
    self.panelMap[inTabName] = {}
  end
  self.panelMap[inTabName].tabIndex = inTabIndex
  if inMsgPanel then
    self.panelMap[inTabName].msgPanel = inMsgPanel
  end
end
function ChatPage:SetTabSlotType()
  for key, value in pairs(self.tabLists) do
    local tabSlot = UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(value)
    local sizeRule = UE4.FSlateChildSize()
    if self.chatCount <= 5 then
      sizeRule.SizeRule = UE4.ESlateSizeRule.Automatic
    else
      sizeRule.SizeRule = UE4.ESlateSizeRule.Fill
    end
    tabSlot:SetSize(sizeRule)
  end
end
function ChatPage:OnClickCollapse()
  if self.bIsCollapse then
    if self.SizeBox_Content then
      self.SizeBox_Content:SetHeightOverride(300)
    end
    if self.Button_Collapse then
      self.Button_Collapse:SetRenderScale(UE4.FVector2D(1, -1))
    end
  else
    if self.SizeBox_Content then
      self.SizeBox_Content:SetHeightOverride(200)
    end
    if self.Button_Collapse then
      self.Button_Collapse:SetRenderScale(UE4.FVector2D(1, 1))
    end
    if self.WidgetSwitcher_TabContents then
      self.WidgetSwitcher_TabContents:GetActiveWidget():ChangeSize()
    end
  end
  self.bIsCollapse = not self.bIsCollapse
end
function ChatPage:OnClickCollapseMsg()
  self.bShowOutMsg = false
  GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SetShowChatMsg(self.bShowOutMsg)
  if self.ScrollBox_OutContent then
    self.ScrollBox_OutContent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.WidgetSwitcher_CollapseChat then
    self.WidgetSwitcher_CollapseChat:SetActiveWidgetIndex(1)
  end
end
function ChatPage:OnClickEllapseMsg()
  self.bShowOutMsg = true
  GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):SetShowChatMsg(self.bShowOutMsg)
  if self.WidgetSwitcher_CollapseChat then
    self.WidgetSwitcher_CollapseChat:SetActiveWidgetIndex(0)
  end
end
function ChatPage:OnClickEnter()
  if self:GetVisibility() == UE4.ESlateVisibility.Collapsed or not self.isActive then
    return
  end
  if self.chatState == ChatEnum.EChatState.deactive then
    self:SetChatState(ChatEnum.EChatState.active)
  else
    self:SetChatState(ChatEnum.EChatState.deactive)
  end
end
function ChatPage:CommitSendContent(text, commitMethod)
  if commitMethod == UE4.ETextCommit.OnEnter then
    if UE4.UKismetTextLibrary.TextIsEmpty(text) then
      self.shieldHotKey = false
    elseif not self.isSendingMsg then
      local textString = UE4.UKismetTextLibrary.Conv_TextToString(text)
      self:TrySendMsg(textString)
    end
  end
end
function ChatPage:TrySendMsg(msgContent, isSystemMsg)
  if self:CheckCanSendContent(msgContent, isSystemMsg) then
    local content = msgContent
    if not isSystemMsg then
      content = UE4.UKismetStringLibrary.Left(msgContent, self.MaxMsgCharacters)
    end
    local msgInfo = {}
    msgInfo.channelType = self.activeTabPanel.channelType
    msgInfo.chatId = self.activeTabPanel.chatId
    msgInfo.msgSend = content
    msgInfo.chatName = self.activeTabPanel.channelTabName
    self:SendMsg(true)
    self.actionOnSendMsg(msgInfo)
  end
end
function ChatPage:CheckCanSendContent(contentText, isSystemMsg)
  if self.MaxMsgCharacters and UE4.UKismetStringLibrary.Len(contentText) > self.MaxMsgCharacters and not isSystemMsg then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20305)
    return false
  end
  if self.WorldChatLevelLimit and self.activeTabPanel and self.activeTabPanel.channelType == ChatEnum.EChatChannel.world then
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
function ChatPage:SetChatState(newChatState)
  if self.chatState == newChatState or not self.isActive then
    return
  end
  if self.WidgetSwitcher_Content then
    self.WidgetSwitcher_Content:SetActiveWidgetIndex(newChatState)
  end
  self.chatState = newChatState
  if self.chatState == ChatEnum.EChatState.active and self.SendContent then
    self.bIsCollapse = false
    self:OnClickCollapse()
    self.shieldHotKey = true
    UE4.UPMLuaBridgeBlueprintLibrary.SetAllowTooltips(self, true)
    self.SendContent:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    self:StopMsgDisappear()
    if self.RedDot_NewMsg then
      self.RedDot_NewMsg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.WorldMsgUpdateInterval_Active then
      self.worldMsgUpdateInterval = self.WorldMsgUpdateInterval_Active
    end
  else
    self.shieldHotKey = false
    UE4.UPMLuaBridgeBlueprintLibrary.SetAllowTooltips(self, false)
    self:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    self:StartMsgDisappear()
    if self.WorldMsgUpdateInterval_Deactive then
      self.worldMsgUpdateInterval = self.WorldMsgUpdateInterval_Deactive
    end
  end
end
function ChatPage:SetChatInvalidation(isInvalid)
  self.isActive = not isInvalid
end
function ChatPage:SendMsgSucceed()
  if self.SendContent then
    self.SendContent:SetText("")
  end
  self:SendMsg(false)
end
function ChatPage:SendMsg(isSending)
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
function ChatPage:UpdateWorldMsg()
  GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):ReqUpdateWorldMsg(self.worldMsgUpdateInterval)
  if self.worldMsgUpdateInterval > 0 then
    self.worldMsgUpdateTask = TimerMgr:AddTimeTask(self.worldMsgUpdateInterval, 0, 1, function()
      self:UpdateWorldMsg()
    end)
  end
end
function ChatPage:AddSystemMsg(msgContent)
  local msgInfo = {
    chatId = 0,
    chatNick = "",
    chatMsg = msgContent,
    isOwnMsg = true
  }
  self:NotifyRecvMsg(ChatEnum.ChannelName.system, msgInfo)
end
function ChatPage:NotifyRecvMsg(channelName, msgInfo)
  if nil == channelName then
    return
  end
  if nil == self.activeTabPanel then
    return
  end
  if self.chatState == ChatEnum.EChatState.deactive and not msgInfo.msgTime and channelName ~= ChatEnum.ChannelName.world and channelName ~= ChatEnum.ChannelName.system then
    if self.RedDot_NewMsg then
      self.RedDot_NewMsg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.MsgAlartSound then
      self:PlayFSlateSound(self.MsgAlartSound)
    end
  end
  local bShowOutMsg = self.bShowOutMsg
  if channelName == ChatEnum.ChannelName.world and GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):GetWorldMsgSetting() == ChatEnum.EWorldMsgSetting.receive then
    bShowOutMsg = false
  end
  if self.ScrollBox_OutContent and bShowOutMsg then
    local showTime = true
    local msgTime = msgInfo.msgTime or os.time()
    if 0 ~= self.lastMsgTime then
      showTime = msgTime - self.lastMsgTime > self.TimeInterval * 60
    end
    self.lastMsgTime = msgTime
    local msgProp = {}
    msgProp.title = channelName
    msgProp.time = msgTime
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
  if nil == self.panelMap[channelName] or 0 == self.panelMap[channelName].tabIndex then
    local activeChannelName = self.activeTabPanel.channelTabName
    self:AddChat(ChatEnum.EChatChannel.private, channelName, msgInfo.chatId)
    self:SetActiveChannel(activeChannelName)
  end
  local tabTarget = self.tabLists[self.panelMap[channelName].tabIndex]
  if tabTarget ~= self.activeTabPanel and nil == msgInfo.msgTime then
    tabTarget:AddMsg()
  end
  if tabTarget.alwaysShow then
    for key, value in pairs(self.panelMap) do
      if key ~= channelName then
        value.msgPanel:AddMsg(msgInfo, channelName)
      else
        value.msgPanel:AddMsg(msgInfo)
      end
    end
  else
    self.panelMap[channelName].msgPanel:AddMsg(msgInfo, nil, true)
  end
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
function ChatPage:UpdateOutMsgShown()
  if self.ScrollBox_OutContent and #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        local msg = self.msgRecord[i]
        if msg.info.chatMsg then
          self.msgPanels[i]:InitMsg(msg.info, msg.prop, msg.disapper)
          self.msgPanels[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        else
          self.msgPanels[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
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
function ChatPage:ScrollToEnd()
  if self.ScrollBox_OutContent then
    self.ScrollBox_OutContent:ScrollToEnd()
    self.scrollHandle = nil
  end
end
function ChatPage:StopMsgDisappear()
  if #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        self.msgPanels[i]:ClearTimer()
      end
    end
  end
end
function ChatPage:StartMsgDisappear()
  if #self.msgPanels > 0 then
    for i = 1, #self.msgPanels do
      if self.msgRecord[i] then
        self.msgPanels[i]:StartTimer()
      end
    end
  end
end
function ChatPage:DeleteMsg(msgTimestamp)
  for key, value in pairs(self.msgRecord) do
    if msgTimestamp and value.prop.time == msgTimestamp then
      for i = 1, key do
        table.remove(self.msgRecord, 1)
      end
    end
  end
  self:UpdateViewTask()
end
function ChatPage:UpdateViewTask()
  if self.updateHandle == nil then
    self.updateHandle = TimerMgr:RunNextFrame(function()
      self:UpdateOutMsgShown()
      self.updateHandle = nil
    end)
  end
end
function ChatPage:AddMember(tabName, playerIn)
  self.panelMap[tabName].msgPanel:AddMember(playerIn)
end
function ChatPage:DeleteMember(tabName, playerId)
  if self.panelMap[tabName] == nil then
    return
  end
  self.panelMap[tabName].msgPanel:DeleteMember(playerId)
end
function ChatPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ShieldHotKeys and self.shieldHotKey and self.ShieldHotKeys:Contains(key) and inputEvent == UE4.EInputEvent.IE_Released then
    return true
  end
  if key.KeyName == "Tab" and inputEvent == UE4.EInputEvent.IE_Released and self.chatState == ChatEnum.EChatState.active then
    self:ChangeChannel()
    return true
  end
  if self.Button_EnterChat then
    return self.Button_EnterChat:MonitorKeyDown(key, inputEvent) and false
  end
  return false
end
function ChatPage:ChangeChannel()
  if self.activeTabPanel then
    local activeChannelName = self.activeTabPanel.channelTabName
    if self.panelMap[activeChannelName] then
      local activeTabIndex = self.panelMap[activeChannelName].tabIndex
      if activeTabIndex > 0 then
        local newActiveIndex = activeTabIndex + 1
        for i = activeTabIndex + 1, self.maxChatNum + 3 do
          newActiveIndex = i
          if self.tabLists[i] and self.tabLists[i]:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            break
          end
        end
        if newActiveIndex > self.maxChatNum + 2 then
          newActiveIndex = 1
        end
        self:SetActiveChannel(self.tabLists[newActiveIndex].channelTabName)
      end
    end
  end
end
function ChatPage:OnRemovedFromFocusPath(inFocusEvent)
  if self.WidgetSwitcher_Content then
    local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if self.WidgetSwitcher_Content:HasUserFocus(playerController) == false then
      self:SetChatState(ChatEnum.EChatState.deactive)
    end
  end
end
function ChatPage:ClearTeamMsgs()
  if self.panelMap[ChatEnum.ChannelName.team] then
    self.panelMap[ChatEnum.ChannelName.team].msgPanel:ClearContent()
  end
end
function ChatPage:InitFriendList()
end
function ChatPage:AddFriend(player)
end
function ChatPage:AddNearPlayer(player)
end
function ChatPage:DeleteFriend(player)
end
function ChatPage:UpdateFriendInfo(player)
end
function ChatPage:ShowEmotionPanel()
  if self.MenuAnchor_EmotionPanel then
    self.MenuAnchor_EmotionPanel:Open(true)
  end
end
function ChatPage:OpenEmotionPanel()
  local emotionPanelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_EmotionPanel.MenuClass)
  if emotionPanelIns then
    emotionPanelIns.actionOnSendEmotion:Add(self.SendEmotion, self)
  end
  return emotionPanelIns
end
function ChatPage:SendEmotion(emoteId)
  if self.MenuAnchor_EmotionPanel then
    self.MenuAnchor_EmotionPanel:Close()
  end
  local formatText = ChatEmotionFormatText
  local stringMap = {
    [0] = emoteId
  }
  local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  self:TrySendMsg(text, true)
end
function ChatPage:ShowSharePanel()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Open(true)
  end
end
function ChatPage:OpenSharePanel()
  local sharePanelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_SharePanel.MenuClass)
  if sharePanelIns then
    sharePanelIns.actionOnSharePlayerInfo:Add(self.SharePlayerInfo, self)
    sharePanelIns.actionOnShareTeam:Add(self.ShareTeam, self)
  end
  return sharePanelIns
end
function ChatPage:SharePlayerInfo()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Close()
  end
  if self.activeTabPanel and self.activeTabPanel.channelType == ChatEnum.EChatChannel.private then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20312)
    return
  end
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if playerProxy:GetPlayerId() > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatPlayerInfoHyper")
    local stringMap = {
      [0] = playerProxy:GetPlayerId(),
      [1] = playerProxy:GetPlayerNick(),
      [2] = playerProxy:GetPlayerNick()
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self:TrySendMsg(text, true)
  end
end
function ChatPage:ShareTeam()
  if self.MenuAnchor_SharePanel then
    self.MenuAnchor_SharePanel:Close()
  end
  if self.activeTabPanel and (self.activeTabPanel.channelType == ChatEnum.EChatChannel.team or self.activeTabPanel.channelType == ChatEnum.EChatChannel.room) then
    self:SetActiveChannel(ChatEnum.ChannelName.world)
  end
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomProxy:GetTeamInfo() and roomProxy:GetTeamInfo().teamId then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTeamHyper")
    local stringMap = {
      [0] = roomProxy:GetTeamInfo().teamId,
      [1] = roomProxy:GetPlayerID()
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self:TrySendMsg(text, true)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20310)
  end
end
return ChatPage
