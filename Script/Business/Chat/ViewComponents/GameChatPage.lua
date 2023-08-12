local GameChatPage = class("GameChatPage", PureMVC.ViewComponentPage)
local GameChatPageMediator = require("Business/Chat/Mediators/GameChatPageMediator")
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function GameChatPage:ListNeededMediators()
  return {GameChatPageMediator}
end
function GameChatPage:InitializeLuaEvent()
  self.actionOnPageInitFinished = LuaEvent.new()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
  self.actionOnDeleteChat = LuaEvent.new(tabName)
end
function GameChatPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("GameChatPage", "Lua implement OnOpen")
  self.chatMap = {}
  self.systemChatCount = 0
  self.privateChatCount = 0
  self.isSendingMsg = false
  self.activeChannelIndex = 0
  self.isInBattle = false
  self.lastMsgTime = 0
  self.teamMsgQueue = {}
  self.roomMsgQueue = {}
  self.teamCoolDown = 0
  self.roomCoolDown = 0
  self.sendMsgCancelTask = nil
  self.updateHandle = nil
  self.scrollHandle = nil
  self.invalidTeamChannelText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "TeamInvalid")
  self.msgRecord = {}
  self.msgPanels_SelectRole = {}
  self.msgPanels_InGame = {}
  if self.ChatTextPanelClass and self.OutContent_InGame and self.OutContent_SelectRole then
    self.OutContent_InGame:ClearChildren()
    self.OutContent_SelectRole:ClearChildren()
    self.chatTextClass = ObjectUtil:LoadClass(self.ChatTextPanelClass)
    if self.chatTextClass then
      for i = 1, 5 do
        local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.chatTextClass)
        if panelIns then
          panelIns.actionOnDeleteMsg:Add(self.DeleteMsg, self)
          self.OutContent_SelectRole:AddChild(panelIns)
          table.insert(self.msgPanels_SelectRole, panelIns)
        end
        local panelIns2 = UE4.UWidgetBlueprintLibrary.Create(self, self.chatTextClass)
        if panelIns2 then
          panelIns2.actionOnDeleteMsg:Add(self.DeleteMsg, self)
          self.OutContent_InGame:AddChild(panelIns2)
          table.insert(self.msgPanels_InGame, panelIns2)
        end
      end
    else
      LogDebug("GameChatPage", "Chat msg panel class load failed")
    end
  end
  if self.PrivateList_InGame then
    self.PrivateList_InGame:ClearChildren()
  end
  if self.PrivateList_SelectRole then
    self.PrivateList_SelectRole:ClearChildren()
  end
  if self.MenuAnchor_SelectRole then
    self.MenuAnchor_SelectRole.OnGetMenuContentEvent:Bind(self, self.OnGetPrivateChatList)
  end
  if self.MenuAnchor_InGame then
    self.MenuAnchor_InGame.OnGetMenuContentEvent:Bind(self, self.OnGetPrivateChatList)
  end
  if self.Button_SelectChat then
    self.Button_SelectChat.OnClicked:Add(self, self.ClickChatName)
  end
  if self.Button_InGame then
    self.Button_InGame.OnClicked:Add(self, self.ClickChatName)
  end
  if self.SendContent_SelectRole then
    self.SendContent_SelectRole.OnTextCommitted:Add(self, self.OnTextCommit)
  end
  if self.SendContent_InGame then
    self.SendContent_InGame.OnTextCommitted:Add(self, self.OnTextCommit)
  end
  self:AddChat(ChatEnum.EChatChannel.team, ChatEnum.ChannelName.team)
  self:InitView()
  self.actionOnPageInitFinished()
end
function GameChatPage:OnClose()
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
  if self.MenuAnchor_SelectRole then
    self.MenuAnchor_SelectRole.OnGetMenuContentEvent:Unbind()
  end
  if self.MenuAnchor_InGame then
    self.MenuAnchor_InGame.OnGetMenuContentEvent:Unbind()
  end
  if self.Button_SelectChat then
    self.Button_SelectChat.OnClicked:Remove(self, self.ClickChatName)
  end
  if self.Button_InGame then
    self.Button_InGame.OnClicked:Remove(self, self.ClickChatName)
  end
  if self.SendContent_SelectRole then
    self.SendContent_SelectRole.OnTextCommitted:Remove(self, self.OnTextCommit)
  end
  if self.SendContent_InGame then
    self.SendContent_InGame.OnTextCommitted:Remove(self, self.OnTextCommit)
  end
end
function GameChatPage:InitView()
  if self.SendContent_InGame then
    self.SendContent_InGame:SetText("")
  end
  if self.SendContent_SelectRole then
    self.SendContent_SelectRole:SetText("")
  end
  if self.WidgetSwitcher_SelectRole then
    self.WidgetSwitcher_SelectRole:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.WidgetSwitcher_InGame then
    self.WidgetSwitcher_InGame:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.GameChatInputPage)
  self:SetChatState(ChatEnum.EChatState.deactive)
end
function GameChatPage:SetInGameState(bInGame)
  LogDebug("GameChatPage", "Set is in game: %s", bInGame)
  if self.isInBattle == bInGame then
    return
  end
  self:SetChatState(ChatEnum.EChatState.deactive)
  self.isInBattle = bInGame
  if self.WidgetSwitcher_SelectRole then
    self.WidgetSwitcher_SelectRole:SetVisibility(self.isInBattle and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.WidgetSwitcher_InGame then
    self.WidgetSwitcher_InGame:SetVisibility(self.isInBattle and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:HidePage(self, UIPageNameDefine.GameChatInputPage)
end
function GameChatPage:AddChat(channelType, tabName, chatId)
  for key, value in pairs(self.chatMap) do
    if value.name == tabName then
      value.chatId = chatId
      return
    end
  end
  if self.privateChatCount >= self.MaxPrivateChatNum then
    table.remove(self.chatMap, self.systemChatCount + 1)
  end
  local chat = {
    name = tabName,
    chatType = ChatEnum.EChatChannel.team,
    chatId = chatId
  }
  if channelType ~= ChatEnum.EChatChannel.private then
    chat.chatType = channelType
    table.insert(self.chatMap, self.systemChatCount + 1, chat)
    self.systemChatCount = self.systemChatCount + 1
    if channelType == ChatEnum.EChatChannel.team then
      self:SetActiveChannel(ChatEnum.ChannelName.team)
    end
  else
    chat.chatType = ChatEnum.EChatChannel.private
    table.insert(self.chatMap, chat)
    self.privateChatCount = self.privateChatCount + 1
  end
end
function GameChatPage:DeleteSystemChat()
  if self.activeChannelIndex <= self.systemChatCount then
    self:SetActiveChannel(ChatEnum.ChannelName.team)
  else
    self.activeChannelIndex = self.activeChannelIndex - self.systemChatCount + 1
  end
  for key, value in pairs(self.chatMap) do
    if value.name ~= ChatEnum.ChannelName.private and value.name ~= ChatEnum.ChannelName.team then
      table.remove(self.chatMap, key)
      self.systemChatCount = self.systemChatCount - 1
    end
    if value.name == ChatEnum.ChannelName.team then
      value.chatId = nil
    end
  end
end
function GameChatPage:ChangeChannel()
  if not (self.systemChatCount + self.privateChatCount > 0) then
    return
  end
  if self.activeChannelIndex < self.systemChatCount then
    self:SetActiveChannel(self.chatMap[self.activeChannelIndex + 1].name)
  elseif self.chatMap[self.activeChannelIndex + 1] then
    self:SetActiveChannel(self.chatMap[self.systemChatCount + self.privateChatCount].name)
  else
    self:SetActiveChannel(self.chatMap[1].name)
  end
end
function GameChatPage:ClickChatName()
  if self.activeChannelIndex > self.systemChatCount then
    self:HandleChatMenu(true)
  end
end
function GameChatPage:OnGetPrivateChatList()
  local nameList = {}
  for key, value in pairs(self.chatMap) do
    if key > self.systemChatCount then
      table.insert(nameList, value.name)
    end
  end
  local itemTip
  if self.isInBattle then
    itemTip = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_InGame.MenuClass)
  else
    itemTip = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_SelectRole.MenuClass)
  end
  if itemTip then
    itemTip:InitChatList(nameList)
    itemTip.actionOnChoose:Add(self.SelectChat, self)
  else
    LogDebug("GameChatPage", "Menu panel create failed")
  end
  return itemTip
end
function GameChatPage:HandleChatMenu(isOpen)
  if self.isInBattle then
    if self.MenuAnchor_InGame then
      if isOpen then
        self.MenuAnchor_InGame:Open(true)
      else
        self.MenuAnchor_InGame:Close()
      end
    end
  elseif self.MenuAnchor_SelectRole then
    if isOpen then
      self.MenuAnchor_SelectRole:Open(true)
    else
      self.MenuAnchor_SelectRole:Close()
    end
  end
end
function GameChatPage:SelectChat(name)
  self:SetActiveChannel(name)
end
function GameChatPage:SetActiveChannel(tabName)
  if nil == tabName then
    return
  end
  LogDebug("GameChatPage", "Active channel: " .. tabName)
  for key, value in pairs(self.chatMap) do
    if value.name == tabName then
      self.activeChannelIndex = key
    end
  end
  self:HandleChatMenu(false)
  local nameShow = tabName
  if UE4.UKismetStringLibrary.Len(nameShow) > 2 then
    nameShow = UE4.UKismetStringLibrary.Left(nameShow, 2) .. " ..."
  end
  if tabName == ChatEnum.ChannelName.team or tabName == ChatEnum.ChannelName.room then
    nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, tabName)
  end
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTitle")
  local stringMap = {
    [0] = nameShow
  }
  local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  if self.ChatTitle_InGame then
    self.ChatTitle_InGame:SetText(text)
  end
  if self.ChatTitle_SelectRole then
    self.ChatTitle_SelectRole:SetText(text)
  end
end
function GameChatPage:SwitchChatState()
end
function GameChatPage:OnTextCommit(text, commitMethod)
  if commitMethod == UE4.ETextCommit.OnCleared then
    self:SetChatState(ChatEnum.EChatState.deactive)
  end
end
function GameChatPage:OnClickEnter()
  if self:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    return
  end
  if self.chatState == ChatEnum.EChatState.deactive then
    self:SetChatState(ChatEnum.EChatState.active)
  else
    if self.isSendingMsg then
      return
    end
    local text = ""
    if self.isInBattle then
      text = self.SendContent_InGame:GetText()
    else
      text = self.SendContent_SelectRole:GetText()
    end
    if not UE4.UKismetTextLibrary.TextIsEmpty(text) then
      local chat = self.chatMap[self.activeChannelIndex]
      if chat.chatId == nil then
        self:AddSystemMsg(self.invalidTeamChannelText)
        return
      end
      if not self:CheckCanChat() then
        return
      end
      local textString = UE4.UKismetTextLibrary.Conv_TextToString(text)
      if self.MaxMsgCharacters and UE4.UKismetStringLibrary.Len(textString) > self.MaxMsgCharacters then
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20305)
        return
      end
      local msgInfo = {}
      msgInfo.channelType = chat.chatType
      msgInfo.chatId = chat.chatId
      msgInfo.msgSend = textString
      msgInfo.chatName = chat.name
      self:SetIsSendMsg(true)
      self.actionOnSendMsg(msgInfo)
    end
    self:SetChatState(ChatEnum.EChatState.deactive)
  end
end
function GameChatPage:CheckCanChat()
  if 1 == self.activeChannelIndex then
    if self.teamCoolDown > 0 then
      self:AddSystemMsg(ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatCoolDownTip"))
      return false
    end
  elseif 2 == self.activeChannelIndex and self.roomCoolDown > 0 then
    self:AddSystemMsg(ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatCoolDownTip"))
    return false
  end
  return true
end
function GameChatPage:SetChatState(newChatState)
  if self.chatState == newChatState then
    return
  end
  if self.isInBattle then
    if self.WidgetSwitcher_InGame then
      self.WidgetSwitcher_InGame:SetActiveWidgetIndex(newChatState)
    end
  elseif self.WidgetSwitcher_SelectRole then
    self.WidgetSwitcher_SelectRole:SetActiveWidgetIndex(newChatState)
  end
  self.chatState = newChatState
  if self.chatState == ChatEnum.EChatState.active then
    if self.isInBattle then
      ViewMgr:OpenPage(self, UIPageNameDefine.GameChatInputPage)
      self.SendContent_InGame:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
    else
      self.SendContent_SelectRole:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
    end
    self:StopMsgDisappear()
  else
    if self.isInBattle then
      ViewMgr:HidePage(self, UIPageNameDefine.GameChatInputPage)
    end
    self:StartMsgDisappear()
  end
end
function GameChatPage:SendMsgSucceed()
  if self.SendContent_InGame then
    self.SendContent_InGame:SetText("")
  end
  if self.SendContent_SelectRole then
    self.SendContent_SelectRole:SetText("")
  end
  self:SetIsSendMsg(false)
end
function GameChatPage:SetIsSendMsg(isSending)
  self.isSendingMsg = isSending
  if self.isInBattle then
    if self.SendContent_InGame then
      if isSending then
        self.SendContent_InGame:SetIsEnabled(false)
        self:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
      else
        self.SendContent_InGame:SetIsEnabled(true)
        self.SendContent_InGame:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
      end
    end
  elseif self.SendContent_SelectRole then
    if isSending then
      self.SendContent_SelectRole:SetIsEnabled(false)
      self:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
    else
      self.SendContent_SelectRole:SetIsEnabled(true)
      self.SendContent_SelectRole:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
    end
  end
  if isSending then
    self.sendMsgCancelTask = TimerMgr:AddTimeTask(5, 0, 1, function()
      self:SetIsSendMsg(false)
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1)
    end)
  elseif self.sendMsgCancelTask then
    self.sendMsgCancelTask:EndTask()
    self.sendMsgCancelTask = nil
  end
end
function GameChatPage:AddSystemMsg(msgContent)
  local msgInfo = {
    chatId = 0,
    chatNick = "",
    chatMsg = msgContent,
    isOwnMsg = true
  }
  self:NotifyRecvMsg(ChatEnum.ChannelName.system, msgInfo)
end
function GameChatPage:NotifyRecvMsg(channelName, msgInfo)
  local showTime = true
  local curTime = msgInfo.time or os.time()
  if 0 ~= self.lastMsgTime and self.TimeInterval then
    showTime = curTime - self.lastMsgTime > self.TimeInterval * 60
  end
  self.lastMsgTime = curTime
  if msgInfo.isOwnMsg and self.TimeCount and self.TimeCoolDown and self.MsgLimit then
    if channelName == ChatEnum.ChannelName.team then
      if self.teamMsgQueue[1] then
        if curTime - self.teamMsgQueue[1] >= self.TimeCount then
          self.teamMsgQueue = {}
        elseif self.teamMsgQueue[self.MsgLimit - 1] then
          self.teamCoolDown = self.TimeCoolDown
          TimerMgr:AddTimeTask(self.TimeCoolDown, 0, 1, function()
            self.teamCoolDown = 0
          end)
        end
      end
      table.insert(self.teamMsgQueue, curTime)
    else
      if channelName == ChatEnum.ChannelName.room then
        if self.roomMsgQueue[1] then
          if curTime - self.roomMsgQueue[1] >= self.TimeCount then
            self.roomMsgQueue = {}
          elseif self.roomMsgQueue[self.MsgLimit - 1] then
            self.roomCoolDown = self.TimeCoolDown
            TimerMgr:AddTimeTask(self.TimeCoolDown, 0, 1, function()
              self.roomCoolDown = 0
            end)
          end
        end
        table.insert(self.roomMsgQueue, curTime)
      else
      end
    end
  end
  if self.OutContent_SelectRole and self.OutContent_InGame then
    local msgProp = {}
    msgProp.title = channelName
    msgProp.time = curTime
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
    if #self.msgRecord > #self.msgPanels_InGame then
      table.remove(self.msgRecord, 1)
    end
    self:UpdateViewTask()
  end
  if msgInfo.isPrivateChat then
    for key, value in pairs(self.chatMap) do
      if value.name == channelName then
        local chat = value
        table.remove(self.chatMap, key)
        table.insert(self.chatMap, chat)
        break
      end
    end
  end
  local channelExist = false
  for key, value in pairs(self.chatMap) do
    if value.name == channelName then
      channelExist = true
      break
    end
  end
  if not channelExist and channelName ~= ChatEnum.ChannelName.system then
    self:AddChat(ChatEnum.EChatChannel.private, channelName, msgInfo.chatId)
  end
  local itemObj = ObjectUtil:CreateLuaUObject(self)
  itemObj.data = msgInfo
  itemObj.title = channelName
  itemObj.time = curTime
  itemObj.showTime = showTime
  if self.ChatContent_InGame then
    local isAtBottom = self:CheckIsAtBottom(self.ChatContent_InGame)
    self.ChatContent_InGame:AddItem(itemObj)
    if not (not isAtBottom and not msgInfo.isOwnMsg and self.isInBattle) or msgInfo.time and msgInfo.time < os.time() - 1 then
      self.ChatContent_InGame:ScrollToBottom()
    end
  end
  if self.ChatContent_SelectRole then
    local isAtBottom = self:CheckIsAtBottom(self.ChatContent_SelectRole)
    self.ChatContent_SelectRole:AddItem(itemObj)
    if isAtBottom or msgInfo.isOwnMsg or self.isInBattle or msgInfo.time and msgInfo.time < os.time() - 1 then
      self.ChatContent_SelectRole:ScrollToBottom()
    end
  end
end
function GameChatPage:UpdateOutMsgShown()
  if self.isInBattle then
    if self.OutContent_InGame and #self.msgPanels_InGame > 0 then
      for i = 1, #self.msgPanels_InGame do
        if self.msgRecord[i] then
          local msg = self.msgRecord[i]
          if msg.info.chatMsg then
            self.msgPanels_InGame[i]:InitMsg(msg.info, msg.prop, msg.disapper)
            self.msgPanels_InGame[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
          else
            self.msgPanels_InGame[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        else
          self.msgPanels_InGame[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      self.OutContent_InGame:SetVisibility(#self.msgRecord <= 0 and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.HitTestInvisible)
      self.scrollHandle = TimerMgr:RunNextFrame(function()
        self.OutContent_InGame:ScrollToEnd()
        self.scrollHandle = nil
      end)
    end
  elseif self.OutContent_SelectRole and #self.msgPanels_SelectRole > 0 then
    for i = 1, #self.msgPanels_SelectRole do
      if self.msgRecord[i] then
        local msg = self.msgRecord[i]
        self.msgPanels_SelectRole[i]:InitMsg(msg.info, msg.prop, msg.disapper)
        self.msgPanels_SelectRole[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      else
        self.msgPanels_SelectRole[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.OutContent_SelectRole:SetVisibility(#self.msgRecord <= 0 and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.HitTestInvisible)
    self.scrollHandle = TimerMgr:RunNextFrame(function()
      self.OutContent_SelectRole:ScrollToEnd()
      self.scrollHandle = nil
    end)
  end
end
function GameChatPage:UpdateViewTask()
  if self.updateHandle == nil then
    self.updateHandle = TimerMgr:RunNextFrame(function()
      self:UpdateOutMsgShown()
      self.updateHandle = nil
    end)
  end
end
function GameChatPage:CheckIsAtBottom(listView)
  if listView then
    local number = listView:GetNumItems()
    return listView:BP_IsItemVisible(listView:GetItemAt(number - 1))
  end
  return false
end
function GameChatPage:StopMsgDisappear()
  if self.isInBattle then
    if #self.msgPanels_InGame > 0 then
      for i = 1, #self.msgPanels_InGame do
        if self.msgRecord[i] then
          self.msgPanels_InGame[i]:ClearTimer()
        end
      end
    end
  elseif #self.msgPanels_SelectRole > 0 then
    for i = 1, #self.msgPanels_SelectRole do
      if self.msgRecord[i] then
        self.msgPanels_SelectRole[i]:ClearTimer()
      end
    end
  end
end
function GameChatPage:StartMsgDisappear()
  if self.isInBattle then
    if #self.msgPanels_InGame > 0 then
      for i = 1, #self.msgPanels_InGame do
        if self.msgRecord[i] then
          self.msgPanels_InGame[i]:StartTimer()
        end
      end
    end
  elseif #self.msgPanels_SelectRole > 0 then
    for i = 1, #self.msgPanels_SelectRole do
      if self.msgRecord[i] then
        self.msgPanels_SelectRole[i]:StartTimer()
      end
    end
  end
end
function GameChatPage:DeleteMsg(msgTimestamp)
  for key, value in pairs(self.msgRecord) do
    if msgTimestamp and value.prop.time == msgTimestamp then
      for i = 1, key do
        table.remove(self.msgRecord, 1)
      end
    end
  end
  self:UpdateViewTask()
end
function GameChatPage:LuaHandleKeyEvent(key, inputEvent)
  if UE4.UPMLuaBridgeBlueprintLibrary.IsOpenPageBlocked(self, UIPageNameDefine.ChatPage) then
    return false
  end
  if key.KeyName == "Enter" and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickEnter()
    return false
  end
  if key.KeyName == "Tab" and inputEvent == UE4.EInputEvent.IE_Pressed and self.chatState == ChatEnum.EChatState.active then
    self:ChangeChannel()
    return true
  end
  return false
end
function GameChatPage:OnRemovedFromFocusPath(inFocusEvent)
  if self.isInBattle then
    if self.WidgetSwitcher_InGame then
      local playerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
      if self.WidgetSwitcher_InGame:HasUserFocus(playerController) == false then
        self:SetChatState(ChatEnum.EChatState.deactive)
      end
    end
  elseif self.WidgetSwitcher_SelectRole then
    local playerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
    if false == self.WidgetSwitcher_SelectRole:HasUserFocus(playerController) then
      self:SetChatState(ChatEnum.EChatState.deactive)
    end
  end
end
return GameChatPage
